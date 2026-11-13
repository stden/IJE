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

#ifndef __LOGON_SERVICE_H__
#define __LOGON_SERVICE_H__

#include <windows.h>
#include <string>
#include "wide_stl.h"
#include "WinApiException.h"

class LogonService
{
public:
    static LogonService * instance();
    HANDLE logon(std::_string user, std::_string password);
private:
    LogonService() {}
    HANDLE actualLogon(std::_string user, std::_string password);
    std::map<std::pair<std::_string,std::_string>, HANDLE> tokens;
    std::map<std::pair<std::_string,std::_string>, WinApiException> errors;
};

#endif // __LOGON_SERVICE_H__
