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

#ifndef __WINAPI_EXCEPTION__
#define __WINAPI_EXCEPTION__

#include <stdio.h>
#include <tchar.h>
#include <windows.h>
#include <string>

#include "wide_stl.h"

class WinApiException {
public:
    WinApiException(std::_string name, DWORD code, std::_string file, long line);
    WinApiException(std::_string msg, DWORD code);
    WinApiException();
    ~WinApiException();
    std::_string message() const;
    DWORD errorCode() const { return code; }

private:
    std::_string name;
    std::_string file;
    std::_string line;
    DWORD code;
    bool expected;
};

#define tryApi(_name,_result) tryApiImpl((_name),(_result),_T(__FILE__),__LINE__)
#define tryApiEx(_msg,_result) tryApiImpl((_msg),(_result))

void tryApiImpl(std::_string name, bool result, std::_string file, long line);
void tryApiImpl(std::_string msg, bool result);

#endif // __WINAPI_EXCEPTION__
