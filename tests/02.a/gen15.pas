var f:text;
    ord:array[1..200] of byte;
    gr:array[1..200,1..200] of byte;
    i,j,t:integer;
begin
for i:=1 to 200 do begin
    ord[i]:=i;
    j:=random(i-1)+1;
    t:=ord[i];ord[i]:=ord[j];ord[j]:=t;
end;
fillchar(gr,sizeof(gr),0);
for i:=1 to 200-1 do begin
    gr[ord[i],ord[i+1]]:=1;
    gr[ord[i+1],ord[i]]:=1;
end;
gr[ord[1],ord[200]]:=1;
gr[ord[200],ord[1]]:=1;
assign(f,'15');rewrite(f);
writeln(f,200);
for i:=1 to 200 do begin
    for j:=1 to 200 do write(f,gr[i,j],' ');
    writeln(f);
end;
close(f);
assign(f,'15.a');rewrite(f);
writeln(f,1);
close(f);
end.