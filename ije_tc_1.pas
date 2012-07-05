{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O-,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ This file is part of IJE: the Integrated Judging Environment system }
{ (C) Kalinin Petr 2002-2008 }
{ $Id: ije_tc_1.pas 202 2008-04-19 11:24:40Z *KAP* $ }
{$define debug}
unit ije_tc_1;

interface

uses
  WinSock, ShellApi,Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AppEvnts, StdCtrls, ExtCtrls,
  Windows_XP, NIcon, IJEconsts, Sock, sock_IJE, IJE_cmdline, xmlije, ije_main, ije_crt32, tc_main;
const WM_ICONEVENT=WM_USER;
      MAX_OUTPUT_LINES=300;

type
  TForm1 = class(TForm)
    ApplicationEvents1: TApplicationEvents;
    StaticText1: TStaticText;
    output: TMemo;
    Panel1: TPanel;
    Button1: TButton;
    FontDialog1: TFontDialog;
    Timer1: TTimer;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OnIconEvent(var msg:tMessage); message WM_ICONEVENT;
    procedure ApplicationEvents1Minimize(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    FName: string;
    procedure SetName(const Value: string);
    procedure write(s: string);
    procedure writeln(s: string);
    procedure SetIcons;
    procedure RestoreSelf;
  published
    property Name:string read FName write SetName;
  end;

  twThread=class(tThread)
  private
    ws:string;
    procedure _write;
    procedure _writeln;
  protected
    procedure write(s:string);
    procedure writeln(s:string);
  end;

  tTestThread=class(twThread)
  private
    Sock:tSocket;
    Error:exception;
    procedure doHalt;
    procedure Activate;
    procedure TestSolution(a:tSTCtestSolution);
    procedure ShutDown;
    procedure SendAbout;
    procedure Restart;
  protected
    procedure Execute; override;
  end;

var
  Form1: TForm1;

implementation
var WSAdata:tWSAdata;
    ni:tNotifyIcon;
    TestThread:ttestThread;
    RestoreAfterBalloon:boolean=false;
    LockFileCreated:boolean;
    NeedHalt:boolean=false;
    ReadyToHalt:boolean=false;
{$R ije_tc_1.dfm}
{$R ije_all.res}
{$o-}

procedure tForm1.SetIcons;
var big,small:tHandle;
    hExe:tHandle;
begin
hExe:=LoadLibrary(PChar(paramstr(0)));
big:=LoadImage(hexe,'TC_BIG',IMAGE_ICON,0,0,0);
small:=LoadImage(hexe,'TC_SMALL',IMAGE_ICON,0,0,0);
SendMessage(application.Handle,WM_SETICON,1,big);//both big and small
SendMessage(application.Handle,WM_SETICON,0,small);//only small
SendMessage(form1.Handle,WM_SETICON,1,big);//both big and small
SendMessage(form1.Handle,WM_SETICON,0,small);//only small
if ConsoleMode then begin
   SendMessage(GetConsoleWindow,WM_SETICON,1,big);//both big and small
   SendMessage(GetConsoleWindow,WM_SETICON,0,small);//both big and small
end;
FreeLibrary(hExe);
end;

procedure tForm1.write(s:string);
var i:integer;
begin
i:=output.Lines.Count-1;
output.Lines.Strings[i]:=output.Lines.Strings[i]+s;
end;

procedure tForm1.writeln(s:string);
begin
write(s);
output.Lines.Add('> ');
if output.Lines.Count>MAX_OUTPUT_LINES then
   output.Lines.Delete(0);
end;

type tAdditionalCtrlHandlerThread=class(tThread)
       protected
         procedure Execute; override;
     end;
procedure tAdditionalCtrlHandlerThread.Execute;
begin
Synchronize(Form1.Close);
end;

function CtrlHandler(var typ:dWord):bool; stdcall;
var at:tAdditionalCtrlHandlerThread;
begin
at:=tAdditionalCtrlHandlerThread.Create(false);
result:=true;
end;

procedure TForm1.FormCreate(Sender: TObject);
var ics:tHandle;
    hExe:tHandle;
    f:textFile;
begin
initLog('ije_tc.log');
LogEnterProc('IJETC',LOG_LEVEL_TOP);
try
writeln(format('This is IJE V (IJE %s rev %s) TestClient: The Integrated Judging Environment',[ije_ver_full,IJE_REV]));
hExe:=LoadLibrary(PChar(paramstr(0)));
ics:=LoadImage(hExe,'TC_SMALL',IMAGE_ICON,0,0,0);
FreeLibrary(hExe);
ni:=tNotifyIcon.Create(form1.Handle,0);
ni.SetIcon(ics);
ni.SetTip('IJE TestClient');
ni.SetMessage(WM_ICONEVENT);

if fileexists('ije_tc_lock.$$$') then begin
   logwrite('Lock-file found... ',LOG_LEVEL_MAJOR);   
   if windows.MessageBox(0,'Lock file found'#13'IJE TC is working in this directory, or the previous IJE TC session was finished incorrectly.'#13'Continue?','IJE TC lock-file found',MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL)=IDNO then begin
      LogWriteln('Exiting.',LOG_LEVEL_MAJOR);
      Application.Terminate;
      exit;
   end;
   logwriteln('Continuing.',LOG_LEVEL_MAJOR);
end;
assignFile(f,'ije_tc_lock.$$$');rewrite(f);closeFile(f);
LockFileCreated:=true;

FontDialog1.Font:=output.Font;
LoadSettings('ije_cfg.xml',cfg);
if not ParseCmdLine(_tc) then begin
   Application.Terminate;
   exit;
end;
if ConsoleMode then begin
   AllocConsole;
   SetConsoleTitle('IJE TestClient');
   MaximizeConsole;
   InitConsole;
   SetConsoleCtrlHandler(@CtrlHandler,true);
end;
SetIcons;
WSAStartUp($101,WSAdata);
writeln('TC started');
writeln('Using Windows sockets: '+WSAdata.szDescription);
myInfo.ip:=GetMyIp;
Name:='IJE TC @ '+inet_ntoa(myInfo.ip);
MyInfo.client:=IJE_TYPE_TC;
MyInfo.ver:=IJE_VERSION;
except
  on e:exception do begin
     LogError(e);
     ShowError(e);
     application.Terminate;
     exit;
  end;
end;
TestThread:=tTestThread.Create(false);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
try
try
  writeln('Terminating...');
  if ConsoleMode then 
     CloseConsole;
  ni.Destroy;
  if (TestThread<>nil) then begin
     TestThread.Terminate;
     TestThread.WaitFor;
  end;
  WSACleanUp;
  if LockFileCreated then
     ForceNoFile(IJEdir+'\ije_tc_lock.$$$');
except
  on e:exception do begin
     LogError(e);
     ShowError(e);
  end;
end;
finally
  LogLeaveProc('IJETC',LOG_LEVEL_TOP);
end;
end;

procedure tForm1.RestoreSelf;
begin
ShowWindow(application.Handle,SW_restore);
SetForegroundWindow(form1.handle);
end;

procedure TForm1.OnIconEvent(var msg:tMessage);
begin
case msg.lParam of
     WM_LBUTTONDBLCLK:RestoreSelf;
     NIN_BALLOONHIDE,NIN_BALLOONTIMEOUT,NIN_BALLOONUSERCLICK:
         if RestoreAfterBalloon then
            RestoreSelf;
end;
end;

procedure TForm1.ApplicationEvents1Minimize(Sender: TObject);
begin
  ShowWindow(application.Handle,SW_HIDE);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
if FontDialog1.Execute then
   output.Font:=FontDialog1.Font;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
application.Minimize;
timer1.enabled:=false;
end;

procedure TForm1.SetName(const Value: string);
begin
  FName := Value;
  writeln('TC name changed to '''+fname+'''');
  application.Title:=fname;
  form1.Caption:=fname;
  ni.SetTip(fname);
//  StrCopy(myInfo.name,PChar(copy(form1.name,1,sizeof(myInfo.name))));
  StrToArray(myInfo.name,form1.name,sizeof(myInfo.name));
end;

{ twThread }

procedure twThread._write;
begin
form1.write(ws);
ws:='';
end;

procedure twThread._writeln;
begin
form1.writeln(ws);
ws:='';
end;

procedure twThread.write(s: string);
begin
ws:=s;
Synchronize(_write);
end;

procedure twThread.writeln(s: string);
begin
ws:=s;
Synchronize(_writeln);
end;

{ tTestThread }

procedure tTestThread.doHalt;
var name:string;
    msg:string;
    ProcPath:string;
begin
if Error is eIJEerror then begin
   name:=eIJEerror(error).name;
   ProcPath:=eIJEerror(error).ProcPath;
end else begin
    name:='';
    ProcPath:='???';
end;
msg:=error.Message;
ni.SetBalloon(msg,name,30000,NIIF_ERROR);
writeln('');
writeln(name);
writeln(ProcPath+msg);
RestoreAfterBalloon:=true;
ReadyToHalt:=true;
end;

procedure tTestThread.Activate;
var small:tHandle;
    hExe:tHandle;
begin
hExe:=LoadLibrary(PChar(paramstr(0)));
small:=LoadImage(hexe,'TC_ACTIVE_SMALL',IMAGE_ICON,0,0,0);
SendMessage(application.Handle,WM_SETICON,0,small);//only small
SendMessage(form1.Handle,WM_SETICON,0,small);//only small
if ConsoleMode then
   SendMessage(GetConsoleWindow,WM_SETICON,0,small);
ni.SetIcon(small);
form1.Name:=form1.Name+' - connected';
FreeLibrary(hExe);
LogWrite('Activated',LOG_LEVEL_MAJOR);
end;

procedure tTestThread.TestSolution(a:tSTCtestSolution);
var tf:tTCStestingFinished;
    ti:tTCStestingInfo;
    err:tALLeIJEerror;
    i:integer;
    ie:eIJEerror;
begin
LogEnterProc('TestSolution',LOG_LEVEL_MAJOR,''''+a.fname+'''');
try
try
//Code starts
fillchar(tf,sizeof(tf),0);
tf.typ:=TCS_TESTINGFINISHED;
tf.gtid:=a.gtid;
fillchar(err,sizeof(err),0);
err.typ:=ALL_EIJEERROR;
fillchar(ti,sizeof(ti),0);
ti.typ:=TCS_TESTINGINFO;
ti.gtid:=a.gtid;

try
  CleanDir(cfg.testingp);
  for i:=1 to a.nFiles do
      RecvFileFromSocket(Sock,cfg.testingp);
  ije_crt32.writeln;
  ije_crt32.writeln(format('\$0f;Testing %s\*;',[a.fname]));
  writeln('Testing '+a.fname);

  LoadProblem(cfg.testp+'\'+a.problem+'\problem.xml',tcProblem);
  
  ti.fname:=a.fname;
  ti.problem:=a.problem;
  StrToArray(ti.pname,tcProblem.name,sizeof(ti.pname));
  ti.tasktype:=a.tasktype;
  ti.tests:=tcProblem.ntests;
  ti.max:=0;
  for i:=1 to tcProblem.ntests do
      ti.max:=ti.max+tcProblem.test[i].points[0];
  StrToArray(ti.inf,tcProblem.input_name,sizeof(ti.inf));
  StrToArray(ti.ouf,tcProblem.output_name,sizeof(ti.ouf));
  ti.tl:=tcProblem.tl;
  ti.ml:=tcProblem.ml;
  SendToSocket(Sock,ti,sizeof(ti));

  if a.tasktype='P' then
     compile(a,Sock,tf);
  if (a.tasktype='O')or((a.tasktype='P')and(tf.res=_cp)) then
     test(a,Sock,tf);
except
  on e:exception do begin
     ShowErrorToConsole(e);
     LogError(e);
     tf.pts:=0;
     tf.max:=0;
     tf.res:=_fl;
     ie:=eIJEerror.CreateAppendPath(e,'TC','TC Error');
     StrToArray(err.name,ie.name,sizeof(err.name));
     StrToArray(err.procpath,ie.ProcPath,sizeof(err.procpath));
     StrToArray(err.text,ie.Message,sizeof(err.text));
     SendToSocket(sock,err,sizeof(err));
  end;
end;

SendToSocket(sock,tf,sizeof(tf));
writeln('Done '+a.fname);
ije_crt32.writeln('\$0f;Done\*;');
ije_crt32.writeln;

//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'TestSolution');
end;
finally
  LogLeaveProc('TestSolution',LOG_LEVEL_MAJOR);
end;
end;

procedure tTestThread.Execute;
var addr:tSockAddr;
    cmd:tMsgBuffer;
    pa:tALLpingAnswer;
begin
LogEnterProc('tTestThread.Execute',LOG_LEVEL_MAJOR);
fillchar(pa,sizeof(pa),0);
pa.typ:=ALL_PINGANSWER;

//Sock:=socket(AF_INET,SOCK_STREAM,IPPROTO_IP);
Sock:=CreateSocket(SOCK_STREAM);
try
addr.sin_family := AF_INET;
addr.sin_port := htons(TC_STREAM_PORT);
addr.sin_addr.S_addr := INADDR_ANY;
if bind(Sock,addr,sizeof(addr))=SOCKET_ERROR then
   raise eIJEerror.CreateWin('Can''t create stream socket','tTestThread.Execute: ');
myInfo.port:=TC_STREAM_PORT;
writeln(Format('Created a stream (Test) socket on port $%x',[htons(addr.sin_port)]));
try
  LookForServers(TC_DGRAM_PORT);
  ConnectToServer(Sock);
  SendAbout;
  Synchronize(Activate);
  repeat
    try
      RecvFromSocket(Sock,cmd,sizeof(cmd),0,0,0,500000);
      case cmd.typ of
           STC_TESTSOLUTION:TestSolution(pSTCtestSolution(@cmd)^);
           ALL_SHUTDOWN:ShutDown;
           ALL_RESTART:Restart;
           ALL_PING:SendToSocket(sock,pa,sizeof(pa));
      end;
    except
      on e:exception do
         if not ((e is eIJEerror) and (eIJEerror(e).WinErrorNo=10060)) then
            raise;
    end;
  until Terminated or NeedHalt;
  if NeedHalt then begin
     ReadyToHalt:=true;
     Synchronize(Form1.RestoreSelf);
     Synchronize(Form1.Close);
  end;
except
  on e:exception do begin
     error:=e;
     LogError(e);
     Synchronize(doHalt);
  end;
end;
finally
  CloseSocket(sock);
  LogLeaveProc('tTestThread.Execute',LOG_LEVEL_MAJOR);
end;
end;

procedure tTestThread.SendAbout;
var ab:tALLabout;
    s:string;
    doserror:integer;
    rec:tSearchRec;
    dll:cardinal;
    _abProc:function :string;

function abProc:string;
begin
try
  result:=_abProc;
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'abProc');
end;
end;

begin
LogEnterProc('tTestThread.SendAbout',LOG_LEVEL_MAJOR);
try
try
//Code starts
fillchar(ab,sizeof(ab),0);
ab.typ:=ALL_ABOUT;

s:='\$0f;Test client\*;'#13;
s:=s+format('The TC exe file (%s) was compiled from revision %s, at %s',[paramstr(0),IJE_REV,IJE_COMPILETIME]);
if IJE_LOCALMODIF then
   s:=s+' (with local modifications)';
s:=s+#13'\$0f;Availiable RUN DLLs:\*;'#13;
doserror:=findfirst(cfg.dllp+'\run\*',faDirectory,rec);
while doserror=0 do begin
      if (rec.name<>'.')and(rec.name<>'..')and(DirectoryExists(cfg.dllp+'\run\'+rec.Name)) then begin
        try
          dll:=LoadDll(cfg.dllp+'\run\'+rec.Name+'\run.dll');
          try
            s:=s+rec.Name; //only add if there is run.dll
            if (rec.name=cfg.rundll)or(rec.name+'\'=cfg.rundll) then
               s:=s+'   \$0e;(active)\*;';
            _abProc:=LoadDLLproc(dll,'about');
            s:=s+'   '+abProc;
          finally
            FreeLibrary(dll);
          end;
        except
        end;
        s:=s+#13;
      end;
      doserror:=findnext(rec);
end;
findclose(rec);
StrToArray(ab.text,s,sizeof(ab.text));
SendToSocket(Sock,ab,sizeof(ab));
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'tTestThread.SendAbout');
end;
finally
  LogLeaveProc('tTestThread.SendAbout',LOG_LEVEL_MAJOR);
end;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
if ReadyToHalt then begin
   CanClose:=true;
   exit;
end;
case MessageBox(0,'Close TC right now?'#13+
                  'YES to wait until current test is done'#13+
                  'NO to wait until current testing task is done'#13+
                  'CANCEL not to close TC','Close IJE TC',MB_ICONQUESTION or MB_YESNOCANCEL or MB_SYSTEMMODAL) of
     IDYES:begin Needhalt:=true;tc_main.interrupted:=true;CanClose:=false;end;
     IDNO:begin NeedHalt:=true;tc_main.interrupted:=false;CanClose:=false; end;
     IDCANCEL:begin CanClose:=false;tc_main.interrupted:=false;NeedHalt:=false; end;
end;
end;

procedure tTestThread.ShutDown;
var sa:tALLshutDownAnswer;
begin
LogEnterProc('tTestThread.ShutDown',LOG_LEVEL_MAJOR);
try
try
//Code starts
fillchar(sa,sizeof(sa),0);
sa.typ:=ALL_SHUTDOWNANSWER;

NeedHalt:=true;
sa.ok:=true;
SendToSocket(sock,sa,sizeof(sa));
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'tTestThread.ShutDown');
end;
finally
  LogLeaveProc('tTestThread.ShutDown',LOG_LEVEL_MAJOR);
end;
end;

procedure tTestThread.Restart;
var ra:tALLRestartAnswer;
begin
LogEnterProc('tTestThread.Restart',LOG_LEVEL_MAJOR);
try
try
//Code starts
fillchar(ra,sizeof(ra),0);
ra.typ:=ALL_RESTARTANSWER;

ra.ok:=true;
SendToSocket(sock,ra,sizeof(ra));
chdir(IJEdir);
loadSettings(IJEdir+'\ije_cfg.xml',cfg);
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'tTestThread.Restart');
end;
finally
  LogLeaveProc('tTestThread.Restart',LOG_LEVEL_MAJOR);
end;
end;

end.
