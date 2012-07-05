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
#include "PerformanceCounter.h"
#include "WinAPiException.h"

PerformanceCounter::PerformanceCounter(PDH_HCOUNTER handle) : hCounter(handle)
{
    setFormatFlags(PDH_FMT_NOCAP100);
}

PerformanceCounter::~PerformanceCounter()
{
}

LONG PerformanceCounter::getLongValue()
{
    DWORD type;
    PDH_FMT_COUNTERVALUE value;
    PDH_STATUS result = PdhGetFormattedCounterValue(hCounter,PDH_FMT_LONG | formatFlags,&type,&value);
    SetLastError(result); tryApi(_T("PdhGetFormattedCounterValue"),result == ERROR_SUCCESS);
    tryApi(_T("PdhGetFormattedCounterValue"),value.CStatus == PDH_CSTATUS_VALID_DATA);
    return value.longValue;
}

LONGLONG PerformanceCounter::getLargeValue()
{
    DWORD type;
    PDH_FMT_COUNTERVALUE value;
    PDH_STATUS result = PdhGetFormattedCounterValue(hCounter,PDH_FMT_LARGE | formatFlags,&type,&value);
    SetLastError(result); tryApi(_T("PdhGetFormattedCounterValue"),result == ERROR_SUCCESS);
    tryApi(_T("PdhGetFormattedCounterValue"),value.CStatus == PDH_CSTATUS_VALID_DATA);
    return value.largeValue;
}

double PerformanceCounter::getDoubleValue()
{
    DWORD type;
    PDH_FMT_COUNTERVALUE value;
    PDH_STATUS result = PdhGetFormattedCounterValue(hCounter,PDH_FMT_DOUBLE | formatFlags,&type,&value);
    SetLastError(result); tryApi(_T("PdhGetFormattedCounterValue"),result == ERROR_SUCCESS);
    tryApi(_T("PdhGetFormattedCounterValue"),value.CStatus == PDH_CSTATUS_VALID_DATA);
    return value.doubleValue;
}