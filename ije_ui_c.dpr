{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O-,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ This file is part of IJE: the Integrated Judging Environment system }
{ (C) Kalinin Petr 2002-2008 }
{ $Id: ije_ui_c.dpr 202 2008-04-19 11:24:40Z *KAP* $ }
{$APPTYPE CONSOLE}
program ije_ui_c;
uses
  ShareMem,WinSock,Windows,SysUtils,
  crt32,ije_crt32,xmlije,ije_main,ijeconsts,ije_cmdline,ui_main,io,sock_ije;

var head:string;
begin
initLog('ije_ui_c.log');
LogEnterProc('IJEUIC',LOG_LEVEL_TOP);
try
try
//Code starts
LoadSettings('ije_cfg.xml',cfg);
if not ParseCmdLine(_uic) then
   exit;
ConsoleMode:=true;
MaximizeConsole;
settextattr($07);
clrscr;
head:=format('\$5f;%s%-*s%s\*;',[headleft,CurrentCols-length(headleft)-length(headright),ije_ver_full+' rev '+IJE_REV,headright]);
crt32.writelna(head);//To avoid WinToDOS
writeln(format('This is IJE V (IJE %s rev %s) UI Classic: The Integrated Judging Environment',[ije_ver_full,IJE_REV]));
writeln;
settitle(titlemain+' '+ije_ver_full);
fillchar(cur,sizeof(cur),0);

try
  InitSocket;
except
 on e:exception do begin
   ShowError(e);
   writeln;
   writeln('Press Enter...');
   readln;
   halt;
 end;
end;
try
  while true do begin
        try
          lookup;
          updatetable;
          UpdateMode;
        except
          on e:exception do
             raise eIJEerror.CreateAppendPath(e,'','Error during lookup or updatetable');
        end;
        try
          writeprompt;
          readcmd;
          docmd;
          if (cmd='EXIT')or(cmd='SHUTDOWN') then
             break;
        except
          on e:exception do begin
             if (e is eIJEerror) and (eIJEerror(e).name='') then
                eIJEerror(e).name:='Error while processing commamd';
             ShowError(e);
          end;
        end;
  end;
finally
  CloseSocket(sock);
end;
//Code ends
except
  on e:exception do begin
     LogError(e);
     ShowError(e);
  end;
end;
finally
  LogLeaveProc('IJEUIC',LOG_LEVEL_TOP);
end;
end.
