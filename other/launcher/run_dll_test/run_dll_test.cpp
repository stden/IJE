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
#include "..\run_dll\run_dll.h"
#include "..\launcher_lib\wide_stl.h"

using namespace std;

volatile bool terminated = false;

BOOL WINAPI CtrlHandler(DWORD)
{
    terminated = true;
    return TRUE;
}

BOOL StatusCallback(RunStatus* status) {
    _cout << dec << fixed << showpoint << setprecision(1);
    _cout << setw(6) << status->cpuTime
        << _T(" (") << setw(6) << status->elapsedTime << _T("), ") 
        << setw(6) << status->memoryUsed/1024 << _T(" KB\r");
    return !terminated;
}

int _tmain(int argc, _TCHAR* argv[])
{
    locale::global(locale(".866",locale::ctype));
    SetConsoleCtrlHandler(CtrlHandler,TRUE);
    while (!terminated) {
        RunOptions options;
        memset(&options,0,sizeof options);
        options.size = sizeof options;
        options.user = NULL;
        options.password = NULL;
        options.callback = StatusCallback;
        options.useDefaultDesktop = TRUE;

        if (runApplication(_T("vla02_a.exe"),&options) != FALSE) {
            RunResult * result = getResult();
            _cout << _T("Exit code:     ") << setw(6) << result->resultcode << _T(' ') << result->message << endl;
            _cout << dec << fixed << showpoint << setprecision(1);
            _cout << _T("Time elapsed:  ") << setw(6) << result->elapsedTime << _T("\n");
            _cout << _T("Time used:     ") << setw(6) << result->cpuTime << _T("\n");
            _cout << _T("Memory used:   ") << setw(6) << result->memoryUsed/1024 << _T(" KB\n");
        } else {
            RunResult * result = getResult();
            _cout << _T("Error occured: ") << setw(6) << result->exitcode << _T(' ') << result->message << endl;
        }
        _cout << endl;
    }
    return 0;
}
