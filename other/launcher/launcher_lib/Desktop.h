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

#ifndef __DESKTOP_H__
#define __DESKTOP_H__

#include <windows.h>
#include <atlsecurity.h>
#include <string>
#include <vector>
#include "wide_stl.h"

class Desktop
{
public:
    Desktop(bool usedefault);
    ~Desktop();

    void setAccess(CSid trustee);
    void cleanupAccess();
    std::_string fullname() const { return name; }

private:
    static const std::_string WINSTA_NAME;
    static const std::_string DESKTOP_NAME;

    bool defaultdesk;
    void removeAces();
    void addAce(HANDLE handle, CSid sid, DWORD deny);
    void cleanupObjectAccess(HANDLE handle);

    HWINSTA hWinSta;
    HDESK hDesktop;
    std::_string name;
    std::vector<CSid> sids;
};

#endif // __DESKTOP_H__
