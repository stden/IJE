{$q+,r+,s+,i+,o+}
{$APPTYPE CONSOLE}
uses sysutils,Windows,
     ijeconsts,ije_crt32,run_dll_h;
var terminated:boolean=false;
    opt:tRunOptions;
    res:pRunResult;
    user:WideString='Run';
    pwd:WideString='euntgug';

function CtrlHandler(a:DWORD):boolean; winapi;
begin
terminated:=true;
Result:=true;
end;

function StatusCallback(var status:tRunStatus):boolean; cdecl;
begin
write(format(#13'%6.2f (%6.2f), %6.2f Kb',[status.cpuTime,status.elapsedTime,status.memoryUsed/1024]));
result:=not terminated;
end;

function runApplication(cmdline:pWideChar;var opt:tRunOptions):bool; cdecl; external 'run_dll.dll';
function getResult:pRunResult; cdecl; external 'run_dll.dll';

begin
ConsoleMode:=true;
InitConsole;
SetConsoleCtrlHandler(@CtrlHandler,TRUE);
fillchar(opt,sizeof(opt),0);
opt.size:=sizeof(opt);
opt.callback:=@StatusCallback;
opt.forbidChildProcesses:=true;
opt.useDefaultDesktop:=false;
opt.timeLimit:=2000;
opt.memoryLimit:=64*1024*1024;
opt.idlenessTimeLimit:=5000;
opt.idleCpuUsagePercent:=5;
opt.user:=PWideChar(user);
opt.password:=PWideChar(pwd);
{
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
CmdLine:='"'+prg+'" '+params;
ok:=runApplication(pWideChar(CmdLine),opt);
}
while (not terminated) do begin
      if (runApplication('vla02_a.exe',opt)<>FALSE)  then begin
         res:=getResult;
         writeln;
         writeln(format('Exit code:     %3d %s',[res.resultcode,res.message]));
         writeln(format('Time elapsed:  %0.3f',[res.elapsedTime]));
         writeln(format('Time used:     %0.3f',[res.cpuTime]));
         writeln(format('Memory used:   %0.3f Kb',[res.memoryUsed/1024]));
      end else begin
          res:=getResult();
          writeln;
          writeln(format('Error: %d %s',[res.exitcode,res.message]));
      end;
      readln;
end;
end.


