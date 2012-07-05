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
#include "LogonService.h"
#include "WinApiException.h"

LogonService * LogonService::instance()
{
    static LogonService logonService;
    return &logonService;
}

HANDLE LogonService::logon(std::_string user, std::_string password)
{
    std::map<std::pair<std::_string,std::_string>, WinApiException>::const_iterator error =
        errors.find(std::pair<std::_string, std::_string>(user,password));
    if (error != errors.end()) {
        throw error->second;
    }
    std::map<std::pair<std::_string,std::_string>, HANDLE>::const_iterator token =
        tokens.find(std::pair<std::_string, std::_string>(user,password));
    HANDLE hToken;
    if (token != tokens.end())
        hToken = token->second;
    else
        hToken = actualLogon(user,password);
    HANDLE hDupToken;
    tryApi(_T("DuplicateToken"),
        DuplicateToken(hToken,SecurityImpersonation,&hDupToken) != 0);
    return hDupToken;
}

HANDLE LogonService::actualLogon(std::_string user, std::_string password)
{
    HANDLE hToken;
    try {
        tryApiEx(_T(""),
            LogonUser(user.c_str(),NULL,password.c_str(),LOGON32_LOGON_NETWORK,LOGON32_PROVIDER_DEFAULT,&hToken) != 0);
        tokens[std::pair<std::_string, std::_string>(user,password)] = hToken;
        return hToken;
    } catch (WinApiException e) {
        errors[std::pair<std::_string, std::_string>(user,password)] = e;
        throw;
    }
}
