{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O+,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ This file is part of IJE: the Integrated Judging Environment system }
{ (C) Kalinin Petr 2002-2008 }
{ $Id: ije_cmdline.pas 202 2008-04-19 11:24:40Z *KAP* $ }
unit ije_cmdline;

interface

type tPrgType=(_server,_tc,_uic,_other);
function ParseCmdLine(prg_type:tPrgType):boolean;

implementation
uses Forms,Windows,SysUtils,
     ijeconsts,sock_ije,ije_main,crt32,xmlije;
const t_INTEGER=1;
      t_WORD=2;
      t_SWITCH=3;
type tCmdLineParam=record
                      param:string;//название параметра в ком. строке, lowercase, без - или /
                      name:string;
                      typ:integer;
                      addr:pointer;
                   end;
const NParams=10;
      Param:array[1..NParams] of tCmdLineParam=(
        (param:'stc';name:'(only for server) Start also a TC';typ:t_SWITCH;addr:@NeedSelfTC),
        (param:'console';name:'for TC: use console window'#13'for server: if used with -stc, start TC with -console parameter';typ:t_SWITCH;addr:@ConsoleMode),
        (param:'ll';name:'Max Log Level';typ:t_INTEGER;addr:@MaxLogLevel),
        (param:'acmconsole';name:'(only for server) Start console to display ACM monitor';typ:t_SWITCH;addr:@ACMconsoleMode),

        (param:'sdp';name:'Server datagram port';typ:t_WORD;addr:@SERVER_DGRAM_PORT),
        (param:'ssp';name:'Server stream port';typ:t_WORD;addr:@SERVER_STREAM_PORT),
        (param:'tdp';name:'TC datagram port';typ:t_WORD;addr:@TC_DGRAM_PORT),
        (param:'tsp';name:'TC stream port';typ:t_WORD;addr:@TC_STREAM_PORT),
        (param:'udp';name:'UI datagram port';typ:t_WORD;addr:@UI_DGRAM_PORT),
        (param:'usp';name:'UI stream port';typ:t_WORD;addr:@UI_STREAM_PORT)
        );

procedure ShowHelp;
const indent='     ';
var i,j:integer;
begin
AllocConsole;
InitConsole;
writelna(#13#10'\$0f;Command-line parameters for IJE:\*;'#13#10);
writeln('Each parameter can be specified with prefix - or /');
writeln('Non-switch parameters should be followed by a number'#13#10);
for i:=1 to NParams do begin
    writea(format('\$0e;-%0:s\*; or \$0e;/%0:s\*;',[param[i].param]));
    if param[i].typ=t_SWITCH then
       writelna(' \$0f;SWITCH\*;')
    else writeln;
    write(indent);
    for j:=1 to length(param[i].name) do
        if param[i].name[j]=#13 then begin
           writeln;write(indent);
        end else write(param[i].name[j]);
    writeln;
end;
readln;
FreeConsole;
end;

function ParseCmdLine(prg_type:tPrgType):boolean;
var i,j:integer;
    ss:string;
    val:string;
    cmdparam:array[1..100] of string;
    cmdparamc:integer;
    addcmdline:string;
label 1;
begin
LogEnterProc('ParseCmdLine',LOG_LEVEL_0);
try
try
//Code starts
result:=false;
case prg_type of
     _server:addcmdline:=cfg.defcmd.server;
     _tc:addcmdline:=cfg.defcmd.tc;
     _uic:addcmdline:=cfg.defcmd.uic;
end;
cmdparamc:=1;
fillchar(cmdparam,sizeof(cmdparam),0);
for i:=1 to length(addcmdline) do
    if (addcmdline[i]=' ') then begin
       if (cmdparam[cmdparamc]<>'') then
          inc(cmdparamc)
    end else cmdparam[cmdparamc]:=cmdparam[cmdparamc]+addcmdline[i];
if cmdparam[cmdparamc]='' then
   dec(cmdparamc);
for i:=1 to ParamCount do begin
    inc(cmdparamc);
    cmdparam[cmdparamc]:=ParamStr(i);
end;
for i:=1 to cmdparamc do
    if (cmdparam[i][1] in ['-','/']) then begin
       ss:=LowerCase(copy(cmdparam[i],2,length(cmdparam[i])-1));
       if (ss='h') or (ss='?') then begin
          LogWriteln('Parameter -? specified. Displaying help and exiting.',LOG_LEVEL_0);
          ShowHelp;
          exit;
       end;
       if (i=cmdparamc) then
          val:=''
       else
       val:=cmdparam[i+1];
       LogWriteln(format('Parameter %s specified: value %s...',[ss,val]),LOG_LEVEL_0);

       for j:=1 to NParams do
           if param[j].param=ss then begin
              LogWriteln(format('Parameter %s: index %d; name %s',[ss,j,param[j].name]),LOG_LEVEL_MINOR);
              if (val='')and(param[j].typ<>t_SWITCH) then
                 raise eIJEerror.Create('Wrong parameters given','','No value specified for parameter -%s',[ss]);
              try
                case param[j].typ of
                     t_INTEGER:(pInteger(param[j].addr))^:=StrToInt(val);
                     t_WORD:(pWord(param[j].addr))^:=StrToInt(val);
                     t_SWITCH:(pBoolean(param[j].addr))^:=true;
                     else raise eIJEerror.Create('Internal error','','Unknown type for parametr %s: type %d',[ss,param[j].typ]);
                end;
              except
                on e:exception do
                   if not (e is eIJEerror) then
                      raise eIJEerror.Create('Strange parameter','','Error while parsing value for parameter -%s (index %d): %s',[ss,i,e.Message]);
              end;
              goto 1;
           end;
       raise eIJEerror.Create('Unknown parameter','','Unknown parameter -%s (index %d)',[ss,i]);
       1:
    end;
result:=true;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'ParseCmdLine');
end;
finally
  LogLeaveProc('ParseCmdLine',LOG_LEVEL_0);
end;
end;

begin
end.
 