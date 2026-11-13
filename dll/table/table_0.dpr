{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O-,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ This file is part of IJE: the Integrated Judging Environment system }
{ (C) Kalinin Petr 2002-2008 }
{ $Id: table_0.dpr 202 2008-04-19 11:24:40Z *KAP* $ }
library ^;
uses ShareMem,SysUtils,
     xmlije,ijeconsts;//If you are giong to use cfg & ije_main, export init proc!

(*procedure init(var cfg:tSettings);
begin
ije_main.cfg:=cfg;
end;*)//Don''t forget to export it!

procedure load(fname:string;var table:ttable);
begin
if ExtractFileExt(fname)='' then
   fname:=fname+'.'^;
^
end;
          
procedure save(fname:string;var table:ttable);
var f:text;
begin
if ExtractFileExt(fname)='' then
   fname:=fname+'.'^;
assign(f,fname);rewrite(f);
try
^
finally
  close(f);
end;
end;
          
function about:string;//it is not guaranteed that init proc will be called before it
begin
^
end;

exports
  load,save,about;

begin
end.