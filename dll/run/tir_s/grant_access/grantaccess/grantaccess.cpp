// grantaccess.cpp : Defines the entry point for the DLL application.
//

#include "stdafx.h"
#include "grantaccess.h"
BOOL APIENTRY DllMain( HANDLE hModule, 
                       DWORD  ul_reason_for_call, 
                       LPVOID lpReserved
					 )
{
	switch (ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH:
	case DLL_THREAD_ATTACH:
	case DLL_THREAD_DETACH:
	case DLL_PROCESS_DETACH:
		break;
	}
    return TRUE;
}

ULONG SetFileSecurityInfo(_TCHAR* filename,PSID pSidUser, DWORD dwAccess)
{
	SID_IDENTIFIER_AUTHORITY sia = SECURITY_NT_AUTHORITY;
	PSID pSidSystem = NULL;
	PSID pSidAdmins = NULL;
	PSID pSidPowerUsers = NULL;
	PACL pDacl = NULL;
	EXPLICIT_ACCESS ea[4];
	ULONG lRes = ERROR_SUCCESS;
	__try
	{
		if (!AllocateAndInitializeSid(&sia,1,SECURITY_LOCAL_SYSTEM_RID,0,0,0,0,0,0,0,&pSidSystem))
		{
			lRes = GetLastError();
			__leave;
		}
		if (!AllocateAndInitializeSid(&sia,2,SECURITY_BUILTIN_DOMAIN_RID,DOMAIN_ALIAS_RID_ADMINS,0,0,0,0,0,0,&pSidAdmins))
		{
			lRes = GetLastError();
			__leave;
		}
		if (!AllocateAndInitializeSid(&sia,2,SECURITY_BUILTIN_DOMAIN_RID,DOMAIN_ALIAS_RID_POWER_USERS,0,0,0,0,0,0,&pSidPowerUsers))
		{
			lRes = GetLastError();
			__leave;
		}
		ea[0].grfAccessMode = GRANT_ACCESS;
		ea[0].grfAccessPermissions = FILE_ALL_ACCESS;
		ea[0].grfInheritance = OBJECT_INHERIT_ACE|CONTAINER_INHERIT_ACE;
		ea[0].Trustee.MultipleTrusteeOperation = NO_MULTIPLE_TRUSTEE;
		ea[0].Trustee.pMultipleTrustee = NULL;
		ea[0].Trustee.TrusteeForm = TRUSTEE_IS_SID;
		ea[0].Trustee.TrusteeType = TRUSTEE_IS_WELL_KNOWN_GROUP;
		ea[0].Trustee.ptstrName = (LPTSTR)pSidSystem;

		ea[1].grfAccessMode = GRANT_ACCESS;
		ea[1].grfAccessPermissions = FILE_ALL_ACCESS;
		ea[1].grfInheritance = OBJECT_INHERIT_ACE|CONTAINER_INHERIT_ACE;
		ea[1].Trustee.MultipleTrusteeOperation = NO_MULTIPLE_TRUSTEE;
		ea[1].Trustee.pMultipleTrustee = NULL;
		ea[1].Trustee.TrusteeForm = TRUSTEE_IS_SID;
		ea[1].Trustee.TrusteeType = TRUSTEE_IS_ALIAS;
		ea[1].Trustee.ptstrName = (LPTSTR)pSidAdmins;

		ea[2].grfAccessMode = GRANT_ACCESS;
		ea[2].grfAccessPermissions = FILE_ALL_ACCESS;
		ea[2].grfInheritance = OBJECT_INHERIT_ACE|CONTAINER_INHERIT_ACE;
		ea[2].Trustee.MultipleTrusteeOperation = NO_MULTIPLE_TRUSTEE;
		ea[2].Trustee.pMultipleTrustee = NULL;
		ea[2].Trustee.TrusteeForm = TRUSTEE_IS_SID;
		ea[2].Trustee.TrusteeType = TRUSTEE_IS_ALIAS;
		ea[2].Trustee.ptstrName = (LPTSTR)pSidPowerUsers;

		ea[3].grfAccessMode = GRANT_ACCESS;
		ea[3].grfAccessPermissions = dwAccess;
		ea[3].grfInheritance = OBJECT_INHERIT_ACE|CONTAINER_INHERIT_ACE;
		ea[3].Trustee.MultipleTrusteeOperation = NO_MULTIPLE_TRUSTEE;
		ea[3].Trustee.pMultipleTrustee = NULL;
		ea[3].Trustee.TrusteeForm = TRUSTEE_IS_SID;
		ea[3].Trustee.TrusteeType = TRUSTEE_IS_USER;
		ea[3].Trustee.ptstrName = (LPTSTR)pSidUser;

		lRes = SetEntriesInAcl(4, ea, NULL, &pDacl);
		if (lRes != ERROR_SUCCESS)
			__leave;

		lRes = SetNamedSecurityInfo(filename,SE_FILE_OBJECT,DACL_SECURITY_INFORMATION,NULL,NULL,pDacl,NULL);
	}
	__finally
	{
		if (pSidSystem != NULL)
			FreeSid(pSidSystem);
		if (pSidAdmins != NULL)
			FreeSid(pSidAdmins);
		if (pSidPowerUsers != NULL)
			FreeSid(pSidPowerUsers);
		if (pDacl != NULL)
			LocalFree((HLOCAL)pDacl);
	}
	return lRes;
}
GRANTACCESS_API ULONG SetFilePermissions(_TCHAR* infile,_TCHAR* outfile,_TCHAR* exefile,_TCHAR* username)
{
	ULONG lRes = ERROR_SUCCESS;
	DWORD sidsize = 0;
	DWORD domainsize = 0;
	SID_NAME_USE sid_use;
	LookupAccountName(NULL,username,NULL,&sidsize,NULL,&domainsize,&sid_use);
	PSID sid = (PSID)LocalAlloc(LMEM_FIXED,sidsize);
	_TCHAR* domain = (_TCHAR*)LocalAlloc(LMEM_FIXED,domainsize);
	__try
	{
		if (LookupAccountName(NULL,username,sid,&sidsize,domain,&domainsize,&sid_use)==FALSE)
		{
			lRes = GetLastError();
			__leave;
		}
		lRes = SetFileSecurityInfo(infile,sid,FILE_GENERIC_READ/* | FILE_GENERIC_WRITE*/);
		if (lRes != ERROR_SUCCESS) __leave;
		lRes = SetFileSecurityInfo(outfile,sid,FILE_GENERIC_WRITE | FILE_GENERIC_READ);
		if (lRes != ERROR_SUCCESS) __leave;
		lRes = SetFileSecurityInfo(exefile,sid,FILE_GENERIC_EXECUTE | FILE_GENERIC_READ);
		if (lRes != ERROR_SUCCESS) __leave;
	}
	__finally
	{
		LocalFree(domain);
		LocalFree(sid);
	}
	return lRes;
}