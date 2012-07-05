{ $Id: CmpLInt.dpr 193 2007-11-01 16:23:38Z *KAP* $ }
{$q+,r+,s+,i+,o+}
{$APPTYPE CONSOLE}
uses testlib;
var a,b:longint;
begin
a:=ouf.readlongint;
b:=ans.readlongint;
if a<>b then
   quit(_wa,str(a)+' גלוסעמ '+str(b))
else quit(_ok,str(a));
end.