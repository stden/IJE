{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O-,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ This file is part of IJE: the Integrated Judging Environment system }
{ $Id: run.dpr 160 2007-02-13 16:43:11Z *KAP* $ }
library tir_s;
uses ShareMem,sysutils,windows,winsvc,math,
     ijeconsts,xmlije;

const ResByExitCode:array[0..6] of tresult=(_nt,_tl,_ml,_cr,_sv,_il,_fail);
      ServiceName = 'RunAppService';
      PipeName = '\\.\pipe\RunAppServicePipe';
      BUFFER_SIZE = 1024; // May be it's enough
      Domain = '.'; // We will run application on our machine, won't we?
      IdleUnit = 30; // ms

type TDllImport=function(infile:PAnsiChar;outfile:PAnsiChar;exefile:PAnsiChar;username:PAnsiChar):ULONG; cdecl;
var errstr:string;
    Username,Userpwd:array[false..true] of string;     
    settings:tsettings;

function LoadUser:boolean;
var f:textFile;
    a:boolean;
begin
LoadUser:=true;
try
  assignFile(f,settings.dllp+'run\'+settings.rundll+'users.txt');
  reset(f);
  for a:=false to true do begin
      readln(f,UserName[a]);
      readln(f,UserPwd[a]);
  end;
  close(f);
except
  on E:exception do begin
     LoadUser:=false;
     errstr:='Error in LoadUser: '+e.message;
  end;
end;
end;  

function StartRunAppService:boolean;
var status:TServiceStatus;
    srv,scm:SC_HANDLE;
    nilptr:PAnsiChar;
    starttick,oldchkpoint,waittime:DWORD;
begin
   scm:=OpenSCManager(nil,nil,0);
   if scm=0 then begin
    errstr:='Error in OpenSCMManager: '+SysErrorMessage(GetLastError());
    result:=false;
    exit;
   end;
   srv:=OpenService(scm,ServiceName,SERVICE_START or SERVICE_INTERROGATE or SERVICE_QUERY_STATUS);
   if scm=0 then begin
    errstr:='Error in OpenService: '+SysErrorMessage(GetLastError());
    result:=false;
    CloseServicehandle(scm);
    exit;
   end;
   nilptr:=nil;
   if (not QueryServiceStatus(srv,status)) then begin
    errstr:='Error in QueryServiceStatus: '+SysErrorMessage(GetLastError());
    result:=false;
    CloseServicehandle(srv);
    CloseServicehandle(scm);
    exit;
   end;
   if status.dwCurrentState<>SERVICE_RUNNING then begin
    if (not StartService(srv,0,nilptr)) then begin
     errstr:='Error in StartService: '+SysErrorMessage(GetLastError());
     result:=false;
     CloseServicehandle(srv);
     CloseServicehandle(scm);
     exit;
    end;
    if (not QueryServiceStatus(srv,status)) then begin
     errstr:='Error in QueryServiceStatus: '+SysErrorMessage(GetLastError());
     result:=false;
     CloseServicehandle(srv);
     CloseServicehandle(scm);
     exit;
    end;
   end;
   starttick:=GetTickCount();
   oldchkpoint:=status.dwCheckPoint;
   while status.dwCurrentState = SERVICE_START_PENDING do begin
    waittime:=status.dwWaitHint div 10;
          if  waittime < 1000 then waittime:=1000
    else if waittime>10000 then waittime:=10000;
    sleep(waittime);
    if (not QueryServiceStatus(srv,status)) then break;
    if (status.dwCheckPoint>oldchkpoint) then begin
     starttick:=GetTickCount();
     oldchkpoint:=status.dwCheckPoint;
    end   else begin
     if(GetTickCount()-starttick>status.dwWaitHint) then break;
    end;
   end;
   if (status.dwCurrentState<>SERVICE_RUNNING) then begin
    errstr:='Error: service not started.';
    result:=false;
          CloseServiceHandle(srv);
          CloseServiceHandle(scm);
    exit;
   end;
   CloseServiceHandle(srv);
   CloseServiceHandle(scm);
   result:=true;
end;

function CheckService:boolean;
begin
 if WaitNamedPipe(PipeName,0) then begin
  result:=true;
  exit;
 end;
 if not StartRunAppService() then begin
  result:=false;
  exit;
 end;
 if WaitNamedPipe(PipeName,0) then begin
  result:=true;
  exit;
 end;
 result:=false;
 errstr:='Service is running but no pipe instances is available.';
end;

function ReadNext(var s:string):string;
var i,j:integer;
begin
 i:=pos('<',s);
 j:=pos('>',s);
 if (i=0)or(j=0)or(i>=j) then raise EConvertError.Create('Not enough parameters.');
 result:=copy(s,i+1,j-i-1);
 delete(s,1,j);
end;

function run(prg:string;params:string;p:trunparams;s:tsettings):tRUNoutcome;
var request,reply:array[0..BUFFER_SIZE-1] of char;
    replysize:Cardinal;
    ans:string;
    res:integer;
    exitcode:int64;
    hlib:HMODULE;
    SetFilePermissions:TDllImport;
    f:text;
begin
 if not fileexists(prg) then begin
    result.result:=_fl;
    result.text:='File '+prg+' not found';
    exit;
 end;
 DecimalSeparator:='.';
 prg:=ExpandFileName(prg);
 settings:=s;
 if not LoadUser then begin
  result.result:=_fail;
  result.text:='TIR_S RUN: Application execution failed. '+errstr;
  CharToOem(PAnsiChar(result.text),PAnsiChar(result.text));
  exit;
 end;
 hLib:=LoadLibrary(PChar(s.dllp+'run\'+s.rundll+'grantaccess.dll'));
 if hLib = 0 then begin
  result.result:=_fail;
  result.text:='TIR_S RUN: Error in LoadLibrary("grantaccess.dll"): '+SysErrorMessage(GetLastError);
  CharToOem(PAnsiChar(result.text),PAnsiChar(result.text));
  exit;
 end;
 @SetFilePermissions:=GetProcAddress(hLib,'SetFilePermissions');
 if @SetFilePermissions = nil then begin
  result.result:=_fail;
  result.text:='TIR_S RUN: Error in GetProcAddress("SetFilePermissions"): '+SysErrorMessage(GetLastError);
  CharToOem(PAnsiChar(result.text),PAnsiChar(result.text));
  FreeLibrary(hLib);
  exit;
 end;
 if not fileexists(p.p.input_name) then begin
    assign(f,p.p.input_name);rewrite(f);close(f);
 end;
 if not fileexists(p.p.output_name) then begin
    assign(f,p.p.output_name);rewrite(f);close(f);
 end; 
 SetFilePermissions(PChar(p.p.input_name),PChar(p.p.output_name),PChar(prg),PChar(UserName[p.norights]));
 FreeLibrary(hLib);
 StringToWideChar('<'+prg+'><'+params+'><'+GetCurrentDir+'><'+Username[p.norights]+'><'+UserPwd[p.norights]+'><'+Domain+'><'+FloatToStr(p.tl/1000)+'><'+FloatToStr(p.ml/1024)+'><'+IntToStr(s.idlepercent)+'><'+IntToStr(ceil(s.idlelim/IdleUnit))+'>',@request,BUFFER_SIZE);
 if not CheckService then begin
  result.result:=_fail;
  result.text:='TIR_S RUN: Application execution failed. '+errstr;
  CharToOem(PAnsiChar(result.text),PAnsiChar(result.text));
  exit;
 end;
 if not CallNamedPipe(PipeName,@request,BUFFER_SIZE,@reply,BUFFER_SIZE,replysize,NMPWAIT_USE_DEFAULT_WAIT) then begin
  result.result:=_fail;
  result.text:='TIR_S RUN: Application execution failed. Error in CallNamedPipe: '+SysErrorMessage(GetLastError);
  CharToOem(PAnsiChar(result.text),PAnsiChar(result.text));
  exit;
 end;
 ans:=WideCharToString(@reply);
 try
  res:=StrToInt(ReadNext(ans));
  exitcode:=StrToInt64(ReadNext(ans));
  result.time:=StrToFloat(ReadNext(ans));
  result.mem:=-1;
  result.text:=ReadNext(ans);
  result.result:=ResByExitCode[res];
  if (res=0)and(exitcode<>0) then begin
   result.text:='Runtime error '+IntToStr(exitcode);
   result.result:=_re;
  end;
  if result.text='' then begin
     if result.result<>_fl then
        result.text:=ltext(result.result)
     else result.text:='TIR_S RUN returned _fl';
  end;
 except
  on e:EConvertError do begin
   result.result:=_fail;
   result.text:='TIR_S RUN: Application execution failed while processing service response: '+e.Message;
  end;
 end;
end;

function about:string;
begin
about:='(C) Timushev Roman';
end;

exports run,about;

begin
end.