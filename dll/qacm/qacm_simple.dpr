{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O+,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
library qacm_simple;
uses ShareMem,sysutils,xmlije,ijeconsts,acm,crt32;//it is guaranteed that WriteScreenTable will be called only in ConsoleMode
var log,log1:text;
    nContests:integer;
    nSols:array[1..10] of integer;
    s:array[1..10] of string;

procedure LogWrite(s:string);
begin
append(log);
writeln(log,s);
close(log);
end;

procedure LogWrite1(s:string);
begin
append(log1);
writeln(log1,s);
close(log1);
end;

procedure LoadTable(id:integer);
begin
LogWrite(IntToStr(id)+'LoadTable');
end;

procedure SaveTable(id:integer);
begin
LogWrite(IntToStr(id)+'SaveTable');
end;

procedure OnIdle(id:integer;time:integer);
begin
LogWrite(format(IntToStr(id)+'OnIdle(%d)',[time]));
end;

function Init(var cfg:tsettings;fname:string;var qacms:tQACMcontestInfo):integer;
begin
inc(nContests);
result:=nContests;
qacms.needfirstwa:=true;
qacms.StartTime:=0;
qacms.Length:=10000;
qacms.Title:='Simple contest ('+fname+')';
qacms.nParty:=1;
if fname='1' then qacms.party[1]:='VLA'
else qacms.party[1]:='VLA';
qacms.ntask:=1;
if fname='1' then qacms.task[1]:='02.A'
else qacms.task[1]:='03.A';
if nContests=1 then begin
   assign(log,'_simple.log');rewrite(log);close(log);
   assign(log1,'_simple1.log');rewrite(log1);close(log1);
end;
LogWrite(IntToStr(nContests)+'Init');
s[nContests]:='';
end;

procedure Finish(id:integer);
begin
LogWrite(IntToStr(id)+'Finish');
end;

function AddSolution(id:integer;sol:tsoldata;time:integer):integer;
begin
inc(nSols[id]);
result:=nSols[id];
LogWrite(IntToStr(id)+'AddSolution '+sol.fname);
end;

procedure TestedSolution(id:integer;solid:integer;res:ttestresults);
var i:integer;
begin
LogWrite(IntToStr(id)+'TestedSolution');
LogWrite(format(' %d tests:',[res.ntests]));
for i:=1 to res.ntests do
    LogWrite(format('%d %s %s',[i,stext(res.test[i].res),res.test[i].text]));
end;

procedure PressedKey(id:integer;ch:char);
begin
s[id]:=s[id]+ch+'`';
end;

procedure WriteScreenTable(id:integer);
begin
clrscr;
writeln(id);
writeln(s[id]);
end;

exports
  LoadTable,
  SaveTable,
  OnIdle,
  Init,
  AddSolution,
  Finish,
  TestedSolution,
  PressedKey,
  WriteScreenTable;
  
begin
nContests:=0;
fillchar(nsols,sizeof(nsols),0);
end.