{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O+,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ This file is part of IJE: the Integrated Judging Environment system }
{ (C) Kalinin Petr 2002-2008 }
{ $Id: qacm_kirov.dpr 202 2008-04-19 11:24:40Z *KAP* $ }
library qacm_acm;
uses ShareMem,windows,
     sysutils,xmlije,ijeconsts,acm,ije_crt32,ije_main;
const TABLE_ROWS=15;
type tKirovACMcontest=class
       m:tKirovACMmonitor;
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
    Contest:array[1..MAX_ACM_CONTESTS] of tKirovACMcontest;
    qcfg:tQACmsettings;
    
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

function timestamp(time:double):int64;
begin
timestamp:=trunc((time-25569)*24*60-3*60-qcfg.dst*60);
end;

function Init(var cfg:tsettings;var acm_qcfg:tQACmsettings;fname:string;var qacms:tQACMcontestInfo):integer;
begin
inc(nContests);
result:=nContests;
Contest[nContests]:=tKirovACMContest.Create(fname,qacms);

ije_main.cfg:=cfg;//it should always (i.e for all instances of contest) be the same
qcfg:=acm_qcfg;
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

{ tKirovACmcontest }

function tKirovACmcontest.AddSolution(sol: tSolData; SolTime: integer):integer;
begin
inc(m.submits.nsubmit);
with m.submits.s[m.submits.nsubmit] do begin
     party:=sol.boy;
     task:=maketask(sol.day,sol.task);
     lang:=sol.ext;
     time:=SolTime;
     id:=m.submits.nsubmit;
     //----
     fillchar(tr,sizeof(tr),0);
     tr.ntests:=1;
     tr.test[1].res:=_NT;
     pts:=0;
     maxpts:=0;
end;
result:=m.submits.nsubmit;
end;

constructor tKirovACmcontest.Create(fname: string;var qacms:tQACMcontestInfo);
var i:integer;
begin
m.ije_ver:=ije_ver_full;
LoadKirovACMsettings(fname,m.qcfg);
qacms.needfirstwa:=false;
qacms.needglobaltime:=true;
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

function tKirovACmcontest.CurrentTime: integer;
begin
result:=timestamp(now)-m.qcfg.start;
end;

function tKirovACmcontest.findboy(s: string): integer;
begin
result:=findstring(m.qcfg.nparty,boy,s);
end;

function tKirovACmcontest.findtask(s: string): integer;
begin
result:=findstring(m.qcfg.ntask,task,s);
end;

procedure tKirovACmcontest.LoadTable;
var was:array[1..MAX_ACM_SUBMITS] of boolean;
    i:integer;
    d:integer;
    nn:integer;
begin
if not fileexists(cfg.resp+m.qcfg.submitsFile) then begin
   m.submits.nsubmit:=0;
   SaveKirovACMsubmits(cfg.resp+m.qcfg.submitsFile,m.submits);
   exit;
end;
LoadKirovACMsubmits(cfg.resp+m.qcfg.submitsFile,m.submits);
fillchar(was,sizeof(was),0);
nn:=m.submits.nsubmit;
for i:=1 to m.submits.nsubmit do begin
    if findtask(m.submits.s[i].task)*findboy(m.submits.s[i].party)<>0 then
      was[i]:=true
    else
      raise eIJEerror.Create('Unknown party or task','tKirovACMcontest.LoadTable('+m.qcfg.submitsFile+'):','Unknown party or task: %s,%s (submit-id %d)',[m.submits.s[i].party,m.submits.s[i].task,m.submits.s[i].id]);
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
   NonModalMessageBox(0,'Kirov ACM contest "'+m.qcfg.title+'"'#13'WARNING: while loading Kirov ACM submits from file '+m.qcfg.submitsFile+': '+IntToStr(d)+' submits were missing','Kirov ACM contest "'+m.qcfg.title+'" - IJE',MB_ICONWARNING);
ReCalcTable;
end;

procedure tKirovACmcontest.PressedKey(ch: char);
begin
if ch=#72 then
   if TableStartRow>1 then
      dec(TableStartRow);
if ch=#80 then
   if TableStartRow+TABLE_ROWS<m.qcfg.nparty then
      inc(TableStartRow);
end;

procedure tKirovACmcontest.ReCalcTable;
var i:integer;
    sb,sp:integer;
begin
fillchar(m.pts,sizeof(m.pts),0);
fillchar(m.max,sizeof(m.max),0);
fillchar(m.attempts,sizeof(m.attempts),0);
for i:=1 to m.submits.nsubmit do
    if m.submits.s[i].tr.test[1].res<>_nt then begin
       sb:=findboy(m.submits.s[i].party);
       sp:=findtask(m.submits.s[i].task);
       assert(sb*sp<>0,'sb*sp=0');

       inc(m.attempts[sb,sp]);

       dec(m.pts[sb,0],m.pts[sb,sp]);
       m.pts[sb,sp]:=m.submits.s[i].pts-(m.attempts[sb,sp]-1)*m.qcfg.penalty;
       if m.pts[sb,sp]<0 then
          m.pts[sb,sp]:=0;
       inc(m.pts[sb,0],m.pts[sb,sp]);

       m.max[sb,sp]:=m.submits.s[i].maxpts;
   end;
end;


procedure tKirovACmcontest.SaveTable;
begin
ReCalcTable;
SaveKirovACMsubmits(cfg.resp+m.qcfg.submitsFile,m.submits);
m.contest_time:=CurrentTime;
if m.contest_time<0 then
   m.status:='Not started yet'
else if m.contest_time>=m.qcfg.length then
     m.status:='Finished'
else m.status:='Running';
SaveKirovACMmonitor(cfg.resp+m.qcfg.monitorFile,m);
end;

procedure tKirovACmcontest.TestedSolution(solid: integer; SolRes: ttestresults);
var i:integer;
begin
assert(solid<=m.submits.nsubmit);
with m.submits.s[solid] do begin
     tr:=SolRes;
     m.submits.s[solid].pts:=0;
     m.submits.s[solid].maxpts:=0;
     for i:=1 to solres.ntests do begin
         inc(m.submits.s[solid].pts,SolRes.test[i].pts);
         inc(m.submits.s[solid].maxpts,SolRes.test[i].max);
     end;
end;
ReCalcTable;
end;

procedure tKirovACMcontest.WriteResult(i:integer);

  procedure writeast;
  begin
  write('\$07; * \*;');
  end;

var j:integer;
begin
with m.submits.s[i] do begin
     settextattr($0f);
     write(format('%3d',[i]));writeast;
     write(format('%3d',[time]));writeast;
     write(party);writeast;
     write(task);writeast;
     if pts+m.attempts[findboy(party),findtask(task)]*m.qcfg.penalty=maxpts then
        settextattr($0a);
     write(format('%3d',[pts]));
     settextattr($07);
     write(format(' / %3d',[maxpts]));writeast;
     if pts<>maxpts then
        for j:=1 to tr.ntests do
            if tr.test[j].res<>_ok then begin
               settextattr(attrib(tr.test[j].res));write(stext(tr.test[j].res));writeast;
               settextattr($07);
               write(tr.test[j].text);
               writeast;
               write(format('N %d',[j]));
               break;
            end;
end;
end;

procedure tKirovACMcontest.WriteScreenTable;
var fin:integer;
    was:array[1..maxboys] of byte;
    i,j:integer;
    maxj:integer;
    maxp:longint;
    nf:integer;
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
  writeln;
  settextattr($0f);
  writeln('  p  Name      =   =Full');
  fin:=TableStartRow+TABLE_ROWS;
  if fin>m.qcfg.nparty then fin:=m.qcfg.nparty;
  fillchar(was,sizeof(was),0);
  for i:=1 to m.qcfg.nparty do begin
      maxp:=-1;
      for j:=1 to m.qcfg.nparty do
          if was[j]=0 then 
             if (m.pts[j,0]>maxp) then begin
                maxj:=j;maxp:=m.pts[j,0];
             end;
      was[maxj]:=1;
      nf:=0;
      for j:=1 to m.qcfg.ntask do
          if m.pts[maxj,j]=m.max[maxj,j]-(m.attempts[maxj,j]-1)*m.qcfg.penalty then
             inc(nf);
      if (i<TableStartRow)or(i>fin) then continue;
      settextattr($0b);
      if (i=TableStartRow)and(TableStartRow>1) then
         write(#30)
      else if (i=fin)and(fin<m.qcfg.nparty) then
           write(#31)
      else write(' ');
      settextattr($0f);
      write(format('%2d. ',[i]));
      write(format('%6s',[m.qcfg.party[maxj].name]));
      settextattr($0f);
      write(format('%5d',[m.pts[maxj,0]]));
      writeln(format(' %3d',[nf]));
  end;
  settextattr($0f);
  writeln;
  writeln('Last results: ');
  settextattr($07);
  for i:=m.submits.nsubmit downto m.submits.nsubmit-10 do begin
      if i>0 then begin
         WriteResult(i);
         writeln;
      end;
  end;
  writeln;
end;

begin
nContests:=0;
ConsoleMode:=true;//it is guaranteed that WriteScreenTable will be called only in real ConsoleMode
end.
