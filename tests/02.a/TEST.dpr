{$A+,B-,D+,E+,F-,G-,I+,L+,N+,O-,P-,Q+,R+,S+,T-,V-,X+,Y+}
{$apptype console}
uses sysutils,itestlib,ijeconsts;
var gr:array[1..200,1..200] of byte;
    was:array[1..200] of byte;
    n,k:longint;
    i,j,a,b:integer;

begin
WorkingEncoding:=866;
n:=inf.readlongint;
if (n<1)or(n>200) then quit(_fail,'N!');
for i:=1 to n do
    for j:=1 to n do begin
        gr[i,j]:=inf.readlongint;
        if (gr[i,j]<0)or(gr[i,j]>1) then quit(_fail,'gr['+inttostr(i)+','+inttostr(j)+']!');
    end;
for i:=1 to n do
    for j:=1 to n do
        if gr[i,j]<>gr[j,i] then quit(_fail,'gr['+inttostr(i)+','+str(j)+']<>!');
k:=ouf.readlongint;
if k<0 then quit(_pe,'Странное первое число в выходном файле: '+str(k)+'. N='+str(n));
if k=0 then
   if ans.readlongint=0 then begin
      {if N=2 then quit(_pc,2,'No: N=2')
      else }quit(_ok,'No: N='+inttostr(n))
   end else quit(_wa,'0, когда решение существует. N='+str(n));
if (k=1)or(k=2) then quit(_pe,'Странное первое число в выходном файле: '+str(k)+'. N='+str(n));
a:=ouf.readlongint;b:=a;
if (a<=0)or(a>n) then quit(_pe,'Странный номер вершины в выходном файле: '+str(a)+'. N='+str(n));
was[a]:=1;
for i:=2 to k do begin
    j:=ouf.readlongint;
    if (j<=0)or(j>n) then quit(_pe,'Странный номер вершины в выходном файле: '+str(a)+'. N='+str(n));
    if was[j]<>0 then quit(_pe,'Вершина '+str(j)+' повторяется в выходном файле');
         was[j]:=1;
    if gr[b,j]=0 then quit(_wa,'Ребра между вершинами '+str(b)+' и '+str(j)+' нет');
    b:=j;
end;
if gr[j,a]=0 then quit(_wa,'Ребра между вершинами '+str(j)+' и '+str(a)+' нет');
if ans.readlongint=0 then quit(_fail,'Найден цикл!');
if N<>10 then
   quit(_ok,'Ну "он" "<>крут!" N='+str(n))
else quit(_pc,1,'Ну он крут! N=10');
end.