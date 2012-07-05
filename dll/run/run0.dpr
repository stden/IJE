{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O-,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ This file is part of IJE: the Integrated Judging Environment system }
{ $Id: run0.dpr 160 2007-02-13 16:43:11Z *KAP* $ }
library ^;
uses ShareMem;

function run(prg:string;params:string;p:trunparams;s:tsettings):tRUNoutcome;
begin
^
end;

function about:string;
begin
about:=^;
end;

exports run,about;

begin
end.