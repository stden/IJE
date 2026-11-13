{$A+,B-,D+,E+,F-,G-,I+,L+,N+,O-,P-,Q+,R-,S-,T-,V-,X+,Y+}
{$M 65520,0,655360}
{
DEAR USER! PLEASE CALL (83130) 97189 TO REGISTER THIS PRODUCT!!!
OTHERWISE YOU'LL HAVE TO GET ACQUANTED WITH PEOPLE WHO LIVED
LONG LONG AGO...

IF NOT "OK" FOR EVERY TESTCASE THEN PIT_MUST_DIE(VERY_CRUEL_DEATH);
ELSE PIT_MAY_BE_ALIVE

IMPORTANT
ONLY IJE IS ALLOWED TO TEST THIS PROGRAM~!

KEEP DRY AND COOL UNTIL MUST DIE!!!

INGREDIENTS:
SOME USEFUL THOUGHTS
SOME USELESS THOUGHTS
SOME FUNNY THOUGHTS
SOME STUPID THOUGHTS
VIOLENT AND TERRIBLE REALIZATION
NOTE: AssEmbler is used here everywhere!!!}

const
  inf = 'input.txt'; ouf = 'output.txt';
  max = 215;
type
   melkaya_chush = byte;
var
  g: array[1..max, 1..max] of melkaya_chush;
  w: array[1..max] of melkaya_chush;
  r: array[0..max] of melkaya_chush;
  qr, j, p, ro, n: melkaya_chush;
  procedure EXECUTE_DOOM(k: melkaya_chush);
  var
    i: melkaya_chush;
  begin
    w[k] := 1; inc(qr); r[qr] := k;
    for i := 1 to n do
      if (g[k, i] = 1) then
      begin
        if (w[i] = 0) then EXECUTE_DOOM(i)
        else
          if (r[qr - 1] <> i) then
          begin
            j := qr; ro := 1;
            while (r[j] <> i) do
            begin
              dec(j); inc(ro);
            end;
            writeln(output, ro);
            for p := j to qr do write(output, r[p], ' ');
            close(output); halt;
          end;
      end;
    r[qr] := 0; dec(qr);
  end;
var
  i: melkaya_chush;
begin
  assign(input,inf); reset(input);
  assign(output,ouf); rewrite(output);
  readln(input, n);
  for i := 1 to n do
  begin
    for j := 1 to n do
      read(input, g[i, j]);
    readln(input);
  end;
  fillchar(w, sizeof(w), 0);
  qr := 0;
  for i := 1 to n do
    if (w[i] = 0) then
      EXECUTE_DOOM(i);
  writeln(output, 0);
  close(input); close(output);
end.