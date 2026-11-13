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

#ifndef __WIDE_STL__
#define __WIDE_STL__

#ifdef _UNICODE

#define _cout wcout
#define _cerr wcerr
#define _string wstring
#define _stringstream wstringstream
#define _ostream wostream

#else

#define _cout cout
#define _cerr cerr
#define _string string
#define _stringstream stringstream
#define _ostream ostream

#endif

#endif // __WIDE_STL__
