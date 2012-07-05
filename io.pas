{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O-,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ This file is part of IJE: the Integrated Judging Environment system }
{ (C) Kalinin Petr 2002-2008 }
{ $Id: io.pas 202 2008-04-19 11:24:40Z *KAP* $ }
unit io;
interface

uses Windows,SysUtils,
     ijeconsts,ije_main,xmlije;
//var table:ttable;

procedure Clean(var table:ttable);
function FindBoy(var table:ttable;s:string):integer;
function FindTask(var table:ttable;s:string):integer;
procedure LoadTable(var table:ttable;fname:string;dllName:string);
procedure SaveTable(var table:ttable;fname:string;dllName:string);
function Get(var table:ttable;b,t:integer):word;
procedure MoveTask(var table:ttable;a,b:integer);
procedure AddBoy(var table:ttable;id:string);
procedure AddTask(var table:ttable;id:string;ttype:char;pos:integer);

implementation
uses ije_crt32;

procedure Clean(var table:ttable);
begin
LogEnterProc('IO.Clean',LOG_LEVEL_MINOR);
try
try
//Code starts
fillchar(table,sizeof(table),0);
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'IO.clean');
end;
finally
  LogLeaveProc('IO.Clean',LOG_LEVEL_MINOR);
end;
end;

function findboy(var table:ttable;s:string):integer;
begin
result:=findString(table.nboy,table.boy,s);
end;

function findtask(var table:ttable;s:string):integer; overload;
begin
result:=findString(table.ntask,table.task,s);
end;

procedure LoadTable(var table:ttable;fname:string;dllName:string);
var dll:THandle;
    _LoadProc:procedure (fname:string;var table:ttable);
    _InitProc:procedure (var cfg:tSettings);

procedure LoadProc(fname:string;var table:ttable);
begin
try
  _LoadProc(fname,table);
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'LoadProc');
end;
end;

procedure InitProc(var cfg:tSettings);
begin
try
  _InitProc(cfg);
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'InitProc');
end;
end;

begin
LogEnterProc('LoadTable',LOG_LEVEL_MAJOR);
try
try
//Code starts
  dllName:='table_'+dllName+'.dll';
  write('Loading DLL "'+dllName+'"...');
  Dll:=ijeconsts.LoadDll(cfg.dllp+'table\'+dllName);
  try
    @_InitProc:=LoadDllProc(dll,'init',false);
    if @_initProc<>nil then begin
       write('initializing...');
       InitProc(cfg);
    end;
    @_LoadProc:=LoadDllProc(dll,'load');
    write('Loading...');
    LoadProc(cfg.resp+fname,table);
    writeln('done load');
    write(format('The table was loaded. %d problems, %d contestants',[table.ntask,table.nboy]));
    writeln;
  finally
    FreeLibrary(dll);
  end;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'LoadTable('+fname+','+dllName+')');
end;
finally
  LogLeaveProc('LoadTable',LOG_LEVEL_MAJOR);
end;
end;

procedure SaveTable(var table:ttable;fname:string;dllName:string);
var dll:THandle;
    _SaveProc:procedure (fname:string;var table:ttable);
    _InitProc:procedure (var cfg:tSettings);

procedure SaveProc(fname:string;var table:ttable);
begin
try
  _SaveProc(fname,table);
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'SaveProc');
end;
end;

procedure InitProc(var cfg:tSettings);
begin
try
  _InitProc(cfg);
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'InitProc');
end;
end;

begin
LogEnterProc('SaveTable',LOG_LEVEL_MAJOR);
try
try
//Code starts
  fname:=lowercase(fname);
  dllName:='table_'+dllName+'.dll';
  write('Saving DLL "'+dllName+'"...');
  Dll:=LoadDll(cfg.dllp+'table\'+dllName);
  try
  try
    @_InitProc:=LoadDllProc(dll,'init',false);
    if @_InitProc<>nil then begin
      write('initializing...');
      InitProc(cfg);
    end;
    @_SaveProc:=LoadDllProc(dll,'save');
    write('Saving...');
    SaveProc(cfg.resp+fname,table);
    writeln('done save');
  except//т.к., похоже, все exception, который идут из dll, портятся при FreeLibrary
    on e:exception do
       raise eIJEerror.CreateAppendPath(e,'');
  end;
  finally
    FreeLibrary(dll);
  end;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'SaveTable('+fname+','+dllName+')');
end;
finally
  LogLeaveProc('SaveTable',LOG_LEVEL_MAJOR);
end;
end;

function get(var table:ttable;b,t:integer):word;
begin
if table.t[b,t].pts>table.t[b,t].minus then
   get:=table.t[b,t].pts-table.t[b,t].minus
else get:=0;
end;

procedure MoveTask(var table:ttable;a,b:integer);
var i:integer;
begin
table.task[b]:=table.task[a];
for i:=1 to table.nboy do
    move(table.t[i,a],table.t[i,b],sizeof(table.t[i,a]));
table.tasktype[b]:=table.tasktype[a];
end;

procedure AddBoy(var table:ttable;id:string);
var i:integer;
begin
LogEnterProc('io.AddBoy',LOG_LEVEL_MINOR);
try
try
//Code starts
for i:=1 to table.nboy do
    if table.boy[i]=id  then
       raise eIJEerror.Create('','','Contestant %s already exists',[id]);
if table.nboy=maxboys then
   raise eIJEerror.Create('','','No place for new contestant');

inc(table.nboy);
table.boy[table.nboy]:=id;
for i:=1 to table.ntask do begin
    table.t[table.nboy,i].minus:=0;
    table.t[table.nboy,i].pts:=0;
    table.t[table.nboy,i].res:=_NS;
end;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'io.AddBoy');
end;
finally
  LogLeaveProc('io.AddBoy',LOG_LEVEL_MINOR);
end;
end;

procedure AddTask(var table:ttable;id:string;ttype:char;pos:integer);
var i:integer;
begin
LogEnterProc('io.AddTask',LOG_LEVEL_MINOR);
try
try
//Code starts
for i:=1 to table.ntask do
    if table.task[i]=id  then
       raise eIJEerror.Create('','','Task %s already exists',[id]);
       
if (pos<0)or(pos>table.ntask) then
   raise eIJEerror.Create('','','Strange task position: %d',[pos]);
if not (ttype in ['P','O']) then
   raise eIJEerror.Create('','','Unknown task type: %s',[ttype]);
if table.ntask=maxtasks then
   raise eIJEerror.Create('','','No place for new task');
for i:=table.ntask downto pos+1 do
    movetask(table,i,i+1);
inc(table.ntask);
table.task[pos+1]:=id;
table.tasktype[pos+1]:=ttype;
for i:=1 to table.nboy do begin
    table.t[i,pos+1].minus:=0;
    table.t[i,pos+1].pts:=0;
    table.t[i,pos+1].res:=_NS;
end;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'io.AddTask');
end;
finally
  LogLeaveProc('io.AddTask',LOG_LEVEL_MINOR);
end;
end;

end.
