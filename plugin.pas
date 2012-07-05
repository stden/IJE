{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O+,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ This file is part of IJE: the Integrated Judging Environment system }
{ (C) Kalinin Petr 2002-2008 }
{ $Id: plugin.pas 202 2008-04-19 11:24:40Z *KAP* $ }
unit plugin;
interface
uses iPlugin;
const MAX_PLUGIN=100;

procedure LoadPlugins(path:string);
procedure FreePlugins;

implementation
uses Windows,SysUtils,
     ije_main,ijeconsts,sock;
var plgin:array[1..MAX_PLUGIN] of tHandle;
    nPlgIn:integer;
type tPluginInit=function (data:tPluginData):boolean;//check proc init in LoadPlugin if this changed!

procedure LoadPlugins(path:string);
var rec:TSearchRec;
    a:tPluginData;
    _init:tPluginInit;

function init(data:tPluginData):boolean;
begin
try
  result:=_init(data);
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'init');
end;
end;


begin
LogEnterProc('LoadPlugins('+path+')',LOG_LEVEL_MINOR);
try
try
//Code starts
a.cfg:=cfg;
a.SetSockCB:=@SetSockCB;
if FindFirst(path+'\*.dll',faAnyFile-faDirectory,rec)=0 then begin
   repeat
     inc(nPlgIn);
     if nPlgIn>MAX_PLUGIN then
        raise exception.CreateFmt('Not enougn place for plugin %s',[path+'\'+rec.Name]);
     logwrite('Found plugin '+path+'\'+rec.name+'... ',LOG_LEVEL_MINOR);
     a.selfname:=path+'\'+rec.name;
     plgin[nPlgin]:=LoadDLL(PChar(path+'\'+rec.name));
     try
       @_init:=LoadDLLproc(plgin[nPlgin],'init');
       if not init(a) then begin
          logwrite('INIT returned false!...',LOG_LEVEL_MINOR);
          FreeLibrary(plgin[nPlgin]);
          dec(nPlgin);
       end;
     except
       FreeLibrary(plgin[nPlgin]);
       raise;
     end;
     logwriteln('ok',LOG_LEVEL_MINOR);
   until FindNext(rec)<>0;
   FindClose(rec);
end;
if FindFirst(path+'\*.*',faDirectory,rec)=0 then begin
   repeat
     if (rec.attr and faDirectory<>0)and(rec.name<>'..')and(rec.name<>'.') then
        LoadPlugins(path+'\'+rec.name);
   until FindNext(rec)<>0;
   findClose(rec);
end;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'LoadPlugins('+path+')');
end;
finally
  LogLeaveProc('LoadPlugins('+path+')',LOG_LEVEL_MINOR,format('%d plugins found',[nPlgIn]));
end;
end;

procedure FreePlugins;
var i:integer;
    free:procedure;
begin
LogEnterProc('FreePlugins',LOG_LEVEL_MINOR);
try
try
//Code starts
for i:=1 to nPlgIn do begin
    try
      free:=LoadDLlProc(plgin[i],'free');
      free;
    except;
    end;
    FreeLibrary(plgIn[i]);
end;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'FreePlugins');
end;
finally
  LogLeaveProc('FreePlugins',LOG_LEVEL_MINOR);
end;
end;


end.
