{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O-,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ This file is part of IJE: the Integrated Judging Environment system }
{ (C) Kalinin Petr 2002-2008 }
{ $Id: table_tex.dpr 202 2008-04-19 11:24:40Z *KAP* $ }
library table_tex;
uses ShareMem,SysUtils,
     xmlije,ijeconsts,ije_main,io;

procedure init(var cfg:tSettings);
begin
ije_main.cfg:=cfg;
end;

procedure save(fname:string;var table:ttable);
var i,j,k:integer;
    s:integer;
    max:integer;
    was:array[1..maxboys] of byte;
    maxj:integer;
    f:text;
    yy,mm,dd:word;
    hh,min,ss,sss:word;
    cpp,cp:integer;
    op:integer;
    day,oldday:string;
    bboy:string;
    
begin
if ExtractFileExt(fname)='' then
   fname:=fname+'.tex';
assign(f,fname);rewrite(f);
try
with table do begin
   writeln(f,'\documentclass{article}');
   writeln(f,'\usepackage{problems}');
   writeln(f,'\parindent=0pt');
   writeln(f,'\begin{document}');
   getdate(yy,mm,dd,hh);gettime(hh,min,ss,sss);
   writeln(f,format('{\bf \Large Результаты по состоянию на %2.2d:%2.2d %2.2d.%2.2d.%d}\hfill',[hh,min,dd,mm,yy]));
   writeln(f,'\IJE');
   writeln(f,'\par');
   write(f,'\begin{center}\begin{tabular}{||ll||');
   oldday:=#0;
   for i:=1 to ntask do begin 
       GetTaskInfo(task[i],day,bboy);
       if day<>oldday then
          write(f,'|');
       oldday:=day;
       write(f,'l');
   end;
   writeln(f,'||l||}\hline');
   write(f,'&&');
   for i:=1 to ntask do 
       write(f,task[i],'&');
   writeln(f,'=\\\hline');
   fillchar(was,sizeof(was),0);
   cp:=0;op:=-1;cpp:=0;
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
       if  boy[maxj]<>'MAX' then begin
           inc(cpp);
           if op<>max then
              cp:=cpp;
           write(f,cp,'.');
       end;
       op:=max;
       write(f,'&');
       write(f,boy[maxj],'&');
       for k:=1 to ntask do 
           if t[maxj,k].res=_NS then write(f,'&')
           else write(f,get(table,maxj,k),'&');
       write(f,max,'\\\hline');
       writeln(f);
   end;
   writeln(f,'\end{tabular}\end{center}');
   writeln(f,'\end{document}');
end;
finally
  close(f);
end;
end;
          
function about:string;//it is not guaranteed that init proc will be called before it
begin
about:='(save only)';
end;

exports
  init,save,about;

begin
end.