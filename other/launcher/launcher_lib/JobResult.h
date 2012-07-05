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

#ifndef __JOB_RESULT_H__
#define __JOB_RESULT_H__

#include <string>
#include <iostream>
#include "wide_stl.h"

class JobResult {
public:
    enum Value {
        OK = 0,
        RE = 1,
        TL = 2,
        ML = 3,
        CR = 4,
        SV = 5,
        IS = 6,
        ER = 7
    };

    JobResult(Value result, std::_string info);
    JobResult();
    ~JobResult();
    Value result() const { return res; }
    std::_string info() const { return inf; }
    bool valid() const { return val; }

private:
    Value res;
    std::_string inf;
    bool val;
};

std::_ostream &operator<<(std::_ostream &stream, const JobResult::Value &value);

#endif // __JOB_RESULT_H__
