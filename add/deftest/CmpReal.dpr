{ $Id: CmpReal.dpr 193 2007-11-01 16:23:38Z *KAP* $ }
{$q+,r+,s+,i+,o+}
{$APPTYPE CONSOLE}
uses sysutils,testlib;
const eps=^;
var a,b:extended;
begin
a:=ouf.readreal;
b:=ans.readreal;
if abs(a-b)>eps then
   quit(_wa,format('%10.8f גלוסעמ %10.8f',[a,b]))
else quit(_ok,format('%10.8f',[a]));
end.