{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O+,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ This file is part of IJE: the Integrated Judging Environment system }
{ (C) Kalinin Petr 2002-2008 }
{ $Id: server_main.pas 205 2008-04-21 15:50:00Z *KAP* $ }
unit server_main;
interface
uses WinSock,Windows,SyncObjs,SysUtils,
     ije_server_1,ijeconsts,sock,sock_ije,io,ije_main;

type
  tTableCB=procedure (msg:pMSGbuffer;data:pointer);
  tTestingTask=record
    ts:tUIStestSolution;
    sock:tSocket;
    SolData:tSolData;
    TaskType:char;
    CB:tTableCB;
    data:pointer;
    real:boolean;
    killed:boolean;
  end;

  tTestingThread=class(twThread)
  public
    constructor Create(tt:tTestingTask;c:integer);
  protected
    procedure Execute; override;
  private
    tt:tTestingTask;
    c:integer;
  end;
    
  tTQthread=class(twThread)
  public
    procedure Add(a:tTestingTask);
    function Kill(id:string):integer;
    constructor Create(CreateSuspended:boolean);
  private
    task:array[1..MAX_TESTINGTASKS] of tTestingTask;
    l,r:integer;
    TaskLock:tCriticalSection;
  protected
    procedure Execute; override;
    function pred(a:integer):integer;
    function succ(a:integer):integer;
  end;
var TQThread:tTQthread;

implementation

{ tTQthread }

procedure tTQthread.Add(a:tTestingTask);
begin
TaskLock.Enter;
try
if l=pred(pred(r)) then
   raise eIJEerror.Create('','tTestingThread.Add: ','No place for new testing task');
l:=succ(l);
task[l]:=a;
task[l].killed:=false;
finally
TaskLock.Leave;
end;
end;

constructor tTQthread.Create(CreateSuspended: boolean);
begin
inherited Create(true);
l:=MAX_TESTINGTASKS;
r:=1;
TaskLock:=tCriticalSection.Create;
if not CreateSuspended then
   Self.Resume;
end;

procedure tTQthread.Execute;
var ct:tTestingTask;
    i:integer;
begin
writeln('Testing thread started');
while not terminated do begin
      if nFreeClients>0 then begin
         try
         TaskLock.Enter;
         ClientLock.Enter;
         try
           if l<>pred(r) then begin
              for i:=1 to nClient do
                  if client[i].status=_free then begin
                     if isPinging(client[i].sock) then begin
                        ct:=task[r];
                        r:=succ(r);
                        tTestingThread.Create(ct,i);
                        break;
                     end else begin
                         client[i].status:=_deleted;
                         writeln(format('Client %d is not pinging; deleted.',[i]));
                         dec(nFreeClients);
                     end;
                  end;
           end;
         finally
           ClientLock.Leave;
           TaskLock.Leave;
         end;
         except
           on e:exception do begin
              LogError(e);
              ShowError(e);
           end;
         end;
      end;
      sleep(100);
end;
end;

function tTQthread.Kill(id: string): integer;
var rr:integer;
begin
TaskLock.Enter;
try
result:=0;
rr:=r;
while l<>pred(rr) do begin
      if MakeTask(task[rr].soldata.day,task[rr].soldata.task)=id then begin
         task[rr].killed:=true;
         inc(result);
      end;
      rr:=succ(rr);
end;
finally
TaskLock.Leave;
end;
end;

function tTQthread.pred(a: integer): integer;
begin
if a=1 then
   result:=MAX_TESTINGTASKS
else result:=a-1;
end;

function tTQthread.succ(a: integer): integer;
begin
if a=MAX_TESTINGTASKS then
   result:=1
else result:=a+1;
end;

{ tTestingThread }

constructor tTestingThread.Create(tt: tTestingTask;c:integer);
begin
self.tt:=tt;
client[c].status:=_working;
dec(nFreeClients);
self.c:=c;
inherited Create(false);
sleep(100);
end;

procedure tTestingThread.Execute;
var ts:tSTCtestSolution;
    fname:array[1..1000] of string;
    rec:tsearchrec;
    doserror:integer;
    i:integer;
    msg:tMSGbuffer;
    len:integer;
    eee:eIJEerror;
    ee:tALLeIJEerror;
    tf:tTCStestingFinished;
begin
LogEnterProc('tTestingThread.Execute',LOG_LEVEL_MINOR);
try
try
//Code starts
try
fillchar(ts,sizeof(ts),0);
ts.typ:=STC_TESTSOLUTION;
ts.gtid:=tt.ts.gtid;
fillchar(ee,sizeof(ee),0);
ee.typ:=ALL_EIJEERROR;
fillchar(tf,sizeof(tf),0);
tf.typ:=TCS_TESTINGFINISHED;
tf.gtid:=tt.ts.gtid;

if tt.killed then
   exit;

StrToArray(ts.fname,tt.SolData.fname,sizeof(ts.fname));
StrToArray(ts.ext,tt.SolData.ext,sizeof(ts.ext));
ts.testset:=tt.ts.testset;
ts.args:=tt.ts.args;
ts.tasktype:=tt.tasktype;
ts.real:=tt.real;
StrToArray(ts.problem,MakeTask(tt.SolData.day,tt.SolData.task),sizeof(ts.problem));
StrToArray(ts.boy,tt.SolData.boy,sizeof(ts.boy));

ts.nFiles:=0;
doserror:=findfirst(tt.soldata.dir+'\'+tt.soldata.fname+'.*',$2f,rec);{Not dir!}
while doserror=0 do begin
      inc(ts.nFiles);
      fname[ts.nFiles]:=rec.Name;
      doserror:=findnext(rec);
end;
findclose(rec);

SendToSocket(client[c].sock,ts,sizeof(ts));
for i:=1 to ts.nFiles do
    SendFileToSocket(Client[c].sock,tt.soldata.dir+'\'+fname[i]);

repeat
  try
    len:=RecvFromSocket(Client[c].sock,msg,sizeof(msg),0,0,60);
  except
    on e:exception do begin
       LogError(e);
       LogWriteln('An error occured; exiting from tTestingThread.Execute',LOG_LEVEL_MAJOR);
       eee:=eIJEerror.CreateAppendPath(e,'tTestingThread.Execute','Error on server side while listening for TC answer');
       eee.message:=eee.message+' ! IJE will work wrongly now; you''d better fix the problem and restart IJE';
       StrToArray(ee.name,eee.name,sizeof(ee.name));
       StrToArray(ee.procpath,eee.ProcPath,sizeof(ee.ProcPath));
       StrToArray(ee.text,eee.Message,sizeof(ee.text));
       tf.pts:=0;
       tf.max:=0;
       tf.res:=_fl;
       try
         tt.CB(@tf,tt.data);
         if tt.ts.synchro then begin
            SendToSocket(tt.sock,ee,sizeof(ee));
            SendtoSocket(tt.sock,tf,sizeof(tf));
         end;
       except end;
       break;
    end;
  end;
  try
    LogWrite(IntToStr(msg.typ)+'...',LOG_LEVEL_MAJOR);
    tt.CB(@msg,tt.data);
    LogWrite('CB done...',LOG_LEVEL_MAJOR);
    if tt.ts.synchro then
       SendToSocket(tt.sock,msg,len);
  except
    on e:exception do begin
       LogError(e);
       eee:=eIJEerror.CreateAppendPath(e,'tTestingThread.Execute','Internal server error while processing TC answer');
       eee.Message:=eee.Message+' ! IJE will try to work as best as it can, but you''d better fix the problem and restart IJE';
       NonModalShowError(eee);
    end;
  end;
  if msg.typ=TCS_TESTINGFINISHED then
     break;
  if tt.ts.synchro then begin
     try
       len:=RecvFromSocket(tt.Sock,msg,sizeof(msg),0,0,0,1000);
       SendToSocket(Client[c].sock,msg,len);
     except end;
  end;
until false;

finally
  client[c].status:=_free;
  inc(nFreeClients);
end;
//Code ends
except
  on e:exception do begin
     LogError(e);
     ShowError(e);
  end;
end;
finally
  LogLeaveProc('tTestingThread.Execute',LOG_LEVEL_MINOR);
end;
end;

end.



