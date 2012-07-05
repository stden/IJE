{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O-,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ This file is part of IJE: the Integrated Judging Environment system }
{ $Id: run.dpr 211 2010-01-22 17:09:54Z Стандартный $ }
library launcher;
uses ShareMem,Windows,SysUtils,
     Windows_XP,xmlije,run_dll_h,ijeconsts;
var CB:function (var status:xmlije.tRunStatus):boolean;
    runApplication:tRunApplication;
    getResult:tGetResult;
    dll:tHandle;
    SaveDllProc:procedure (reason:integer); 
    runcfg:tRunLauncherSettings;

function RunCB(var status:run_dll_h.tRunStatus):bool; cdecl;
var st:xmlije.tRunStatus;
begin
try
st.time:=status.cpuTime;
st.totalTime:=status.elapsedTime;
st.mem:=status.memoryUsed;
st.peakMem:=status.peakMemoryUsed;
result:=CB(st);
except end;
end;

function run(prg:string;params:string;p:trunparams;s:tsettings):tRUNoutcome;
var opt:tRunOptions;
    CmdLine:WideString;
    res:pRunResult;
    ok:boolean;
begin
try
//Code starts
//prg:=ExpandFileName(prg);
opt.size:=sizeof(opt);
opt.user:=PWideChar(runcfg.user[p.norights].name);
opt.password:=pWideChar(runcfg.user[p.norights].pwd);
opt.forbidChildProcesses:=p.norights;
opt.timeLimit:=p.tl;
opt.memoryLimit:=p.ml;
opt.idlenessTimeLimit:=p.il;
opt.idleCpuUsagePercent:=p.idlepercent;
opt.useDefaultDesktop:=runcfg.UseDefDesktop;
opt.showStatusWindow:=(GetConsoleWindow<>0);
opt.stdIn:=nil;
opt.stdOut:=nil;
if @p.CB<>nil then begin
   CB:=@p.CB;
   opt.callback:=@RunCB;
end else
  opt.callback:=nil;
CmdLine:=prg+' '+params;
ok:=runApplication(pWideChar(CmdLine),opt);
if ok then begin
   res:=getResult;
   result.result:=ResByExitCode[res.resultcode];
   result.text:=res.message;
   result.time:=res.cpuTime;
   result.mem:=res.memoryUsed;
   if res.exception then
      result.result:=_cr;
   if (res.resultcode=0)and(res.ExitCode<>0) then 
      result.result:=_re;
   if result.text='' then begin
      if result.result<>_fl then
         result.text:=ltext(result.result)
      else result.text:='RUN Launcher returned _fl with no comment...';
   end;
end else begin
    res:=getResult;
    result.result:=_fl;
    result.text:='RUN internal error: '+trim(res.message);
    result.time:=-1;
    result.mem:=-1;
end;
//Code ends
except
  on e:exception do begin
     result.result:=_fl;
     result.text:='RUN internal error: ';
     if e is eIJEerror then
        result.text:=result.text+'in '+eIJEerror(e).ProcPath;
     result.text:=result.text+e.Message;
     result.time:=-1;
     result.mem:=-1;
  end;
end;
end;

function about:string;
begin
about:='Copyright (c) 2006, Roman Timushev';
end;

procedure init(cfg:tSettings);
begin
dll:=LoadDll(cfg.dllp+'run\'+cfg.rundll+'run_dll.dll');
runApplication:=LoadDllProc(dll,'runApplication');
getResult:=LoadDllProc(dll,'getResult');
LoadRunLauncherSettings(cfg.dllp+'run\'+cfg.rundll+'launcher_cfg.xml',runcfg);
end;

procedure LibExit(Reason:Integer); 
begin
if (Reason=DLL_PROCESS_DETACH)and(dll<>0) then
   FreeLibrary(dll);
if @SaveDllProc<>nil then
   SaveDllProc(Reason);
end;

exports run,about,init;

begin
dll:=0;
SaveDllProc:=DllProc;
DllProc:=@LibExit;
end.
