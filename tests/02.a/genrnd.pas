var f:text;
    r,n,p,q,k:integer;
    i,j,a:integer;
    gr:array[1..200,1..200] of byte;
    cc:array[1..200] of byte;

procedure paramval(i:integer;var a:integer);
var c:integer;
begin
val(paramstr(i),a,c);
if c<>0 then begin
    writeln('paramstr ',i);
    halt;
end;
end;

begin
if paramcount<>6 then begin
    writeln('Params!');
    halt;
end;
paramval(2,n);
paramval(3,p);
paramval(4,q);
paramval(5,k);
paramval(6,r);randseed:=r;
fillchar(cc,sizeof(cc),0);
for i:=1 to k do begin
    repeat
      j:=random(n)+1;
    until cc[j]=0;
    cc[j]:=i;
end;
for i:=1 to n do if cc[i]=0 then cc[i]:=random(k)+1;
for i:=1 to n do begin
    for j:=i+1 to n do begin
        if (cc[i]<>cc[j])or(i=j) then a:=0
        else if random(q)<p then a:=1
        else a:=0;
        gr[i,j]:=a;gr[j,i]:=a;
    end;
end;
assign(f,paramstr(1));rewrite(f);
writeln(f,n);
for i:=1 to n do begin
    for j:=1 to n do write(f,gr[i,j],' ');
    writeln(f);
end;
close(f);
assign(f,paramstr(1)+'.a');rewrite(F);
if k<>n then writeln(f,1)
else writeln(f,0);
close(f);
end.