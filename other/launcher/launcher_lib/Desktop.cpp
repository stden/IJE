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
#include "Desktop.h"
#include "WinApiException.h"

const std::_string Desktop::WINSTA_NAME = _T("SecureLaunchWinSta");
const std::_string Desktop::DESKTOP_NAME = _T("SecureLaunchDesktop");

Desktop::Desktop(bool usedefault) : defaultdesk(usedefault), hWinSta(NULL), hDesktop(NULL)
{
    if (defaultdesk) {
        hWinSta = GetProcessWindowStation();
        tryApi(_T("GetProcessWindowStation"),hWinSta != NULL);
        hDesktop = GetThreadDesktop(GetCurrentThreadId());
        tryApi(_T("GetThreadDesktop"),hDesktop != NULL);
    } else {
        HWINSTA hOldWinSta = GetProcessWindowStation();
        hWinSta = CreateWindowStation(WINSTA_NAME.c_str(),0,MAXIMUM_ALLOWED,NULL);
        tryApi(_T("CreateWindowStation"),hWinSta != NULL);
        tryApi(_T("SetProcessWindowStation"),
            SetProcessWindowStation(hWinSta) != 0);
        hDesktop = CreateDesktop(DESKTOP_NAME.c_str(),NULL,NULL,0,MAXIMUM_ALLOWED,NULL);
        tryApi(_T("CreateDesktop"),hDesktop != NULL);
        tryApi(_T("SetProcessWindowStation"),
            SetProcessWindowStation(hOldWinSta) != 0);

        CDacl dacl;
        tryApi(_T("CDacl::AddAlowedAce"),
            dacl.AddAllowedAce(Sids::World(),GENERIC_ALL));
        tryApi(_T("AtlSetDacl"),
            AtlSetDacl(hWinSta,SE_KERNEL_OBJECT,dacl));
        tryApi(_T("AtlSetDacl"),
            AtlSetDacl(hDesktop,SE_KERNEL_OBJECT,dacl));
    }
    DWORD req;
    _TCHAR buf[128];
    tryApi(_T("GetUserObjectInformation"),
        GetUserObjectInformation(hWinSta,UOI_NAME,buf,sizeof buf,&req) != 0);
    name.append(buf);
    name.append(_T("\\"));
    tryApi(_T("GetUserObjectInformation"),
        GetUserObjectInformation(hDesktop,UOI_NAME,buf,sizeof buf,&req) != 0);
    name.append(buf);
}

Desktop::~Desktop()
{
    cleanupAccess();

    if (!defaultdesk) {
        CloseDesktop(hDesktop);
        CloseWindowStation(hWinSta);
    }
}

void Desktop::setAccess(CSid trustee)
{
    if (find(sids.begin(),sids.end(),trustee) != sids.end()) return;
    addAce(hWinSta, trustee,
        WINSTA_ACCESSCLIPBOARD |
        WINSTA_CREATEDESKTOP |
        WINSTA_WRITEATTRIBUTES);
    addAce(hDesktop, trustee,
        DESKTOP_HOOKCONTROL |
        DESKTOP_JOURNALPLAYBACK |
        DESKTOP_JOURNALRECORD |
        DESKTOP_SWITCHDESKTOP);
    sids.push_back(trustee);
}

void Desktop::addAce(HANDLE handle, CSid sid, DWORD deny)
{
    CDacl dacl;
    tryApi(_T("AtlGetDacl"),
        AtlGetDacl(handle,SE_KERNEL_OBJECT,&dacl));
    tryApi(_T("CDacl::AddAllowedAce"),
        dacl.AddAllowedAce(sid,GENERIC_ALL));
    tryApi(_T("CDacl::AddDeniedAce"),
        dacl.AddDeniedAce(sid,deny));
    tryApi(_T("AtlSetDacl"),
        AtlSetDacl(handle,SE_KERNEL_OBJECT,dacl));
}

void Desktop::cleanupAccess()
{
    cleanupObjectAccess(hWinSta);
    cleanupObjectAccess(hDesktop);
    sids.clear();
}

void Desktop::cleanupObjectAccess(HANDLE handle)
{
    CDacl dacl;
    tryApi(_T("AtlGetDacl"),
        AtlGetDacl(handle,SE_KERNEL_OBJECT,&dacl));
    for (std::vector<CSid>::const_iterator i = sids.begin(); i != sids.end(); ++i) {
        dacl.RemoveAces(*i);
    }
    tryApi(_T("AtlSetDacl"),
        AtlSetDacl(handle,SE_KERNEL_OBJECT,dacl));
}
