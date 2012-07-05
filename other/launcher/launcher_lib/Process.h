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

#ifndef __PROCESS_H__
#define __PROCESS_H__

#include <windows.h>

#include <string>
#include "wide_stl.h"
#include "desktop.h"

class Process {
public:
    Process(std::_string cmd);
    ~Process();

    void setDesktop(Desktop *desktop) { this->desktop = desktop; }
    void setCredentials(std::_string user, std::_string password);
    void load();
    void resume();

    void redirect(std::_string infile, std::_string outfile);

    bool active();
    DWORD exitCode() const;

    HANDLE processHandle() const { return pi.hProcess; }
    HANDLE mainThreadHandle() const { return pi.hThread; }
    DWORD processId() const { return pi.dwProcessId; }

    void showWindowFlags(WORD flags) { showFlags = flags; }

private:
    std::_string cmdline;
    std::_string user, password;
    PROCESS_INFORMATION pi;
    Desktop *desktop;
    bool usehandles;
    CHandle stdinFile, stdoutFile;
    WORD showFlags;
};

#endif // __PROCESS_H__
