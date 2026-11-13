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

#ifndef __STDAFX_H__
#define __STDAFX_H__

#define WIN32_LEAN_AND_MEAN
#define _WIN32_WINNT 0x0500

#define _CRTDBG_MAP_ALLOC
#include <stdlib.h>
#include <crtdbg.h>

#include <stdio.h>
#include <tchar.h>

// CRT
#include <process.h>
#include <cassert>

// WIN API

#include <windows.h>
#include <ntsecapi.h>
#include <AccCtrl.h>
#include <Aclapi.h>
#include <pdh.h>
#include <pdhmsg.h>

// ATL
#include <atlbase.h>
#include <atltypes.h>
#include <atlsecurity.h>

//STL
#include <string>
#include <iostream>
#include <map>
#include <vector>
#include <sstream>
#include <algorithm>

#endif // __STDAFX_H__
