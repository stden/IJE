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

#ifndef __CONSOLE_WINDOW_H__
#define __CONSOLE_WINDOW_H__

#include <atlbase.h>
#include <atltypes.h>
#include "wide_stl.h"

class ConsoleWindow
{
public:
    ConsoleWindow(CRect rectangle, int hmargin = 2, int vmargin = 1);
    ~ConsoleWindow();
    void show();
    void hide();
    void redraw();
    void setMessage(std::_string msg);

private:
    void clear();

    HANDLE hConsole;
    CRect rect;
    SMALL_RECT smallrect;
    bool visible;
    int hmargin, vmargin;
    CAutoVectorPtr<CHAR_INFO> savedarea, area;
};

#endif // __CONSOLE_WINDOW_H__
