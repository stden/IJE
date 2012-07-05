{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O-,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ This file is part of IJE: the Integrated Judging Environment system }
{ (C) Kalinin Petr 2002-2008 }
{ $Id: ui_main.pas 209 2010-01-18 17:27:06Z Petr $ }
unit ui_main;
interface
uses ShareMem,WinSock,Windows,SysUtils,
     ije_crt32,ijeconsts,sock,sock_ije,ije_main,io,xmlije;
const TESTING_WAITTIME=60;//sec
      TESTING_FIRSTWAITTIME=60*60;//sec
var narg:integer;
    arg:array[0..100] of string;
    cmd:string;
    Sock:tSocket;
    table:ttable;
    ResFileName:string;
    cur:record b,d,t:string; depth:integer; end;
    nsol:integer;
    sol:tSolDatas;
    mode:cardinal;

procedure ShowError(e:exception);
procedure WritePrompt(ta:byte=$07);
procedure ReadCmd;
procedure ParseCmd(s:string);
procedure DoCmd;
procedure LookUp;
procedure UpdateTable;
procedure Load(rload:boolean);
procedure Save;
procedure InitSocket;
procedure Clean;
procedure AddTask(id:string='');
procedure AddBoy(id:string='');
procedure Show;
procedure doHelp;
procedure DoMac;
procedure CD;
function IsHere(a:integer):boolean;
procedure doDelete;
function FindHereSol:integer;
procedure Archive;
procedure Restore;
procedure GetPoints;
procedure SetPoints;
procedure Minus;
procedure CT;
procedure TestMask;
procedure About;
procedure DoMode;
procedure UpdateMode;
procedure killTask;
procedure ShutDown;
procedure ReStart;

implementation
const nhelp=25;
      help:array[1..nhelp,1..3] of string=(
      ('lookup','look for solutions','lookup'),
      ('load','load result table','load [[<dll>] <filename>]'),
      ('rload','load result table in realtesting mode','rload [[<dll>] <filename>]'),
      ('save','save result table','save [<dll> [<filename>]]'),
      ('clean','clean result table','clean'),
      ('addtask','add new task','addtask'),
      ('addboy','add new contestant','addboy'),
      ('show','print current result table to screen','show'),
      ('mac','execute macros','mac [<mac-name>]'),
      ('cd','change location to select solutions','cd <where-to>'),
      ('delete','delete current solution','delete'),
      ('archive','move current solution to archive','archive'),
      ('restore','restore solution(s) from archive','restore <boy-mask> <day-mask> <task-mask>'),
      ('get','get points from table for current boy (n=-1,0,1)','get <n>'),
      ('set','set points to table to current boy (n=-1,0,1)','set <n> <value>'),
      ('minus','set penalty (minus) pts for current solution','minus'),
      ('ct','compile and test current solution','ct [-AS] [testset] [-- <compile args>]'),
      ('testmask','test solutions','testmask <contestant-mask> <day-mask> <task-mask> [archive]'),
      ('mode','add/delete/view modes','mode [{ADD|DELETE} <mode-name>]'),
      ('killtask','kill specified task from testing queue','killtask <task-id>'),
      ('shutdown','shutdown the UI, server and all the clients connected to server','shutdown'),
      ('restart','restart (reload ije_cfg.xml)','restart'),

      ('about','display information about IJE','about'),
      ('exit','exit from UI','exit'),
      ('help','write this information','help')
      );

procedure ShowError(e:exception);
var ee:eIJEerror;
    msg:string;
begin
LogError(e);
msg:=e.message;
if copy(msg,1,length(ErrorPrefix))=ErrorPrefix then
   delete(msg,1,length(ErrorPrefix));
writeln;
if e is eIJEerror then begin
   ee:=eIJEerror(e);
   writeln(format(#7'\$0c;! %s\*; in %s\$0f;%s\*;',[ee.name,ee.ProcPath,msg]));
end else
   writeln(format(#7'\$0c;! Error\*;: \$0f;%s\*;',[msg]));
end;

procedure WritePrompt(ta:byte=$07);
var was:array[1..maxsols] of byte;
    i,j,k:integer;
    b,t:integer;
    s:string;
    ps:string;
    wastask:array[1..maxtasks] of byte;
    task,task2:array[1..maxtasks] of string;
    n,n2:integer;
begin
SetTextAttr(ta);
writeln;
if nsol=0 then
   writeln('\$0f;There aren''t any solutions\*;')
else if nsol>100 then
     writeln(format('\$0f;There are %d solutions, not shown\*;',[nsol]))
else begin
    writeln('\$0f;There are next solutions:\*;');
    fillchar(was,sizeof(was),0);
    fillchar(wastask,sizeof(wastask),0);
    n2:=0;
    for i:=1 to nsol do if was[i]=0 then begin
        t:=findtask(table,maketask(sol[i].day,sol[i].task));
        if t<>0 then
           wastask[t]:=1
        else begin
             inc(n2);
             task2[n2]:=maketask(sol[i].day,sol[i].task);
             for j:=i+1 to nsol do
                 if maketask(sol[j].day,sol[j].task)=task2[n2] then
                    was[j]:=1;
        end;
    end;
    n:=0;
    for i:=1 to table.ntask do
        if wastask[i]=1 then begin
           inc(n);
           task[n]:=table.task[i];
        end;
    for i:=1 to n2 do begin
        inc(n);
        task[n]:=task2[i];
    end;
    fillchar(was,sizeof(was),0);
    for i:=1 to nsol do if was[i]=0 then begin
        write(sol[i].boy+':  ');
        b:=findboy(table,sol[i].boy);
        for j:=i to nsol do
            if (was[j]=0)and(sol[j].boy=sol[i].boy) then begin
               if length(sol[i].boy)+3+(3+length(cfg.taskformat)+2)*n<CurrentCols then//если вся табличка влезает на экран по ширине
                  for k:=1 to n do
                      if maketask(sol[j].day,sol[j].task)=task[k] then
                         gotoxy(length(sol[i].boy)+3+(3+length(cfg.taskformat)+2)*(k-1),WhereY);
               t:=findtask(table,maketask(sol[j].day,sol[j].task));
               if b*t<>0 then begin
                  settextattr(attrib(table.t[b,t].res));
                  write(stext(table.t[b,t].res)+' ');
                  settextattr(ta);
               end else write('   ');
               if not ishere(j) then
                  settextattr($8);
               write(maketask(sol[j].day,sol[j].task)+'; ');
               settextattr(ta);
               was[j]:=1;
               if wherex>CurrentCols-10 then writeln;
            end;
        writeln;
    end;
end;
logwriteln('',LOG_LEVEL_MAJOR,true,false);
s:='';
if cur.depth>=1 then s:=s+'\'+cur.b;
if cur.depth>=2 then s:=s+'\'+cur.d;
if cur.depth>=3 then s:=s+'\'+cur.t;
logwrite(ResFileName+s+'>',LOG_LEVEL_MAJOR,true,false);
ps:=ResFileName;
if mode and SMODE_REALTESTING<>0 then
   ps:='\$0a;! '+ps+'\*;';
write(ps+s+'>');
end;

procedure ParseCmd(s:string);
var s0:string;
    i:integer;
    d:integer;
begin
s0:=s;
S:=UpperCase(S);
d:=0;
s:=' '+s;
for i:=2 to length(s) do
    if (s[i]=' ')and(s[i-1]=' ') then
       inc(d)
    else s[i-d]:=s[i];
SetLength(s,length(s)-d);
narg:=-1;
fillchar(arg,sizeof(arg),0);
for i:=1 to length(s) do
    if s[i]=' ' then
       inc(narg)
    else arg[narg]:=arg[narg]+s[i];
while (narg>0)and(arg[narg]='') do
      dec(narg);
for i:=1 to narg do
    if arg[i][1]='`' then
       delete(arg[i],1,1);
cmd:=arg[0];
end;

procedure ReadCmd;
var s:string;
begin
settextattr($0f);
readln(s);
settextattr($07);
ParseCmd(s);
end;

procedure doCmd;
var i:integer;
    s:string;
begin
s:=cmd;
for i:=1 to narg do
    s:=s+' '+arg[i];
logwriteln('>  '+s+'  <',LOG_LEVEL_MAJOR);
writeln;
if cmd='EXIT' then 
else if cmd='LOOKUP' then lookup
else if cmd='LOAD' then load(false)
else if cmd='SAVE' then save
else if cmd='CLEAN' then clean
else if cmd='ADDTASK' then addtask
else if cmd='ADDBOY' then addboy
else if cmd='SHOW' then show
else if cmd='MAC' then doMac
else if cmd='CD' then cd
else if cmd='DELETE' then doDelete
else if cmd='ARCHIVE' then Archive
else if cmd='RESTORE' then Restore
else if cmd='GET' then getPoints
else if cmd='SET' then setPoints
else if cmd='MINUS' then minus
else if (cmd='TEST') or (cmd='CT') then ct
else if cmd='TESTMASK' then Testmask
else if cmd='HELP' then dohelp
else if cmd='ABOUT' then about
else if cmd='MODE' then doMode
else if cmd='RLOAD' then Load(true)
else if cmd='KILLTASK' then killtask
else if cmd='SHUTDOWN' then shutdown
else if cmd='RESTART' then restart
else raise eIJEerror.Create('Unknown command','DoCmd: ','Unknown command "%s"',[cmd]);
logwriteln('',LOG_LEVEL_MAJOR);
end;

procedure InitSocket;
var addr:tSockAddr;
    WSAdata:tWSAdata;
begin
WSAStartUp($101,WSAdata);
myInfo.IP:=GetMyIp;
MyInfo.client:=IJE_TYPE_UI;
MyInfo.ver:=IJE_VERSION;
//Sock:=socket(AF_INET,SOCK_STREAM,IPPROTO_IP);
Sock:=CreateSocket(SOCK_STREAM);
addr.sin_family:=AF_INET;
addr.sin_port:=htons(UI_STREAM_PORT);
addr.sin_addr.S_addr:=INADDR_ANY;
if bind(Sock,addr,sizeof(addr))=SOCKET_ERROR then
   raise eIJEerror.CreateWin('Can''t create stream socket','InitSocket: ');
myInfo.port:=UI_STREAM_PORT;
LookForServers(UI_DGRAM_PORT);
ConnectToServer(Sock);
end;

procedure LookUp;
var lu:tUISlookup;
    la:tSUIlookupAnswer;
    ls:tSUIlookupSolData;
    i:integer;
begin
LogEnterProc('LookUp',LOG_LEVEL_MINOR);
try
try
//Code starts
lu.typ:=UIS_LOOKUP;
SendToSocket(sock,lu,sizeof(lu));
RecvFromSocket(sock,la,sizeof(la),SOCK_ACCEPTERROR,sizeof(la));
nsol:=la.nsol;
for i:=1 to nsol do begin
    RecvFromSocket(sock,ls,sizeof(ls),SOCK_ACCEPTERROR,sizeof(ls));
    sol[i].boy:=ls.boy;
    sol[i].day:=ls.day;
    sol[i].task:=ls.task;
    sol[i].ext:=ls.ext;
    sol[i].fname:=ls.fname;
end;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'LookUp');
end;
finally
  LogLeaveProc('LookUp',LOG_LEVEL_MINOR,format('%d sols found',[nsol]));
end;
end;

procedure UpdateTable;
var ut:tUISupdateTable;
    ua:tSUIupdateAnswer;
    nm:tSUItbName;
    i:integer;
begin
LogEnterProc('UpdateTable',LOG_LEVEL_MINOR);
try
try
//Code starts
ut.typ:=UIS_UPDATETABLE;
SendToSocket(sock,ut,sizeof(ut));
RecvFromSocket(sock,ua,sizeof(ua),SOCK_ACCEPTERROR,sizeof(ua));
fillchar(table,sizeof(table),0);
table.t:=ua.stable;
table.nboy:=ua.nboy;
table.ntask:=ua.ntask;
table.tasktype:=ua.tasktype;
ResFileName:=ua.ResFileName;
for i:=1 to table.nboy do begin
    RecvFromSocket(sock,nm,sizeof(nm),SOCK_ACCEPTERROR,sizeof(nm));
    table.boy[i]:=nm.name;
end;
for i:=1 to table.ntask do begin
    RecvFromSocket(sock,nm,sizeof(nm),SOCK_ACCEPTERROR,sizeof(nm));
    table.task[i]:=nm.name;
end;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'UpdateTable');
end;
finally
  LogLeaveProc('UpdateTable',LOG_LEVEL_MINOR);
end;
end;

procedure Load(rload:boolean);
var lt:tUISloadTable;
    ok:tALLok;
    md:tUISmode;
    ma:tSUImodeAnswer;
begin
LogEnterProc('Load',LOG_LEVEL_MAJOR);
try
try
//Code starts
try
fillchar(lt,sizeof(lt),0);
lt.typ:=UIS_LOADTABLE;
fillchar(md,sizeof(md),0);
md.typ:=UIS_MODE;

try
  StrToArray(lt.dll,cfg.tabledll,sizeof(lt.dll));
  StrToArray(lt.fname,ResFileName,sizeof(lt.fname));
  if narg=1 then begin
     if pos('.',arg[1])<>0 then
        warning('You have specified the extension');
     StrToArray(lt.fname,arg[1],sizeof(lt.fname));
  end;
  if narg>=2 then begin
     StrToArray(lt.dll,arg[1],sizeof(lt.dll));
     if pos('.',arg[2])<>0 then
        warning('You have specified the extension');
     StrToArray(lt.fname,arg[2],sizeof(lt.fname));
  end;

  SendToSocket(Sock,lt,sizeof(lt));
  RecvFromSocket(sock,ok,sizeof(ok),SOCK_ACCEPTERROR,sizeof(ok),5);
  if ok.typ<>ALL_OK then
     raise eIJEerror.Create('OK not recieved','','OK message not recieved in reply to Load');
  writeln('Table was successfully loaded');
  except
    warning('There was an error during load. Probably, loaded table has been changed. Reload to get correct table');
    raise;
  end;

  if rLoad then
     md.cmd:=1
  else md.cmd:=-1;
  md.mode:=SMODE_REALTESTING;
  SendToSocket(sock,md,sizeof(md));
  RecvFromSocket(sock,ma,sizeof(ma),SOCK_ACCEPTERROR,sizeof(ma));

except
  md.cmd:=-1;
  md.mode:=SMODE_REALTESTING;
  SendToSocket(sock,md,sizeof(md));
  RecvFromSocket(sock,ma,sizeof(ma),SOCK_ACCEPTERROR,sizeof(ma));
  raise;
end;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'Load');
end;
finally
  LogLeaveProc('Load',LOG_LEVEL_MAJOR);
end;
end;

procedure Save;
var st:tUISSaveTable;
    ok:tALLok;
begin
LogEnterProc('Save',LOG_LEVEL_MAJOR);
try
try
//Code starts
try
fillchar(st,sizeof(st),0);
st.typ:=UIS_SAVETABLE;

StrToArray(st.dll,cfg.tabledll,sizeof(st.dll));
StrToArray(st.fname,ResFileName,sizeof(st.fname));
if narg>=1 then
   StrToArray(st.dll,arg[1],sizeof(st.dll));
if narg>=2 then begin
   if pos('.',arg[2])<>0 then
      warning('You have specified the extension');
   StrToArray(st.fname,arg[2],sizeof(st.fname));
end;

SendToSocket(Sock,st,sizeof(st));
RecvFromSocket(sock,ok,sizeof(ok),SOCK_ACCEPTERROR,sizeof(ok));
if ok.typ<>ALL_OK then
   raise eIJEerror.Create('OK not recieved','','OK message not recieved in reply to Save');
writeln('Table was successfully saved');
except
  warning('There was an error during Save. Probably, loaded table has been changed. Reload to get correct table');
  raise;
end;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'Save');
end;
finally
  LogLeaveProc('Save',LOG_LEVEL_MAJOR);
end;
end;

procedure Clean;
var ct:tUIScleanTable;
    ok:tALLok;
begin
LogEnterProc('Clean',LOG_LEVEL_MAJOR);
try
try
//Code starts
try
fillchar(ct,sizeof(ct),0);
ct.typ:=UIS_CLEANTABLE;

SendToSocket(Sock,ct,sizeof(ct));
RecvFromSocket(sock,ok,sizeof(ok),SOCK_ACCEPTERROR,sizeof(ok));
if ok.typ<>ALL_OK then
   raise eIJEerror.Create('OK not recieved','','OK message not recieved in reply to Clean');
writeln('Table was successfully cleaned');
except
  warning('There was an error during Clean. Probably, table has been changed. Reload to get correct table');
  raise;
end;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'Clean');
end;
finally
  LogLeaveProc('Clean',LOG_LEVEL_MAJOR);
end;
end;

procedure addtask(id:string='');
var at:tUISaddTask;
    ok:tALLok;
    i:integer;
    cpl:integer;
    ch:char;
begin
LogEnterProc('AddTask',LOG_LEVEL_MAJOR);
try
try
//Code starts
fillchar(at,sizeof(at),0);
at.typ:=UIS_ADDTASK;

if table.ntask=maxtasks then
   raise exception.Create('No place for new task');
if id='' then begin
   write('Task id:');
   readln(at.id)
end else StrToArray(at.id,id,sizeof(at.id));
ArrStrUpper(at.id);
logwrite('Task id: '+at.id,LOG_LEVEL_MINOR);
repeat
  write('Select type of task ("P"= program-submitted; "O"=output-file-submitted): ');
  readln(at.ttype);
  at.ttype:=UpCase(at.ttype);
until at.ttype in ['P','O'];
logwrite(at.id+'-type... ',LOG_LEVEL_MINOR);
writeln('Select place for task '+at.id);
for i:=1 to table.ntask do
    write(format('%5s',[table.task[i]]));
writeln;
cpl:=table.ntask;
settextattr($0f);
repeat
  gotoxy(1+cpl*5,wherey);
  write('^'#8);
  ch:=readkey;
  case ch of
       #77:inc(cpl);
       #75:dec(cpl);
  end;
  if cpl>table.ntask then cpl:=0;
  if cpl<0 then cpl:=table.ntask;
  write(' ');
until ch=#13;
settextattr($07);gotoxy(1,wherey);writeln;
at.pos:=cpl;

SendToSocket(Sock,at,sizeof(at));
RecvFromSocket(sock,ok,sizeof(ok),SOCK_ACCEPTERROR,sizeof(ok));
if ok.typ<>ALL_OK then
   raise eIJEerror.Create('OK not recieved','','OK message not recieved in reply to AddTask');

writeln('Task was successfully added');
logwriteln('OK',LOG_LEVEL_MINOR);
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'AddTask');
end;
finally
  LogLeaveProc('AddTask',LOG_LEVEL_MAJOR);
end;
end;

procedure AddBoy(id:string='');
var ab:tUISaddBoy;
    ok:tALLok;
begin
LogEnterProc('AddBoy',LOG_LEVEL_MAJOR);
try
try
//Code starts
fillchar(ab,sizeof(ab),0);
ab.typ:=UIS_ADDBOY;

if table.nboy=maxboys then
   raise exception.Create('No place for new contestant');

if id='' then begin
   write('Contestant id:');
   readln(ab.id);
end else StrToArray(ab.id,id,sizeof(ab.id));
logwrite('Adding contestant '+ab.id+'...',LOG_LEVEL_MINOR);
ArrStrUpper(ab.id);

SendToSocket(sock,ab,sizeof(ab));
RecvFromSocket(sock,ok,sizeof(ok),SOCK_ACCEPTERROR,sizeof(ok));
if ok.typ<>ALL_OK then
   raise eIJEerror.Create('OK not recieved','','OK message not recieved in reply to AddBoy');

writeln('Contestant was successfully added');
logwriteln('OK',LOG_LEVEL_MINOR);
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'AddBoy');
end;
finally
  LogLeaveProc('AddBoy',LOG_LEVEL_MAJOR);
end;
end;

procedure Show;
var i,j,k:integer;
    s:integer;
    max:integer;
    was:array[1..maxboys] of byte;
    maxj:integer;
    ta:integer;
begin
LogEnterProc('Show',LOG_LEVEL_MAJOR);
try
try
UpdateTable;

ta:=textattr;
clrscr;
fillchar(was,sizeof(was),0);
writeln('\$0d;Current result table:\*; ');
settextattr($0f);
write('         ');
for i:=1 to table.ntask do
    write(format('%5s',[table.task[i]]));
write('      Sum');
writeln;
for i:=1 to table.nboy do begin
    settextattr($0f);
    write(format('%2d.',[i]));
    max:=-1;
    for j:=1 to table.nboy do if was[j]=0 then begin
        s:=0;
        for k:=1 to table.ntask do s:=s+get(table,j,k);
        if s>max then begin
           max:=s;
           maxj:=j;
        end;
    end;
    was[maxj]:=1;
    write(format( '%3s   ',[table.boy[maxj]]));
    settextattr($0a);
    for k:=1 to table.ntask do
        if table.t[maxj,k].res=_NS then
           write(format('%5s',[' ']))
        else write(format('%5d',[get(table,maxj,k)]));
    settextattr($0f);
    write(format('  = %5d',[max]));
    writeln;
end;
readln;
settextattr(ta);
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'Show');
end;
finally
  LogLeaveProc('Show',LOG_LEVEL_MAJOR);
end;
end;

procedure doHelp;
var i:integer;
begin
settextattr($0f);
writeln(format('%23s',['IJEhelp']));
settextattr($07);
writeln(format('%15s   Description    Format',['Command']));
for i:=1 to nhelp do begin
    writeln(format('%15s - %s: >%s',[help[i,1],help[i,2],help[i,3]]));
    if i mod (CurrentRows-3)=CurrentRows-5 then begin
       write('  more...');
       readln;
    end;
end;
writeln;
end;

procedure DoMac;
var f:text;
    auto:boolean;
    s:string;
    mfn:string;
    ch:char;
begin
LogEnterProc('DoMac',LOG_LEVEL_MAJOR);
try
try
//Code starts
  if (narg<1)or(narg>2) then
     raise eIJEerror.Create('','','Usage: mac <macros-name> [AUTO]');

  auto:=false;
  if narg=2 then begin
     if arg[2]<>'AUTO' then
        raise exception.Create('Usage: mac <macros-name> [AUTO]');
     auto:=true;
  end;

  mfn:=cfg.macp+arg[1];
  if pos('.',arg[1])=0 then
     mfn:=mfn+'.mac';
  if not fileexists(mfn) then
     raise exception.Create('Macros file '+mfn+' not found.');
     
  writeln;
  logwriteln('Mac '+mfn+' started',LOG_LEVEL_MAJOR);
  assign(f,mfn);reset(f);
  while not seekeof(f) do
        try
          try
            lookup;
            updatetable;
          except
            on e:exception do
               raise eIJEerror.CreateAppendPath(e,'','Error during lookup or updatetable');
          end;
          readln(f,s);
          parsecmd(s);
          writeln;
          write('\$0f;(MAC active):\*;');
          writeprompt($08);
          settextattr($0f);
          writeln(s);
          settextattr($07);
          if (not auto) then begin
             write('Press Enter to continue macros or Esc to break... ');
             repeat
               ch:=readkey;
               if ch in [#27,#13] then
                  break;
               write(#7);
             until false;
             if ch=#27 then begin
                writeln;
                warning('Interrupted');
                break;
             end;
             gotoxy(1,wherey);
             write('                                                    ');
             gotoxy(1,wherey);
          end;
          docmd;
          writeln;
        except
          on e:exception do begin
             ShowError(e);
             if not ask('Continue macros?') then begin
                warning('Interrupted');
                break;
             end;
          end;
        end;
  close(f);
  writeln;
  writeln('Macros finished');
  logwriteln('Mac finished',LOG_LEVEL_MAJOR);
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'DoMac','Error while executing command');
end;
finally
  LogLeaveProc('DoMac',LOG_LEVEL_MAJOR);
end;
end;

procedure cd;
var s:string;
begin
LogEnterProc('CD',LOG_LEVEL_MAJOR);
try
try
//Code starts
if narg<>1 then 
   raise exception.Create('Usage: cd <where-to>');
if arg[1][1]='\' then begin
   cur.depth:=0;
   arg[1]:=copy(arg[1],2,length(arg[1])-1);
end;
while arg[1]<>'' do begin
   split(arg[1],s,'\');
   if s='..' then begin
     if cur.depth>=1 then dec(cur.depth)
     else raise exception.Create('It is the highest level!');
   end else begin
       if cur.depth=3 then
          raise exception.Create('It is the lowest level!');
       inc(cur.depth);
       case cur.depth of
            1:cur.b:=s;
            2:cur.d:=s;
            3:cur.t:=s;
       end;
   end;
end;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'CD');
end;
finally
  LogLeaveProc('CD',LOG_LEVEL_MAJOR);
end;
end;

function ishere(a:integer):boolean;
begin
if (a<=0)or(a>nsol) then begin
    ishere:=false;
    exit;
end;
case cur.depth of
     0:ishere:=true;
     1:ishere:=cur.b=sol[a].boy;
     2:ishere:=(cur.b=sol[a].boy)and(cur.d=sol[a].day);
     3:ishere:=(cur.b=sol[a].boy)and(cur.d=sol[a].day)and(cur.t=sol[a].task);
     else eIJEerror.Create('Internal error','IsHere: ','Internal error: Strange depth!');
end;
end;

procedure doDelete;
var ds:tUISdeleteSolution;
    ok:tALLok;
    i:integer;
begin
LogEnterProc('Delete',LOG_LEVEL_MAJOR);
try
try
//Code starts
fillchar(ds,sizeof(ds),0);
ds.typ:=UIS_DELETESOLUTION;

if cur.depth<>3 then
   raise eIJEerror.Create('Can''t delete solution','','Select solution first (use cd)!');
i:=findheresol;
if i=0 then
   raise eIJEerror.Create('Can''t delete solution','','Here isn''t any solution!');
if not ask('Are you sure to delete '+sol[i].fname+'?') then begin
   logwriteln('Not confirmed, not deleted',LOG_LEVEL_MAJOR);
   exit;
end;
ds.num:=i;

SendToSocket(sock,ds,sizeof(ds));
RecvFromSocket(sock,ok,sizeof(ok),SOCK_ACCEPTERROR,sizeof(ok));
if ok.typ<>ALL_OK then
   raise eIJEerror.Create('OK not recieved','','OK message not recieved in reply to Delete');

writeln('Solution was successfully deleted');
Lookup;
logwriteln('OK',LOG_LEVEL_MINOR);
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'Delete');
end;
finally
  LogLeaveProc('Delete',LOG_LEVEL_MAJOR);
end;
end;

function findheresol:integer;
var i:integer;
begin
LogEnterProc('FindHereSol',LOG_LEVEL_MINOR);
try
try
//Code starts
result:=0;
for i:=nsol downto 1 do
    if ishere(i) then
       result:=i;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'FindHereSol');
end;
finally
  LogLeaveProc('FindHereSol',LOG_LEVEL_MINOR,inttostr(result));
end;
end;

procedure Archive;
var ar:tUISarchiveSolution;
    ok:tALLok;
    i:integer;
begin
LogEnterProc('Archive',LOG_LEVEL_MAJOR);
try
try
//Code starts
fillchar(ar,sizeof(ar),0);
ar.typ:=UIS_ARCHIVESOLUTION;

if cur.depth<>3 then
   raise eIJEerror.Create('Can''t archive solution','','Select solution first (use cd)!');
i:=findheresol;
if i=0 then
   raise eIJEerror.Create('Can''t archive solution','','Here isn''t any solution!');
ar.num:=i;

SendToSocket(sock,ar,sizeof(ar));
RecvFromSocket(sock,ok,sizeof(ok),SOCK_ACCEPTERROR,sizeof(ok));
if ok.typ<>ALL_OK then
   raise eIJEerror.Create('OK not recieved','','OK message not recieved in reply to Archive');

writeln('Solution was successfully archived');
logwriteln('OK',LOG_LEVEL_MINOR);
Lookup;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'Archive');
end;
finally
  LogLeaveProc('Archive',LOG_LEVEL_MAJOR);
end;
end;

procedure Restore;
var rs:tUISrestoreSolution;
    ans:tMSGbuffer;
    ok:tALLok absolute ans;
    rds:tSUIrestoredSolution absolute ans;
begin
LogEnterProc('Restore',LOG_LEVEL_MAJOR);
try
try
//Code starts
fillchar(rs,sizeof(rs),0);
rs.typ:=UIS_RESTORESOLUTION;

if narg<>3 then
   raise exception.Create('Must be exactly 3 args');
StrToArray(rs.mb,arg[1],sizeof(rs.mb));
StrToArray(rs.md,arg[2],sizeof(rs.md));
StrToArray(rs.mt,arg[3],sizeof(rs.mt));

SendToSocket(sock,rs,sizeof(rs));
repeat
  RecvFromSocket(sock,ans,sizeof(ans),SOCK_ACCEPTERROR);
  case ans.typ of
       ALL_OK:break;
       SUI_RESTOREDSOLUTION:writeln(rds.fname);
       else raise eIJEerror.Create('Strange server answer','','Strange server answer in reply to Restore: %d',[ans.typ]);
  end;
until false;

writeln('Solution(s) was(were) successfully restored');
logwriteln('OK',LOG_LEVEL_MINOR);
Lookup;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'Restore');
end;
finally
  LogLeaveProc('Restore',LOG_LEVEL_MAJOR);
end;
end;

procedure GetPoints;
var i,j,k:integer;
    x:integer;
begin
LogEnterProc('GetPoints',LOG_LEVEL_MAJOR);
try
try
//Code starts
  UpdateTable;
  
  if cur.depth<>3 then
     raise exception.Create('Select then solution first!');

  i:=findboy(table,cur.b);
  if i=0 then
     raise exception.Create('Unknown boy');
  j:=findtask(table,maketask(cur.d,cur.t));
  if j=0 then
     raise exception.Create('Unknown task');

  k:=StrToInt(arg[1]);
  if (k<-1)or(k>1) then
     raise exception.Create('Wrong argument');
  case k of
       -1:x:=table.t[i,j].minus;
       0:x:=table.t[i,j].pts;
       1:x:=table.t[i,j].res;
  end;
  write(format('table[%d,%d,%d]=',[i,j,k]));
  if x in [minres..maxres] then begin
     write(stext(tresult(x))+'=');
  end;
  writeln(IntToStr(x));

//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'GetPoints');
end;
finally
  LogLeaveProc('GetPoints',LOG_LEVEL_MAJOR,IntToStr(x));
end;
end;

procedure SetPoints;
var sp:tUISsetPoints;
    ok:tALLok;
begin
LogEnterProc('SetPoints',LOG_LEVEL_MAJOR);
try
try
//Code starts
fillchar(sp,sizeof(sp),0);
sp.typ:=UIS_SETPOINTS;

if cur.depth<>3 then
   raise exception.Create('Select then solution first!');
sp.b:=findboy(table,cur.b);
if sp.b=0 then
   raise exception.Create('Unknown boy');
sp.t:=findtask(table,maketask(cur.d,cur.t));
if sp.t=0 then
   raise exception.Create('Unknown task');

sp.k:=StrToInt(arg[1]);
if (sp.k<-1)or(sp.k>1) then
   raise exception.Create('Wrong first argument');

try
  sp.x:=StrToInt(arg[2]);
except
  sp.x:=STextToResult(arg[2]);
end;

SendToSocket(sock,sp,sizeof(sp));
RecvFromSocket(sock,ok,sizeof(ok),SOCK_ACCEPTERROR,sizeof(ok));
if ok.typ<>ALL_OK then
   raise eIJEerror.Create('OK not recieved','','OK message not recieved in reply to SetPoints');

writeln('Table was successfully changed');
logwriteln('OK',LOG_LEVEL_MINOR);
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'SetPoints');
end;
finally
  LogLeaveProc('SetPoints',LOG_LEVEL_MAJOR);
end;
end;

procedure minus;
var sp:tUISsetPoints;
    ok:tALLok;
begin
LogEnterProc('Minus',LOG_LEVEL_MAJOR);
try
try
//Code starts
fillchar(sp,sizeof(sp),0);
sp.typ:=UIS_SETPOINTS;

UpdateTable;
if cur.depth<>3 then
   raise exception.Create('Select then solution first!');
sp.b:=findboy(table,cur.b);
if sp.b=0 then
   raise exception.Create('Unknown boy');
sp.t:=findtask(table,maketask(cur.d,cur.t));
if sp.t=0 then
   raise exception.Create('Unknown task');
sp.k:=-1;

writeln(format('Current minus pts: %d',[table.t[sp.b,sp.t].minus]));
write('How many pts to minus (in total)? ');
readln(sp.x);
logwriteln(format('Minusing %d pts',[sp.x]),LOG_LEVEL_MINOR);

SendToSocket(sock,sp,sizeof(sp));
RecvFromSocket(sock,ok,sizeof(ok),SOCK_ACCEPTERROR,sizeof(ok));
if ok.typ<>ALL_OK then
   raise eIJEerror.Create('OK not recieved','','OK message not recieved in reply to SetPoints');

writeln('Table was successfully changed');
logwriteln('OK',LOG_LEVEL_MINOR);
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'Minus');
end;
finally
  LogLeaveProc('Minus',LOG_LEVEL_MAJOR);
end;
end;

function ParseTestSet(s:string):tTestSet;
var cur:integer;
    a,b:integer;
begin
LogEnterProc('ParseTestSet',LOG_LEVEL_Minor);
try
try
//Code starts
result:=[];
s:=s+','#0;cur:=1;
while s[cur]<>#0 do begin
      try
        case s[cur] of
             '[':begin
                    inc(cur);
                    a:=0;
                    while s[cur] in ['0'..'9'] do begin
                          a:=a*10+ord(s[cur])-48;inc(cur);
                    end;
                    case s[cur] of
                         '-':inc(cur);
                         '.':inc(cur,2);{for '..'}
                         else raise exception.Create('Strange symbol: ''-'' or ''.'' expected');
                    end;
                    b:=0;
                    while s[cur] in ['0'..'9'] do begin
                          b:=b*10+ord(s[cur])-48;inc(cur);
                    end;
                    if s[cur]<>']' then raise exception.Create(''']'' expected');
                    inc(cur);
                    if s[cur]<>',' then raise exception.Create(''','' excepted');
                    inc(cur);
                    result:=result+[a..b];
             end;
             '0'..'9':begin
                        a:=0;
                        while s[cur] in ['0'..'9'] do begin
                              a:=a*10+ord(s[cur])-48;inc(cur);
                        end;
                        if s[cur] in ['-','.'] then begin
                           case s[cur] of
                                '-':inc(cur);
                                '.':inc(cur,2);
                           end;
                           b:=0;
                           while s[cur] in ['0'..'9'] do begin
                                 b:=b*10+ord(s[cur])-48;inc(cur);
                           end;
                           result:=result+[a..b];
                        end else
                           result:=result+[a];
                        if s[cur]<>',' then raise exception.Create(''','' excepted');
                        inc(cur);
                      end;
             else raise exception.Create('Strange symbol');
        end;
      except
        on e:exception do
           raise Exception.CreateFmt(e.Message+' in position %d',[cur]);
      end;
end;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'ParseTestSet');
end;
finally
  LogLeaveProc('ParseTestSet',LOG_LEVEL_MINOR);
end;
end;

procedure FollowTesting;
var msg:tMSGbuffer;
    err:tALLeIJEerror absolute msg;
    co:tTCScompilerOutput absolute msg;
    tr:tTCStestResult absolute msg;
    cs:tTCScompileStarted absolute msg;
    ts:tTCStestingStarted absolute msg;
    tf:tTCStestingFinished absolute msg;
    st:tTCStestingStatus absolute msg;
    ti:tTCStestingInfo absolute msg;
    tiSave:tTCStestingInfo;
    state:(_wait,_compile,_test,_eval);
    timeString:string;
    evalChanged:boolean;
    hisres:array[1..maxtests] of tTCStestResult;
    i:integer;
    allTested:boolean;
    ub:tALLuserBreak;
    lasttime:double;
    needclean:boolean;

function FormatRunTimes:string;
var stime,sttime,smem:string;
begin
if st.time>-0.01 then
   stime:=format('%1.2fs',[st.time]);
if st.totalTime>-0.01 then
   sttime:=format(' (%1.2fs passed)',[st.totalTime]);
if st.mem>=0 then
   smem:=format('%d Kb used',[round(st.mem/1024)]);
result:=stime+sttime;
if (result<>'')and(smem<>'') then
   result:=result+', ';
result:=result+smem;
if result<>'' then
   result:=': '+result;
end;

procedure CleanLine;
var s:string;
    i:integer;
begin
s:='';
for i:=Wherex+1 to CurrentCols-1 do
    s:=s+' ';
write(s,false);
gotoxy(8,WhereY);
end;

begin
LogEnterProc('FollowTesting',LOG_LEVEL_MINOR);
try
try
//Code starts
ub.typ:=ALL_USERBREAK;

state:=_wait;
lasttime:=-1;
writeln;
writeln('\$0f;Solution is waiting in TestQueue...\*;');
repeat
  if keypressed and (readkey=#27)then
     SendToSocket(sock,ub,sizeof(ub));
  if state=_wait then
     RecvFromSocket(sock,msg,sizeof(msg),0,0,TESTING_FIRSTWAITTIME)//this can also include waiting in testQueue, so waiting here may be long...
  else
     RecvFromSocket(sock,msg,sizeof(msg),0,0,TESTING_WAITTIME);
//  writeln(format('Message type %d recieved',[msg.typ]));
  case msg.typ of
       TCS_TESTINGINFO:tiSave:=ti;
       TCS_TESTINGFINISHED:begin
                            if tf.res=_ok then begin
                              settextattr($07);
                              writeln;
                              write('RESULT: ');
                              for i:=1 to tiSave.tests do begin
                                  if not(hisres[i].res in [_nt,_ns]) then
                                     write(format('\$%x;%2d\*;+',[attrib(hisres[i].res),hisres[i].pts]))
                                  else write(' .+');
                              end;
                              write(#8' = ');
                              writeln(format('\$0f;%4d\$07;',[tf.pts]));
                              write('MAX:    ');
                              alltested:=true;
                              for i:=1 to tiSave.tests do
                                  if hisres[i].res<>_nt then
                                     write(format('%2d+',[hisres[i].max]))
                                  else begin
                                       write(format('\$08;%2d\*;+',[hisres[i].max]));
                                       alltested:=false;
                                  end;
                              writeln(format(#8' = %4d',[tf.max]));
                              if alltested then begin
                                 if tf.pts=tf.max then
                                    writeln('\$0a;Congratulation with maximal sum!')
                                 else if tf.pts>0.6*tf.max then
                                     writeln('\$02;Congratulation! It''s a good result!')
                                 else
                                     writeln('\$07;So small sum?!');
                              end;
                              settextattr($07);
                            end;
                            writeln;
                            writeln('\$0f;Testing finished\*;'); 
                            break;
                           end; 
       ALL_EIJEERROR:ShowErrorToConsole(eIJEerror.Create(err.name,err.procpath,err.text));
       TCS_COMPILESTARTED:begin
                            state:=_compile;   
                            writeln;   
                            writeln(format('\$0f;Compiling %s...\*;',[cs.fname]));
                            writeln;
                            writeln('>'+cs.cmdline,false);
                          end;
       TCS_COMPILEROUTPUT:writeln(co.output,false);
       TCS_TESTRESULT:case state of
                      _compile:begin
                         writeln;
                         writeln(format('*\$%x; %s \$07;* %s',[attrib(tr.res),stext(tr.res),ltext(tr.res)]));
                         writeln;
                      end;
                      _test:begin
                          timestring:=format('%5.2fs',[tr.time]);
                          if tr.time<0 then begin
                             timestring:=StringOfChar(' ',length(timestring));
                             timestring[length(timestring) div 2]:='-';
                          end;
                          CleanLine;
                          writeln(format('\$%x;%s\$07; * %2d/%-2d * %s * %s',
                             [attrib(tr.res),stext(tr.res),tr.pts,tr.max,timestring,tr.text]));
                          hisres[tr.id]:=tr;
                      end;
                      _eval:begin
                          if not evalchanged then begin
                             writeln;
                             writeln('\$0f;Changed by evaluator:\*;');
                             evalchanged:=true;
                          end;
                          writeln(format('\$07;N%3d * (\$%x;%s\*;) -> \$%x;%s\$07; * %2d/%-2d * %s',
                            [tr.id,attrib(hisres[tr.id].res) and (not $08),stext(hisres[tr.id].res),
                            attrib(tr.res),stext(tr.res),tr.pts,tr.max,
                            tr.evaltext]));
                          hisres[tr.id]:=tr;
                      end;
                      end;
       TCS_TESTINGSTARTED:begin
                      state:=_test;         
                      settextattr($0f);
                      writeln('Testing...');
                      writeln('Solution:         '+tiSave.fname);
                      writeln('Problem:          '+tiSave.problem+' ('+tiSave.pname+'); type '+tiSave.tasktype);
                      writeln('Number of tests:  '+inttostr(tiSave.tests));
                      writeln('Max points:       '+inttostr(tiSave.max));
                      writeln('Files:            '+tiSave.inf+'/'+tiSave.ouf);
                      writeln('Time limit:       '+inttostr(tiSave.tl)+' ms');
                      writeln('Memory limit:     '+inttostr(tiSave.ml)+' b');
                      writeln;
                      settextattr($07);
                    end;
       TCS_EVALSTARTED:begin
                      state:=_eval;
                      evalChanged:=false;
                      end;
       TCS_TESTINGSTATUS:begin
                      assert(state=_test);
                      needclean:=true;
                      case st.status of
                           _started:   write(format('N%3d *',
                                           [st.id]));
                           _copy:      write('Copying test data...');
                           _run:       if st.time>lasttime+0.3 then begin
                                          write(format('Running %s%s...',
                                                     [tiSave.fname,FormatRunTimes]));
                                          needclean:=true;
                                          lasttime:=st.time;
                                       end else needclean:=false;   
                           _copyoutput:write('Copying output file...');
                           _check:     write('Checking answer...');
                      end;
                      if needclean then CleanLine;
                    end;
  end;
until false;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'FollowTesting');
end;
finally
  LogLeaveProc('FollowTesting',LOG_LEVEL_MAJOR);
end;
end;

procedure CT;
var ts:tUIStestSolution;
    cargs:string;
    i:integer;
    msg:tMSGbuffer;
    ok:tALLok absolute msg;
    wa:tALLwarning absolute msg;
begin
LogEnterProc('CT',LOG_LEVEL_MAJOR);
try
try
//Code starts
fillchar(ts,sizeof(ts),0);
ts.typ:=UIS_TESTSOLUTION;
ts.gtid:=GenerateGTID;

if cur.depth<>3 then
   raise exception.Create('Select the solution first!');
ts.num:=findheresol;
if ts.num=0 then
   raise exception.Create('There isn''t any solution');
if findtask(table,maketask(sol[ts.num].day,sol[ts.num].task))=0 then begin
   warning('Unknown task');
   if ask('Add task to table?') then
      addtask(maketask(sol[ts.num].day,sol[ts.num].task));
end;
if findboy(table,sol[ts.num].boy)=0 then begin
   warning('Unknown contestant');
   if ask('Add contestant to table?') then
      addboy(sol[ts.num].boy);
end;
ts.synchro:=true;
ts.testset:=[];

cargs:='';
i:=1;
while i<=narg do begin
      if UpperCase(arg[i])='-AS' then begin
         ts.synchro:=false;
         inc(i);
         continue;
      end;
      if arg[i]='--' then begin
         for i:=i+1 to narg do
             cargs:=cargs+arg[i]+' ';
         break;
      end;
      //assume this arg is a testset
      ts.testset:=ts.testset+ParseTestSet(arg[i]);
      inc(i);
end;
if ts.testset=[] then
   ts.testset:=[0..255];
StrToArray(ts.args,cargs,sizeof(ts.args));

SendToSocket(sock,ts,sizeof(ts));
repeat
  RecvFromSocket(sock,msg,sizeof(msg),SOCK_ACCEPTERROR,0);
  case msg.typ of
       ALL_OK:break;
       ALL_WARNING:warning(wa.text);
       else
         raise eIJEerror.Create('OK not recieved','','OK message not recieved in reply to TestSolution');
  end;
until false;
writeln;
writeln('Solution has been successfully added to test queue');

if ts.synchro then
   FollowTesting
else writeln('In asyncro mode you can continue working while the solution is being tested');

//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'CT');
end;
finally
  LogLeaveProc('CT',LOG_LEVEL_MAJOR);
end;
end;

procedure TestMask;
var nn:integer;
    ts:tUIStestSolution;
    i:integer;
    msg:tMSGbuffer;
    ok:tALLok absolute msg;
    wa:tALLwarning absolute msg;
begin
LogEnterProc('TestMask',LOG_LEVEL_MAJOR);
try
try
//Code starts
fillchar(ts,sizeof(ts),0);
ts.typ:=UIS_TESTSOLUTION;

if (narg<3)or(narg>4) then
   raise exception.Create('Usage: <contestant-mask> <day-mask> <test-mask> [ARCHIVE]');
if narg=4 then begin
   if arg[4]='ARCHIVE' then
      ts.archive:=true
   else raise exception.Create('ARCHIVE expected as 4th argument');
end;
for i:=1 to nsol do begin
    if mask(arg[1],sol[i].boy) and mask(arg[2],sol[i].day) and mask(arg[3],sol[i].task) then begin
       writeln(format('Solution %d: %s:%s:%s...',[i,sol[i].boy,sol[i].Day,sol[i].task]));
       inc(nn);
       ts.gtid:=GenerateGTID;//each time the new
       ts.num:=i;
       ts.testset:=[0..255];
       ts.synchro:=false;
       SendToSocket(sock,ts,sizeof(ts));
       repeat
         RecvFromSocket(sock,msg,sizeof(msg),SOCK_ACCEPTERROR,0);
         case msg.typ of
              ALL_OK:break;
              ALL_WARNING:warning(wa.text);
              else
                raise eIJEerror.Create('OK not recieved','','OK message not recieved in reply to TestSolution');
         end;
       until false;
       writeln;
       writeln(format('Solution %d: %s:%s:%s has been successfully added to test queue',[i,sol[i].boy,sol[i].Day,sol[i].task]));
       writeln;
    end;
end;//for i:=1 to nsol
writeln(format('%d solutions added to testing queue',[nn]));
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'TestMask');
end;
finally
  LogLeaveProc('TestMask',LOG_LEVEL_MAJOR);
end;
end;

procedure About;
var ar:tUISaboutRequest;
    ab:tALLabout;
    ss:string;
    i:integer;
begin
LogEnterProc('About',LOG_LEVEL_MAJOR);
try
try
//Code starts
fillchar(ar,sizeof(ar),0);
ar.typ:=UIS_ABOUTREQUEST;

writeln;
writeln(format('\$0f;This is IJE V: The Integrated Judging Environment %s\*;',[ije_ver_full]));
writeln('(C) Kalinin Petr, 2002-2008');
writeln;
writeln('\$0f;UI Classic\*;');
write(format('The UI Classic exe file (%s) was compiled from revision %s, at %s',[paramstr(0),IJE_REV,IJE_COMPILETIME]));
if IJE_LOCALMODIF then 
   write(' (with local modifications)');
writeln;
writeln;
SendToSocket(sock,ar,sizeof(ar));
RecvFromSocket(sock,ab,sizeof(ab),SOCK_ACCEPTERROR,sizeof(ab));
ss:='';
for i:=0 to sizeof(ab.text)-1 do
    case ab.text[i] of
         #0:;
         #13:ss:=ss+#13#10;
         else ss:=ss+ab.text[i];
    end;
writeln(ss);
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'About');
end;
finally
  LogLeaveProc('About',LOG_LEVEL_MINOR);
end;
end;

procedure DoMode;
var md:tUISmode;
    ma:tSUImodeAnswer;
    i:integer;
begin
LogEnterProc('DoMode',LOG_LEVEL_MAJOR);
try
try
//Code starts
fillchar(md,sizeof(md),0);
md.typ:=UIS_MODE;

if (narg<>0)and(narg<>2) then
   raise exception.Create('Usage: MODE [{ADD|DELETE} <mode-name>]');
if narg=2 then begin
   for i:=0 to nMode-1 do
       if arg[2]=UpperCase(ModeName[i]) then
          md.mode:=1 shl i;
   if md.mode=0 then
      raise exception.CreateFmt('Unknown mode ''%s''',[arg[2]]);
   if arg[1]='ADD' then md.cmd:=1
   else if arg[1]='DELETE' then md.cmd:=-1
   else raise exception.Create('Usage: MODE [{ADD|DELETE} <mode-name>]');
end;
if md.mode and SMODE_REALTESTING<>0 then begin
   Warning('You shouldn''t work with mode RealTesting directly; consider using rload and load. You should continue only if you fully understand what you are doing!');
   if not ask('Continue?') then
      exit;
end;
SendToSocket(sock,md,sizeof(md));
RecvFromSocket(sock,ma,sizeof(ma),SOCK_ACCEPTERROR,sizeof(ma));
writeln('Current modes:');
for i:=0 to nMode-1 do
    if ma.mode and (1 shl i)<>0 then
       writeln(ModeName[i]);
if ma.mode=0 then
   writeln('(none)');
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'DoMode');
end;
finally
  LogLeaveProc('DoMode',LOG_LEVEL_MAJOR);
end;
end;

procedure UpdateMode;
var md:tUISmode;
    ma:tSUImodeAnswer;
begin
LogEnterProc('UpdateMode',LOG_LEVEL_MINOR);
try
try
//Code starts
fillchar(md,sizeof(md),0);
md.typ:=UIS_MODE;

SendToSocket(sock,md,sizeof(md));
RecvFromSocket(sock,ma,sizeof(ma),SOCK_ACCEPTERROR,sizeof(ma));
mode:=ma.mode;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'UpdateMode');
end;
finally
  LogLeaveProc('UpdateMode',LOG_LEVEL_MINOR);
end;
end;

procedure killTask;
var kt:tUISkillTask;
    ka:tSUIkillTaskAnswer;
begin
LogEnterProc('KillTask',LOG_LEVEL_MAJOR);
try
try
//Code starts
fillchar(kt,sizeof(kt),0);
kt.typ:=UIS_KILLTASK;

if narg<>1 then
   raise exception.Create('Usage: killtask <task-id>');
StrToArray(kt.task,arg[1],sizeof(kt.task));

SendToSocket(Sock,kt,sizeof(kt));
RecvFromSocket(sock,ka,sizeof(ka),SOCK_ACCEPTERROR,sizeof(ka));
if ka.typ<>SUI_KILLTASKANSWER then
   raise eIJEerror.Create('KILLTASKANSWER not recieved','','KILLTASKANSWER message not recieved in reply to KillTask');
writeln(format('%d tasks successfully killed',[ka.nkilled]));
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'KillTask');
end;
finally
  LogLeaveProc('KillTask',LOG_LEVEL_MAJOR);
end;
end;

procedure ShutDown;
var sd:tALLshutdown;
    sa:tALLshutdownAnswer;
begin
LogEnterProc('ShutDown',LOG_LEVEL_MAJOR);
try
try
//Code starts
fillchar(sd,sizeof(sd),0);
sd.typ:=ALL_shutdown;

SendToSocket(Sock,sd,sizeof(sd));
RecvFromSocket(Sock,sa,sizeof(sa),SOCK_ACCEPTERROR,sizeof(sa));
if sa.typ<>ALL_SHUTDOWNANSWER then
   raise eIJEerror.Create('SHUTDOWNANSWER not recieved','','SHUTDOWNANSWER message not recieved in reply to ShutDown');
if not sa.ok then
   raise eIJEerror.create('Can''t shutdown','','Can''t shutdown now: '+sa.reason);
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'ShutDown');
end;
finally
  LogLeaveProc('ShutDown',LOG_LEVEL_MAJOR);
end;
end;

procedure ReStart;
var rs:tALLrestart;
    ra:tALLrestartAnswer;
begin
LogEnterProc('Restart',LOG_LEVEL_MAJOR);
try
try
//Code starts
fillchar(rs,sizeof(rs),0);
rs.typ:=ALL_Restart;

SendToSocket(Sock,rs,sizeof(rs));
RecvFromSocket(Sock,ra,sizeof(ra),SOCK_ACCEPTERROR,sizeof(ra));
if ra.typ<>ALL_RestartANSWER then
   raise eIJEerror.Create('RESTARTANSWER not recieved','','RESTARTANSWER message not recieved in reply to Restart');
if not ra.ok then
   raise eIJEerror.create('Can''t restart','','Can''t restart now: '+ra.reason)
else loadSettings('ije_cfg.xml',cfg);
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'Restart');
end;
finally
  LogLeaveProc('Restart',LOG_LEVEL_MAJOR);
end;
end;

end.
