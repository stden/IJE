{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O+,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ This file is part of IJE: the Integrated Judging Environment system }
{ (C) Kalinin Petr 2002-2008 }
{ $Id: qacm_acm.dpr 202 2008-04-19 11:24:40Z *KAP* $ }
library qacm_acm;
uses ShareMem,windows,
     sysutils,xmlije,ijeconsts,acm,ije_crt32,ije_main;
const TABLE_ROWS=15;
type tClassicACMcontest=class
       m:tClassicACMmonitor;
       boy:tboys;
       task:ttasks;
       TableStartRow:integer;
       constructor Create(fname:string;var qacms:tQACMcontestInfo);
       procedure ReCalcTable;
       function findboy(s:string):integer;
       function findtask(s:string):integer;
       procedure LoadTable;
       procedure WriteScreenTable;
       procedure WriteResult(i:integer);
       procedure SaveTable;
       function AddSolution(sol:tSolData;SolTime:integer):integer;
       procedure TestedSolution(solid:integer;SolRes:ttestresults);
       procedure PressedKey(ch:char);
       function CurrentTime:integer;
     end;
var nContests:integer;
    Contest:array[1..MAX_ACM_CONTESTS] of tClassicACMcontest;

function WinToDos(s:string):string;
var s1:pWideChar;
    s2:pChar;
begin
GetMem(s1,length(s)*4);
GetMem(s2,length(s)*4);
MultiByteToWideChar(1251,0,PChar(s),-1,s1,length(s)*2);
WideCharToMultiByte(866,0,s1,-1,s2,length(s)*4,nil,nil);
result:=s2;
FreeMem(s1);
FreeMem(s2);
end;

function Init(var cfg:tsettings;var acm_qcfg:tQACmsettings;fname:string;var qacms:tQACMcontestInfo):integer;
begin
inc(nContests);
result:=nContests;
Contest[nContests]:=tClassicACMContest.Create(fname,qacms);
ije_main.cfg:=cfg;//it should be always the same
end;

procedure LoadTable(id:integer);
begin
Contest[id].LoadTable;
end;

procedure SaveTable(id:integer);
begin
Contest[id].SaveTable;
end;

procedure OnIdle(id:integer;time:integer);
begin
end;

procedure Finish(id:integer);
begin
end;

function AddSolution(id:integer;sol:tsoldata;time:integer):integer;
begin
result:=Contest[id].AddSolution(sol,time);
end;

procedure TestedSolution(id:integer;solid:integer;res:ttestresults);
begin
Contest[id].TestedSolution(solid,res);
end;

procedure PressedKey(id:integer;ch:char);
begin
Contest[id].PressedKey(ch);
end;

procedure WriteScreenTable(id:integer);
begin
Contest[id].WriteScreenTable;
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
  
{ tClassicACmcontest }

function tClassicACmcontest.AddSolution(sol: tSolData; SolTime: integer):integer;
begin
inc(m.submits.nsubmit);
with m.submits.s[m.submits.nsubmit] do begin
     party:=sol.boy;
     task:=maketask(sol.day,sol.task);
     lang:=sol.ext;
     time:=SolTime;
     id:=m.submits.nsubmit;
     res:=_NT;
     test:=0;
     comment:='';
end;
result:=m.submits.nsubmit;
end;

constructor tClassicACmcontest.Create(fname: string;var qacms:tQACMcontestInfo);
var i:integer;
begin
m.ije_ver:=ije_ver_full;
LoadClassicACMsettings(fname,m.qcfg);
qacms.needfirstwa:=true;
qacms.needglobaltime:=false;
qacms.StartTime:=m.qcfg.start;
qacms.Length:=m.qcfg.length;
qacms.Title:=m.qcfg.title;
qacms.nParty:=m.qcfg.nparty;
for i:=1 to m.qcfg.nparty do begin
    qacms.party[i]:=m.qcfg.party[i].id;
    boy[i]:=m.qcfg.party[i].id;
end;
qacms.nTask:=m.qcfg.ntask;
for i:=1 to m.qcfg.ntask do begin
    qacms.task[i]:=m.qcfg.task[i].id;
    task[i]:=m.qcfg.task[i].id;
end;
TableStartRow:=1;
end;

function tClassicACmcontest.CurrentTime: integer;
var h,min,s,ss:word;
begin
gettime(h,min,s,ss);
result:=h*60+min-m.qcfg.start;
end;

function tClassicACmcontest.findboy(s: string): integer;
begin
result:=findstring(m.qcfg.nparty,boy,s);
end;

function tClassicACmcontest.findtask(s: string): integer;
begin
result:=findstring(m.qcfg.ntask,task,s);
end;

procedure tClassicACmcontest.LoadTable;
var was:array[1..MAX_ACM_SUBMITS] of boolean;
    i:integer;
    d:integer;
    nn:integer;
begin
if not fileexists(cfg.resp+m.qcfg.submitsFile) then begin
   m.submits.nsubmit:=0;
   SaveClassicACmsubmits(cfg.resp+m.qcfg.submitsFile,m.submits);
   exit;
end;
LoadClassicACMsubmits(cfg.resp+m.qcfg.submitsFile,m.submits);
fillchar(was,sizeof(was),0);
nn:=m.submits.nsubmit;
for i:=1 to m.submits.nsubmit do begin
    if findtask(m.submits.s[i].task)*findboy(m.submits.s[i].party)<>0 then
      was[i]:=true
    else
      raise eIJEerror.Create('Unknown party or task','tClassicACMcontest.LoadTable('+m.qcfg.submitsFile+'):','Unknown party or task: %s,%s (submit-id %d)',[m.submits.s[i].party,m.submits.s[i].task,m.submits.s[i].id]);
    if m.submits.s[i].id>nn then
       nn:=m.submits.s[i].id;
end;
m.submits.nsubmit:=nn;
d:=0;
for i:=1 to m.submits.nsubmit do
    if not was[i] then
       inc(d)
    else m.submits.s[i-d]:=m.submits.s[i];
dec(m.submits.nsubmit,d);
if d<>0 then
   NonModalMessageBox(0,'Classic ACM contest "'+m.qcfg.title+'"'#13'WARNING: while loading Classic ACM submits from file '+m.qcfg.submitsFile+': '+IntToStr(d)+' submits were missing','Classic ACM contest "'+m.qcfg.title+'" - IJE',MB_ICONWARNING);
ReCalcTable;
end;

procedure tClassicACmcontest.PressedKey(ch: char);
begin
if ch=#72 then
   if TableStartRow>1 then
      dec(TableStartRow);
if ch=#80 then
   if TableStartRow+TABLE_ROWS<m.qcfg.nparty then
      inc(TableStartRow);
end;

procedure tClassicACmcontest.ReCalcTable;
var i:integer;
    sb,sp:integer;
begin
fillchar(m.solved,sizeof(m.solved),0);
fillchar(m.time,sizeof(m.time),0);
for i:=1 to m.submits.nsubmit do begin
    sb:=findboy(m.submits.s[i].party);
    sp:=findtask(m.submits.s[i].task);
    assert(sb*sp<>0,'sb*sp=0');
    if m.submits.s[i].res=_ok then begin
         if m.solved[sb,sp]<=0 then begin
            m.solved[sb,sp]:=-m.solved[sb,sp]+1;
            inc(m.solved[sb,0]);
            m.time[sb,sp]:=m.submits.s[i].time;
            inc(m.time[sb,0],m.submits.s[i].time+(m.solved[sb,sp]-1)*m.qcfg.penalty);
         end;
    end else if m.submits.s[i].res<>_nt then begin
          if m.solved[sb,sp]<=0 then
             dec(m.solved[sb,sp]);
    end;
end;
end;

procedure tClassicACmcontest.SaveTable;
begin
ReCalcTable;
SaveClassicACMsubmits(cfg.resp+m.qcfg.submitsFile,m.submits);
m.contest_time:=CurrentTime;
if m.contest_time<0 then
   m.status:='Not started yet'
else if m.contest_time>=m.qcfg.length then
     m.status:='Finished'
else m.status:='Running';
SaveClassicACMmonitor(cfg.resp+m.qcfg.monitorFile,m);
end;

procedure tClassicACmcontest.TestedSolution(solid: integer; SolRes: ttestresults);
var i:integer;
begin
assert(solid<=m.submits.nsubmit);
with m.submits.s[solid] do begin
     res:=_ok;
     test:=0;
     comment:='';
     for i:=1 to SolRes.ntests do
         if SolRes.test[i].res<>_ok then begin
            res:=SolRes.test[i].res;
            test:=i;
            comment:=Solres.test[i].text;//we assume there is no evaluators in ACM tasks and so ignore evaltext
            break;
         end;
     if res in [_ok,_ce] then
        test:=0;
end;
ReCalcTable;
end;

procedure tClassicACMcontest.WriteResult(i:integer);

  procedure writeast;
  begin
  write('\$07; * \*;');
  end;

begin
with m.submits.s[i] do begin
     settextattr($0f);
     write(format('%3d',[i]));writeast;
     write(format('%4d',[time]));writeast;
     write(format('%3s',[party]));writeast;
     write(task);writeast;
     settextattr(attrib(res));write(stext(res));writeast;
     settextattr($07);
     if comment<>'' then
        write(comment)
     else write(ltext(res));
     if test<>0 then begin
        writeast;
        write(format('N %2d',[test]));
     end;
end;
end;

procedure tClassicACmcontest.WriteScreenTable;
var fin:integer;
    was:array[1..maxboys] of byte;
    i,j:integer;
    maxj:integer;
    maxs,mint:longint;
    s:string;
    head:string;
    hr:string;
begin
  clrscr;
  gotoxy(1,1);
  head:=#205#205' '+WinToDos(m.qcfg.title)+' - IJE - Integrated Judging Environment '+ije_ver_full+'      ';
  hr:='';
  while length(head+'ACM MODE'+hr)<CurrentCols-6 do
        hr:=' '+hr;  
  write('\$5f;'+head+'\$5e;ACM MODE\$5f;'+hr,true,false);//т.к. псевдографика
  settextattr($1f);
  write(format('%5d ',[CurrentTime]));
  writeln;
  settextattr($07);
  j:=0;
  for i:=m.submits.nsubmit downto 1 do
      if (m.submits.s[i].res=_ok) then begin
         j:=i;
         break;
      end;
  writeln;
  if j<>0 then begin
     write('Last success: ');
     WriteResult(j);
  end;
  writeln;
  settextattr($0f);
  write('  p  Name ');
  for j:=1 to m.qcfg.ntask do
      write(format('%5s',[m.qcfg.task[j].id]));
  writeln('  = Time');
  fin:=TableStartRow+TABLE_ROWS;
  if fin>m.qcfg.nparty then fin:=m.qcfg.nparty;
  fillchar(was,sizeof(was),0);
  for i:=1 to m.qcfg.nparty do begin
      maxs:=-1;mint:=0;
      for j:=1 to m.qcfg.nparty do
          if was[j]=0 then
             if (m.solved[j,0]>maxs)or((m.solved[j,0]=maxs)and(m.time[j,0]<mint)) then begin
                maxj:=j;maxs:=m.solved[j,0];mint:=m.time[j,0];
             end;
      was[maxj]:=1;
      if (i<TableStartRow)or(i>fin) then continue;
      settextattr($0b);
      if (i=tableStartRow)and(tableStartRow>1) then
         write(#30)
      else if (i=fin)and(fin<m.qcfg.nparty) then
           write(#31)
      else write(' ');
      settextattr($0f);
      write(format('%2d. ',[i]));
      s:=m.qcfg.party[maxj].id;
      while length(s)<6 do s:=s+' ';
      write(s);
      for j:=1 to m.qcfg.ntask do
          if m.solved[maxj,j]>0 then begin
             if m.solved[maxj,j]>1 then s:='  +'+IntToStr(m.solved[maxj,j]-1)
             else s:='  +';
             while length(s)<5 do s:=s+' ';
             write('\$0a;'+s);
          end else if m.solved[maxj,j]<0 then begin
              s:='  '+IntToStr(m.solved[maxj,j]);
              while length(s)<5 do s:=s+' ';
              write('\$0c;'+s);
          end else begin
              settextattr($07);
              write('\$07;  .  ');
          end;
      settextattr($0f);
      write(format('%2d',[m.solved[maxj,0]]));
      settextattr($07);
      writeln(format(' %4d',[m.time[maxj,0]]));
  end;
  settextattr($0f);
  writeln;
  writeln('Last results: ');
  settextattr($07);
  j:=0;
  for i:=m.submits.nsubmit downto 1 do begin
      if j>10 then
         break;
      WriteResult(i);
      writeln;
      inc(j);
  end;
  writeln;
end;

begin
nContests:=0;
ConsoleMode:=true;//it is guaranteed that WriteScreenTable will be called only in real ConsoleMode
end.
