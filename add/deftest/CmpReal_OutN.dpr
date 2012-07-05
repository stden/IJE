{ $Id: CmpReal_OutN.dpr 193 2007-11-01 16:23:38Z *KAP* $ }
{$q+,r+,s+,i+,o+}
{$APPTYPE CONSOLE}
uses sysutils,testlib;
const eps=^;
var a,b:extended;
    n:integer;
begin
a:=ouf.readreal;
b:=ans.readreal;
n:=inf.readlongint;
if abs(a-b)>eps then
   quit(_wa,format('N=%d: %10.8f גלוסעמ %10.8f',[n,a,b]))
else quit(_ok,format('N=%d: %10.8f',[n,a]));
end.