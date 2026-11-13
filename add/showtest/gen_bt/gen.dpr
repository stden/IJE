{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O-,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{ This file is part of IJE: the Integrated Judging Environment system }
{ (C) Kalinin Petr 2002-2008 }
{ $Id: gen.dpr 202 2008-04-19 11:24:40Z *KAP* $ }
{$APPTYPE CONSOLE}
uses sysutils;
const nb=5;
      nt=6;
      ntest=20;
var f:text;
    i,j,k:integer;
    task,ltask:array[1..nt] of shortstring;
    boy:array[1..nb] of shortstring;
    st:array[1..nb,1..nt] of integer;
    sb:array[1..nb] of integer;
    tt:array[1..nb,1..nt] of integer;
    tb:array[1..nb] of integer;
    a,b:integer;
begin
randomize;
for i:=1 to nt do begin
    task[i][0]:=chr(random(5)+1);
    for j:=1 to ord(task[i][0]) do
        task[i][j]:=chr(random(26)+65);
    ltask[i][0]:=chr(random(5)+1);
    for j:=1 to ord(ltask[i][0]) do
        ltask[i][j]:=chr(random(26)+65);
end;
for i:=1 to nb do begin
    boy[i][0]:=chr(random(5)+1);
    for j:=1 to ord(boy[i][0]) do
        boy[i][j]:=chr(random(26)+65);
end;
fillchar(st,sizeof(st),0);
fillchar(sb,sizeof(sb),0);
for i:=1 to nb do
    for j:=1 to nt do
        for k:=1 to ntest do begin
            assign(f,Format('res\%0.3d_%0.3d_%0.3d.test',[i,j,k]));
            rewrite(f);
            writeln(f,boy[i]);
            writeln(f,task[j]);
            writeln(f,ltask[j]);
            writeln(f,k);
            writeln(f,'accepted');
            a:=random(20);
            b:=random(20);
            writeln(f,a);
            writeln(f,b);
            close(f);
            inc(st[i,j],a);
            inc(tt[i,j],b);
            inc(sb[i],a);
            inc(tb[i],b);
        end;
assign(f,'tasks');rewrite(f);
for i:=1 to nt do 
    writeln(f,task[i],':',ltask[i]);
close(f);
assign(f,'boys');rewrite(f);
write(f,' ':5,'  ');
for i:=1 to nt do
    write(f,task[i]:5,' ');
writeln(f);
write(f,' ':5,'  ');
for i:=1 to nt do
    write(f,ltask[i]:5,' ');
writeln(f);
for i:=1 to nb do begin
    write(f,boy[i]:5,'  ');
    for j:=1 to nt do
        write(f,st[i,j]:5,' ');
    write(f,sb[i]);
    writeln(f);
    write(f,' ':5,'  ');
    for j:=1 to nt do
        write(f,tt[i,j]:5,' ');
    write(f,tb[i]);
    writeln(f);
end;
close(f);
end.
    