{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O+,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ This file is part of IJE: the Integrated Judging Environment system }
{ (C) Kalinin Petr 2002-2008 }
{ $Id: qacm_rw.dpr 202 2008-04-19 11:24:40Z *KAP* $ }
library qacm_acm;
uses ShareMem,windows,math,
     sysutils,xmlije,ijeconsts,acm,ije_crt32,ije_main,io;
const TABLE_ROWS=15;
type tRWACMcontest=class
       m:tRWACMmonitor;
       boy:tboys;
       task:ttasks;
       TableStartRow:integer;
       br:ttable;
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
       function CurrentTime: integer;
     end;
var nContests:integer;
    Contest:array[1..MAX_ACM_CONTESTS] of tRWACMcontest;
    qcfg:tQACMsettings;
    
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
ije_main.cfg:=cfg;//it should always (i.e for all instances of contest) be the same

Contest[nContests]:=tRWACMContest.Create(fname,qacms);

qcfg:=acm_qcfg;
end;

function tRWACmcontest.CurrentTime: integer;
var h,min,s,ss:word;
begin
gettime(h,min,s,ss);
result:=h*60+min-m.qcfg.start;
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

{ tRWACMContest }

function tRWACMContest.AddSolution(sol: tSolData; SolTime: integer):integer;
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
end;
result:=m.submits.nsubmit;
end;

constructor tRWACMContest.Create(fname: string;var qacms:tQACMcontestInfo);
var i:integer;
begin
m.ije_ver:=ije_ver_full;
LoadRWACMsettings(fname,m.qcfg);
io.LoadTable(br,m.qcfg.baseresults,cfg.tabledll);
qacms.needfirstwa:=false;
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

function tRWACMContest.findboy(s: string): integer;
begin
result:=findstring(m.qcfg.nparty,boy,s);
end;

function tRWACMContest.findtask(s: string): integer;
begin
result:=findstring(m.qcfg.ntask,task,s);
end;

procedure tRWACMContest.LoadTable;
var was:array[1..MAX_ACM_SUBMITS] of boolean;
    i:integer;
    d:integer;
    nn:integer;
begin
if not fileexists(cfg.resp+m.qcfg.submitsFile) then begin
   m.submits.nsubmit:=0;
   SaveRWACMsubmits(cfg.resp+m.qcfg.submitsFile,m.submits);
   exit;
end;
LoadRWACMsubmits(cfg.resp+m.qcfg.submitsFile,m.submits);
fillchar(was,sizeof(was),0);
nn:=m.submits.nsubmit;
for i:=1 to m.submits.nsubmit do begin
    if findtask(m.submits.s[i].task)*findboy(m.submits.s[i].party)<>0 then
      was[i]:=true
    else
      raise eIJEerror.Create('Unknown party or task','tRWACMcontest.LoadTable('+m.qcfg.submitsFile+'):','Unknown party or task: %s,%s (submit-id %d)',[m.submits.s[i].party,m.submits.s[i].task,m.submits.s[i].id]);
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
   NonModalMessageBox(0,'RW ACM contest "'+m.qcfg.title+'"'#13'WARNING: while loading RW ACM submits from file '+m.qcfg.submitsFile+': '+IntToStr(d)+' submits were missing','RW ACM contest "'+m.qcfg.title+'" - IJE',MB_ICONWARNING);
ReCalcTable;
end;

procedure tRWACMContest.PressedKey(ch: char);
begin
if ch=#72 then
   if TableStartRow>1 then
      dec(TableStartRow);
if ch=#80 then
   if TableStartRow+TABLE_ROWS<m.qcfg.nparty then
      inc(TableStartRow);
end;

procedure tRWACMContest.ReCalcTable;
var i,j:integer;
    sb,sp:integer;
    sbt,spt:integer;
    add:extended;
    r0:integer;
begin
fillchar(m.pts,sizeof(m.pts),0);
fillchar(m.attempts,sizeof(m.attempts),0);
for i:=1 to m.submits.nsubmit do
    if m.submits.s[i].tr.test[1].res<>_nt then begin
       sb:=findboy(m.submits.s[i].party);
       sp:=findtask(m.submits.s[i].task);
       sbt:=io.FindBoy(br,m.submits.s[i].party);
       spt:=io.FindTask(br,m.submits.s[i].task);
       assert(sb*sp<>0,'sb*sp=0');
       assert(sbt<>0,'sbt*spt=0');
       if spt=0 then
          r0:=0
       else r0:=io.Get(br,sbt,spt);
       
       if m.submits.s[i].pts>0 then begin
            if m.attempts[sb,sp]<=0 then begin
               m.attempts[sb,sp]:=-m.attempts[sb,sp]+1;
               inc(m.attempts[sb,0]);
               add:=m.submits.s[i].pts-r0;
               for j:=1 to m.attempts[sb,sp] do
                   add:=add*m.qcfg.coeff;
               m.pts[sb,sp]:=ceil(add);
               inc(m.pts[sb,0],m.pts[sb,sp]);
            end;
       end else if m.submits.s[i].tr.test[1].res<>_nt then begin
             if m.attempts[sb,sp]<=0 then
                dec(m.attempts[sb,sp]);
       end;
   end;
end;


procedure tRWACMContest.SaveTable;
begin
ReCalcTable;
SaveRWACMsubmits(cfg.resp+m.qcfg.submitsFile,m.submits);
m.contest_time:=CurrentTime;
if m.contest_time<0 then
   m.status:='Not started yet'
else if m.contest_time>=m.qcfg.length then
     m.status:='Finished'
else m.status:='Running';
SaveRWACMmonitor(cfg.resp+m.qcfg.monitorFile,m);
end;

procedure tRWACMContest.TestedSolution(solid: integer; SolRes: ttestresults);
var i:integer;
    max:integer;
begin
assert(solid<=m.submits.nsubmit);

with m.submits.s[solid] do begin
     tr:=SolRes;
     pts:=0;
     max:=0;
     for i:=1 to SolRes.ntests do begin
         inc(pts,SolRes.test[i].pts);
         inc(max,SolRes.test[i].max);
     end;
     if pts<>max then
        pts:=0;
end;
ReCalcTable;
end;

procedure tRWACMcontest.WriteResult(i:integer);

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
     for i:=1 to tr.ntests do
         if tr.test[i].res<>_ok then
            break;
     if i>tr.ntests then
        i:=tr.ntests;
     settextattr(attrib(tr.test[i].res));write(stext(tr.test[i].res));writeast;
     settextattr($07);
     if (tr.test[i].text<>'')and(tr.test[i].res<>_ok) then
        write(tr.test[i].text)
     else write(ltext(tr.test[i].res));
     if (tr.test[i].res<>_ok) then begin
        writeast;
        write(format('N %2d',[i]));
     end;
end;
end;

procedure tRWACMcontest.WriteScreenTable;
var fin:integer;
    was:array[1..maxboys] of byte;
    i,j:integer;
    maxj:integer;
    max:longint;
    s:string;
    head:string;
    hr:string;
begin
  ConsoleMode:=true;
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
  settextattr($07);
  j:=0;
  for i:=m.submits.nsubmit downto 1 do
      if (m.submits.s[i].pts>0) then begin
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
  writeln('    =');
  fin:=TableStartRow+TABLE_ROWS;
  if fin>m.qcfg.nparty then fin:=m.qcfg.nparty;
  fillchar(was,sizeof(was),0);
  for i:=1 to m.qcfg.nparty do begin
      max:=-1;
      for j:=1 to m.qcfg.nparty do
          if was[j]=0 then
             if (m.pts[j,0]>max) then begin
                maxj:=j;max:=m.pts[j,0];
             end;
      was[maxj]:=1;
      if (i<TableStartRow)or(i>fin) then continue;
      settextattr($0b);
      if (i=TableStartRow)and(TableStartRow>1) then
         write(#30)
      else if (i=fin)and(fin<m.qcfg.nparty) then
           write(#31)
      else write(' ');
      settextattr($0f);
      write(format('%2d. %-6s',[i,m.qcfg.party[maxj].id]));
      for j:=1 to m.qcfg.ntask do
          if m.attempts[maxj,j]>0 then begin
             settextattr($0a);
             if m.attempts[maxj,j]>1 then s:='  +'+inttostr(m.attempts[maxj,j]-1)
             else s:='  +';
             while length(s)<5 do s:=s+' ';
             write(s);
          end else if m.attempts[maxj,j]<0 then begin
              settextattr($0c);
              s:='  '+inttostr(m.attempts[maxj,j]);
              while length(s)<5 do s:=s+' ';
              write(s);
          end else begin
              settextattr($07);
              write('  .  ');
          end;
      settextattr($0f);
      writeln(format('%4d',[m.pts[maxj,0]]));
      settextattr($07);
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
  ConsoleMode:=false;
end;

begin
nContests:=0;
ConsoleMode:=false;//иначе LoadTable выводит данные на экран
end.
