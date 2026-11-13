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
#include "Process.h"
#include "WinApiException.h"
#include "Desktop.h"
#include "LogonService.h"

Process::Process(std::_string cmd) : cmdline(cmd), usehandles(false)
{
	pi.hProcess = INVALID_HANDLE_VALUE;
	pi.hThread = INVALID_HANDLE_VALUE;
	showFlags = SW_SHOWMINNOACTIVE;
}

Process::~Process()
{
	try {
		if (processHandle() != INVALID_HANDLE_VALUE && active()) {
			TerminateProcess(processHandle(), 0);
		}
	}
	catch(WinApiException e) {}
	CloseHandle(pi.hProcess);
	CloseHandle(pi.hThread);
}

void Process::setCredentials(std::_string user, std::_string password)
{
	this->user = user;
	this->password = password;
}

void Process::resume()
{
	tryApi(_T("ResumeThread"),
		ResumeThread(mainThreadHandle()) != (DWORD)-1);
}

void Process::load()
{
	STARTUPINFO si;
	memset(&si,0,sizeof si);
	si.cb = sizeof si;
	si.dwFlags = STARTF_USESHOWWINDOW;
	si.wShowWindow = showFlags;
	if (usehandles) {
		si.hStdInput = stdinFile;
		si.hStdOutput = stdoutFile;
		si.hStdError = stdoutFile;
		si.dwFlags |= STARTF_USESTDHANDLES;
	}

	DWORD flags = CREATE_SUSPENDED | CREATE_NEW_CONSOLE | CREATE_BREAKAWAY_FROM_JOB;

	CAccessToken myToken, userToken, restrictedToken;
	tryApi(_T("GetProcessToken"),
		myToken.GetProcessToken(TOKEN_ALL_ACCESS));

	if (user.length() != 0) {
		userToken.Attach(LogonService::instance()->logon(user,password));

		CSid logonSid;
		tryApi(_T("GetLogonSid"),
			userToken.GetLogonSid(&logonSid));
		desktop->setAccess(logonSid);
	}

	std::_string desktopName = desktop->fullname();
	si.lpDesktop = const_cast<LPTSTR>(desktopName.c_str());

	if (user.length() != 0) {
		CTokenGroups groups;
		tryApi(_T("GetTokenInformation"),
			userToken.GetGroups(&groups));
		CSid::CSidArray sids;
		groups.GetSidsAndAttributes(&sids);
		groups.DeleteAll();
		for (size_t i=0; i<sids.GetCount(); ++i) groups.Add(sids[i],0);
		tryApi(_T("CreateRestrictedToken"),
			myToken.CreateRestrictedToken(&restrictedToken,CTokenGroups(),groups));
//			myToken.CreateRestrictedToken(&restrictedToken,CTokenGroups(),CTokenGroups()));//groups));
	} else {
		restrictedToken.Attach(myToken.Detach());
	}
	std::_string curdir;
	if (user.length() != 0) {
		tryApi(_T("CreateProcessAsUser"),
			CreateProcessAsUser(restrictedToken.GetHandle(),NULL,const_cast<LPTSTR>(cmdline.c_str()),NULL,NULL,usehandles,flags,NULL,NULL,&si,&pi) != 0);
	} else {
		tryApi(_T("CreateProcess"),
			CreateProcess(NULL,const_cast<LPTSTR>(cmdline.c_str()),NULL,NULL,usehandles,flags,NULL,NULL,&si,&pi) != 0);
	}
}

bool Process::active()
{
	DWORD res = WaitForSingleObject(processHandle(),0);
	if (res == WAIT_OBJECT_0) return false;
	else if (res == WAIT_TIMEOUT) return true;
	else {
		tryApi(_T("WaitForSingleObject"),res != WAIT_FAILED);
		return false;
	}
}

DWORD Process::exitCode() const
{
	DWORD code;
	tryApi(_T("GetExitCodeProcess"),
		GetExitCodeProcess(processHandle(),&code) != 0);
	return code;
}

void Process::redirect(std::_string infile, std::_string outfile)
{
	usehandles = true;
	SECURITY_ATTRIBUTES sa;
	sa.nLength = sizeof sa;
	sa.lpSecurityDescriptor = NULL;
	sa.bInheritHandle = true;
	HANDLE hStdIn = CreateFile(infile.c_str(),GENERIC_READ,0,&sa,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL | FILE_FLAG_SEQUENTIAL_SCAN,NULL);
	tryApiEx(_T(""),hStdIn != INVALID_HANDLE_VALUE);
	stdinFile.Attach(hStdIn);
	HANDLE hStdOut = CreateFile(outfile.c_str(),GENERIC_WRITE,0,&sa,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL | FILE_FLAG_SEQUENTIAL_SCAN,NULL);
	tryApiEx(_T(""),hStdOut != INVALID_HANDLE_VALUE);
	stdoutFile.Attach(hStdOut);
}