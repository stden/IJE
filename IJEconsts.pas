{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O-,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ This file is part of IJE: the Integrated Judging Environment system }
{ (C) Kalinin Petr 2002-2008 }
{ $Id: IJEconsts.pas 211 2010-01-22 17:09:54Z РЎС‚Р°РЅРґР°СЂС‚РЅС‹Р№ $ }
unit ijeconsts;

interface
uses SyncObjs,SysUtils,WinSock,Windows;//Здесь не должно быть никаких IJE-модулей!!!

{$i tresult.pas}
const minres=_ok;maxres=_pc;
      _stext:array[minres..maxres] of string=
              ('OK','WA','PE','TL','ML','OL','IL','RE','CR','SV','NC','CE','NS','CP','FL','NT','PC');
      _attrib:array[minres..maxres] of byte=
              (10,   12,  11,  9,   9,   9,    9,  4,    4,  3,   2,   13,  1,    2,  13,  13,14);
      _TextColor:array[minres..maxres] of longint=
              ($00aa00,$0000ff,$777700,$770000,$770000,$770000,$770000{IL},$000077,$000077,$000077,
                  $004400,$aa00aa{CE},$000000,$004400,$ff00ff,$004400,$00aaaa{PC});
      _ltext:array[minres..maxres] of string=
              ('Accepted',
               'Wrong answer',
               'Presentation error',
               'Time limit exceeded',
               'Memory limit exceeded',
               'Output limit exceeded',
               'Idleness limit exceeded',
               'Runtime error',
               'Crash',
               'Security violation',
               'Accepted, but not counted',
               'Compilation error',
               'Problem wasn''t submitted',
               'Compiled, but wasn''t tested',
               'Tester failed',
               'Not tested',
               'Partial correct');
      _RusText:array[minres..maxres] of string=
              ('Верно',
               'Неверный ответ',
               'Нарушен формат выходных данных',
               'Превышен предел времени исполнения',
               'Превышен предел памяти',
               'Превышен предел размера выходного файла',
               'Превышен предел вренени простоя',
               'Ненулевой код возврата',
               'Недопустимая операция', 
               'Нарушение правил',
               'Верно, но не зачтено',
               'Ошибка компиляции',
               'Задача не сдавалась',
               'Скомпилировано',
               'Ошибка тестирующей системы',
               'Не тестировано',
               'Частично верно');
      _XMLtext:array[minres..maxres] of string=
              ('accepted',
               'wrong-answer',
               'presentation-error',
               'time-limit-exceeded',
               'memory-limit-exceeded',
               'output-limit-exceeded',
               'idleness-limit-exceeded',
               'runtime-error',
               'crash',
               'security-violation',
               'accepted-not-counted',
               'compilation-error',
               'not-submitted',
               'compiled-not-tested',
               'fail',
               'not-tested',
               'partial-correct');
const maxtasks=80;
      maxboys=100;maxtests=150;maxevaltypes=10;maxPC=10;
      maxNamelen=5;
      maxFNamelen=63;//Also check sock.pas
      maxsols=500;
      MAX_CLIENTS=10;
      MAX_TESTINGTASKS=1000;
      MAX_ACM_CONTESTS=10;
      MAX_ACM_SUBMITS=10000;
type tSolData=record boy,day,task,ext,fname,dir:string; end;
     tSolDatas=array[1..maxsols] of tSolData;
     tGTID=array[0..26] of char;//20061104180425####xxxxxxx; always has 25 bytes
type tTestSet=set of byte;
     tTestResults=record
         ntests:integer;
         test:array[1..maxtests] of record
           res:tresult;
           text:string;
           evaltext:string;
           pts:integer;
           max:integer;
           time:double;
           mem:integer;
         end;
     end;
const nMode=2;
      MaxModeVal=1 shl nMode -1;
      SMODE_REALTESTING=1;
      SMODE_AUTOADD=2;
      ModeName:array[0..nMode-1] of string=('RealTesting','AutoAdd');
{$i ije_rev.pas}
const IJE_VERSION=50;
      IJE_VERSION_ADD='';

      LOG_LEVEL_0=0;//Internal: for errors, etc.
      LOG_LEVEL_TOP=1;//For top-level procs
      LOG_LEVEL_MAJOR=2;//For major procs
      LOG_LEVEL_MINOR=3;//For minor procs
const headleft:string='НН IJE - Integrated Judging Environment ';
      titlemain:string='IJE - Integrated Judging Environment';
      headright:string='НН';
      defFileName='_noname';
type eIJEerror=class(Exception)
       public
        name:string;
        ProcPath:string;
        WinErrorNo:integer;
        constructor Create(name:string;ProcPath:string;msg:string); overload;
        constructor CreateWin(name:string;ProcPath:string);
        constructor Create(name:string;ProcPath:string;msg:string;const Args: array of const); overload;
        constructor CreateAppendPath(e:exception;proc:string); overload;
        constructor CreateAppendPath(e:exception;proc:string;NewName:string); overload;
     end;
const ErrorPrefix='[IJE] ';
var MaxLogLevel:integer=LOG_LEVEL_MAJOR;
    ije_ver_full:string;
    ConsoleMode:boolean=false;//used now only by TC
    ACMconsoleMode:boolean;//server
    NeedSelfTC:boolean=false;//used now only by server

procedure initlog(fname:string);
procedure LogEnterProc(s:string;LogLevel:integer;param:string='');
procedure LogLeaveProc(s:string;LogLevel:integer;res:string='');
procedure LogWrite(s:string;LogLevel:integer;writeind:boolean=true;writestack:boolean=false;addind:integer=0);
procedure LogWriteln(s:string;LogLevel:integer;writeind:boolean=true;writestack:boolean=false;addind:integer=0);
procedure LogError(e:exception);
procedure ShowError(e:exception);
procedure NonModalShowError(e:exception);
procedure IJEassert(a:boolean;s:string); overload;
procedure IJEassert(a:boolean;s:string;const Args:array of const); overload;
function GetWinError(errno:integer;forCrt32:boolean=false):string;
function GetLastWinError(forCrt32:boolean=false):string;
procedure CleanDir(s:string;fileleave:string='');
procedure ForceNoFile(fname:string);
procedure ForceNoDir(fname:string);
procedure copyfile(f1,f2:string);
procedure MoveFile(f1,f2:string);
function subs(s,s1,s2,s3:string):string;
function OpenInheritableFile(fname:string;mode:cardinal;cmode:cardinal):THandle;
function exec(cmdline:string;flags:dword;x:integer=300;y:integer=0;title:string=#0;show:word=SW_SHOW;inf:string='';ouf:string='';errf:string=''):dword;
procedure ArrStrUpper(var s:array of char);
procedure ConvertFile10(fname:string);
procedure StrToArray(var a:array of char;s:string;size:integer);
procedure CloseConsole;
function LoadDll(fname:string):Cardinal;
function loadDLLproc(dll:cardinal;name:PChar;raiseonerror:boolean=true):pointer;
function XMltoResult(s:string):tresult;
function STexttoResult(s:string):tresult;
function stext(a:tresult):string;
function attrib(a:tresult):byte;
function TextColor(a:tresult):longint;
function ltext(a:tresult):string;
function RusText(a:tresult):string;
function XmlText(a:tresult):string;
function CurrentTime:int64; //returns current time in 1e-7 seconds
procedure GetDate(var y,m,d,dow:word);
procedure GetTime(var h,m,s,ss:word);
function Ask(s:string):boolean;
procedure split(var s1,s2:string;ch:char);
function CorrectPath(s:string):string;
function ForceDirectories(s:string):boolean;
function Mask(msk,str:string):boolean;
function GenerateGTID:tGTID;
function StrToGTID(s:string):tGTID;
function findString(nStr:integer;var str:array of string;s:string):integer;
procedure NonModalMessageBox(Wnd:HWND;text:string;capt:string;typ:cardinal);

implementation
uses Classes,Messages,DateUtils;//No IJE units in uses!
const MaxProc=1000;
var logdata:record
       log:text;
       logopened:boolean;
       lastln:boolean;
       curproc:array[1..MaxProc] of string;
       nproc:integer;
    end;
    LogLock:tCriticalSection;
    GTIDnum:integer=0;

function GetConsoleWindow:HWnd; stdcall; external kernel32 name 'GetConsoleWindow';

procedure LogWarning(s:string);
begin
logwriteln('!  Warning: '+s,LOG_LEVEL_0,false,false);
end;

//Log starts
procedure initlog(fname:string);
begin
LogLock.Enter;
try
  with logData do begin
    assign(log,ExpandFileName(fname));
    if fileexists(fname) then
       append(log)
    else begin
         rewrite(log);
         writeln(log,'IJE log file');
    end;
    writeln(log);
    writeln(log,'IJE session on '+formatDateTime('dd.m.yyyy, hh:nn:ss',Now));
    close(log);
    lastln:=true;
    logopened:=true;
  end;
finally
  LogLock.Leave;
end;
end;

procedure LogEnterProc(s:string;LogLevel:integer;param:string='');
var ss:string;
    i:integer;
begin
with logData do begin
  for i:=1 to length(s) do
      if s[i]=' ' then
         s[i]:='_';
  if nproc=MaxProc then begin
     LogWarning('LogEnterProc: Too many procs');
     exit;
  end;
  
  LogLock.Enter;
  try
    if param='' then
       ss:=''
    else ss:='('+param+')';
    ss:=ss+'  ';
    for i:=1 to nproc do
        ss:=ss+'/'+curproc[i];
    ss:=ss+'/'+s;
    inc(nproc);
    curproc[nproc]:=s;
  finally
    LogLock.Leave;
  end;

  if not lastln then
     logwriteln('',LogLevel);
  logwriteln('>'+s+ss,LogLevel,true,false,-1);
end;
end;

procedure LogLeaveProc(s:string;LogLevel:integer;res:string='');
var ss:string;
begin
with logData do begin
  if nproc=0 then
     raise exception.Create('LogLeaveProc: internal error: call stack is emplty');
  if s<>curproc[nproc] then
     LogWarning('LogLeaveProc: Wrong proc name ('+s+' instead of '+curproc[nproc]+')');

  LogLock.Enter;
  try
    ss:=curproc[nproc];
    if res<>'' then
       ss:=ss+'   = '+res;
    dec(nproc);
  finally
    LogLock.Leave;
  end;

  if not lastln then
     logwriteln('',LogLevel);
  logwriteln('<'+ss,LogLevel,true,false);
end;
end;

procedure logwrite(s:string;LogLevel:integer;writeind:boolean=true;writestack:boolean=false;addind:integer=0);
var i:integer;
begin
if LogLevel>MaxLogLevel then
   exit;
LogLock.Enter;
try
  with logData do begin
    if not logopened then
       exit;
    append(log);
    if writeind and lastln then
       for i:=1 to nproc+addind do
           write(log,'  ');
    if writestack and lastln then begin
       for i:=1 to nproc+addind do
           write(log,curproc[i],':');
       if nproc>0 then
          write(log,' ');
    end;

    lastln:=false;
    write(log,s);
    close(log);
    if (length(s)>0)and (s[length(s)] in [#10,#13]) then
       logdata.lastln:=true;
  //  flush(log);
  end;
finally
  LogLock.Leave;
end;
end;

procedure logwriteln(s:string;LogLevel:integer;writeind:boolean=true;writestack:boolean=false;addind:integer=0);
begin
if MaxLogLevel>=LOG_LEVEL_MINOR then
   s:=s+formatDateTime(' @ hh:nn:ss',Now);
logwrite(s+#13#10,LogLevel,writeind,writestack,addind);
end;
//Log ends

procedure LogError(e:exception);
var ee:eIJEerror;
begin
if e is eIJEerror then begin
   ee:=eIJEerror(e);
   LogWriteln(format('!ERROR: %s in %s %s',[ee.name,ee.ProcPath,ee.Message]),LOG_LEVEL_0,false,false);
end else
    LogWriteln(format('!ERROR: %s',[e.Message]),LOG_LEVEL_0,false,false);
end;

procedure ShowError(e:exception);
var ee:eIJEerror;
begin
if e is eIJEerror then begin
   ee:=eIJEerror(e);
   windows.MessageBox(0,PChar(ee.name+#13#13+ee.procpath+#13#13+ee.message),PChar('IJE: '+ee.name),MB_ICONEXCLAMATION or MB_APPLMODAL);
end else
    windows.MessageBox(0,PChar('Error:'+#13#13+e.message),PChar('IJE'),MB_ICONEXCLAMATION or MB_APPLMODAL);
end;

procedure NonModalShowError(e:exception);
var ee:eIJEerror;
begin
if e is eIJEerror then begin
   ee:=eIJEerror(e);
   NonModalMessageBox(0,PChar(ee.name+#13#13+ee.procpath+#13#13+ee.message),PChar('IJE: '+ee.name),MB_ICONEXCLAMATION or MB_SYSTEMMODAL);
end else
    NonModalMessageBox(0,PChar('Error:'+#13#13+e.message),PChar('IJE'),MB_ICONEXCLAMATION or MB_SYSTEMMODAL);
end;

procedure IJEassert(a:boolean;s:string);
begin
if not a then
   raise eIJEerror.Create('Assertion failed','IJEassert: ',s);
end;

procedure IJEassert(a:boolean;s:string;const Args:array of const); overload;
begin
IJEassert(a,format(s,args));
end;

function GetWinError(errno:integer;forCrt32:boolean=false):string;
var err:array[0..1000] of char;
    i,j:integer;
begin
fillchar(err,sizeof(err),0);
FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM,nil,errno,0,@err,1000,nil);
result:=Format('Windows error %d: %s',[errno,err]);
i:=length(result);j:=i;
while result[i] in[#10,#13] do
      dec(i);
delete(result,i+1,j-i);
if forCrt32 then
   result:='\$0f;'+result+'\*;';
end;


function GetLastWinError(forCrt32:boolean=false):string;
begin
result:=GetWinError(GetLastError,forCrt32);
end;

{ eIJEerror }

constructor eIJEerror.Create(name,ProcPath,msg:string);
begin
if copy(msg,1,length(ErrorPrefix))<>ErrorPrefix then
   msg:=ErrorPrefix+msg;
inherited Create(msg);
if name='' then
   name:='An error occured (no name specified for this error)';
self.name:=name;
self.ProcPath:=ProcPath;
WinErrorNo:=0;
end;

constructor eIJEerror.Create(name,ProcPath,msg:string;const Args:array of const);
begin
self.Create(name,ProcPath,Format(msg,Args));
end;

constructor eIJEerror.CreateWin(name, ProcPath: string);
var errNo:integer;
begin
errNo:=GetlastError;
self.Create(name,ProcPath,GetWinError(errNo));
WinErrorNo:=errNo;
end;

constructor eIJEerror.CreateAppendPath(e:exception;proc:string);
begin
if proc<>'' then
   proc:=proc+': ';
if (e is eIJEerror)or(copy(e.message,1,length(ErrorPrefix))=ErrorPrefix) then begin//не очень хорошо, но, по-видимому, при передаче exception из dll'к теряются типы, хотя все остальное естается.
   self.Create(eIJEerror(e).name,proc+eIJEerror(e).ProcPath,e.Message);
   WinErrorNo:=eIJEerror(e).WinErrorNo;
end else self.create('',proc,e.Message);
end;

constructor eIJEerror.CreateAppendPath(e:exception;proc:string;NewName:string); 
begin
self.CreateAppendPath(e,proc);
self.name:=NewName;
end;

procedure CleanDir(s:string;fileleave:string='');
var rec:tSearchRec;
begin
LogEnterProc('CleanDir',LOG_LEVEL_MINOR,''''+s+''','''+fileleave+'''');
try
try
//Code starts
if findfirst(s+'\*.*',faAnyFile,rec)=0 then begin
   repeat
     if rec.Attr and faDirectory<>0 then begin
        if (rec.name<>'.')and(rec.name<>'..') then begin
           CleanDir(s+'\'+rec.Name);
           ForceNoDir(s+'\'+rec.name);
        end;
     end else if UpperCase(rec.Name)<>UpperCase(fileleave) then
         ForceNoFile(s+'\'+rec.Name);
   until FindNext(rec)<>0;
   SysUtils.FindClose(rec);
end;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'CleanDir');
end;
finally
  LogLeaveProc('CleanDir',LOG_LEVEL_MINOR);
end;
end;

procedure ForceNoFile(fname:string);
const MaxNN=30;
var nn:integer;
begin
LogEnterProc('ForceNoFile',LOG_LEVEL_MINOR,''''+fname+'''');
try
Windows.DeleteFile(PChar(fname));
nn:=0;
while (nn<maxNN)and(FileExists(fname)) do begin
      sleep(nn*10);
      inc(nn);
end;
if FileExists(fname) then
   raise eIJEerror.Create('Can''t delete file','ForceNoFile('+fname+'): ','Can''t delete file: '+GetLastWinError);
finally
  LogLeaveProc('ForceNoFile',LOG_LEVEL_MINOR);
end;
end;

procedure ForceNoDir(fname:string);
begin
LogEnterProc('ForceNoDir',LOG_LEVEL_MINOR,''''+fname+'''');
try
Windows.RemoveDirectory(PChar(fname));
if DirectoryExists(fname) then
   raise eIJEerror.Create('Can''t delete dir','ForceNoDir('+fname+')','Can''t delete dir: '+GetLastWinError);
finally
  LogLeaveProc('ForceNoDir',LOG_LEVEL_MINOR);
end;
end;

procedure copyfile(f1,f2:string);
begin
LogEnterProc('CopyFile',LOG_LEVEL_MINOR,''''+f1+''','''+f2+'''');
try
if UpperCase(ExpandFileName(f1))=UpperCase(ExpandFileName(f2)) then begin
   logwriteln('skipping',LOG_LEVEL_MINOR);
   exit;
end;
if not Windows.CopyFile(PChar(f1),PChar(f2),false) then
   raise eIJEerror.Create('','CopyFile','Error while copying ''%s'' to ''%s'': '+GetLastWinError,[f1,f2]);
finally
  LogLeaveProc('CopyFile',LOG_LEVEL_MINOR);
end;
end;

procedure MoveFile(f1,f2:string);
begin
LogEnterProc('MoveFile',LOG_LEVEL_MINOR,format('''%s'',''%s''',[f1,f2]));
try
try
//Code starts
if UpperCase(ExpandFileName(f1))=UpperCase(ExpandFileName(f2)) then begin
   logwriteln('skipping',LOG_LEVEL_MINOR);
   exit;
end;
if not Windows.MoveFileEx(PChar(f1),PChar(f2),MOVEFILE_REPLACE_EXISTING or MOVEFILE_WRITE_THROUGH) then
   raise eIJEerror.CreateWin('Error while moving file','');
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'MoveFile');
end;
finally
  LogLeaveProc('MoveFile',LOG_LEVEL_MINOR);
end;
end;

function subs(s,s1,s2,s3:string):string;
var i,i1,i2,i3:integer;
    ss:string;
begin
ss:='';
i1:=1;i2:=1;i3:=1;
for i:=1 to length(s) do
    case s[i] of
         '@':begin 
               if i1>length(s1) then continue;
               ss:=ss+s1[i1];inc(i1);
               if pos('@',copy(s,i+1,length(s)-i))=0 then begin
                  ss:=ss+copy(s1,i1,length(s1)-i1+1);
                  i1:=length(s1);
               end;
             end;
         '#':begin 
               if i2>length(s2) then continue;    
               ss:=ss+s2[i2];inc(i2); 
               if pos('#',copy(s,i+1,length(s)-i))=0 then begin
                  ss:=ss+copy(s2,i2,length(s2)-i2+1);
                  i2:=length(s2);
               end;
             end;
         '$':begin
               if i3>length(s3) then continue;
               ss:=ss+s3[i3];inc(i3);
               if pos('$',copy(s,i+1,length(s)-i))=0 then begin
                  ss:=ss+copy(s3,i3,length(s3)-i3+1);
                  i3:=length(s3);
               end;
             end;
         else ss:=ss+s[i];
    end;
subs:=ss;
end;

function OpenInheritableFile(fname:string;mode:cardinal;cmode:cardinal):THandle;
var sa:TSecurityAttributes;
begin
sa.nLength:=sizeof(sa);
sa.lpSecurityDescriptor:=nil;
sa.bInheritHandle:=true;
result:=CreateFile(PChar(fname),mode,0,@sa,cmode,0,0);
if result=INVALID_HANDLE_VALUE then
   raise exception.Create('OpenInheritableFile: Error while opening '''+fname+''': '+GetLastWinError);
end;

function exec(cmdline:string;flags:dword;x:integer=300;y:integer=0;title:string=#0;show:word=SW_SHOW;inf:string='';ouf:string='';errf:string=''):dword;
var h:_process_information;
    i:_startupinfoa;
    a:dword;
begin
LogEnterProc('Exec',LOG_LEVEL_MAJOR,format('''%s'',inf=%s,ouf=%s,errf=%s',[cmdline,inf,ouf,errf]));
try
try
//Code starts
  if x=-1 then x:=300;
  if y=-1 then y:=0;
  if title=#0 then
     title:=cmdline;

  fillchar(i,sizeof(i),0);
  i.cb:=sizeof(i);
  i.lptitle:=pchar(title);
  i.dwflags:=STARTF_USEPOSITION+STARTF_USESHOWWINDOW+STARTF_USESTDHANDLES;
  i.dwx:=x;
  i.dwy:=y;
  i.wshowwindow:=show;//SW_SHOWMINNOACTIVE;
  
  if inf<>'' then
     i.hStdInput:=OpenInheritableFile(inf,GENERIC_READ,OPEN_EXISTING)
  else i.hStdInput:=getstdhandle(STD_INPUT_HANDLE);
  try
    if ouf<>'' then
       i.hStdOutput:=OpenInheritableFile(ouf,GENERIC_WRITE,CREATE_ALWAYS)
    else i.hStdOutput:=getstdhandle(STD_OUTPUT_HANDLE);
    try
      if errf<>'' then begin
         if UpperCase(ExpandFileName(errf))=UpperCase(ExpandFileName(ouf)) then
            i.hStdError:=i.hStdOutput
         else i.hStdError:=OpenInheritableFile(errf,GENERIC_WRITE,CREATE_ALWAYS)
      end else
          i.hStdError:=getstdhandle(STD_OUTPUT_HANDLE);
      try
        if not createprocess(nil,pchar(cmdline),nil,nil,true,flags,nil,nil,i,h) then
           raise eIJEerror.CreateWin('Error while executing program','');
        waitforsingleobject(h.hProcess,Infinite);
        getexitcodeprocess(h.hprocess,a);
        result:=a;
        CloseHandle(h.hProcess);
        CloseHandle(h.hThread);
      finally
        if (errf<>'')and(UpperCase(ExpandFileName(errf))<>UpperCase(ExpandFileName(ouf))) then
           CloseHandle(i.hStdError);
      end;
    finally
      if ouf<>'' then
         CloseHandle(i.hStdOutput);
    end;
  finally
    if inf<>'' then
       CloseHandle(i.hStdInput);
  end;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'Exec');
end;
finally
  LogLeaveProc('Exec',LOG_LEVEL_MAJOR,inttostr(result));
end;
end;

procedure ArrStrUpper(var s:array of char);
var i:integer;
begin
for i:=Low(s) to High(s) do
    s[i]:=UpCase(s[i]);
end;

procedure ConvertFile10(fname:string);
var f:text;
    s,ss:string;
    ch:char;
begin
assign(f,fname);reset(f);
s:='';ss:='';
while not eof(f) do begin
      read(f,ch);
      if ch=#13 then begin
         read(f,ch);
         if ch=#10 then begin
            s:=s+ss+#13#10;
            ss:='';
         end else ss:=ch;
       end else
           ss:=ss+ch;
end;
s:=s+ss;
close(f);rewrite(f);
write(f,s);
close(f);
end;

procedure StrToArray(var a:array of char;s:string;size:integer);
begin
StrCopy(a,PChar(copy(s,1,size-1)));
end;

procedure CloseConsole;
var a:integer;
begin
a:=GetConsoleWindow;
FreeConsole;
SendMessage(a,WM_CLOSE,0,0);
end;

function LoadDll(fname:string):Cardinal;
begin
result:=LoadLibrary(PChar(fname));
if result=0 then
   raise eIJEerror.CreateWin('Can''t load dll '+fname,'LoadDll('+fname+'): ');
end;

function loadDLLproc(dll:cardinal;name:PChar;raiseonerror:boolean=true):pointer;
var dllname:array[0..1000] of char;
begin
result:=GetProcAddress(Dll,name);
if (raiseonerror)and(result=nil) then begin
   GetModuleFileName(dll,@dllname,1000);
   raise eIJEerror.CreateWin('Can''t load proc '+name+' from dll '+dllname,'LoadDllProc('+dllname+','+name+'): ');
end;
end;

function XMltoResult(s:string):tresult;
begin
for result:=minres to maxres do
    if XMLtext(result)=s then
       exit;
for result:=_pcbase+1 to _pcbase+maxpc do
    if XMLtext(result)=s then
       exit;
raise Exception.Create('Strange XML result: '''+s+'''');
end;

function STexttoResult(s:string):tresult;
begin
for result:=minres to maxres do
    if stext(result)=s then
       exit;
raise Exception.Create('Strange result: '''+s+'''');
end;

function stext(a:tresult):string;
begin
if a<_pcbase then
   result:=_stext[a]
else result:=_stext[_pc];
end;

function attrib(a:tresult):byte;
begin
if a<_pcbase then
   result:=_attrib[a]
else result:=_attrib[_pc];
end;

function TextColor(a:tresult):longint;
begin
if a<_pcbase then
   result:=_TextColor[a]
else result:=_TextColor[_pc];
end;

function ltext(a:tresult):string;
begin
if a<_pcbase then
   result:=_ltext[a]
else result:=_ltext[_pc]+format('(%d)',[a-_pcbase]);
end;

function RusText(a:tresult):string;
begin
if a<_pcbase then
   result:=_Rustext[a]
else result:=_Rustext[_pc]+format('(%d)',[a-_pcbase]);
end;

function XmlText(a:tresult):string;
begin
if a<_pcbase then
   result:=_XMLtext[a]
else result:=_XMLtext[_pc]+'-'+inttostr(a-_pcbase);
end;

function CurrentTime:int64;
var st:SYSTEMTIME;
    ft:FILETIME;
    res:int64 absolute ft;
begin
getSystemTime(st);
SystemTimeToFileTime(st,ft);
result:=res;
end;

procedure getdate(var y,m,d,dow:word);
var dd:tdatetime;
begin
dd:=date;
y:=yearof(dd);
m:=monthof(dd);
d:=dayof(dd);
dow:=dayoftheweek(dd);
end;

procedure gettime(var h,m,s,ss:word);
var dd:tdatetime;
begin
dd:=time;
h:=hourof(dd);
m:=minuteof(dd);
s:=secondof(dd);
end;

function Ask(s:string):boolean;
var ss:char;
begin
LogEnterProc('Ask',LOG_LEVEL_MINOR);
try
try
//Code starts
repeat
  write(s,'  1 - Yes, 2 - No: ');
  readln(ss);
  if ss='1' then begin
     result:=true;exit;
  end else if ss='2' then begin
     result:=false;exit;
  end else write(#7);
until false;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'Ask');
end;
finally
  LogLeaveProc('Ask',LOG_LEVEL_MINOR,BoolToStr(result));
end;
end;

procedure split(var s1,s2:string;ch:char);
var i:integer;
    ss:string;
begin
s1:=s1+#0+ch+#0;
s2:='';
i:=1;
while (s1[i]<>ch)and(s1[i]<>#0) do begin
      s2:=s2+s1[i];inc(i);
end;
if s1[i]=ch then inc(i);
if s1[i]=#0 then begin
   s1:='';exit;
end;
ss:='';
while s1[i]<>#0 do begin
      ss:=ss+s1[i];
      inc(i);
end;
s1:=ss;
end;

function CorrectPath(s:string):string;
var i,d:integer;
begin
d:=0;
result:=s;
for i:=2 to length(result) do
    if (result[i-1]='\')and(s[i]='\') then inc(d)
    else result[i-d]:=result[i];
Setlength(result,length(result)-d);
end;

function ForceDirectories(s:string):boolean;
begin
SysUtils.ForceDirectories(CorrectPath(s));
end;

function Mask(msk,str:string):boolean;
var ok:array[0..30,0..30]of byte;
    i,j,k:integer;
begin
msk:=#0+msk;str:=#0+str;
fillchar(ok,sizeof(ok),0);
ok[0,0]:=1;
for i:=1 to length(msk) do
    for j:=1 to length(str) do
        case msk[i] of
             '?':ok[i,j]:=ok[i-1,j-1];
             '*':for k:=0 to j do
                     if ok[i-1,k]=1 then begin
                        ok[i,j]:=1;break;
                     end;
             else if msk[i]=str[j] then ok[i,j]:=ok[i-1,j-1]else ok[i,j]:=0;
        end;
mask:=ok[length(msk),length(str)]=1;
end;

function GenerateGTID:tGTID;
const fmt='yyyymmddhhnnss';
var max_rnd:integer;
    i:integer;
    nn:integer;
begin
LogEnterProc('GenerateGTID',LOG_LEVEL_MINOR);
try
try
//Code starts
max_rnd:=1;
nn:=0;
for i:=length(fmt)+4+1 to sizeof(tGTID)-1 do begin
    max_rnd:=max_rnd*10;
    inc(nn);
end;
StrToArray(result,Format('%s%4.4d%*.*d',[FormatDateTime(fmt,Now),GTIDnum,nn,nn,random(max_rnd)]),sizeof(result));
GTIDnum:=(GTIDnum+1) mod 10000;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'GenerateGTID');
end;
finally
  LogLeaveProc('GenerateGTID',LOG_LEVEL_MINOR,result);
end;
end;

function StrToGTID(s:string):tGTID;
begin
StrToArray(result,s,sizeof(result));
end;

function findString(nStr:integer;var str:array of string;s:string):integer;
var i:integer;
begin
LogEnterProc('FindString',LOG_LEVEL_MINOR,format('nStr=%d',[nStr]));
try
try
//Code starts
result:=0;
for i:=0 to nStr-1 do//array of нумеруется с нуля всегда
    if Str[i]=s then begin
       result:=i+1;
       break;
    end;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'FindString');
end;
finally
  LogLeaveProc('FindString',LOG_LEVEL_MINOR,IntToStr(result));
end;
end;

type tNMMBthread=class(tThread)
        typ:cardinal;
        Wnd:Hwnd;
        capt,text:string;
        procedure Execute; override;
     end;

procedure tNMMBthread.Execute;
begin
Windows.MessageBox(Wnd,PChar(text),PChar(capt),typ);
end;

procedure NonModalMessageBox(Wnd:HWND;text:string;capt:string;typ:cardinal);
var tt:tNMMBthread;
begin
tt:=tNMMBthread.Create(true);
tt.Wnd:=wnd;
tt.typ:=typ;
tt.capt:=capt;
tt.text:=text;
tt.Resume;
end;

begin
randomize;//at least for GenerateGTID
LogLock:=tCriticalSection.Create;
logData.logopened:=false;
ije_ver_full:=format('%d.%d%s',[IJE_VERSION div 10,IJE_VERSION mod 10,IJE_VERSION_ADD]);
DecimalSeparator:='.';
end.
