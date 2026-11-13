{$q+,r+,s+,i+,o+}
{$APPTYPE CONSOLE}
uses sysutils,ievallib,ijeconsts;
var i,j:integer;
    s:string;
begin
init;
for i:=1 to p.ntests do begin
    s:='';
    for j:=1 to maxevaltypes do
        if hastype(i,j) then 
           s:=s+inttostr(j)+' ';
    if s<>'' then begin
       hisres.test[i].res:=_wa;
       hisres.test[i].evaltext:=s;
    end;
end;
finish;
end.