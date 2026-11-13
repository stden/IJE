{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O-,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ (C) Kalinin Petr 2002-2008 }
{ $Id: windows_xp.pas 202 2008-04-19 11:24:40Z *KAP* $ }
{$A-}//!!!
unit windows_xp;

interface
uses Messages,ShellAPI,windows;

type _NOTIFYICONDATA_XP=record
       cbSize:DWORD; 
       hWnd:HWnd; 
       uID:UINT; 
       uFlags:UINT; 
       uCallbackMessage:UINT; 
       hIcon:HICON; 
       szTip:array[0..127] of Char;
       dwState:dWord;
       dwStateMask:dWord;
       szInfo:array[0..255] of Char;
       uTimeOut:UInt;
       szInfoTitle:array[0..63] of Char; 
       dwInfoFlags:Dword; 
    end;
    pNotifyIconData_XP=^_NOTIFYICONDATA_XP; 
const NIM_ADD=$00000000;
      NIM_MODIFY=$00000001;
      NIM_DELETE=$00000002;
      NIM_SETFOCUS=$00000003;
      NIM_SETVERSION=$00000004;

      NIF_MESSAGE=$00000001;
      NIF_ICON=$00000002;
      NIF_TIP=$00000004;
      NIF_STATE=$00000008;
      NIF_INFO=$00000010;

      NOTIFYICON_VERSION=3;

      NIS_HIDDEN=$00000001;
      NIS_SHAREDICON=$00000002;
      
      NIIF_NONE=$00000000;
      NIIF_INFO=$00000001;
      NIIF_WARNING=$00000002;
      NIIF_ERROR=$00000003;
      NIIF_ICON_MASK=$0000000F;
      NIIF_NOSOUND=$00000010;

      NIN_SELECT=(WM_USER + 0);
      NINF_KEY=$1;
      NIN_KEYSELECT=(NIN_SELECT or NINF_KEY);
      NIN_BALLOONSHOW=(WM_USER + 2);
      NIN_BALLOONHIDE=(WM_USER + 3);
      NIN_BALLOONTIMEOUT=(WM_USER + 4);
      NIN_BALLOONUSERCLICK=(WM_USER + 5);
      
function GetConsoleWindow:HWnd; stdcall; external kernel32 name 'GetConsoleWindow';

implementation

begin
end.