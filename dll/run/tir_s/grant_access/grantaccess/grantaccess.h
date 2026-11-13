// The following ifdef block is the standard way of creating macros which make exporting 
// from a DLL simpler. All files within this DLL are compiled with the GRANTACCESS_EXPORTS
// symbol defined on the command line. this symbol should not be defined on any project
// that uses this DLL. This way any other project whose source files include this file see 
// GRANTACCESS_API functions as being imported from a DLL, whereas this DLL sees symbols
// defined with this macro as being exported.
#ifdef GRANTACCESS_EXPORTS
#define GRANTACCESS_API extern "C" __declspec(dllexport)

#else
#define GRANTACCESS_API __declspec(dllimport)
#endif

GRANTACCESS_API ULONG SetFilePermissions(_TCHAR* infile,_TCHAR* outfile,_TCHAR* exefile,_TCHAR* username);
