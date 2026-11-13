{$q+,r+,s+,i+,o+}
{$APPTYPE CONSOLE}
uses ijeconsts;
var i:tresult;
    
procedure writer(s:string;i:tresult;k:integer);
var f:text;
begin    
    assign(f,stext[i]+'.test');rewrite(f);
    writeln(f,s);
    writeln(f,s+'.');
    writeln(f,'C');
    writeln(f,k);
    writeln(f,xmltext[i]);
    writeln(f,1);
    writeln(f,1);
    close(f);
end;
    
begin
for i:=minres to maxres do 
    if not (i in [_cp,_ce]) then 
       writer('A',i,ord(i)+1);
writer('B',_cp,1);
writer('C',_ce,1);
end.
