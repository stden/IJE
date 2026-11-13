{ $Id: CmpInt64.dpr 193 2007-11-01 16:23:38Z *KAP* $ }
{$q+,r+,s+,i+,o+}
{$APPTYPE CONSOLE}
uses sysutils,testlib;
var a,b:int64;
begin
a:=ouf.readint64;
b:=ans.readint64;
if a<>b then
   quit(_wa,inttostr(a)+' גלוסעמ '+inttostr(b))
else quit(_ok,inttostr(a));
end.