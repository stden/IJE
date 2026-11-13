{ $Id: CmpStrTrim.dpr 193 2007-11-01 16:23:38Z *KAP* $ }
{$q+,r+,s+,i+,o+}
{$APPTYPE CONSOLE}
uses sysutils,testlib;
var a,b:string;
begin
a:=trim(ouf.readstring);
b:=trim(ans.readstring);
if a<>b then
   quit(_wa,cutHelp(a)+' גלוסעמ '+cutHelp(b))
else quit(_ok,cutHelp(a));
end.