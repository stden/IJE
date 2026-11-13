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

#ifndef __JOB_H__
#define __JOB_H__

#include "Process.h"
#include "CompletionPort.h"
#include "JobResult.h"
#include "PerformanceQuery.h"
#include "PerformanceCounter.h"

class Job{
public:
    Job();
    ~Job();

    void assignMainProcess(const Process &process);

    void applyRestrictions();
    void pocessNbRestriction(bool restrict);
    void timeLimitRestriction(int tl); // in milliseconds
    void idlenessLimitRestriction(int ti, double percent = 0.1); // in milliseconds
    void memoryLimitRestriction(size_t ml); // in bytes

    void waitForEvent(DWORD timeout); // timeout in milliseconds
    bool active() const;
    void terminate();

    JobResult result() const { return res; }

    void gatherInfo();
    double infoCPUTime();
    double infoElapsedTime();
    LONGLONG infoMemoryUsage();
    LONGLONG infoMemoryUsagePeak();

private:
    void testRestrictions();

    HANDLE hJob;
    CompletionPort port;
    std::_string name, qualifiedname;

    PerformanceQuery perfQuery;
    PerformanceCounter processTimeCounter;
    PerformanceCounter elapsedTimeCounter;
    PerformanceCounter memoryUsageCounter;

    LONGLONG initialElapsedTimeCounter;
    ULONGLONG millisecondsIdle;
    LONG prevJobTime;
    LONGLONG prevElapsedTime;

    JobResult res;

    bool jobactive;

    HANDLE hMainProcess;

    // Restrictions:
    bool processesLimit;

    ULONGLONG timeLimit; // in 100 nanosec intervals
    size_t memoryLimit; // in bytes

    double cpuUsageIdle;
    ULONGLONG idlenessLimit; // in 100 nanosec intervals

    static const std::_string JOB_OBJECT_NAME;
    static const std::_string JOB_OBJECT_NAMESPACE;
};

#endif // __JOB_H__
