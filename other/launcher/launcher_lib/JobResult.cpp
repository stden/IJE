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
#include "JobResult.h"
#include "Messages.h"

JobResult::JobResult(Value result, std::_string info) : res(result), inf(info),
val(true)
{
}

JobResult::JobResult() : res(ER), inf(Messages::RESULT_NOT_EXECUTED),
val(false)
{
}

JobResult::~JobResult()
{
}

std::_ostream&operator<<(std::_ostream &stream, const JobResult::Value &value)
{
    static std::map<JobResult::Value,std::_string> names;
    if (names.empty()) {
        names[JobResult::OK] = _T("OK");
        names[JobResult::RE] = _T("RE");
        names[JobResult::TL] = _T("TL");
        names[JobResult::ML] = _T("ML");
        names[JobResult::CR] = _T("CR");
        names[JobResult::SV] = _T("SV");
        names[JobResult::IS] = _T("IS");
        names[JobResult::ER] = _T("ER");
    }
    stream << names[value];
    return stream;
}
