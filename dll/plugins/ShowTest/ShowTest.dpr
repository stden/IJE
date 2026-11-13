{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O+,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ This file is part of IJE: the Integrated Judging Environment system }
{ (C) Kalinin Petr 2002-2008 }
{ $Id: ShowTest.dpr 204 2008-04-20 17:20:31Z *KAP* $ }
library Showtest;
uses ShareMem,WinSock,SysUtils,SyncObjs,
     ijeconsts,iPlugin,sock,sock_ije,xmlije;
type tTestingData=record
        used:boolean;
        ts:tSTCtestSolution;
        ti:tTCStestingInfo;
    end;
const nummod=100000;
      numdig=5;
var path:string;
    TestingData:array[1..MAX_TESTINGTASKS] of tTestingData;
    lock:tCriticalSection;
    num:integer=0;

procedure SendToProg(td:tTestingData;tr:tTCStestResult);
var fn:string;
    str:tShowtestTestResult;
begin
inc(num);
num:=num mod nummod;
fn:=format('%s\%s_%s_%0.3d_%0.5d_%0.6d.test',
      [path,td.ts.boy,td.ts.problem,tr.id,num,random(1000000)]);
str.boy:=td.ts.boy;
str.problem:=td.ts.problem;
str.pname:=td.ti.pname;
str.id:=tr.id;
str.res:=tr.res;
str.pts:=tr.pts;
str.max:=tr.max;
try
  SaveShowtesttestResult(fn,str);
except
  on e:exception do
     raise eIJEerror.Create('Showttest path not found','SaveShowtesttestResult('+fn+'): ',e.message+'; Probably, wrong path specified in ShowTest plugin settings');
end;
end;

procedure CB(sock:tSocket;id:tSockCbid;len:integer;var data);
var msg:tMSGbuffer absolute data;
    ts:tSTCtestSolution absolute data;
    ti:tTCStestingInfo absolute data;
    tf:tTCStestingFinished absolute data;
    tr:tTCStestResult absolute data;
    i:integer;
    was:boolean;
begin
lock.Enter;
try
if (id=SOCKCB_SEND)and(msg.typ=STC_TESTSOLUTION) then begin
   for i:=1 to MAX_TESTINGTASKS do
       if not TestingData[i].used then begin
          TestingData[i].used:=true;
          TestingData[i].ts:=ts;
          exit;
       end;
   raise eIJEerror.Create('Internal ShowTest plugin error','ShowTest.dll::CB','ShowTest error: Not enough place for new testing task');
end;
if id=SOCKCB_RECV then begin
    if msg.typ=TCS_TESTINGINFO then
       for i:=1 to MAX_TESTINGTASKS do
           if (TestingData[i].used)and(TestingData[i].ts.gtid=tf.gtid) then
              TestingData[i].ti:=ti;
    if msg.typ=TCS_TESTINGFINISHED then
       for i:=1 to MAX_TESTINGTASKS do
           if (TestingData[i].used)and(TestingData[i].ts.gtid=tf.gtid) then
              fillchar(TestingData[i],sizeof(TestingData[i]),0);
    if msg.typ=TCS_TESTRESULT then begin
       was:=false;
       for i:=1 to MAX_CLIENTS do
           if (TestingData[i].used)and(TestingData[i].ts.gtid=tr.gtid) then begin
              if was then
                 raise eIJEerror.Create('Internal ShowTest plugin error','ShowTest.dll::CB','ShowTest error: Testing task dublicate');
              SendToProg(TestingData[i],tr);
              was:=true;
           end;
       if not was then
          raise eIJEerror.Create('Internal ShowTest plugin error','ShowTest.dll::CB','ShowTest error: Testing task not found');
    end;
end;
finally
lock.leave;
end;
end;

function init(data:tPluginData):boolean;
var f:text;
begin
assign(f,ExtractFilePath(data.selfname)+'\path.txt');reset(f);
readln(f,path);
ExpandFileName(path);
close(f);
if (path='') then begin
   result:=false;
   exit;
end;
randomize;
fillchar(TestingData,sizeof(TestingData),0);
Lock:=tCriticalSection.Create;
data.SetSockCB(SOCKCB_RECV,CB);
data.SetSockCB(SOCKCB_SEND,CB);
result:=true;
end;

exports
  init;

end.

