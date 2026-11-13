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
#include "Messages.h"
#include "RuntimeErrorMessages.h"

std::_string RuntimeErrorMessages::getFullMessage(DWORD exitCode, RuntimeErrorMessages::AppType type)
{
	std::_stringstream info;
	std::_string msg = RuntimeErrorMessages::get(exitCode,type);
	info << Messages::RUNTIME_ERROR;
	if (exitCode > 0xFFFF) info << std::hex << std::uppercase << _T("0x");
	info << exitCode;
	if (msg.length() != 0) {
		info << _T(" (") << msg << _T(")");
	}
	return info.str();
}

std::_string RuntimeErrorMessages::get(DWORD exitCode, AppType type)
{
	static std::map<std::pair<AppType,DWORD>,std::_string> names;
	if (names.empty()) {
		AppType curType;
#define ADD_MACRO(a) names[std::pair<AppType,DWORD>(curType,a)] = _T(#a)
#define ADD_VALUE(a,b) names[std::pair<AppType,DWORD>(curType,a)] = _T(#b)

		curType = ANY;
		ADD_MACRO(STATUS_ACCESS_VIOLATION);
		ADD_MACRO(STATUS_ARRAY_BOUNDS_EXCEEDED);
		ADD_MACRO(STATUS_BREAKPOINT);
		ADD_MACRO(STATUS_CONTROL_C_EXIT);
		ADD_MACRO(STATUS_DATATYPE_MISALIGNMENT);
		ADD_MACRO(STATUS_FLOAT_DENORMAL_OPERAND);
		ADD_MACRO(STATUS_FLOAT_DIVIDE_BY_ZERO);
		ADD_MACRO(STATUS_FLOAT_INEXACT_RESULT);
		ADD_MACRO(STATUS_FLOAT_INVALID_OPERATION);
		ADD_MACRO(STATUS_FLOAT_MULTIPLE_FAULTS);
		ADD_MACRO(STATUS_FLOAT_MULTIPLE_TRAPS);
		ADD_MACRO(STATUS_FLOAT_OVERFLOW);
		ADD_MACRO(STATUS_FLOAT_STACK_CHECK);
		ADD_MACRO(STATUS_FLOAT_UNDERFLOW);
		ADD_MACRO(STATUS_GUARD_PAGE_VIOLATION);
		ADD_MACRO(STATUS_ILLEGAL_INSTRUCTION);
		ADD_MACRO(STATUS_IN_PAGE_ERROR);
		ADD_MACRO(STATUS_INVALID_DISPOSITION);
		ADD_MACRO(STATUS_INTEGER_DIVIDE_BY_ZERO);
		ADD_MACRO(STATUS_INTEGER_OVERFLOW);
		ADD_MACRO(STATUS_NONCONTINUABLE_EXCEPTION);
		ADD_MACRO(STATUS_PRIVILEGED_INSTRUCTION);
		ADD_MACRO(STATUS_REG_NAT_CONSUMPTION);
		ADD_MACRO(STATUS_SINGLE_STEP);
		ADD_MACRO(STATUS_STACK_OVERFLOW);

		ADD_VALUE(  0,Successful operation);
		ADD_VALUE(  1,Invalid function);
		ADD_VALUE(  2,File not found);
		ADD_VALUE(  3,Path not found);
		ADD_VALUE(  4,Too many open files);
		ADD_VALUE(  5,File access denied);
		ADD_VALUE(  6,Invalid file handle);
		ADD_VALUE(  7,Bad storage control blocks);
		ADD_VALUE(  8,Not enough memory);
		ADD_VALUE(  9,Address invalid);
		ADD_VALUE( 10,Bad environment);
		ADD_VALUE( 11,Invalid format);
		ADD_VALUE( 12,Invalid file access code);
		ADD_VALUE( 13,Invalid data);
		ADD_VALUE( 14,Not enough memory);
		ADD_VALUE( 15,Invalid drive number);
		ADD_VALUE( 16,Cannot remove current directory);
		ADD_VALUE( 17,Cannot rename across drives);
		ADD_VALUE( 18,No more files);
		ADD_VALUE( 19,Invalid argument);
		ADD_VALUE( 20,Arg list too long);
		ADD_VALUE( 21,Exec format error);
		ADD_VALUE( 22,Cross-device link);
		ADD_VALUE( 33,Math argument);
		ADD_VALUE( 34,Result too large);
		ADD_VALUE( 35,File already exists);
		ADD_VALUE( 36,Locking violation);

		ADD_VALUE(100,Disk read error);
		ADD_VALUE(101,Disk write error);
		ADD_VALUE(102,File not assigned);
		ADD_VALUE(103,File not open);
		ADD_VALUE(104,File not open for input);
		ADD_VALUE(105,File not open for output);
		ADD_VALUE(106,Invalid numeric format);

		ADD_VALUE(150,Disk is write-protected);
		ADD_VALUE(151,Unknown unit);
		ADD_VALUE(152,Drive not ready);
		ADD_VALUE(153,Unknown command);
		ADD_VALUE(154,CRC error);
		ADD_VALUE(155,Bad drive request structure length);
		ADD_VALUE(156,Disk seek error);
		ADD_VALUE(157,Unknown media type);
		ADD_VALUE(158,Sector not found);
		ADD_VALUE(159,Printer out of paper);
		ADD_VALUE(160,Device write fault);
		ADD_VALUE(161,Device read fault);
		ADD_VALUE(162,Hardware failure);
		ADD_VALUE(163,Sharing violation);
		ADD_VALUE(164,Lock violation);
		ADD_VALUE(165,Invalid disk change);
		ADD_VALUE(167,Sharing buffer overflow);
		ADD_VALUE(169,End of file);
		ADD_VALUE(170,Disk is full);
		ADD_VALUE(183,Duplicate name on network);
		ADD_VALUE(184,Network name not found);
		ADD_VALUE(185,Network busy);
		ADD_VALUE(186,Network device no longer exists);
		ADD_VALUE(187,NetBIOS command limit exceeded);
		ADD_VALUE(188,Network adapter error);
		ADD_VALUE(189,Incorrect network response);
		ADD_VALUE(190,Unexpected network error);
		ADD_VALUE(191,Incompatible remote adapter);
		ADD_VALUE(192,Print queue full);
		ADD_VALUE(193,No space for print file);
		ADD_VALUE(194,Print file deleted);
		ADD_VALUE(195,Network name deleted);
		ADD_VALUE(196,Access denied);
		ADD_VALUE(197,Network device type incorrect);
		ADD_VALUE(198,Network name not found);
		ADD_VALUE(199,Network name limite exceeded);

		ADD_VALUE(200,Division by zero);
		ADD_VALUE(201,Range check error);
		ADD_VALUE(202,Stack overflow error);
		ADD_VALUE(203,Heap overflow error);
		ADD_VALUE(204,Invalid pointer operation);
		ADD_VALUE(205,Floating point overflow);
		ADD_VALUE(206,Floating point underflow);
		ADD_VALUE(207,Invalid floating point operation);
		ADD_VALUE(208,Overlay manager not installed);
		ADD_VALUE(209,Overlay file read error);
		ADD_VALUE(210,Object not initialized);
		ADD_VALUE(211,Call to abstract method);
		ADD_VALUE(212,Stream registration error);
		ADD_VALUE(213,Collection index out of range);
		ADD_VALUE(214,Collection overflow error);
		ADD_VALUE(215,Arithmetic overflow error);
		ADD_VALUE(216,General Protection fault);

#undef ADD_MACRO
#undef ADD_VALUE
	}
	if (names.find(std::pair<AppType,DWORD>(type,exitCode)) != names.end()) {
		return names[std::pair<AppType,DWORD>(type,exitCode)];
	} else if (type != ANY) {
		return get(exitCode,ANY);
	} else return _T("");
}
