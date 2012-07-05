{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O+,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ This file is part of IJE: the Integrated Judging Environment system }
{ (C) Kalinin Petr 2002-2008 }
{ $Id: Reports.dpr 202 2008-04-19 11:24:40Z *KAP* $ }
library Reports;               
uses ShareMem,WinSock,SyncObjs,SysUtils,
     iPlugin,sock,sock_ije,ijeconsts,xmlije;
type tTestingData=record
        used:boolean;
        rep:tReport;
        fname:string;
    end;
var lock:tCriticalSection;
    TestingData:array[1..MAX_TESTINGTASKS] of tTestingData;
    cfg:tSettings;

function FindTask(gtid:tGTID):integer;
var i:integer;
begin
result:=0;
for i:=1 to MAX_TESTINGTASKS do
    if TestingData[i].rep.gtid=gtid then
       result:=i;
end;

procedure TestingFinished(i:integer;var data);
var tf:tTCStestingFinished absolute data;
begin
with TestingData[i].rep do begin
     pts:=tf.pts;
     maxpts:=tf.max;
     res:=tf.res;
end;
ForceDirectories(cfg.reportsp+'\'+TestingData[i].rep.task);
SaveReport(cfg.reportsp+'\'+TestingData[i].rep.task+'\'+TestingData[i].fname,TestingData[i].rep);
TestingData[i].used:=false;
end;

procedure TestingInfo(i:integer;var data);
var ti:tTCStestingInfo absolute data;
begin
with TestingData[i].rep do begin
     task:=ti.problem;
     taskname:=ti.pname;
     tasktype:=ti.tasktype;
     tl:=ti.tl;
     ml:=ti.ml;
end;
end;

procedure TestingStarted(i:integer;var data);
var ts:tTCStestingStarted absolute data;
begin
TestingData[i].rep.nTests:=0;
end;

procedure TestResult(i:integer;var data);
var tr:tTCStestResult absolute data;
begin
with TestingData[i].rep do begin
     if nTests=-1 then
        comp.res:=tr.res
     else begin
       if nTests<tr.id then
          nTests:=tr.id;
       test[tr.id].res:=tr.res;
       test[tr.id].pts:=tr.pts;
       test[tr.id].maxpts:=tr.max;
       test[tr.id].text:=tr.text;
       test[tr.id].evaltext:=tr.evaltext;
       test[tr.id].time:=tr.time;
       test[tr.id].mem:=tr.mem;
     end;
end;
end;

procedure CompileStarted(i:integer;var data);
var cs:tTCScompileStarted absolute data;
begin
TestingData[i].rep.comp.cmdline:=cs.cmdline;
TestingData[i].rep.nTests:=-1;
end;

procedure CompilerOutput(i:integer;var data);
var co:tTCScompilerOutput absolute data;
begin
TestingData[i].rep.comp.text:=co.output;
end;

procedure CB(sock:tSocket;id:tSockCbid;len:integer;var data);
const nEvent=6;
const CBfunc:array[1..nEvent] of record
               typ:integer;proc:procedure (i:integer;var data);
             end=(
                  (typ:TCS_COMPILESTARTED;proc:CompileStarted),
                  (typ:TCS_COMPILEROUTPUT;proc:CompilerOutput),
                  (typ:TCS_TESTRESULT;proc:TestResult),
                  (typ:TCS_TESTINGFINISHED;proc:TestingFinished),
                  (typ:TCS_TESTINGSTARTED;proc:TestingStarted),
                  (typ:TCS_TESTINGINFO;proc:TestingInfo)
                  );
var msg:record typ:integer;gtid:tGTID end absolute data;
    ts:tSTCtestSolution absolute data;
    i:integer;
    nn:integer;
    ok:boolean;
begin
lock.Enter;
try
if (id=SOCKCB_SEND)and(msg.typ=STC_TESTSOLUTION) then begin
   if not ts.real then
      exit;
   for i:=1 to MAX_TESTINGTASKS do
       if not TestingData[i].used then begin
          TestingData[i].used:=true;
          TestingData[i].rep.gtid:=ts.gtid;
          TestingData[i].rep.boy:=ts.boy;
          TestingData[i].fname:=ts.fname+'.xml';
          exit;
       end;
   raise eIJEerror.Create('Internal Reports plugin error','Reports.dll::CB','Reports error: Not enough place for new testing task');
end;
if id=SOCKCB_RECV then begin
   ok:=false;
   for i:=1 to nEvent do
       if CBfunc[i].typ=msg.typ then
          ok:=true;
   if not ok then
      exit;
   nn:=Findtask(msg.gtid);
   if nn=0 then
      exit;
   for i:=1 to nEvent do
       if CBfunc[i].typ=msg.typ then
          CBfunc[i].proc(nn,data);
end;
finally
  lock.Leave;
end;
end;

function init(data:tPluginData):boolean;
begin
fillchar(TestingData,sizeof(TestingData),0);
Lock:=tCriticalSection.Create;
data.SetSockCB(SOCKCB_RECV,CB);
data.SetSockCB(SOCKCB_SEND,CB);
cfg:=data.cfg;
result:=true;
end;

exports
  init;

end.
