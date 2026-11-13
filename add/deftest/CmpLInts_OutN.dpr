{ $Id: CmpLInts_OutN.dpr 193 2007-11-01 16:23:38Z *KAP* $ }
{$q+,r+,s+,i+,o+}
{$APPTYPE CONSOLE}
uses testlib,sysutils;
var a,b:longint;
    n:integer;
begin
n:=0;
while not ans.seekeof do begin
      inc(n);
      a:=ouf.readlongint;
      b:=ans.readlongint;
      if a<>b then
         quit(_wa,inttostr(n)+'-ое число: '+inttostr(a)+' вместо '+inttostr(b))
end;
quit(_ok,'N='+inttostr(n));
end.