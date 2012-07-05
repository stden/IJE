{ $Id: CmpNLints.dpr 193 2007-11-01 16:23:38Z *KAP* $ }
{$q+,r+,s+,i+,o+}
{$APPTYPE CONSOLE}
uses testlib;
const n=2;
var a,b:longint;
    i:integer;
begin
for i:=1 to n do begin
    a:=ouf.readlongint;
    b:=ans.readlongint;
    if a<>b then
       quit(_wa,str(i)+'-ое число: '+str(a)+' вместо '+str(b))
end;
quit(_ok,'');
end.