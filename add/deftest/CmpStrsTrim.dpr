{ $Id: CmpStrsTrim.dpr 193 2007-11-01 16:23:38Z *KAP* $ }
{$q+,r+,s+,i+,o+}
{$APPTYPE CONSOLE}
uses sysutils,testlib;
var a,b:string;
    i:integer;
begin
i:=0;
while not ans.seekeof do begin
      inc(i);
      if ouf.seekeof then
         quit(_pe,'���� ������� ��������');
      a:=trim(ouf.readstring);
      b:=trim(ans.readstring);
      if a<>b then
         quit(_wa,'������ '+str(i)+': '+cutHelp(a)+' ������ '+cutHelp(b))
end;
quit(_ok,'');
end.