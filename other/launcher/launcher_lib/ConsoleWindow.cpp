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
#include "ConsoleWindow.h"
#include "WinApiException.h"

ConsoleWindow::ConsoleWindow(CRect rectangle, int hmargin, int vmargin) : rect(rectangle), visible(false), hmargin(hmargin), vmargin(vmargin)
{
    hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
    tryApi(_T("GetStdHandle"),hConsole != INVALID_HANDLE_VALUE && hConsole != NULL);
    CONSOLE_SCREEN_BUFFER_INFO info;
    tryApi(_T("GetConsoleScreenBufferInfo"),
        GetConsoleScreenBufferInfo(hConsole,&info) != 0);
    if (rect.left < 0) rect.left += info.dwSize.X+1;
    if (rect.right < 0) rect.right += info.dwSize.X+1;
    if (rect.top < 0) rect.top += info.dwSize.Y+1;
    if (rect.bottom < 0) rect.bottom += info.dwSize.Y+1;
    smallrect.Left = static_cast<SHORT>(rect.left);
    smallrect.Top = static_cast<SHORT>(rect.top);
    smallrect.Right = static_cast<SHORT>(rect.right);
    smallrect.Bottom = static_cast<SHORT>(rect.bottom);
    savedarea.Allocate(rect.Width()*rect.Height());
    area.Allocate(rect.Width()*rect.Height());
    clear();
}

ConsoleWindow::~ConsoleWindow()
{
    hide();
}

void ConsoleWindow::show()
{
    if (visible) return;
    visible = true;
    COORD bufsize = {rect.Width(), rect.Height()};
    COORD bufpos = {0,0};
    SMALL_RECT conrect = smallrect;
    tryApi(_T("ReadConsoleOutput"),
        ReadConsoleOutput(hConsole, savedarea, bufsize, bufpos, &conrect) != 0);
    redraw();
}

void ConsoleWindow::hide()
{
    if (!visible) return;
    visible = false;
    COORD bufsize = {rect.Width(), rect.Height()};
    COORD bufpos = {0,0};
    SMALL_RECT conrect = smallrect;
    tryApi(_T("WriteConsoleOutput"),
        WriteConsoleOutput(hConsole, savedarea, bufsize, bufpos, &conrect) != 0);
}

void ConsoleWindow::clear()
{
    int size = rect.Width()*rect.Height();
    for(int i=0; i<size; ++i) {
#ifdef _UNICODE
        area[i].Char.UnicodeChar = L' ';
#else
        area[i].Char.AsciiChar = ' ';
#endif
        area[i].Attributes =
            FOREGROUND_BLUE |
            FOREGROUND_GREEN |
            FOREGROUND_RED |
            FOREGROUND_INTENSITY |
            BACKGROUND_BLUE;
    }
}

void ConsoleWindow::redraw()
{
    COORD bufsize = {rect.Width(), rect.Height()};
    COORD bufpos = {0,0};
    SMALL_RECT conrect = smallrect;
    tryApi(_T("WriteConsoleOutput"),
        WriteConsoleOutput(hConsole, area, bufsize, bufpos, &conrect) != 0);
}

void ConsoleWindow::setMessage(std::_string msg)
{
    clear();
    int i = hmargin; int j = vmargin;
    const int maxi = rect.Width() - 2*hmargin + 1;
    const int maxj = rect.Height() - 2*vmargin + 1;
    const int w = rect.Width();
    for (std::_string::const_iterator c = msg.begin(); c != msg.end(); ++c) {
        if (j>maxj) break;
        if (*c == _T('\n')) {
            i = hmargin; ++j;
        } else if (i<=maxi) {
#ifdef _UNICODE
            area[i+j*w].Char.UnicodeChar = *c;
#else
            area[i+j*w].Char.AsciiChar = *c;
#endif
            ++i;
        }
    }
}
