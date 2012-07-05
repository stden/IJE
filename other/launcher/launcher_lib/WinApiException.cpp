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
#include "WinApiException.h"
#include "Messages.h"

WinApiException::WinApiException(std::_string apiname, DWORD errcode, std::_string filename, long fileline)
: code(errcode), name(apiname), file(filename), expected(false)
{
    std::_stringstream tmp;
    tmp << fileline;
    line = tmp.str();
}

WinApiException::WinApiException(std::_string msg, DWORD errcode)
: code(errcode), name(msg), expected(true)
{
}

WinApiException::WinApiException()
: code(0), name(_T("")), expected(false)
{
}


WinApiException::~WinApiException(void)
{
}

std::_string WinApiException::message() const
{
    _TCHAR *lpMsgBuf;
    DWORD result = FormatMessage(
        FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM,
        NULL,
        code,
        MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
        reinterpret_cast<LPTSTR>(&lpMsgBuf),
        0,
        NULL);
    std::_string msg;
    if (result != 0) {
        msg = lpMsgBuf;
        LocalFree(lpMsgBuf);
    } else {
        std::_stringstream tmp;
        tmp << Messages::NO_ERROR_DESCRIPTION;
        tmp << std::hex << std::uppercase << _T("0x") << code;
        msg = tmp.str();
    }

    if (expected)
        return _T("")+name+msg;
    else
        return _T("Error in ") + file + _T("(") + line + _T(") : ") + name +
        _T(" - ") + msg;
}

void tryApiImpl(std::_string name, bool result, std::_string file, long line)
{
    if (!result) {
        throw WinApiException(name,GetLastError(),file,line);
    }
}

void tryApiImpl(std::_string msg, bool result)
{
    if (!result) {
        throw WinApiException(msg,GetLastError());
    }
}
