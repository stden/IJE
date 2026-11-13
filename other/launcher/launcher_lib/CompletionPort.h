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

#ifndef __COMPLETION_PORT_H__
#define __COMPLETION_PORT_H__

#include <windows.h>

class CompletionPort {
public:
    CompletionPort();
    ~CompletionPort();

    HANDLE handle() const { return hPort; }

private:
    HANDLE hPort;
};

#endif // __COMPLETION_PORT_H__
