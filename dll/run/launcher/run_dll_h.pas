{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O+,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ This file is part of IJE: the Integrated Judging Environment system }
{ (C) Kalinin Petr 2002-2008 }
{ $Id: run_dll_h.pas 202 2008-04-19 11:24:40Z *KAP* $ }
{$A8}
unit run_dll_h;
interface
uses windows,ijeconsts;

type
(*struct RunStatus {
    double elapsedTime;
    double cpuTime;
    LONGLONG memoryUsed;
    LONGLONG peakMemoryUsed;
};*)
    tRunStatus=record
        elapsedTime:double;
        cpuTime:double;
        memoryUsed:longlong;
        peakMemoryUsed:longlong;
     end;
(*typedef BOOL (*StatusHandler)(RunStatus* status);*)
    tStatusHandler=function(var status:tRunStatus):bool; cdecl;
(*struct RunOptions {
    BYTE size;
    LPTSTR user;
    LPTSTR password;
    BOOL forbidChildProcesses;
    INT timeLimit;
    SIZE_T memoryLimit;
    INT idlenessTimeLimit;
    BYTE idleCpuUsagePercent;
    BOOL useDefaultDesktop;
    BOOL showStatusWindow;
    LPTSTR stdIn;
    LPTSTR stdOut;

    StatusHandler callback;
};*)
    tRunOptions=record
      size:byte;
      user:pWideChar;
      password:pWideChar;
      forbidChildProcesses:bool;
      timeLimit:integer;
      memoryLimit:integer;//size_t
      idlenessTimeLimit:integer;
      idleCpuUsagePercent:byte;
      useDefaultDesktop:bool;
      showStatusWindow:bool;
      stdIn:pWideChar;
      stdOut:pWideChar;
      callback:tStatusHandler;
    end;
(*struct RunResult {
    BOOL exception;
    DWORD exitcode;
    LPCTSTR message;
    BYTE resultcode;
    double elapsedTime;
    double cpuTime;
    LONGLONG memoryUsed;
};*)
    tRunResult=record
      exception:bool;
      exitcode:dWord;
      message:pWideChar;
      resultcode:byte;
      elapsedTime:double;
      cpuTime:double;
      memoryUsed:longlong;
    end;
    pRunResult=^tRunResult;
(*extern "C" {
    __declspec(dllexport) BOOL runApplication(LPCTSTR cmdline, const RunOptions * options);
    __declspec(dllexport) RunResult * getResult();
}*)
    tRunApplication=function(cmdline:pWideChar;var options:tRunOptions):bool; cdecl;
    tGetResult=function:pRunResult; cdecl;

const
  ResByExitCode:array[0..7] of tResult=(_nt,_re,_tl,_ml,_cr,_sv,_il,_fl);

implementation

end.
