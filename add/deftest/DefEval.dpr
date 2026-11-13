{ $Id: DefEval.dpr 155 2007-01-26 16:46:18Z *KAP* $ }
{1 --- Yes, 2 --- No}
{$q+,r+,s+,i+,o+}
{$APPTYPE CONSOLE}
uses ievallib,ijeconsts;
var i:integer;
    ok:boolean;
begin
init;
ok:=false;
for i:=1 to p.ntests do
    if hastype(i,1) then
       if hisres.test[i].res=_ok then
          ok:=true;
for i:=1 to p.ntests do
    if (not ok)and(hastype(i,2))and(hisres.test[i].res=_ok) then begin
       hisres.test[i].res:=_nc;
       hisres.test[i].evaltext:='Тест не зачтен';
    end;
finish;
end.