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
#include "PerformanceQuery.h"
#include "PerformanceCounter.h"
#include "WinApiException.h"
#include "wide_stl.h"

const std::_string PerformanceQuery::INSTANCE_TOTAL = _T("_Total");

PerformanceQuery::PerformanceQuery(void)
{
    PDH_STATUS result = PdhOpenQuery(NULL,0,&hQuery);
    SetLastError(result); tryApi(_T("PdhOpenQuery"),result == ERROR_SUCCESS);
}

PerformanceQuery::~PerformanceQuery(void)
{
    PdhCloseQuery(hQuery);
}

PerformanceCounter PerformanceQuery::addCounter(std::_string objectName, std::_string parentInstanceName, std::_string instanceName, std::_string counterName)
{
    PDH_HCOUNTER hCounter;
    _TCHAR path[PDH_MAX_COUNTER_PATH];
    DWORD size = sizeof path / sizeof(_TCHAR);
    PDH_COUNTER_PATH_ELEMENTS elems;
    memset(&elems,0,sizeof elems);
    elems.szObjectName = const_cast<LPTSTR>(objectName.c_str());
    if (instanceName.length() > 0)
        elems.szInstanceName = const_cast<LPTSTR>(instanceName.c_str());
    if (parentInstanceName.length() > 0)
        elems.szParentInstance = const_cast<LPTSTR>(parentInstanceName.c_str());
    elems.szCounterName = const_cast<LPTSTR>(counterName.c_str());
    elems.dwInstanceIndex = (DWORD)-1;

    PDH_STATUS result = PdhMakeCounterPath(&elems,path,&size,0);
    SetLastError(result); tryApi(_T("PdhMakeCounterPath"),result == ERROR_SUCCESS);
    result = PdhAddCounter(hQuery,path,NULL,&hCounter);
    SetLastError(result); tryApi(_T("PdhAddCounter"),result == ERROR_SUCCESS);
    return hCounter;
}

void PerformanceQuery::collectData()
{
    PDH_STATUS result = PdhCollectQueryData(hQuery);
    SetLastError(result); tryApi(_T("PdhCollectQueryData"),result == ERROR_SUCCESS);
}

std::_string PerformanceQuery::getPerformanceObjectNameByIndex(DWORD index)
{
    _TCHAR buf[PDH_MAX_COUNTER_NAME];
    DWORD size = sizeof buf / sizeof(_TCHAR);
    PDH_STATUS result = PdhLookupPerfNameByIndex(NULL,index,buf,&size);
    SetLastError(result); tryApi(_T("PdhLookupPerfNameByIndex"),result == ERROR_SUCCESS);
    return buf;
}

DWORD PerformanceQuery::getPerformanceObjectIndexByName(std::_string name)
{
    DWORD index;
    PDH_STATUS result = PdhLookupPerfIndexByName(NULL,name.c_str(),&index);
    SetLastError(result); tryApi(_T("PdhLookupPerfNameByIndex"),result == ERROR_SUCCESS);
    return index;
}
