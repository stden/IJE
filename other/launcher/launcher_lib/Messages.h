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

#ifndef __MESSAGES_H__
#define __MESSAGES_H__

#include <string>
#include "wide_stl.h"

class Messages {
public:
    static const std::_string RESULT_NOT_EXECUTED;
    static const std::_string RESULT_CHILD_PROCESS;
    static const std::_string RESULT_TERMINATED;
    static const std::_string NO_ERROR_DESCRIPTION;
    static const std::_string RUNTIME_ERROR;
private:
    Messages() {}
};

#endif // __MESSAGES_H__
