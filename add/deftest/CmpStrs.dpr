{ $Id: CmpStrs.dpr 193 2007-11-01 16:23:38Z *KAP* $ }
{$q+,r+,s+,i+,o+}
{$APPTYPE CONSOLE}
uses sysutils,testlib;
var a,b:string;
    i:integer;
begin
i:=0;
while not ans.eof do begin
      inc(i);
      if ouf.eof then
         quit(_pe,'Файл слишком короткий');
      a:=ouf.readstring;
      b:=ans.readstring;
      if a<>b then
         quit(_wa,'Строка '+str(i)+': '+cutHelp(a)+' вместо '+cutHelp(b))
end;
quit(_ok,'');
end.