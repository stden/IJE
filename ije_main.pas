{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O-,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ This file is part of IJE: the Integrated Judging Environment system }
{ (C) Kalinin Petr 2002-2008 }
{ $Id: ije_main.pas 202 2008-04-19 11:24:40Z *KAP* $ }
unit ije_main;

interface
uses SysUtils,
     ijeconsts,xmlije,ije_crt32;
var cfg:tSettings;
    IJEdir:string;

procedure Warning(s:string);
function FindComp(s:string):integer;
procedure LookUp(var nsol:integer;var sol:tSolDatas;dir:string='');
function MakeSol(b,d,p,ext:string):string;
function MakeTask(d,p:string):string;
procedure GetSolInfo(sol:string;var b,d,p,ext:string);
procedure GetTaskInfo(dp:string;var d,p:string);
procedure ShowErrorToConsole(e:exception);
procedure ArchiveSolution(sol:tSolData);

implementation

procedure Warning(s:string);
begin
logwriteln('!  Warning: '+s,LOG_LEVEL_0,false,false);
writeln(format('\$0e;! Warning: \*; %s',[s]));
end;

function FindComp(s:string):integer;
var i:integer;
begin
LogEnterProc('FindComp',LOG_LEVEL_MINOR,''''+s+'''');
try
try
//Code starts
for i:=1 to cfg.ncomp do
    if cfg.comp[i].ext=s then 
       break;
if (i>cfg.ncomp)or(cfg.comp[i].ext<>s) then
   raise eIJEerror.Create('','','Compiler for extension %s not found',[s]); 
findcomp:=i;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'FindComp');
end;
finally
  LogLeaveProc('FindComp',LOG_LEVEL_MINOR,IntToStr(result));
end;
end;

procedure lookup(var nsol:integer;var sol:tSolDatas;dir:string='');
var rec:tsearchrec;
    i:integer;
    b,d,p,ext:string;
    doserror:integer;
    name:string;
    dd:integer;
begin
LogEnterProc('LookUp',LOG_LEVEL_MINOR,'dir='+dir);
try
try
//Code starts
if dir='' then
   dir:=cfg.solp;
dd:=0;
for i:=1 to nsol do begin
    if not fileexists(dir+'\'+sol[i].fname+'.'+sol[i].ext) then
       inc(dd)
    else sol[i-dd]:=sol[i];
end;
nsol:=nsol-dd;
doserror:=findfirst(dir+'\*.*',$2f,rec);{Not dir!}
while doserror=0 do begin
      name:=UpperCase(rec.name);
      getsolinfo(name,b,d,p,ext);
      if b<>'' then begin
         inc(nsol);
         sol[nsol].boy:=b;
         sol[nsol].day:=d;
         sol[nsol].task:=p;
         sol[nsol].ext:=ext;
         sol[nsol].fname:=copy(name,1,length(name)-length(ext)-1);
         sol[nsol].dir:=dir;
         for i:=1 to nsol-1 do
             if (sol[nsol].fname=sol[i].fname) then begin
                dec(nsol);break;
             end;
      end;
      doserror:=findnext(rec);
end;
findclose(rec);
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'LookUp');
end;
finally
  LogLeaveProc('LookUp',LOG_LEVEL_MINOR);
end;
end;

function makesol(b,d,p,ext:string):string;
begin
makesol:=subs(cfg.solformat,b,d,p)+ext;
end;

function maketask(d,p:string):string;
begin
maketask:=subs(cfg.taskformat,'',d,p);
end;

procedure GetSolInfo(sol:string;var b,d,p,ext:string);
var i:integer;
    sformat:string;
begin
ext:=ExtractFileExt(sol);
delete(ext,1,1);
sformat:=cfg.solformat;
b:='';d:='';p:='';
if length(sol)<length(sformat) then
   exit;
for i:=1 to length(sformat) do begin
    case sformat[i] of
         '@':b:=b+sol[i];
         '#':d:=d+sol[i];
         '$':p:=p+sol[i];
         else if sol[i]<>sformat[i] then begin
              b:='';d:='';p:='';
              exit;
         end;
    end;
end;
end;

procedure GetTaskInfo(dp:string;var d,p:string);
var i:integer;
    sformat:string;
begin
LogEnterProc('GetTaskInfo',LOG_LEVEL_MINOR);
try
try
//Code starts
sformat:=cfg.taskformat;
d:='';p:='';
if length(dp)<>length(sformat) then
   raise eIJEerror.Create('Error in GetTaskInfo','','Different length of task name and task format: %s vs %s',[dp,sformat]);
for i:=1 to length(sformat) do begin
    case sformat[i] of
         '#':d:=d+dp[i];
         '$':p:=p+dp[i];
         else if dp[i]<>sformat[i] then
              raise eIJEerror.Create('Error in GetTaskInfo','','Wrong symbol in pos %d in taskname %s',[i,dp]);
    end;
end;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'GetTaskInfo('+dp+')');
end;
finally
  LogLeaveProc('GetTaskInfo',LOG_LEVEL_MINOR);
end;
end;

procedure ShowErrorToConsole(e:exception);
var ee:eIJEerror;
    msg:string;
begin
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

procedure ArchiveSolution(sol:tSolData);
var rec:tsearchrec;
    doserror:integer;
    ct:string;
begin
     doserror:=findfirst(sol.dir+sol.fname+'.*',$3f,rec);
ct:=maketask(sol.day,sol.task);
ForceDirectories(cfg.archivep+'\'+ct+'\');
while doserror=0 do begin
      ForceNoFile(cfg.archivep+'\'+ct+'\'+rec.name);
      MoveFile(sol.dir+'\'+rec.name,cfg.archivep+'\'+ct+'\'+rec.name);
      doserror:=findnext(rec);
end;
findclose(rec);
end;

begin
IJEdir:=GetCurrentDir;
end.

