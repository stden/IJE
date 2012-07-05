{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O-,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ This file is part of IJE: the Integrated Judging Environment system }
{ (C) Kalinin Petr 2002-2008 }
{ $Id: Sock.pas 202 2008-04-19 11:24:40Z *KAP* $ }
unit sock;
interface
uses Windows,WinSock;
const MAX_SOCK_CB=50;
type tSockCBid=(SOCKCB_CONNECT,SOCKCB_SEND,SOCKCB_RECV,SOCKCB_SENDFILE,SOCKCB_RECVFILE);
     tSockCB=procedure (sock:tSocket;id:tSockCBid;len:integer;var msg);
type tSockConnectData=record//it will be the msg parameter for SOCKCB_CONNECT
       ip:in_addr;port:integer
     end;

procedure RecvTime(s:TSocket;var Buf;len,flags:Integer;WaitSec:integer=1;mkSec:Integer=0);

procedure ConnectSocket(var sock:tSocket;ip:in_addr;port:integer);
procedure SendToSocket(sock:tSocket;var buf;len:integer);
function RecvFromSocket(sock:tSocket;var buf;len,flags:integer;minlen:integer=0;WaitSec:integer=1;mkSec:Integer=0):integer; //returns length readen
procedure RecvFileFromSocket(sock:tSocket;path:string;WaitSec:integer=1;mkSec:Integer=0);
procedure SendFileToSocket(sock:tSocket;fname:string);
function CreateSocket(stype:integer):tSocket;

procedure SetSockCB(id:tSockCBid;f:tSockCB);

implementation
uses SysUtils,ijeconsts,sock_ije;
type tFileName=array[0..63] of char;
type tSockCBs=record
                n:integer;
                cb:array[1..50] of tSockCB;
              end;
var SockCB:array[SOCKCB_CONNECT..SOCKCB_RECVFILE] of tSockCBs;

procedure CallCb(id:tSockCBid;sock:tSocket;len:integer;var msg);
var i:integer;
begin
LogEnterProc('CallCb',LOG_LEVEL_MINOR);
try
try
//Code starts
for i:=1 to SockCB[id].n do
    try
      SockCb[id].cb[i](sock,id,len,msg);
    except
      on e:exception do
         raise eIJEerror.CreateAppendPath(e,format('Proc #%d',[i]));
    end;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'CallCb');
end;
finally
  LogLeaveProc('CallCb',LOG_LEVEL_MINOR);
end;
end;

procedure RecvTime(s:TSocket;var Buf;len,flags:Integer;WaitSec:integer=1;mkSec:integer=0);
var wFDS:tFDset;
    time:tTimeVal;
    ptime:pTimeVal;
    getBuf:array[0..100] of char;
    WantRead:integer;
    sr:integer;
    posp:pointer;
    pos:integer absolute posp;
    lread:integer;
begin
LogEnterProc('RecvTime',LOG_LEVEL_MINOR);
try
try
//Code starts
if WaitSec+mkSec>0 then begin
   time.tv_usec:=mkSec;
   time.tv_sec:=WaitSec;
   ptime:=@time
end else
   ptime:=nil;
sr:=0;
posp:=@buf;
while sr<len do begin
  FD_ZERO(wfds);
  FD_SET(s,wfds);
  select(0,@wfds,nil,nil,ptime);
  if wfds.fd_count=0 then begin
     SetLastError(WSAETIMEDOUT);
     raise eIJEerror.CreateWin('Error while recieving data','select: ');
  end;
  if sizeof(getbuf)>len-sr then
     WantRead:=len-sr
  else WantRead:=sizeof(getbuf);
  lread:=recv(S,getBuf[0],WantRead,0);
  if lread=SOCKET_ERROR then
     raise eIJEerror.CreateWin('Error while recieving data','recv: ');
  if lread=0 then
     raise eIJEerror.Create('Error while recieving data','recv: ','0 bytes recieved');
  move(getBuf,posp^,lread);
  pos:=pos+lread;
  sr:=sr+lread;
end;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'RecvTime');
end;
finally
  LogLeaveProc('RecvTime',LOG_LEVEL_MINOR);
end;
end;

procedure ConnectSocket(var sock:tSocket;ip:in_addr;port:integer);
var addr:TSockAddr;
    d:tSockConnectData;
begin
Sock := socket(AF_INET,SOCK_STREAM,IPPROTO_IP);
if Sock = INVALID_SOCKET then
   raise eIJEerror.createWin('Can''t connect to socket','ConnectSocket: socket: ');
FillChar(addr,SizeOf(addr),0);
addr.sin_family:=AF_INET;
addr.sin_port:=htons(Port);
addr.sin_addr:=ip;
if connect(Sock,addr,SizeOf(TSockAddr))=SOCKET_ERROR then
   raise eijeError.CreateWin('Can''t connect to socket','ConnectSocket: connect: ');

d.ip:=ip;
d.port:=port;
CallCb(SOCKCB_CONNECT,sock,sizeof(d),d);
end;

procedure SendToSocket(sock:tSocket;var buf;len:integer);
var lsent:integer;
begin
LogEnterProc('SendToSocket',LOG_LEVEL_MINOR,'len='+inttostr(len));
try
try
//Code starts
if len>sizeof(tMSGbuffer) then
   raise exception.CreateFmt('Too long message: len=%d',[len]);
if send(Sock,len,sizeof(integer),0)<>sizeof(integer) then
   raise eIJEerror.CreateWin('Can''t send data to socket','send(header): ');
if len<>0 then
   lsent:=send(Sock,buf,len,0)
else lsent:=0;
if lsent<>len then
   raise eIJEerror.Create('Can''t send data to socket','send(data): ',Format('Sent %d, had to send %d',[lsent,len]));

CallCb(SOCKCB_SEND,sock,len,buf);
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'SendToSocket');
end;
finally
  LogLeaveProc('SendToSocket',LOG_LEVEL_MINOR);
end;
end;

function RecvFromSocket(sock:tSocket;var buf;len,flags:integer;minlen:integer=0;WaitSec:integer=1;mkSec:Integer=0):integer;
var rLen:integer;
    a:pointer;
begin
LogEnterProc('sock.RecvFromSocket',LOG_LEVEL_MINOR);
try
try
//Code starts
ijeAssert(flags=0,'sock.RecvFromSocket can''t accept flags<>0 (%d given)',[flags]);
RecvTime(sock,rLen,sizeof(integer),flags,WaitSec,mkSec);
result:=rLen;
try
  if (rLen>len) then
     raise eIJEerror.Create('Can''t recv data from socket','','Recieved length %d is greater then maximum expected %d',[rlen,len]);
  if (rLen<minlen) then
     raise eIJEerror.Create('Can''t recv data from socket','','Recieved length %d is smaller then minimum expected %d',[rlen,minlen]);
except // чтобы не потерять синхронизацию с отправителем
  getMem(a,rLen);
  RecvTime(sock,a,rLen,flags,WaitSec,mkSec);
  FreeMem(a);
  raise;
end;
RecvTime(sock,buf,rLen,flags,WaitSec,mkSec);

CallCb(SOCKCB_RECV,sock,rLen,buf);
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'sock.RecvFromSocket');
end;
finally
  LogLeaveProc('sock.RecvFromSocket',LOG_LEVEL_MINOR,IntToStr(result));
end;
end;

procedure RecvFileFromSocket(sock:tSocket;path:string;WaitSec:integer=1;mkSec:Integer=0);
var a:tFileName;
    rLen:integer;
    buf:pointer;
    f:file;
    fullname:array[0..1023] of char;
begin
LogEnterProc('RecvFileFromSocket',LOG_LEVEL_MINOR);
try
try
//Code starts
RecvTime(sock,a,sizeof(a),0,WaitSec,mkSec);
RecvTime(sock,rLen,sizeof(integer),0,WaitSec,mkSec);
if (rLen<0) then
   raise eIJEerror.Create('Can''t recv file from socket','','Recieved length %d is negative',[rlen]);
GetMem(buf,rLen);
RecvTime(sock,buf^,rLen,0,WaitSec,mkSec);
assign(f,path+'\'+a);rewrite(f,1);
blockwrite(f,buf^,rLen);
close(f);
FreeMem(buf);

StrToArray(fullname,path+'\'+a,sizeof(fullname));
CallCb(SOCKCB_RECVFILE,sock,sizeof(fullname),fullname);
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'RecvFileFromSocket');
end;
finally
  LogLeaveProc('RecvFileFromSocket',LOG_LEVEL_MINOR);
end;
end;

procedure SendFileToSocket(sock:tSocket;fname:string);
var a:tFileName;
    Len:integer;
    buf:pointer;
    f:file;
    ff:string;
    fullname:array[0..1023] of char;
begin
LogEnterProc('SendFileToSocket',LOG_LEVEL_MINOR);
try
try
//Code starts
ff:=ExtractFileName(fname);
if length(ff)>sizeof(a)-1 then
   raise eIJEerror.Create('Can''t send file to socket','','Can''t send file to socket: filename "%s" too long',[ff]);
StrToArray(a,ff,sizeof(a));

assign(f,fname);reset(f,1);
len:=FileSize(f);
GetMem(buf,len);
blockread(f,buf^,len);
close(f);

send(sock,a,sizeof(a),0);
send(sock,len,sizeof(integer),0);
send(sock,buf^,Len,0);

FreeMem(buf);

StrToArray(fullname,fname,sizeof(fullname));
CallCb(SOCKCB_SENDFILE,sock,sizeof(fullname),fullname);
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'SendFileToSocket');
end;
finally
  LogLeaveProc('SendFileToSocket',LOG_LEVEL_MINOR);
end;
end;

function CreateSocket(stype:integer):tSocket;
const a:integer=1;
begin
LogEnterProc('CreateSocket',LOG_LEVEL_MINOR);
try
try
//Code starts
result:=socket(AF_INET,stype,IPPROTO_IP);
if result=INVALID_SOCKET then
   raise eIJEerror.CreateWin('Can''t create socket','');
if stype=SOCK_STREAM then
   if SetSockOpt(result,SOL_SOCKET,SO_KEEPALIVE,@a,sizeof(integer))=SOCKET_ERROR then
      raise eIJEerror.CreateWin('Can''t set SO_KEEPALIVE','SetSocketOpt: ');
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'CreateSocket');
end;
finally
  LogLeaveProc('CreateSocket',LOG_LEVEL_MINOR);
end;
end;

procedure SetSockCB(id:tSockCBid;f:tSockCB);
begin
LogEnterProc('SetSockCB',LOG_LEVEL_MINOR);
try
try
//Code starts
with SockCB[id] do begin
    if n>=MAX_SOCK_CB then
       raise exception.CreateFmt('Not enough place for Socket CB id %d',[ord(id)]);
    inc(n);
    cb[n]:=f;
end;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'SetSockCB');
end;
finally
  LogLeaveProc('SetSockCB',LOG_LEVEL_MINOR);
end;
end;

begin
fillchar(SockCB,sizeof(SockCB),0);
end.
