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

#ifndef __RUNTIME_ERROR_MESSAGES_H__
#define __RUNTIME_ERROR_MESSAGES_H__

#include <string>
#include "wide_stl.h"

class RuntimeErrorMessages
{
public:
    enum AppType {
        ANY
    };
    static std::_string get(DWORD exitCode, AppType type = ANY);
    static std::_string getFullMessage(DWORD exitCode, AppType type = ANY);
private:
    RuntimeErrorMessages() {}
};

#endif // __RUNTIME_ERROR_MESSAGES_H__
