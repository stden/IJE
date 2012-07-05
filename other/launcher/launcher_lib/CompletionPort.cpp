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
#include "CompletionPort.h"
#include "WinApiException.h"

CompletionPort::CompletionPort()
{
    hPort = CreateIoCompletionPort(INVALID_HANDLE_VALUE,NULL,0,1);
    tryApi(_T("CreateIoCompletionPort"), hPort != NULL);
}

CompletionPort::~CompletionPort()
{
    CloseHandle(hPort);
}
