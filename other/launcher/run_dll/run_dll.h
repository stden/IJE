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

#ifndef __RUN_DLL_H__
#define __RUN_DLL_H__

#include <windows.h>

struct RunStatus {
    double elapsedTime;
    double cpuTime;
    LONGLONG memoryUsed;
    LONGLONG peakMemoryUsed;
};

typedef BOOL (*StatusHandler)(RunStatus* status);

struct RunOptions {
    BYTE size;
    LPTSTR user;
    LPTSTR password;
    BOOL forbidChildProcesses;
    INT timeLimit;
    SIZE_T memoryLimit;
    INT idlenessTimeLimit;
    BYTE idleCpuUsagePercent;
    BOOL useDefaultDesktop;
    BOOL showStatusWindow;
    LPTSTR stdIn;
    LPTSTR stdOut;

    StatusHandler callback;
};

struct RunResult {
    BOOL exception;
    DWORD exitcode;
    LPCTSTR message;
    BYTE resultcode;
    double elapsedTime;
    double cpuTime;
    LONGLONG memoryUsed;
};

extern "C" {
    __declspec(dllexport) BOOL runApplication(LPCTSTR cmdline, const RunOptions * options);
    __declspec(dllexport) RunResult * getResult();
}

#endif // __RUN_DLL_H__
