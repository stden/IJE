{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O-,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ This file is part of IJE: the Integrated Judging Environment system }
{ (C) Kalinin Petr 2002-2008 }
{ $Id: ievallib.pas 202 2008-04-19 11:24:40Z *KAP* $ }
unit ievallib;

interface

uses sysutils,xmlije,ijeconsts;

var hisres:tHisResults;
    p:tproblem;
    
procedure init;
procedure finish;
function hastype(i,j:integer):boolean;

implementation

procedure init;
begin
if paramcount<>2 then begin
   writeln('Evaluator usage: <program name> <problem.xml> <results-file(.xml)>');
   halt;
end;
loadproblem(paramstr(1),p);
LoadHisresults(paramstr(2),hisres);
end;

procedure finish;
begin
SaveHisResults(paramstr(2),hisres);
end;

function hastype(i,j:integer):boolean;
var k:integer;
begin
hastype:=true;
for k:=1 to MaxEvalTypes do
    if p.test[i].evalt[k]=j then
       exit;
hastype:=false;
end;

begin
end.