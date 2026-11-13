{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O-,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ This file is part of IJE: the Integrated Judging Environment system }
{ (C) Kalinin Petr 2002-2008 }
{ $Id: sock_ije.pas 203 2008-04-19 11:41:24Z *KAP* $ }
unit sock_ije;
interface
uses WinSock,
     sock,ijeconsts,xmlije,ije_crt32;

var   SERVER_DGRAM_PORT:word=$ABC0;
      SERVER_STREAM_PORT:word=$ABC1;
      TC_DGRAM_PORT:word=$ABC2;
      TC_STREAM_PORT:word=$ABC3;
      UI_DGRAM_PORT:word=$ABC4;
      UI_STREAM_PORT:word=$ABC5;

const SOCKIJE_PINGTIME=1000000;//mksec

const IJE_TYPE_UI=1;
      IJE_TYPE_SERVER=2;
      IJE_TYPE_TC=3;
      TypeToString:array[1..3] of string=('UI','Server','TC');

      ALL_CONNECTANSWER=1;
      STC_TESTSOLUTION=2;
      TCS_COMPILEROUTPUT=3;
      TCS_TESTRESULT=4;
      TCS_TESTINGFINISHED=5;
      TCS_TESTINGSTARTED=6;
      TCS_COMPILESTARTED=7;
//      TCS_EVALSTARTED=29;
//      ALL_ERROR=7; //now use ALL_EIJEERROR!
      ALL_USERBREAK=8;
      UIS_LOOKUP=9;
      SUI_LOOKUPANSWER=10;
      SUI_LOOKUPSOLDATA=11;
      UIS_UPDATETABLE=12;
      SUI_UPDATEANSWER=13;
      SUI_TBNAME=14;
      UIS_LOADTABLE=15;
      ALL_EIJEERROR=16;
      ALL_OK=17;
      UIS_SAVETABLE=18;
      UIS_CLEANTABLE=19;
      UIS_ADDTASK=20;
      UIS_ADDBOY=21;
      UIS_DELETESOLUTION=22;
      UIS_ARCHIVESOLUTION=23;
      UIS_RESTORESOLUTION=24;
      SUI_RESTOREDSOLUTION=25;
      UIS_SETPOINTS=26;
      UIS_TESTSOLUTION=27;
      ALL_WARNING=28;
      TCS_EVALSTARTED=29;
      TCS_TESTINGSTATUS=30;
      ALL_PING=31;
      ALL_PINGANSWER=32;
      UIS_ABOUTREQUEST=33;
      ALL_ABOUT=34;
      UIS_MODE=35;
      SUI_MODEANSWER=36;
      TCS_TESTINGINFO=37;
      UIS_KILLTASK=38;
      SUI_KILLTASKANSWER=39;
      ALL_SHUTDOWN=40;
      ALL_SHUTDOWNANSWER=41;
      ALL_RESTART=42;
      ALL_RESTARTANSWER=43;

      MAX_DATA_LEN=sizeof(ttable)+10;//будем считать, что ничего длиннее передавать не будем
type //Never use string in these records!!!
     tProblemId=array[0..MaxNameLen] of char;
     tProblemName=array[0..127] of char;
     tBoyId=array[0..MaxNameLen] of char;
     tFileName=array[0..MaxFNameLen] of char;
     tCompileArgs=array[0..63] of char;
     tDGramInfo=record
         client:byte;
         ver:byte;
         ip:in_addr;
         port:word;
         name:array[0..63] of char;
        end;
      tMsgBuffer=record
          typ:integer;
          data:array[0..MAX_DATA_LEN] of char;
        end;
      pMSGbuffer=^tMSGbuffer;
      tSTCconnectAnswer=record
         typ:integer;
         ok:boolean;
         reason:array[0..63] of char;
      end;
      tSTCtestSolution=record
         typ:integer;
         gtid:tGTID;
         fname:tFileName;
         ext:array[0..10] of char;
         testset:tTestSet;
         args:tCompileArgs;
         tasktype:char;
         problem:tProblemId;
         boy:tBoyID;
         nFiles:integer;
         real:boolean;
      end;
      pSTCtestSolution=^tSTCtestSolution;
      tTCScompilerOutput=record
         typ:integer;
         gtid:tGTID;
         output:array[0..MAX_DATA_LEN-sizeof(tGTID)] of char;
      end;
      pTCScompilerOutput=^tTCScompilerOutput;
      tTCStestResult=record
         typ:integer;
         gtid:tGTID;
         id:integer;
         res:tresult;
         text:array[0..100] of char;
         evaltext:array[0..100] of char;
         pts:integer;
         max:integer;
         time:double;
         mem:integer;
      end;
      pTCStestResult=^tTCSTestResult;
      tTCStestingFinished=record
         typ:integer;
         gtid:tGTID;
         pts:integer;
         max:integer;
         res:tResult;
      end;
      pTCSTestingFinished=^tTCStestingFinished;
      tTCStestingStarted=record
         typ:integer;
         gtid:tGTID;
      end;
      pTCStestingStarted=^tTCStestingStarted;
      tTCScompileStarted=record
         typ:integer;
         gtid:tGTID;
         fname:tFileName;
         cmdline:array[0..127] of char;
      end;
      pTCScompileStarted=^tTCScompileStarted;
      //tTCSevalStarted is below
{      tALLerror=record
         typ:integer;
         text:array[0..511] of char;
      end;
      pALLerror=^tALLerror;}
      tALLuserBreak=record
         typ:integer;
      end;
      pALLuserBreak=^tALLuserBreak;
      tUISlookup=record
         typ:integer;
      end;
      pUISlookup=^tUISlookup;
      tSUIlookupAnswer=record
         typ:integer;
         nsol:integer;
      end;
      pSUIlookupAnswer=^tSUIlookupAnswer;
      tSUIlookupSolData=record
         typ:integer;
         boy,day,task,ext:array[0..maxNamelen] of char;
         fname:tFileName;
      end;
      tUISupdateTable=record
         typ:integer;
      end;
      pUISupdateTable=^tUISupdateTable;
      tSUIupdateAnswer=record
         typ:integer;
         nboy,ntask:integer;
         stable:tstable;
         tasktype:ttasktypes;
         ResFileName:array[0..63] of char;
      end;
      pSUIupdateAnswer=^tSUIupdateAnswer;
      tSUItbName=record
         typ:integer;
         name:array[0..maxNamelen] of char;
      end;
      pSUItbName=^tSUItbName;
      tUISloadTable=record
         typ:integer;
         fname:array[0..63] of char;
         dll:array[0..63] of char;
      end;
      pUISloadTable=^tUISloadTable;
      tALLeIJEerror=record
          typ:integer;
          name:array[0..127] of char;
          procpath:array[0..255] of char;
          text:array[0..511] of char;
      end;
      pALLeIJEerror=^tALLeIJEerror;
      tALLok=record
          typ:integer;
      end;
      pALLok=^tALLok;
      tUISsaveTable=record
         typ:integer;
         fname:array[0..63] of char;
         dll:array[0..63] of char;
      end;
      pUISsaveTable=^tUISsaveTable;
      tUIScleanTable=record
         typ:integer;
      end;
      pUIScleanTable=^tUIScleanTable;
      tUISaddTask=record
         typ:integer;
         id:tProblemId;
         ttype:char;
         pos:integer;
      end;
      pUISaddTask=^tUISaddTask;
      tUISaddBoy=record
         typ:integer;
         id:tBoyId;
      end;
      pUISaddBoy=^tUISaddBoy;
      tUISdeleteSolution=record
         typ:integer;
         num:integer;
      end;
      pUISdeleteSolution=^tUISdeleteSolution;
      tUISarchiveSolution=record
         typ:integer;
         num:integer;
      end;
      pUISarchiveSolution=^tUISarchiveSolution;
      tUISrestoreSolution=record
         typ:integer;
         mb:tBoyId;
         md,mt:tBoyId;
      end;
      pUISrestoreSolution=^tUISrestoreSolution;
      tSUIrestoredSolution=record
        typ:integer;
        fname:tFileName;
      end;
      tUISsetPoints=record
        typ:integer;
        b,t:integer;
        k:integer;
        x:integer;
      end;
      pUISsetPoints=^tUISsetPoints;
      tUIStestSolution=record
        typ:integer;
        gtid:tGTID;
        num:integer;
        testset:tTestSet;
        args:tCompileArgs;
        synchro:boolean;
        archive:boolean;
      end;
      pUIStestSolution=^tUIStestSolution;
      tALLwarning=record
        typ:integer;
        text:array[0..511] of char;
      end;
      pALLwarning=^tALLwarning;
      tTCSevalStarted=record
         typ:integer;
         gtid:tGTID;
      end;
      pTCSevalStarted=^tTCSevalStarted;
      tTCStestingStatus=record
         typ:integer;
         gtid:tGTID;
         id:integer;
         status:(_started,_copy,_run,_copyoutput,_check);
         time:double;
         totalTime:double;
         mem:integer;
         peakMem:integer;         
      end;
      pTCStestingStatus=^tTCStestingStatus;
      tALLping=record
         typ:integer;
      end;
      pALLping=^tALLping;
      tALLpingAnswer=tALLping;
      pALLpingAnswer=pALLping;
      tUISaboutRequest=record
         typ:integer;
      end;
      pUISaboutRequest=^tUISaboutRequest;
      tALLabout=record
         typ:integer;
         text:array[0..4095] of char;
      end;
      pALLabout=^tALLabout;
      tUISmode=record
         typ:integer;
         cmd:shortint;
         mode:integer;
      end;
      pUISmode=^tUISmode;
      tSUImodeAnswer=record
         typ:integer;
         mode:integer;
      end;
      pSUImodeAnswer=^tSUImodeAnswer;
      tTCStestingInfo=record
         typ:integer;
         gtid:tGTID;
         fname:tFileName;
         problem:tProblemId;
         pname:tProblemName;
         tasktype:char;
         tests:integer;
         max:integer;
         inf:tFileName;
         ouf:tFileName;
         tl:integer;
         ml:integer;
      end;
      pTCStestingInfo=^tTCStestingInfo;
      tUISkillTask=record
         typ:integer;
         task:tProblemId;
      end;
      pUISkillTask=^tUISkillTask;
      tSUIkillTaskAnswer=record
         typ:integer;
         nkilled:integer;
      end;
      pSUIkillTaskAnswer=^tSUIkillTAskAnswer;
      tALLshutDown=record
         typ:integer;
      end;
      pALLshutDown=^tALLshutDown;
      tALLshutDownAnswer=record
         typ:integer;
         ok:boolean;
         reason:array[0..100] of char;
      end;
      pALLshutDownAnswer=^tALLshutDownAnswer;
      tALLrestart=record
         typ:integer;
      end;
      pALLrestart=^tALLrestart;
      tALLrestartAnswer=record
         typ:integer;
         ok:boolean;
         reason:array[0..100] of char;
      end;
      pALLrestartAnswer=^tALLrestartAnswer;


const MAX_FLAGS=1;
      SOCK_ACCEPTERROR=1;
      {$ifdef debug}
      MAX_CONNECT_ATTEMPTS=1;
      {$else}
      MAX_CONNECT_ATTEMPTS=10;
      {$endif}
var ServerInfo,myInfo:tDGramInfo;

function IsPinging(var sock:tSocket):boolean;
function RecvFromSocket(s:tSocket;var buf;len,flags:integer;minlen:integer=0;WaitSec:integer=1;mkSec:Integer=0):integer; //returns length readen
function GetMyIP:in_addr;
procedure ConnectToServer(var Sock:tSocket);
procedure LookForServers(dgram_port:word);

implementation
uses SysUtils;

function IsPinging(var sock:tSocket):boolean;
var p:tALLping;
begin
LogEnterProc('IsPinging',LOG_LEVEL_MINOR);
try
try
//Code starts
fillchar(p,sizeof(p),0);
p.typ:=ALL_PING;

result:=true;
try
  SendToSocket(sock,p,sizeof(p));
  RecvFromSocket(sock,p,sizeof(p),0,sizeof(p),0,SOCKIJE_PINGTIME);// 0.1 sec
  if p.typ<>ALL_PINGANSWER then
     raise exception.Create('');
except
  result:=false;
end;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'IsPinging');
end;
finally
  LogLeaveProc('IsPinging',LOG_LEVEL_MINOR,BoolToStr(result));
end;
end;

function RecvFromSocket(s:tSocket;var buf;len,flags:integer;minlen:integer=0;WaitSec:integer=1;mkSec:Integer=0):integer;
var rLen:integer;
    msg:tMSGbuffer;
    err:tALLeIJEerror absolute msg;
    procpath:string;
begin
LogEnterProc('sock_ije.RecvFromSocket',LOG_LEVEL_MINOR);
try
try
//Code starts
procpath:='sock_ije.RecvFromSocket';
ijeAssert(flags<=MAX_FLAGS,'sock_ije.RecvFromSocket can''t accept flags>%d (%d given)',[MAX_FLAGS,flags]);
rLen:=sock.RecvFromSocket(s,msg,sizeof(msg),0,0,WaitSec,mkSec);
if flags and SOCK_ACCEPTERROR<>0 then
   if msg.typ=ALL_EIJEERROR then begin
      procpath:='\$0f;Exception recieved from socket\*;';//will be appended after //Code ends
      raise eIJEerror.Create(err.name,err.procpath,err.text);
   end;
if (rLen>len) then
   raise eIJEerror.Create('Can''t recv data from socket','','Recieved length %d is greater then maximum expected %d',[rlen,len]);
if (rLen<minlen) then
   raise eIJEerror.Create('Can''t recv data from socket','','Recieved length %d is smaller then minimum expected %d',[rlen,minlen]);
move(msg,buf,rLen);
result:=rLen;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,procpath);
end;
finally
  LogLeaveProc('sock_ije.RecvFromSocket',LOG_LEVEL_MINOR,IntToStr(result));
end;
end;

function GetMyIP:in_addr;
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
result.S_addr:=IPs^[1]^;
writeln('Now choosing IP '+inet_ntoa(result));
end;

procedure LookForServers;
var DGramSocket:tHandle;
    info:tDGramInfo;
    a:integer;
    ok:boolean;
    addr,myaddr:sockaddr_in;
    i:integer;
    last:eIJEerror;
begin
addr.sin_family:=AF_INET;
addr.sin_port:=htons(SERVER_DGRAM_PORT);
if Myinfo.ip.S_addr=inet_addr('127.0.0.1') then
   addr.sin_addr.S_addr:=inet_addr('127.0.0.1')
else addr.sin_addr.S_addr:=inet_addr('255.255.255.255');//почему-то broadcast'ы не идут, когда "сетевой кабель не подключен"
writeln('Looking for servers at IPs '+inet_ntoa(addr.sin_addr));

//DGramSocket:=socket(AF_INET,SOCK_DGRAM,IPPROTO_IP);
DGramSocket:=CreateSocket(SOCK_DGRAM);
try
a:=1;
SetSockOpt(DGramSocket,SOL_SOCKET,SO_BROADCAST,@a,sizeof(integer));
myaddr.sin_family:=AF_INET;
myaddr.sin_port:=htons(dgram_port);
myaddr.sin_addr.S_addr:=INADDR_ANY;
bind(DGramSocket,myaddr,sizeof(myaddr));

info:=myInfo;
info.port:=dgram_port;

a:=0;
for i:=1 to MAX_CONNECT_ATTEMPTS do begin
    ok:=true;
    try
      sendto(DGramSocket,info,sizeof(info),0,addr,sizeof(addr));
      RecvTime(DGramSocket,Serverinfo,sizeof(ServerInfo),0,0,500000);
    except
      on e:Exception do begin
         last:=eIJEerror.CreateAppendPath(e,'LookForServers');
         ok:=false;
      end;
    end;
    if ok then
       break;
end;
if not ok then begin
   last.name:='Error while looking for servers';
   raise last;
end;
writeln(format('Found server ''%s'' (%s:$%x).',[ServerInfo.name,inet_ntoa(ServerInfo.ip),ServerInfo.port]));
finally
closesocket(DGramSocket);
end;
end;

procedure ConnectToServer(var Sock:tSocket);
var ans:tSTCconnectAnswer;
begin
LogEnterProc('ConnectToServer',LOG_LEVEL_MAJOR);
try
try
  writeln('Connecting to server...');
  ConnectSocket(Sock,ServerInfo.ip,ServerInfo.port);
  send(sock,myInfo,sizeof(myInfo),0);
  RecvTime(sock,ServerInfo,sizeof(ServerInfo),0);
  RecvFromSocket(sock,ans,sizeof(ans),0,sizeof(ans));
  IJEassert(ans.ok,'Server rejected connection: '+ans.reason);
  writeln(format('Connected to server ''%s'' (%s:$%x)',[ServerInfo.name,inet_ntoa(ServerInfo.ip),serverinfo.port]));
  LogWriteln(format('Connected to server ''%s'' (%s:$%x)',[ServerInfo.name,inet_ntoa(ServerInfo.ip),serverinfo.port]),LOG_LEVEL_MAJOR);
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'ConnectToServer','Can''t connect to server');
end;
finally
  LogLeaveProc('ConnectToServer',LOG_LEVEL_MAJOR);
end;
end;

begin
end.
