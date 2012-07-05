{$a-,r+,q+,s+}
uses crt;
var f:text;
    gr:array[1..200,1..200] of byte;
    was:array[1..200] of byte;
    cc:array[1..200] of byte;
    wcc:array[0..200] of byte;
    i,j,p:integer;
    n,k:integer;
    r:integer;


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
if paramcount<>4 then begin
    writeln('Params!');
    halt;
end;
paramval(2,n);
paramval(3,k);
paramval(4,r);randseed:=r;
for i:=1 to n do cc[i]:=random(k);
fillchar(was,sizeof(was),0);
fillchar(wcc,sizeof(wcc),0);
fillchar(gr,sizeof(gr),0);
for i:=1 to n do write(cc[i],' ');
writeln;
for i:=1 to n do begin
    write(i,'.');
    if keypressed then halt;
    repeat
      j:=random(n)+1;
    until was[j]=0;
    write(j);
    write('.',wcc[cc[j]]);
    if wcc[cc[j]]=0 then begin
        wcc[cc[j]]:=1;
        was[j]:=1;
        writeln('.');
        continue;
    end;
    write('.');
    repeat
      p:=random(n)+1;
    until (cc[p]=cc[j])and(was[p]=1);
    write('.');
    gr[p,j]:=1;gr[j,p]:=1;
    was[j]:=1;
    writeln;
end;
assign(f,paramstr(1));rewrite(f);
writeln(f,n);
for i:=1 to n do begin
    for j:=1 to n do 
        write(f,gr[i,j],' ');
    writeln(f);
end;
close(f);
assign(f,paramstr(1)+'.a');rewrite(f);
writeln(f,0);
close(f);
writeln('All');
end.
