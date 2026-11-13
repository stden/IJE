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

#ifndef __PERFORMANCE_COUNTER_H__
#define __PERFORMANCE_COUNTER_H__

#include <pdh.h>

class PerformanceCounter
{
public:
    PerformanceCounter() { hCounter = NULL; setFormatFlags(PDH_FMT_NOCAP100); }
    ~PerformanceCounter();

    void setFormatFlags(DWORD flags) { formatFlags = flags; }
    DWORD getFormatFlags() { return formatFlags; }

    LONG getLongValue();
    LONGLONG getLargeValue();
    double getDoubleValue();
private:
    PerformanceCounter(PDH_HCOUNTER handle);
    PDH_HCOUNTER hCounter;
    DWORD formatFlags;
    friend class PerformanceQuery;
};

#endif // __PERFORMANCE_COUNTER_H__
