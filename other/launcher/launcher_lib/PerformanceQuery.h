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

#ifndef __PERFORMANCE_QUERY_H__
#define __PERFORMANCE_QUERY_H__

#include <pdh.h>
#include "wide_stl.h"

class PerformanceCounter;

class PerformanceQuery
{
public:
    PerformanceQuery();
    ~PerformanceQuery();
    PerformanceCounter addCounter(std::_string objectName, std::_string parentInstanceName, std::_string instanceName, std::_string counterName);

    void collectData();

    static const DWORD INDEX_JOB_OBJECT = 1500;
    static const DWORD INDEX_THIS_PERIOD_MSEC_PROCESSOR = 1508;

    static const DWORD INDEX_JOB_OBJECT_DETAILS = 1548;

    static const DWORD INDEX_PAGEFILE_BYTES = 184;
    static const DWORD INDEX_PAGEFILE_BYTES_PEAK = 182;

    static const DWORD INDEX_SYSTEM = 2;
    static const DWORD INDEX_SYSTEM_UPTIME = 674;

    static const std::_string INSTANCE_TOTAL;

    static std::_string getPerformanceObjectNameByIndex(DWORD index);
    static DWORD getPerformanceObjectIndexByName(std::_string name);
private:
    PDH_HQUERY hQuery;
};

#endif // __PERFORMANCE_QUERY_H__
