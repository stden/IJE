//
//
//  Copyright (c) 2006
//  Roman Timushev
//
//  Permission to use, copy, modify, distribute and sell this software
//  and its documentation for any purpose is hereby granted without fee,
//  provided that the above copyright notice appear in all copies and
//  that both that copyright notice and this permission notice appear
//  in supporting documentation. Roman Timushev makes no representations
//  about the suitability of this software for any purpose.
//  It is provided "as is" without express or implied warranty.
//
//

#include "StdAfx.h"
#include "Job.h"
#include "WinApiException.h"
#include "JobResult.h"
#include "Messages.h"

const std::_string Job::JOB_OBJECT_NAME = _T("SecureLaunchJob");
const std::_string Job::JOB_OBJECT_NAMESPACE = _T("Global\\");

Job::Job()
{
    millisecondsIdle = 0;
    processesLimit = false;
    timeLimit = 0;
    memoryLimit = 0;
    cpuUsageIdle = 0;
    idlenessLimit = 0;

    std::_stringstream tmp;
    tmp << JOB_OBJECT_NAME;
    tmp << GetTickCount();
    name = tmp.str();
    qualifiedname = JOB_OBJECT_NAMESPACE;
    qualifiedname.append(name);

    hJob = CreateJobObject(NULL,qualifiedname.c_str());
    tryApi(_T("CreateJobObject"), hJob != NULL);
    JOBOBJECT_ASSOCIATE_COMPLETION_PORT portInfo;
    portInfo.CompletionPort = port.handle();
    portInfo.CompletionKey = NULL;
    tryApi(_T("SetInformationJobObject"),
        SetInformationJobObject(hJob,JobObjectAssociateCompletionPortInformation,&portInfo,sizeof portInfo) != 0);

    processTimeCounter = perfQuery.addCounter(
        PerformanceQuery::getPerformanceObjectNameByIndex(PerformanceQuery::INDEX_JOB_OBJECT),
        _T(""),name,
        PerformanceQuery::getPerformanceObjectNameByIndex(PerformanceQuery::INDEX_THIS_PERIOD_MSEC_PROCESSOR)
        );
    elapsedTimeCounter = perfQuery.addCounter(
        PerformanceQuery::getPerformanceObjectNameByIndex(PerformanceQuery::INDEX_SYSTEM),
        _T(""),_T(""),
        PerformanceQuery::getPerformanceObjectNameByIndex(PerformanceQuery::INDEX_SYSTEM_UPTIME)
        );
    elapsedTimeCounter.setFormatFlags(elapsedTimeCounter.getFormatFlags() | PDH_FMT_1000);
    memoryUsageCounter = perfQuery.addCounter(
        PerformanceQuery::getPerformanceObjectNameByIndex(PerformanceQuery::INDEX_JOB_OBJECT_DETAILS),
        name,PerformanceQuery::INSTANCE_TOTAL,
        PerformanceQuery::getPerformanceObjectNameByIndex(PerformanceQuery::INDEX_PAGEFILE_BYTES)
        );
}

void Job::assignMainProcess(const Process &process)
{
    hMainProcess = process.processHandle();
    tryApi(_T("AssignProcessToJobObject"),
        AssignProcessToJobObject(hJob,hMainProcess) != 0);
    gatherInfo();
    initialElapsedTimeCounter = elapsedTimeCounter.getLargeValue();
    millisecondsIdle = 0;
    prevJobTime = -1;
    prevElapsedTime = -1;
    res = JobResult();
    jobactive = true;
}


void Job::gatherInfo()
{
    perfQuery.collectData();
}

Job::~Job()
{
    CloseHandle(hJob);
}

void Job::pocessNbRestriction(bool restrict)
{
    processesLimit = restrict;
}

void Job::timeLimitRestriction(int tl)
{
    timeLimit = tl * 10000ULL;
}

void Job::idlenessLimitRestriction(int ti, double percent)
{
    idlenessLimit = ti * 10000ULL;
    cpuUsageIdle = percent;
}


void Job::memoryLimitRestriction(size_t ml)
{
    memoryLimit = ml;
}


void Job::applyRestrictions()
{
    JOBOBJECT_EXTENDED_LIMIT_INFORMATION limits;
    memset(&limits,0,sizeof limits);
    limits.BasicLimitInformation.LimitFlags =
        JOB_OBJECT_LIMIT_DIE_ON_UNHANDLED_EXCEPTION |
        /*
        Not supported by Windows 2000
        JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE |
        */
        JOB_OBJECT_LIMIT_PRIORITY_CLASS;
    limits.BasicLimitInformation.PriorityClass = BELOW_NORMAL_PRIORITY_CLASS;
    if (processesLimit) {
        limits.BasicLimitInformation.LimitFlags |= JOB_OBJECT_LIMIT_ACTIVE_PROCESS;
        limits.BasicLimitInformation.ActiveProcessLimit = 1;
    }
    if (timeLimit > 0) {
        limits.BasicLimitInformation.LimitFlags |=
            JOB_OBJECT_LIMIT_PROCESS_TIME;
        limits.BasicLimitInformation.PerProcessUserTimeLimit.QuadPart =
            timeLimit;
    }
    if (memoryLimit > 0) {
        limits.BasicLimitInformation.LimitFlags |=
            JOB_OBJECT_LIMIT_PROCESS_MEMORY;
        limits.ProcessMemoryLimit = memoryLimit;
    }
    tryApi(_T("SetInformationJobObject"),
        SetInformationJobObject(hJob,JobObjectExtendedLimitInformation,&limits,sizeof limits) != 0);

    JOBOBJECT_BASIC_UI_RESTRICTIONS ui;
    ui.UIRestrictionsClass = JOB_OBJECT_UILIMIT_DESKTOP |
        JOB_OBJECT_UILIMIT_DISPLAYSETTINGS |
        JOB_OBJECT_UILIMIT_EXITWINDOWS |
        JOB_OBJECT_UILIMIT_GLOBALATOMS |
        JOB_OBJECT_UILIMIT_HANDLES |
        JOB_OBJECT_UILIMIT_READCLIPBOARD |
        JOB_OBJECT_UILIMIT_SYSTEMPARAMETERS |
        JOB_OBJECT_UILIMIT_WRITECLIPBOARD;
    tryApi(_T("SetInformationJobObject"),
        SetInformationJobObject(hJob,JobObjectBasicUIRestrictions,&ui,sizeof ui) != 0);
}

bool Job::active() const
{
    return jobactive;
}

void Job::waitForEvent(DWORD timeout)
{
    gatherInfo();
    testRestrictions();

    DWORD evnt;
    ULONG key;
    LPOVERLAPPED lpOverlapped;
    BOOL reslt = GetQueuedCompletionStatus(port.handle(),&evnt,&key,
        &lpOverlapped,timeout);
    if (reslt == 0) {
        DWORD err = GetLastError();
        tryApi(_T("GetQueuedCompletionStatus"),err == WAIT_TIMEOUT);
    } else {
        if (evnt == JOB_OBJECT_MSG_ACTIVE_PROCESS_ZERO)
            jobactive = false;
        else if (evnt == JOB_OBJECT_MSG_END_OF_JOB_TIME ||
            evnt == JOB_OBJECT_MSG_END_OF_PROCESS_TIME)
            res = JobResult(JobResult::TL,_T(""));
        else if (evnt == JOB_OBJECT_MSG_ACTIVE_PROCESS_LIMIT)
            res = JobResult(JobResult::SV, Messages::RESULT_CHILD_PROCESS);
        else if (evnt == JOB_OBJECT_MSG_PROCESS_MEMORY_LIMIT ||
            evnt == JOB_OBJECT_MSG_JOB_MEMORY_LIMIT)
            res = JobResult(JobResult::ML,_T(""));
    }
    if (res.valid()) {
        tryApi(_T("TerminateJobObject"),
            TerminateJobObject(hJob,0) != 0);
    } else if (!active()) {
        DWORD code;
        tryApi(_T("GetExitCodeProcess"),
            GetExitCodeProcess(hMainProcess,&code) != 0);
        res = JobResult(JobResult::OK, _T(""));
    }
}

void Job::testRestrictions()
{
    LONG jobTime = processTimeCounter.getLongValue();
    LONGLONG elapsedTime = elapsedTimeCounter.getLargeValue();
    if (timeLimit > 0 && jobTime*10000ULL > timeLimit) {
        res = JobResult(JobResult::TL,_T(""));
    }
    if (prevJobTime > 0) {
        LONG usedSinceLast = jobTime - prevJobTime;
        LONGLONG elapsedSinceLast = elapsedTime - prevElapsedTime;
        if (elapsedSinceLast > 0 && static_cast<double>(usedSinceLast)/elapsedSinceLast < cpuUsageIdle) {
            millisecondsIdle += elapsedSinceLast;
        }
    }
    if (idlenessLimit > 0 && millisecondsIdle*10000ULL > idlenessLimit) {
        res = JobResult(JobResult::IS,_T(""));
    }
    prevJobTime = jobTime;
    prevElapsedTime = elapsedTime;
}

void Job::terminate()
{
    res = JobResult(JobResult::ER,Messages::RESULT_TERMINATED);
}
double Job::infoCPUTime()
{
    return processTimeCounter.getLongValue()/1000.f;
}
double Job::infoElapsedTime()
{
    return static_cast<double>(elapsedTimeCounter.getLargeValue() - initialElapsedTimeCounter)/1000.f;
}
LONGLONG Job::infoMemoryUsage()
{
    return memoryUsageCounter.getLargeValue();
}

LONGLONG Job::infoMemoryUsagePeak()
{
    JOBOBJECT_EXTENDED_LIMIT_INFORMATION info;
    tryApi(_T("QueryInformationJobObject"),
        QueryInformationJobObject(hJob,JobObjectExtendedLimitInformation,&info,sizeof info,NULL) != 0);
    return info.PeakJobMemoryUsed;
}
