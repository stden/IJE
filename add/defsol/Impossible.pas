{$A+,B-,D+,E+,F-,G-,I+,L+,N+,O-,P-,Q+,R+,S+,T-,V+,X+,Y+}
{$M 65520,0,655360}
{ $Id: Impossible.pas 183 2007-07-02 07:04:19Z kap $ }
var f:text;
begin
assign(f,^'.out');rewrite(f);
writeln(f,^'');
close(f);
end.