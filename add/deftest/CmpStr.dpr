{ $Id: CmpStr.dpr 193 2007-11-01 16:23:38Z *KAP* $ }
{$q+,r+,s+,i+,o+}
{$APPTYPE CONSOLE}
uses testlib;
var a,b:string;
begin
a:=ouf.readstring;
b:=ans.readstring;
if a<>b then
   quit(_wa,cutHelp(a)+' גלוסעמ '+cutHelp(b))
else quit(_ok,cutHelp(a));
end.