{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O-,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ This file is part of IJE: the Integrated Judging Environment system }
{ (C) Kalinin Petr 2002-2008 }
{ $Id: table_dat.dpr 202 2008-04-19 11:24:40Z *KAP* $ }
library table_dat;
uses ShareMem,SysUtils,
     io,xmlije,ijeconsts;

procedure save(fname:string;var table:ttable);
var i,j,k:integer;
    s:integer;
    max:integer;
    was:array[1..maxboys] of byte;
    maxj:integer;
    f:text;
begin
if ExtractFileExt(fname)='' then
   fname:=fname+'.dat';
with table do begin
     assign(f,fname);rewrite(f);
     writeln(f,'{');
     writeln(f,'  cols={');
     for i:=1 to ntask do writeln(f,'    ',i,'=',task[i]);
     writeln(f,'  }');
     writeln(f,'  contestants={');
     fillchar(was,sizeof(was),0);
     for i:=1 to nboy do begin
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
         writeln(f,'    ',boy[maxj],'={');
         if uppercase(boy[maxj])='MAX' then writeln(f,'      location=-1');
         for k:=1 to ntask do
             if t[maxj,k].res=_NS then 
             else writeln(f,'      ',task[k],'=',get(table,maxj,k));
         writeln(f,'    }');
     end;
     writeln(f,'  }');
     writeln(f,'}');
     close(f);
end;
end;
          
function about:string;
begin
about:='(save only)';
end;

exports
  save,about;

begin
end.