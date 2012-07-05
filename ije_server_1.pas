{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O-,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ This file is part of IJE: the Integrated Judging Environment system }
{ (C) Kalinin Petr 2002-2008 }
{ $Id: ije_server_1.pas 202 2008-04-19 11:24:40Z *KAP* $ }
unit ije_server_1;

{$define debug}
interface

uses
  WinSock,ShellApi,Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AppEvnts, StdCtrls, ExtCtrls, SyncObjs,
  Windows_XP, NIcon, IJEconsts, Sock, sock_ije, ije_cmdline, ije_main, xmlije, io, plugin, acm;
const WM_ICONEVENT=WM_USER;
      MAX_OUTPUT_LINES=300;
      {$ifdef debug}
      TC_WAIT_TIME=60000;//sec
      {$else}
      TC_WAIT_TIME=60;
      {$ENDIF}

type
  TForm1 = class(TForm)
  private
    FName: string;
    procedure SetName(const Value: string);
    procedure write(s: string);
    procedure writeln(s: string);
    procedure GetMyIp;
    procedure StartSelfTC;
  published
    ApplicationEvents1: TApplicationEvents;
    StaticText1: TStaticText;
    output: TMemo;
    Panel1: TPanel;
    Button1: TButton;
    FontDialog1: TFontDialog;
    Timer1: TTimer;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OnIconEvent(var msg:tMessage); message WM_ICONEVENT;
    procedure ApplicationEvents1Minimize(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    property Name:string read FName write SetName;
  public
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

  tDGramThread=class(twThread)
  private
    e:exception;
    DGramSocket:tSocket;
    procedure ShowError;
  protected
    procedure Execute; override;
  end;

  tStreamThread=class(twThread)
  private
    StreamSocket:tSOCKET;
    e:exception;
//    procedure TestClient;
//    procedure TestSolution(fname:string);
    procedure ShowError;
  protected
    procedure Execute; override;
  end;

  tUIThread=class(twThread)
  private
    Sock:tSOCKET;
    table:ttable;
    ResFileName:string;
    nSol:integer;
    sol:tSolDatas;
    mode:cardinal;
    AutoSaveLock:tCriticalSection;
    procedure doLookup;
    procedure doUpdateTable;
    procedure doLoadTable(lt:tUISloadTable);
    procedure doSaveTable(lt:tUISsaveTable);
    procedure doCleanTable(lt:tUIScleanTable);
    procedure doAddTask(at:tUISaddTask);
    procedure doAddBoy(ab:tUISaddBoy);
    procedure doDeleteSolution(ds:tUISdeleteSolution);
    procedure doArchiveSolution(ar:tUISarchiveSolution);
    procedure doRestoreSolution(rs:tUISrestoreSolution);
    procedure doSetPoints(rs:tUISsetPoints);
    procedure doTestSolution(ts:tUIStestSolution);
    procedure doAbout(ar:tUISaboutRequest);
    procedure doMode(md:tUISmode);
    procedure doKillTask(kt:tUISkillTask);
    procedure doShutDown;
    procedure doRestart;
    procedure AutoSave;
  protected
    procedure Execute; override;
  end;

var
  Form1: TForm1;
  client:array[1..MAX_CLIENTS] of record
           sock:tSocket;
           status:(_free,_working,_deleted);
           about:tALLabout;
  end;
  nClient:integer=0;
  nFreeClients:integer=0;
  ClientLock:tCriticalSection;

implementation
uses server_main;
var hExe:tHandle;
    WSAdata:tWSAdata;
    ni:tNotifyIcon;
    DGramThread:tDGramThread;
    StreamThread:tStreamThread;
    myIP:in_addr;
    myStreamPort:word;
    LockFileCreated:boolean;
    SelfTCinfo:_process_information;
    SelfTCStarted:boolean=false;
{$R *.dfm}
{$R ije_all.res}
{$o-}

procedure SetIcons;
var big,small:tHandle;
begin
big:=LoadImage(hexe,'S_BIG',IMAGE_ICON,0,0,0);
small:=LoadImage(hexe,'S_SMALL',IMAGE_ICON,0,0,0);
SendMessage(application.Handle,WM_SETICON,1,big);//both big and small
SendMessage(application.Handle,WM_SETICON,0,small);//only small
SendMessage(form1.Handle,WM_SETICON,1,big);//both big and small
SendMessage(form1.Handle,WM_SETICON,0,small);//only small
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

procedure tForm1.StartSelfTC;
var i:_startupinfoa;
    console:string;
begin
fillchar(i,sizeof(i),0);
i.cb:=sizeof(i);
i.dwflags:=STARTF_USESHOWWINDOW;
i.wshowwindow:=SW_SHOW;
console:='';
if ConsoleMode then
   console:='-console';
if not CreateProcess(PChar(IJEdir+'\ije_tc.exe'),
                PChar(format('"%s\ije_tc.exe" -ll %d -sdp %d -ssp %d -tdp %d -tsp %d %s',[IJEdir,MaxLogLevel,SERVER_DGRAM_PORT,SERVER_STREAM_PORT,TC_DGRAM_PORT,TC_STREAM_PORT,console])),
                nil,nil,false,0,nil,nil,i,SelfTCInfo) then
    raise eIJEerror.CreateWin('Can''t start self TC','StartSelfTC');
SelfTCStarted:=true;
end;

procedure TForm1.FormCreate(Sender: TObject);
var ics:tHandle;
    f:textFile;
begin
InitLog('ije_server.log');
LogEnterProc('IJES',LOG_LEVEL_TOP);
try
writeln(format('This is IJE V (IJE %s rev %s) Server: The Integrated Judging Environment',[ije_ver_full,IJE_REV]));
hExe:=LoadLibrary(PChar(paramstr(0)));
ics:=LoadImage(hExe,'S_SMALL',IMAGE_ICON,0,0,0);
ni:=tNotifyIcon.Create(form1.Handle,0);
ni.SetIcon(ics);
ni.SetTip('IJE server');
ni.SetMessage(WM_ICONEVENT);

if fileexists('ije_server_lock.$$$') then begin
   logwrite('Lock-file found... ',LOG_LEVEL_MAJOR);
   if windows.MessageBox(0,'Lock file found'#13'IJE S is working in this directory, or the previous IJE S session was finished incorrectly.'#13'Continue?','IJE S lock-file found',MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL)=IDNO then begin
      LogWriteln('Exiting.',LOG_LEVEL_MAJOR);
      Application.Terminate;
      exit;
   end;
   logwriteln('Continuing.',LOG_LEVEL_MAJOR);
end;
assignFile(f,'ije_server_lock.$$$');rewrite(f);closeFile(f);
LockFileCreated:=true;

FontDialog1.Font:=output.Font;
SetIcons;
WSAStartUp($101,WSAdata);
writeln('Server started');
writeln('Using Windows sockets: '+WSAdata.szDescription);
LoadSettings('ije_cfg.xml',cfg);
if not ParseCmdLine(_server) then begin
   Application.Terminate;
   exit;
end;
TQthread:=tTQthread.Create(false);
ClientLock:=TCriticalSection.Create;
GetMyIp;
if NeedSelfTC then
   StartSelfTC;
LoadPlugins(cfg.dllp+'\plugins');
ConsoleMode:=false;
InitQACM;
except
  on e:exception do begin
     LogError(e);
     ShowError(e);
     application.terminate;
     exit;
  end;
end;
StreamThread:=tStreamThread.Create(false);
sleep(500);
DGramThread:=tDGramThread.Create(false);
end;

function CloseSelfTC(wnd:hwnd;param:lparam):boolean; stdcall;
begin
SendMessage(wnd,WM_CLOSE,0,0);
result:=true;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
try
try
  ni.Destroy;
  if LockFileCreated then
     ForceNoFile('ije_server_lock.$$$');
  if DGramThread<>nil then//не делаем WaitFor, т.к. и DGramThread и StreamThread использует blocking-calls
     DGramThread.Terminate;
  if StreamThread<>nil then
     StreamThread.Terminate;
  if TQthread<>nil then begin
     TQthread.Terminate;
     TQthread.WaitFor;
  end;
  if SelfTCStarted then begin
     if not EnumThreadWindows(SelfTcinfo.dwThreadId,@CloseSelfTC,0) then
        raise eIJEerror.CreateWin('Can''t close self TC','FormDestroy: ');
  end;
  FinishQACM;
  FreePlugins;
  WSACleanUp;
except
  on e:exception do begin
     LogError(e);
     ShowError(e);
  end;
end;
finally
LogLeaveProc('IJES',LOG_LEVEL_TOP);
end;
end;

procedure TForm1.OnIconEvent(var msg:tMessage);
begin
if msg.LParam=WM_LBUTTONDBLCLK then begin
   ShowWindow(application.Handle,SW_restore);
   SetForegroundWindow(form1.handle);
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
  writeln('Server name changed to '''+fname+'''');
  application.Title:=fname;
  form1.Caption:=fname;
  ni.SetTip(fname)
end;

procedure tForm1.GetMyIP;
type pInteger=^integer;
     tpIntArray=array[1..10] of pInteger;
     ppIntArray=^tpIntArray;
var myname:array[0..63] of char;
    myhost:phostent;
    IPs:ppIntArray;
    s:string;
    i:integer;
begin
gethostname(myname,sizeof(myname));
myhost:=gethostbyname(myname);
IPs:=ppIntArray(myhost^.h_addr);
s:='';
for i:=1 to 10 do
    if IPs^[i]<>nil then
       s:=s+' '+inet_ntoa(in_addr(IPs^[i]^))
    else break;
writeln('Availiable IPs are:'+s);
myIP.S_addr:=IPs^[1]^;
writeln('Now choosing IP '+inet_ntoa(myIP));
Name:='IJE server @ '+inet_ntoa(myIP);
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

{ tDGramThread }

procedure tDGramThread.ShowError;
begin
LogError(e);
ijeconsts.ShowError(e);
Application.Terminate;
end;

procedure tDGramThread.Execute;
var addr:tSockAddr;
    myInfo,info:tDGramInfo;
    a:integer;
begin
try
DGramSocket:=CreateSocket(SOCK_DGRAM);
try
addr.sin_family := AF_INET;
addr.sin_port := htons(SERVER_DGRAM_PORT);
addr.sin_addr.S_addr := INADDR_ANY;
if bind(DGramSocket,addr,sizeof(addr))<>0 then
   raise eIJEerror.CreateWin('Can''t bind DGram socket','');
writeln(Format('Created a DGram socket on port $%x',[htons(addr.sin_port)]));
myInfo.client:=IJE_TYPE_SERVER;
myinfo.ip:=myip;
myinfo.port:=myStreamPort;
myInfo.ver:=IJE_VERSION;
StrToArray(myInfo.name,form1.name,sizeof(myInfo.name));

while not terminated do begin
      a:=recv(DGramSocket,info,sizeof(info),0);
      if a<>sizeof(info) then
         continue;
      write(Format('%s ''%s'' (%s:$%x) is looking for server...',[TypeToString[info.client],info.name,inet_ntoa(info.ip),info.port]));
      addr.sin_family:=AF_INET;
      addr.sin_port:=htons(info.port);
      addr.sin_addr:=info.ip;
      sendto(DGramSocket,myinfo,sizeof(myinfo),0,addr,sizeof(addr));
      writeln('Replied');
      sleep(100);
end;
finally
CloseSocket(DGramSocket);
end;
except
  on e:exception do begin
     self.e:=eIJEerror.CreateAppendPath(e,'DGramThread.Execute');
     Synchronize(ShowError);
  end;
end;
end;

{ tStreamThread }

procedure tStreamThread.Execute;
var addr:sockaddr_in;
    NewSock:tSocket;
    myInfo,info:tDGramInfo;
    a:integer;
    ans:tSTCconnectanswer;
    ee:eIJEerror;
    UIthread:tUIthread;
    i:integer;
    cPos:integer;
begin
try
ans.typ:=ALL_CONNECTANSWER;
StreamSocket:=CreateSocket(SOCK_STREAM);
try
addr.sin_family := AF_INET;
addr.sin_port := htons(SERVER_STREAM_PORT);
addr.sin_addr.S_addr := INADDR_ANY;
if bind(StreamSocket,addr,sizeof(addr))<>0 then
   raise eIJEerror.CreateWin('Can''t bind a stream socket','');
myStreamPort:=SERVER_STREAM_PORT;
listen(StreamSocket,SOMAXCONN);
writeln(Format('Created a Stream socket on port $%x',[htons(addr.sin_port)]));
repeat
  try
    NewSock:=accept(StreamSocket,nil,nil);
    a:=sizeof(addr);
    getpeername(NewSock,addr,a);
    write(format('Somebody connects on %s:$%x...',[inet_ntoa(addr.sin_addr),addr.sin_port]));
    recvTime(NewSock,info,sizeof(info),0);
    write(TypeToString[info.client]+'...');
    myInfo.client:=IJE_TYPE_SERVER;
    myInfo.port:=myStreamPort;
    myInfo.ip:=myip;
    myInfo.ver:=IJE_VERSION;
    StrToArray(myInfo.name,form1.name,sizeof(myInfo.name));
    send(NewSock,myInfo,sizeof(myInfo),0);
    write('Replied...');
    case info.client of
     IJE_TYPE_TC: begin
       if info.ver<>IJE_VERSION then begin
          ans.ok:=false;
          StrToArray(ans.reason,format('Version mismatch (S: %d, TC: %d)',[IJE_VERSION,info.ver]),sizeof(ans.reason));
          SendToSocket(NewSock,ans,sizeof(ans));
          writeln(Format('Rejected: Wrong ver (S: %d, TC: %d)',[IJE_VERSION,info.ver]));
          LogWriteln(format('TC connection rejected: Vrong ver (S: %d, TC: %d)',[IJE_VERSION,info.ver]),LOG_LEVEL_MAJOR);
          continue;
       end;
       ClientLock.Enter;
       try
         cPos:=nClient+1;
         for i:=1 to nClient do begin
             if (Client[i].status=_free)and(not IsPinging(Client[i].sock)) then begin
                write(format('(Client %d is not pinging; deleted)...',[i]));
                Client[i].status:=_deleted;
                dec(nFreeClients);
             end;
             if Client[i].status=_deleted then begin
                cPos:=i;
                break;
             end;
         end;
         if cPos>MAX_CLIENTS then begin
            ans.ok:=false;
            ans.reason:='Too many clients';
            SendToSocket(NewSock,ans,sizeof(ans));
            writeln('Rejected: Too many clients');
            LogWriteln('TC connection rejected: Too many clients',LOG_LEVEL_MAJOR);
            continue;
         end;
         if cPos>nClient then begin
            inc(nClient);
            assert(cPos=nClient);
         end;
         inc(nFreeClients);
         Client[cPos].sock:=NewSock;
         Client[cPos].status:=_free;
         ans.ok:=true;
         ans.reason:='';
         SendToSocket(NewSock,ans,sizeof(ans));
         RecvFromSocket(NewSock,Client[cPos].about,sizeof(Client[cPos].about),0,sizeof(Client[cPos].about));
       finally
         ClientLock.Leave;
       end;
       writeln(format('Accepted: TC No. %d',[cPos]));
       LogWriteln(format('TC ''%s'' (%s:$%x) connection accepted',[info.name,inet_ntoa(info.ip),info.port]),LOG_LEVEL_MAJOR);
      end;
    IJE_TYPE_UI: begin
       if info.ver<>IJE_VERSION then begin
           ans.ok:=false;
           StrToArray(ans.reason,format('Version mismatch (S: %d, TC: %d)',[IJE_VERSION,info.ver]),sizeof(ans.reason));
           SendToSocket(NewSock,ans,sizeof(ans));
           writeln(Format('Rejected: Wrong ver (S: %d, TC: %d)',[IJE_VERSION,info.ver]));
           LogWriteln(format('UI connection rejected: Vrong ver (S: %d, TC: %d)',[IJE_VERSION,info.ver]),LOG_LEVEL_MAJOR);
           continue;
        end;
       ans.ok:=true;
       ans.reason:='';
       SendToSocket(NewSock,ans,sizeof(ans));
       writeln('Accepted: UI ');
       LogWriteln(format('UI ''%s'' (%s:$%x) connection accepted',[info.name,inet_ntoa(info.ip),info.port]),LOG_LEVEL_MAJOR);
       UIthread:=tUIthread.Create(true);
       UIthread.Sock:=NewSock;
       UIthread.Resume;
    end;
    else raise eIJEerror.Create('','','Unknown client type %d',[info.client]);
  end;
  except
    on e:exception do begin
       LogError(e);
       ee:=eIJEerror.CreateAppendPath(e,'');
       writeln(format('Error!: %s in %s: %s',[ee.name,ee.ProcPath,ee.Message]));
    end;
  end;
until terminated;
finally
CloseSocket(StreamSocket);
end;
except
  on e:exception do begin
     self.e:=eIJEerror.CreateAppendPath(e,'StreamThread.Execute');
     Synchronize(ShowError);
  end;
end;
end;

procedure tStreamThread.ShowError;
begin
LogError(e);
ijeconsts.ShowError(e);
Application.terminate;
end;

{ tUIThread }

procedure tUithread.doLookup;
var la:tSUIlookupAnswer;
    ls:tSUIlookupSolData;
    i:integer;
begin
fillchar(la,sizeof(la),0);
la.typ:=SUI_LOOKUPANSWER;
fillchar(ls,sizeof(ls),0);
ls.typ:=SUI_LOOKUPSOLDATA;

LookUp(nSol,sol);

la.nsol:=nsol;
SendToSocket(sock,la,sizeof(la));
for i:=1 to nsol do begin
    StrToArray(ls.boy,sol[i].boy,sizeof(ls.boy));
    StrToArray(ls.day,sol[i].day,sizeof(ls.day));
    StrToArray(ls.task,sol[i].task,sizeof(ls.task));
    StrToArray(ls.ext,sol[i].ext,sizeof(ls.ext));
    StrToArray(ls.fname,sol[i].fname,sizeof(ls.fname));
    SendToSocket(sock,ls,sizeof(ls));
end;
end;

procedure tUIThread.Execute;
var cmd:tMsgBuffer;
    s:string;
    err:tALLeIJEerror;
    ie:eIJEerror;
begin
fillchar(err,sizeof(err),0);
err.typ:=ALL_EIJEERROR;

AutoSaveLock:=tCriticalSection.Create;
ResFileName:=defFileName;
io.clean(table);
LogWriteln('UI thread start',LOG_LEVEL_MINOR);
while true do begin
  if mode and SMODE_REALTESTING<>0 then
     AutoSave;
  try
    RecvFromSocket(Sock,cmd,sizeof(cmd),0,0,0,0);
  except
    on ee:exception do begin
       if ee is eIJEerror then
          s:=eIJEerror(ee).name+' in '+eIJEerror(ee).ProcPath+eIJEerror(ee).Message
       else
          s:='Exception: '+ee.Message;
       break;
    end;
  end;
  try
    LogWriteln(format('Command # %d recieved',[cmd.typ]),LOG_LEVEL_MAJOR);
    case cmd.typ of
         UIS_LOOKUP:doLookup;
         UIS_UPDATETABLE:doUpdateTable;
         UIS_LOADTABLE:doLoadTable(pUISloadTable(@cmd)^);
         UIS_SAVETABLE:doSaveTable(pUISsaveTable(@cmd)^);
         UIS_CLEANTABLE:doCleanTable(pUIScleanTable(@cmd)^);
         UIS_ADDTASK:doAddTask(pUISaddTask(@cmd)^);
         UIS_ADDBOY:doAddBoy(pUISaddBoy(@cmd)^);
         UIS_DELETESOLUTION:doDeleteSolution(pUISdeleteSolution(@cmd)^);
         UIS_ARCHIVESOLUTION:doArchiveSolution(pUISarchiveSolution(@cmd)^);
         UIS_RESTORESOLUTION:doRestoreSolution(pUISrestoreSolution(@cmd)^);
         UIS_SETPOINTS:doSetPoints(pUISsetPoints(@cmd)^);
         UIS_TESTSOLUTION:doTestSolution(pUIStestSolution(@cmd)^);
         UIS_ABOUTREQUEST:doAbout(pUISaboutRequest(@cmd)^);
         UIS_MODE:doMode(pUISmode(@cmd)^);
         UIS_KILLTASK:doKillTask(pUISkillTask(@cmd)^);
         ALL_SHUTDOWN:doShutDown;
         ALL_RESTART:doRestart;
         else raise eIJEerror.Create('Unknown message type','','Message type %d unknown to server',[cmd.typ]);
    end;
  except
    on e:exception do begin
       ie:=eIJEerror.CreateAppendPath(e,'','Error on server side while processing command');
       StrToArray(err.name,ie.name,sizeof(err.name));
       StrToArray(err.procpath,ie.ProcPath,sizeof(err.procpath));
       StrToArray(err.text,ie.Message,sizeof(err.text));
       SendToSocket(sock,err,sizeof(err));
    end;
  end;
end;
if s<>'' then
   s:='; reason: '+s;
LogWriteln('UI thread exit'+s,LOG_LEVEL_MINOR);
AutoSaveLock.Destroy;
end;

procedure tUIThread.doUpdateTable;
var ua:tSUIupdateAnswer;
    nm:tSUItbName;
    i:integer;
begin
fillchar(ua,sizeof(ua),0);
ua.typ:=SUI_UPDATEANSWER;
fillchar(nm,sizeof(nm),0);
nm.typ:=SUI_TBNAME;

ua.ntask:=table.ntask;
ua.nboy:=table.nboy;
ua.stable:=table.t;
ua.tasktype:=table.tasktype;
StrToArray(ua.ResFileName,ResFileName,sizeof(ua.ResFileName));
SendToSocket(sock,ua,sizeof(ua));

for i:=1 to table.nboy do begin
    StrToArray(nm.name,table.boy[i],sizeof(nm.name));
    SendToSocket(sock,nm,sizeof(nm));
end;
for i:=1 to table.ntask do begin
    StrToArray(nm.name,table.task[i],sizeof(nm.name));
    SendToSocket(sock,nm,sizeof(nm));
end;
end;

procedure tUIThread.doLoadTable(lt:tUISloadTable);
var ok:tALLok;
begin
ok.typ:=ALL_OK;

io.LoadTable(table,lt.fname,lt.dll);
ResFileName:=lt.fname;
SendToSocket(sock,ok,sizeof(ok));
end;

procedure tUIThread.doSaveTable(lt: tUISsaveTable);
var ok:tALLok;
begin
ok.typ:=ALL_OK;

if mode and SMODE_REALTESTING=0 then
   raise exception.Create('Command SAVE is disabled in non-RealTesting mode');
io.SaveTable(table,lt.fname,lt.dll);
ResFileName:=lt.fname;
SendToSocket(sock,ok,sizeof(ok));
end;

procedure tUIThread.doCleanTable(lt: tUIScleanTable);
var ok:tALLok;
begin
ok.typ:=ALL_OK;

io.Clean(table);
ResFileName:=defFileName;
mode:=mode and (not SMODE_REALTESTING);
SendToSocket(sock,ok,sizeof(ok));
end;

procedure tUIThread.doAddTask(at: tUISaddTask);
var ok:tALLok;
begin
LogEnterProc('tUIthread.doAddTask',LOG_LEVEL_MINOR);
try
try
//Code starts
ok.typ:=ALL_OK;
AddTask(table,at.id,at.ttype,at.pos);
SendToSocket(sock,ok,sizeof(ok));
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'tUIthread.doAddTask','Can''t add task');
end;
finally
  LogLeaveProc('tUIthread.doAddTask',LOG_LEVEL_MINOR,inttostr(at.pos));
end;
end;

procedure tUIThread.doAddBoy(ab: tUISaddBoy);
var ok:tALLok;
begin
LogEnterProc('tUIthread.doAddBoy',LOG_LEVEL_MINOR);
try
try
//Code starts
ok.typ:=ALL_OK;
AddBoy(table,ab.id);
SendToSocket(sock,ok,sizeof(ok));
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'tUIthread.doAddBoy');
end;
finally
  LogLeaveProc('tUIthread.doAddBoy',LOG_LEVEL_MINOR,inttostr(table.nboy));
end;
end;

procedure tUIThread.doDeleteSolution(ds: tUISdeleteSolution);
var doserror:integer;
    ok:tALLok;
    s:tsearchrec;
begin
LogEnterProc('tUIthread.doDeleteSolution',LOG_LEVEL_MINOR);
try
try
//Code starts
ok.typ:=ALL_OK;

if (ds.num<=0)or(ds.num>nsol) then
   raise eIJEerror.create('Can''t delete solution','','Strange solution number: %d',[ds.num]);
doserror:=findfirst(sol[ds.num].dir+'\'+sol[ds.num].fname+'.*',$3f,s);
while doserror=0 do begin
      logwrite(s.name+'...',LOG_LEVEL_MINOR);
      ForceNoFile(sol[ds.num].dir+'\'+s.name);
      doserror:=findnext(s);
end;
findclose(s);
SendToSocket(sock,ok,sizeof(ok));
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'tUIthread.doDeleteSolution');
end;
finally
  LogLeaveProc('tUIthread.doDeleteSolution',LOG_LEVEL_MINOR);
end;
end;

procedure tUIThread.doArchiveSolution(ar: tUISarchiveSolution);
var ok:tALLok;
begin
LogEnterProc('tUIThread.doArchiveSolution',LOG_LEVEL_MAJOR);
try
try
//Code starts
fillchar(ok,sizeof(ok),0);
ok.typ:=ALL_OK;

if mode and SMODE_REALTESTING=0 then
   raise exception.Create('Command ARCHIVE is disabled in non-RealTesting mode');
ArchiveSolution(sol[ar.num]);
SendToSocket(sock,ok,sizeof(ok));
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'tUIThread.doArchiveSolution');
end;
finally
  LogLeaveProc('tUIThread.doArchiveSolution',LOG_LEVEL_MAJOR);
end;
end;

procedure tUIThread.doRestoreSolution(rs:tUISrestoreSolution);
var ok:tALLok;
    rds:tSUIrestoredSolution;
    rec,rec1:tsearchrec;
    doserror:integer;
    b,d,t,ext:string;
    label 1;
begin
LogEnterProc('tUIThread.doRestoreSolution',LOG_LEVEL_MAJOR);
try
try
//Code starts
ok.typ:=ALL_OK;
fillchar(rds,sizeof(rds),0);
rds.typ:=SUI_RESTOREDSOLUTION;

logwriteln('('+rs.md+','+rs.mt+').('+rs.mb+','+rs.md+','+rs.mt+')...',LOG_LEVEL_MINOR);
doserror:=findfirst(cfg.archivep+maketask('*','*'),$10,rec);{dir}
try
while doserror=0 do begin
      if (rec.name<>'.')and(rec.name<>'..') then begin
         GetTaskInfo(rec.Name,d,t);
         d:=UpperCase(d);
         t:=UpperCase(t);
         if not (mask(rs.md,d) and mask(rs.mt,t)) then
            goto 1;
         doserror:=findfirst(cfg.archivep+rec.name+'\'+makesol('*','*','*','.*'),$3f,rec1);
         try
         while doserror=0 do begin
               getsolinfo(rec1.name,b,d,t,ext);
               b:=uppercase(b);
               d:=uppercase(d);
               t:=uppercase(t);
               if mask(rs.mb,b) and mask(rs.md,d) and mask(rs.mt,t) then begin
                  copyfile(cfg.archivep+rec.name+'\'+rec1.name,cfg.solp+'\'+rec1.name);
                  logwriteln(rec1.name+'... ',LOG_LEVEL_MINOR);
                  StrToArray(rds.fname,rec1.Name,sizeof(rds.fname));
                  SendToSocket(sock,rds,sizeof(rds));
               end;
               doserror:=findnext(rec1);
         end;
         finally
           findclose(rec1);
         end;
      end;
      1:doserror:=findnext(rec);
end;
finally
  findclose(rec);
end;

SendToSocket(sock,ok,sizeof(ok));
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'tUIThread.doRestoreSolution');
end;
finally
  LogLeaveProc('tUIThread.doRestoreSolution',LOG_LEVEL_MAJOR);
end;
end;

procedure tUIThread.doSetPoints(rs: tUISsetPoints);
var ok:tALLok;
begin
LogEnterProc('tUIThread.doSetPoints',LOG_LEVEL_MAJOR);
try
try
//Code starts
ok.typ:=ALL_OK;

if (rs.b<=0)or(rs.b>table.nboy) then
   raise exception.CreateFmt('Strange boy number: %d',[rs.b]);
if (rs.t<=0)or(rs.t>table.ntask) then
   raise exception.CreateFmt('Strange task number: %d',[rs.t]);
if (rs.k>1)or(rs.k<-1) then
   raise exception.CreateFmt('Strange position in table (third argument): %d',[rs.k]);
case rs.k of
     -1:table.t[rs.b,rs.t].minus:=rs.x;
     0:table.t[rs.b,rs.t].pts:=rs.x;
     1:table.t[rs.b,rs.t].res:=rs.x;
end;

SendToSocket(sock,ok,sizeof(ok));
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'tUIThread.doSetPoints');
end;
finally
  LogLeaveProc('tUIThread.doSetPoints',LOG_LEVEL_MAJOR);
end;
end;

type tIOItableCBdata=record
         table:psTableresult;
         inTesting:pBoolean;
         needArchive:boolean;
         sol:tSolData;
         UI:tUIthread;
      end;
      pIOItableCbdata=^tIOItableCBdata;

procedure IOItableCB(msg:pMSGbuffer;data:pIOItableCBdata);
var ts:pTCStestingFinished;
begin
if msg^.typ<>TCS_TESTINGFINISHED then
   exit;
if data=nil then
   exit;
ts:=pTCStestingFinished(msg);
if data^.table<>nil then begin
   data^.table^.pts:=ts^.pts;
   data^.table^.res:=ts^.res;
end;
if data^.inTesting<>nil then
   data^.inTesting^:=false;
if data^.needArchive then
   ArchiveSolution(data^.sol);
if data^.UI<>nil then
   data.UI.AutoSave;
Dispose(data);
end;

procedure tUIThread.doTestSolution(ts: tUIStestSolution);
var tt:tTestingTask;
    ok:tALLok;
    nb,nt:integer;
    wa:tALLwarning;
    data:pIOItableCBdata;
    inTesting:boolean;
begin
LogEnterProc('tUIThread.doTestSolution',LOG_LEVEL_MAJOR);
try
try
//Code starts
ok.typ:=ALL_OK;
fillchar(wa,sizeof(wa),0);
wa.typ:=ALL_WARNING;

if nClient=0 then
   raise exception.Create('No clients connected; can''t test');
if (ts.archive)and(mode and SMODE_REALTESTING=0) then
   raise exception.Create('Can''t run with ARCHIVE argument, as ARCHIVing is disabled in non-RealTesting mode');
tt.ts:=ts;
tt.sock:=sock;
tt.SolData:=sol[ts.num];
tt.real:=(mode and SMODE_REALTESTING<>0);
nb:=findboy(table,sol[ts.num].boy);
nt:=findtask(table,maketask(sol[ts.num].day,sol[ts.num].task));
if nb=0 then begin
   if mode and SMODE_AUTOADD<>0 then begin
      AddBoy(table,sol[ts.num].boy);
      nb:=findboy(table,sol[ts.num].boy);
   end else begin
       wa.text:='Unknown contestant';
       SendToSocket(sock,wa,sizeof(wa));
   end;
end;
if nt=0 then begin
   wa.text:='Unknown task';
   if mode and SMODE_AUTOADD<>0 then
      wa.text:='Unknown task. Note that mode AutoAdd does not mean automatically adding new tasks, only contestants!';
   SendToSocket(sock,wa,sizeof(wa));
end;
if mode and SMODE_REALTESTING=0 then begin
   wa.text:='Not in mode RealTesting';
   SendToSocket(sock,wa,sizeof(wa));
end;
if nt<>0 then
   tt.tasktype:=table.tasktype[nt]
else tt.TaskType:='P';
tt.CB:=@IOItableCB;

new(data);
tt.data:=data;
if nt*nb<>0 then
   data^.table:=@(table.t[nb,nt])
else data^.table:=nil;
if ts.synchro then begin
   inTesting:=true;
   data^.inTesting:=@inTesting;
end else data^.inTesting:=nil;
if mode and SMODE_REALTESTING<>0 then
   data^.UI:=self
else data^.UI:=nil;
data^.needArchive:=ts.archive;
data^.sol:=sol[ts.num];

TQthread.Add(tt);

SendToSocket(sock,ok,sizeof(ok));

if ts.synchro then //чтобы сервер не ждал сообщений от UI пока идет тестирование
   while inTesting do
         sleep(100);
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'tUIThread.doTestSolution');
end;
finally
  LogLeaveProc('tUIThread.doTestSolution',LOG_LEVEL_MAJOR);
end;
end;

procedure tUIThread.doAbout(ar: tUISaboutRequest);
var ab:tALLabout;
    s:string;
    i:integer;
    doserror:integer;
    rec:tSearchRec;
    dll:tHandle;
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
LogEnterProc('tUIThread.doAbout',LOG_LEVEL_MAJOR);
try
try
//Code starts
fillchar(ab,sizeof(ab),0);
ab.typ:=ALL_ABOUT;

s:='\$0f;Server\*;'#13;
s:=s+format('The Server exe file (%s) was compiled from revision %s, at %s',[paramstr(0),IJE_REV,IJE_COMPILETIME]);
if IJE_LOCALMODIF then
   s:=s+' (with local modifications)';
{$ifdef debug}
s:=s+#13+'\$0c;!!\$0f; The server was compiled in the DEBUG state';
{$endif}
s:=s+#13'\$0f;Availiable Table DLLs:\*;'#13;
doserror:=findfirst(cfg.dllp+'\table\*.dll',$3f,rec);
while doserror=0 do begin
      s:=s+rec.Name;
      if rec.name='table_'+cfg.tabledll+'.dll' then
         s:=s+'   \$0e;(def)\*;';
      try
        dll:=LoadDll(cfg.dllp+'\table\'+rec.Name);
        try
          _abProc:=LoadDLLproc(dll,'about');
          s:=s+'   '+abProc;
        finally
          FreeLibrary(dll);
        end;
      except
      end;
      s:=s+#13;
      doserror:=findnext(rec);
end;
findclose(rec);
for i:=1 to nClient do
    s:=s+#13+Client[i].about.text;
StrToArray(ab.text,s,sizeof(ab.text));
SendToSocket(Sock,ab,sizeof(ab));
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'tUIThread.doAbout');
end;
finally
  LogLeaveProc('tUIThread.doAbout',LOG_LEVEL_MAJOR);
end;
end;

procedure tUIThread.doMode(md: tUISmode);
var ma:tSUImodeAnswer;
begin
LogEnterProc('tUIThread.doMode',LOG_LEVEL_MAJOR);
try
try
//Code starts
fillchar(ma,sizeof(ma),0);
ma.typ:=SUI_MODEANSWER;

case md.cmd of
     -1:if md.mode<=MaxModeVal then
           mode:=mode and (not md.mode)
        else raise exception.CreateFmt('Unknown mode value %d',[md.mode]);
     1:if md.mode<=MaxModeVal then
           mode:=mode or md.mode
        else raise exception.CreateFmt('Unknown mode value %d',[md.mode]);
     0:;
     else raise exception.CreateFmt('Unknown Mode command %d',[md.cmd]);
end;
ma.mode:=mode;
SendToSocket(sock,ma,sizeof(ma));
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'tUIThread.doMode');
end;
finally
  LogLeaveProc('tUIThread.doMode',LOG_LEVEL_MAJOR,IntToStr(mode));
end;
end;

procedure tUIThread.AutoSave;
begin
AutoSaveLock.Enter;
try
if mode and SMODE_REALTESTING=0 then
   raise exception.Create('Internal error: can''t autosave in non-RealTesting mode');
io.SaveTable(table,ResFileName+'_autosave',cfg.tabledll);
finally
AutoSaveLock.Leave;
end;
end;

procedure tUIThread.doKillTask(kt: tUISkillTask);
var ka:tSUIKillTaskAnswer;
begin
fillchar(ka,sizeof(ka),0);
ka.typ:=SUI_KILLTASKANSWER;

ka.nkilled:=TQthread.kill(kt.task);
SendToSocket(sock,ka,sizeof(ka));
end;

procedure tUIThread.doShutDown;
var sa,sac:tALLshutDownAnswer;
    i:integer;
    sd:tALLshutDown;
begin
LogEnterProc('tUIThread.doShutDown',LOG_LEVEL_MAJOR);
try
try
//Code starts
fillchar(sa,sizeof(sa),0);
sa.typ:=ALL_SHUTDOWNANSWER;
fillchar(sd,sizeof(sd),0);
sd.typ:=ALL_SHUTDOWN;

for i:=1 to nClient do
    if client[i].status=_working then begin
       sa.ok:=false;
       StrToArray(sa.reason,'Some clients are working',sizeof(sa.reason));
       SendToSocket(Sock,sa,sizeof(sa));
       exit;
    end;
for i:=1 to nClient do begin
    SendToSocket(client[i].sock,sd,sizeof(sd));
    RecvFromSocket(client[i].sock,sac,sizeof(sac),0,sizeof(sac));
    if not sac.ok then begin
       sa.ok:=false;
       StrToArray(sa.reason,format('Can''t shutdown client %d: ',[i])+sac.reason,sizeof(sa.reason));
       SendToSocket(Sock,sa,sizeof(sa));
       exit;
    end;
end;
sa.ok:=true;
SendToSocket(Sock,sa,sizeof(sa));
Synchronize(Application.Terminate);
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'tUIThread.doShutDown');
end;
finally
  LogLeaveProc('tUIThread.doShutDown',LOG_LEVEL_MAJOR,BoolToStr(sa.ok));
end;
end;

procedure tUIThread.doRestart;
var ra,rac:tALLRestartAnswer;
    i:integer;
    rs:tALLRestart;
begin
LogEnterProc('tUIThread.doRestart',LOG_LEVEL_MAJOR);
try
try
//Code starts
fillchar(ra,sizeof(ra),0);
ra.typ:=ALL_RestartANSWER;
fillchar(rs,sizeof(rs),0);
rs.typ:=ALL_Restart;

for i:=1 to nClient do
    if client[i].status=_working then begin
       ra.ok:=false;
       StrToArray(ra.reason,'Some clients are working',sizeof(ra.reason));
       SendToSocket(Sock,ra,sizeof(ra));
       exit;
    end;
for i:=1 to nClient do begin
    SendToSocket(client[i].sock,rs,sizeof(rs));
    RecvFromSocket(client[i].sock,rac,sizeof(rac),0,sizeof(rac));
    if not rac.ok then begin
       ra.ok:=false;
       StrToArray(ra.reason,format('Can''t restart client %d: ',[i])+rac.reason,sizeof(ra.reason));
       SendToSocket(Sock,ra,sizeof(ra));
       exit;
    end;
end;
ra.ok:=true;
SendToSocket(Sock,ra,sizeof(ra));
chdir(IJEdir);
loadSettings(IJEdir+'\ije_cfg.xml',cfg);
nSol:=0;
Lookup(nsol,sol);
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'tUIThread.doRestart');
end;
finally
  LogLeaveProc('tUIThread.doRestart',LOG_LEVEL_MAJOR,BoolToStr(ra.ok));
end;
end;

end.
