{$a-,r+,q+,s+,i+}
{$m 65520,0,1024}
procedure q;
var a:array[0..15200] of char;
    f:file;
begin
assign(f,'e:\far.rar');
while true do begin
      reset(f,1);
      blockread(f,a,sizeof(a));
end;
end;

begin
q;
end.