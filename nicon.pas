{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O-,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ (C) Kalinin Petr 2002-2008 }
{ $Id: nicon.pas 202 2008-04-19 11:24:40Z *KAP* $ }
unit nicon;

interface
uses ShellAPI,windows,sysutils,windows_xp;

type tNotifyIcon=class
         private
           uid:integer;
           hwnd:integer;
           procedure InitIconData(var i:_NOTIFYICONDATA_XP);
         public
           constructor Create(wnd:hwnd;id:uint);
           destructor Destroy;
           function SetIcon(ic:hicon):boolean;
           function SetMessage(msg:uint):boolean;
           function SetTip(s:string):boolean;
           function SetState(state,statemask:uint):boolean;
           function SetBalloon(s:string;title:string;time:uint;flags:uint):boolean;
         end;

implementation

{ tNotifyIcon }

constructor tNotifyIcon.Create(wnd: hwnd; id: uint);
var i:_NOTIFYICONDATA_XP;
begin
InitIconData(i);
i.hWnd:=wnd;
i.uID:=id;
uid:=id;
hwnd:=wnd;
Shell_NotifyIcon(NIM_ADD,@i);
end;

destructor tNotifyIcon.Destroy;
var i:_NOTIFYICONDATA_XP;
begin
InitIconData(i);
Shell_NotifyIcon(NIM_DELETE,@i);
end;

procedure tNotifyIcon.InitIconData(var i: _NOTIFYICONDATA_XP);
begin
fillchar(i,sizeof(i),0);
i.cbSize:=sizeof(i);
i.hWnd:=hwnd;
i.uID:=uid;
end;

function tNotifyIcon.SetIcon(ic: hicon):boolean;
var i:_NOTIFYICONDATA_XP;
begin
InitIconData(i);
i.uflags:=NIF_ICON;
i.hIcon:=ic;
result:=Shell_NotifyIcon(NIM_MODIFY,@i);
end;

function tNotifyIcon.SetMessage(msg: uint):boolean;
var i:_NOTIFYICONDATA_XP;
begin
InitIconData(i);
i.uFlags:=NIF_MESSAGE;
i.uCallbackMessage:=msg;
result:=Shell_NotifyIcon(NIM_MODIFY,@i);
end;

function tNotifyIcon.SetState(state, statemask: uint):boolean;
var i:_NOTIFYICONDATA_XP;
begin
InitIconData(i);
i.uFlags:=NIF_STATE;
i.dwState:=state;
i.dwStateMask:=statemask;
result:=Shell_NotifyIcon(NIM_MODIFY,@i);
end;

function tNotifyIcon.SetTip(s: string):boolean;
var i:_NOTIFYICONDATA_XP;
begin
InitIconData(i);

if length(s)>sizeof(i.szTip)-1 then
   raise exception.Create('tNotifyIcon.SetTip: The tooltip is too long');

i.uFlags:=NIF_TIP;
StrCopy(@i.szTip,PChar(s));
result:=Shell_NotifyIcon(NIM_MODIFY,@i)
end;

function tNotifyIcon.SetBalloon(s: string; title: string; time: uint; flags: uint):boolean;
var i:_NOTIFYICONDATA_XP;
begin
InitIconData(i);

if length(s)>sizeof(i.szInfo)-1 then
   raise exception.Create('tNotifyIcon.SetBalloon: The balloon tooltip is too long');
if length(title)>sizeof(i.szInfoTitle)-1 then
   raise exception.Create('tNotifyIcon.SetBalloon: The balloon tooltip title is too long');

i.uFlags:=NIF_INFO;
StrCopy(@i.szInfo,PChar(s));
i.uTimeOut:=time;
StrCopy(@i.szInfoTitle,PChar(title));
i.dwInfoFlags:=flags;
result:=Shell_NotifyIcon(NIM_MODIFY,@i);
end;


begin
end.