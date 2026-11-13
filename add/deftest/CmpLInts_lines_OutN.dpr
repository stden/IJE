{ $Id: CmpLInts_lines_OutN.dpr 193 2007-11-01 16:23:38Z *KAP* $ }
{$q+,r+,s+,i+,o+}
{$APPTYPE CONSOLE}
uses testlib,sysutils;
var a,b:longint;
    i,j:integer;
begin
i:=1;j:=0;
while true do begin
      while ans.seekeoln do begin
            if not ouf.seekeoln then
               quit(_pe,format('Слишком много чисел в %d-ой строке',[i]));
            ouf.nextline;
            ans.nextline;
            if ans.Eof then
               break;
            inc(i);
            j:=0;
      end;
      if ans.Eof then
         break;
      if ouf.seekeoln then
            quit(_pe,format('Слишком мало чисел в %d-ой строке',[i]));
      inc(j);
      a:=ouf.readlongint;
      b:=ans.readlongint;
      if a<>b then
         quit(_wa,format('%d строка, %d число: %d вместо %d',[i,j,a,b]));
end;
quit(_ok,'N='+inttostr(inf.readlongint));
end.