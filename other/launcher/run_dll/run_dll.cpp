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

#include "stdafx.h"
#include "run_dll.h"
#include "..\launcher_lib\wide_stl.h"
#include "..\launcher_lib\Job.h"
#include "..\launcher_lib\WinApiException.h"
#include "..\launcher_lib\ConsoleWindow.h"
#include "..\launcher_lib\RuntimeErrorMessages.h"

using namespace std;

Job * job = NULL;
Desktop * defaultDesktop;
Desktop * specialDesktop;

RunResult result;
_string resultMessage;

void init()
{
    if (job != NULL)
        delete job;
    job = new Job();
}

void cleanup()
{
    if (job != NULL)
        delete job;
    job = NULL;
    if (defaultDesktop != NULL)
        delete defaultDesktop;
    defaultDesktop = NULL;
    if (specialDesktop != NULL)
        delete specialDesktop;
    specialDesktop = NULL;
}

BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved)
{
    if (ul_reason_for_call == DLL_PROCESS_DETACH) cleanup();
    return TRUE;
}

void setRestrictions(Job * job, const RunOptions * options)
{
    job->pocessNbRestriction(options->forbidChildProcesses != FALSE);
    job->timeLimitRestriction(options->timeLimit);
    if (options->idleCpuUsagePercent == 0)
        job->idlenessLimitRestriction(options->idlenessTimeLimit);
    else
        job->idlenessLimitRestriction(options->idlenessTimeLimit,static_cast<double>(options->idleCpuUsagePercent)/100);
    job->memoryLimitRestriction(options->memoryLimit);
    job->applyRestrictions();
}

Desktop * getDesktop(bool useDefault)
{
    if (useDefault) {
        if (defaultDesktop == NULL)
            defaultDesktop = new Desktop(true);
        return defaultDesktop;
    } else {
        if (specialDesktop == NULL)
            specialDesktop = new Desktop(false);
        return specialDesktop;
    }
}

__declspec(dllexport) BOOL runApplication(LPCTSTR cmdline, const RunOptions * options)
{
    try {
        if (options->size != sizeof(RunOptions) ||
            ((options->user != NULL) ^ (options->password != NULL)) ||
            ((options->stdIn != NULL) ^ (options->stdOut != NULL))) {
                throw WinApiException(_T(""),ERROR_INVALID_PARAMETER);
        }
        init();
        setRestrictions(job,options);
        Process process(cmdline);
        process.setDesktop(getDesktop(options->useDefaultDesktop != FALSE));
        if (options->user != NULL && options->password != NULL)
            process.setCredentials(options->user,options->password);
        if (options->stdIn != NULL && options->stdOut != NULL)
            process.redirect(options->stdIn,options->stdOut);
        process.load();
        job->assignMainProcess(process);
        process.resume();
        CAutoPtr<ConsoleWindow> wnd;
        if (options->showStatusWindow) {
            ConsoleWindow * pWnd = new ConsoleWindow(CRect(-28,0,-1,5));
            wnd.Attach(pWnd);
            wnd->show();
        }
        while (job->active()) {
            job->waitForEvent(30);
            if (options->showStatusWindow) {
                _stringstream msg;
                msg << dec << fixed << showpoint << setprecision(1);
                msg << _T("Time elapsed:  ") << setw(6) << job->infoElapsedTime() << _T("\n");
                msg << _T("Time used:     ") << setw(6) << job->infoCPUTime() << _T("\n");
                msg << _T("Memory used:   ") << setw(6) << job->infoMemoryUsage()/1024 << _T("Kb\n");
                wnd->setMessage(msg.str());
                wnd->redraw();
            }
            if (options->callback != NULL ) {
                RunStatus status;
                status.elapsedTime = job->infoElapsedTime();
                status.cpuTime = job->infoCPUTime();
                status.memoryUsed = job->infoMemoryUsage();
                status.peakMemoryUsed = job->infoMemoryUsagePeak();
                if (!options->callback(&status)) {
                    job->terminate();
                }
            }
        }
        if (options->showStatusWindow)
            wnd->hide();
        JobResult jobresult = job->result();
        if (jobresult.result() == JobResult::OK) {
            DWORD code = process.exitCode();
            if (code != 0) {
                jobresult = JobResult(JobResult::RE, RuntimeErrorMessages::getFullMessage(code));
            }
        }
        job->gatherInfo();
        result.resultcode = jobresult.result();
        result.exitcode = process.exitCode();
        resultMessage = jobresult.info();
        result.message = resultMessage.c_str();
        result.elapsedTime = job->infoElapsedTime();
        result.cpuTime = job->infoCPUTime();
        result.memoryUsed = job->infoMemoryUsagePeak();
        result.exception = false;
    }
    catch (WinApiException e) {
        result.exception = true;
        result.exitcode = e.errorCode();
        resultMessage = e.message();
        result.message = resultMessage.c_str();
    }
    return !result.exception;
}

__declspec(dllexport) RunResult * getResult()
{
    return &result;
}
