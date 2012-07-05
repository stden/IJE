{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O-,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ This file is part of IJE: the Integrated Judging Environment system }
{ (C) Kalinin Petr 2002-2008 }
{ $Id: ije_crt32.pas 202 2008-04-19 11:24:40Z *KAP* $ }
unit ije_crt32;

interface

procedure write(s:string='';usecrt32:boolean=true;recode:boolean=true);
procedure writeln(s:string='';usecrt32:boolean=true;recode:boolean=true);
procedure gotoxy(x,y:integer);
Procedure SetTextAttr(c:byte);
function WhereX:integer;
function WhereY:integer;
Function CurrentCols:Integer;
Function CurrentRows:Integer;
procedure InitConsole;
procedure MaximizeConsole;
function ReadKey:char;
function TextAttr:byte;
procedure ClrScr;
function KeyPressed:boolean;


implementation
uses crt32,ijeconsts,windows;

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

function DosToWin(s:string):string;
var s1:pWideChar;
    s2:pChar;
begin
GetMem(s1,length(s)*4);
GetMem(s2,length(s)*4);
MultiByteToWideChar(866,0,PChar(s),-1,s1,length(s)*2);
WideCharToMultiByte(1251,0,s1,-1,s2,length(s)*4,nil,nil);
result:=s2;
FreeMem(s1);
FreeMem(s2);
end;

procedure write(s:string='';usecrt32:boolean=true;recode:boolean=true);
begin
if recode then 
   s:=WinToDos(s);
if ConsoleMode then begin
   if usecrt32 then
      writea(s)
   else system.write(s);
end;
end;

procedure writeln(s:string='';usecrt32:boolean=true;recode:boolean=true);
begin
if recode then
   s:=WinToDos(s);
if ConsoleMode then begin
   if usecrt32 then
      writelna(s)
   else system.writeln(s);
end;
end;

procedure gotoxy(x,y:integer);
begin
if ConsoleMode then
   crt32.GotoXY(x,y);
end;

Procedure SetTextAttr(c:byte);
begin
if ConsoleMode then
   crt32.SetTextAttr(c);
end;

function WhereX:integer;
begin
if ConsoleMode then
   result:=crt32.WhereX
else result:=1;
end;

function wherey:integer;
begin
if ConsoleMode then
   result:=crt32.WhereY
else result:=1;
end;

Function CurrentCols:Integer;
begin
if ConsoleMode then
   result:=crt32.CurrentCols
else result:=100;
end;

Function CurrentRows:Integer;
begin
if ConsoleMode then
   result:=crt32.CurrentRows
else result:=100;
end;

procedure InitConsole;
begin
if ConsoleMode then
   crt32.InitConsole;
end;

procedure MaximizeConsole;
begin
if ConsoleMode then
   crt32.maximizeConsole;
end;

function ReadKey:char;
begin
if ConsoleMode then
   result:=crt32.readkey
else raise eIJEerror.Create('Can''t readkey','ReadKey: ','Not in console mode: can''t readkey');
end;

function TextAttr:byte;
begin
if ConsoleMode then
   result:=crt32.TextAttr
else result:=0;
end;

procedure ClrScr;
begin
if ConsoleMode then
   crt32.ClrScr;
end;

function KeyPressed:boolean;
begin
if ConsoleMode then
   result:=crt32.KeyPressed
else result:=false;
end;

end.
