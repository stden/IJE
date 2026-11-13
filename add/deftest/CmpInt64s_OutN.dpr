{ $Id: CmpInt64s_OutN.dpr 193 2007-11-01 16:23:38Z *KAP* $ }
{$q+,r+,s+,i+,o+}
{$APPTYPE CONSOLE}
uses testlib,sysutils;
var a,b:int64;
    n:integer;
begin
n:=0;
while not ans.seekeof do begin
      inc(n);
      a:=ouf.readint64;
      b:=ans.readint64;
      if a<>b then
         quit(_wa,inttostr(n)+'-ое число: '+inttostr(a)+' вместо '+inttostr(b))
end;
quit(_ok,'N='+inttostr(n));
end.