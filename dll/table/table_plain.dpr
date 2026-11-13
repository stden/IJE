{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O-,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ This file is part of IJE: the Integrated Judging Environment system }
{ (C) Kalinin Petr 2002-2008 }
{ $Id: table_plain.dpr 202 2008-04-19 11:24:40Z *KAP* $ }
library table_plain;
uses ShareMem,SysUtils,
     xmlije,io,ijeconsts;

procedure save(fname:string;var table:ttable);
var i,j,k:integer;
    s:integer;
    max:integer;
    was:array[1..maxboys] of byte;
    maxj:integer;
    f:text;
    yy,mm,dd:word;
    hh,min,ss,sss:word;
begin
if ExtractFileExt(fname)='' then
   fname:=fname+'.txt';
with table do begin
     assign(f,fname);rewrite(f);
     getdate(yy,mm,dd,hh);gettime(hh,min,ss,sss);
     writeln(f,'IJE result table on ',dd,'.',mm,'.',yy,', ',hh,':',min);
     write(f,'          ');
     for i:=1 to ntask do 
         write(f,task[i]:5);
     write(f,'    Sum');
     writeln(f);
     fillchar(was,sizeof(was),0);
     for i:=1 to nboy do begin
         write(f,i:2,'. ');
         max:=-1;
         for j:=1 to nboy do if was[j]=0 then begin
             s:=0;
             for k:=1 to ntask do s:=s+get(table,j,k);
             if s>max then begin
                max:=s;
                maxj:=j;
             end;
         end;
         was[maxj]:=1;
         write(f,boy[maxj]:3,'   ');
         for k:=1 to ntask do
             if t[maxj,k].res=_NS then write(f,' ':5)
             else write(f,get(table,maxj,k):5);
         write(f,' = ',max:5);
         writeln(f);
     end;
     close(f);
end;
end;
          
function about:string;//it is not guaranteed that init proc will be called before it
begin
about:='(save only)';
end;

exports
  save,about;

begin
end.