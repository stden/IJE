{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O-,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ This file is part of IJE: the Integrated Judging Environment system }
{ (C) Kalinin Petr 2002-2008 }
{ $Id: table_xml.dpr 202 2008-04-19 11:24:40Z *KAP* $ }
library table_xml;
uses ShareMem,SysUtils,
     xml,xmlije,ijeconsts;

procedure save(fname:string;var table:ttable);
begin
if ExtractFileExt(fname)='' then
   fname:=fname+'.xml';
SaveTable(fname,table);
end;
          
procedure load(fname:string;var table:ttable);
begin
if ExtractFileExt(fname)='' then
   fname:=fname+'.xml';
LoadTable(fname,table);
end;

exports
  load,save;

begin
end.