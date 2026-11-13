{ ึาฤฤาท ึท  ึท ึาาาาท }{$A+,B-,D+,E-,F-,G-,I+,L+,N+,O-,P-,Q+,R+,S+,T-,V-,X+,Y+}
{ บบ  บบ บบ ึถบ ำฝบบำฝ }{$M 65520,0,655360}
{ บบ  บบ บบึฝบบ   บบ   }{ษอออออออออออออออออออป}
{ บบ  บบ บวฝ บบ   บบ   }{บ LICENSE AGREEMENT บ}
{ ำฝ  ำฝ ำฝ  ำฝ   ำฝ   }{ศอออออออออออออออออออผ}
{ ึาฤฤาท ึท  ึท ึาาาาท }{
{ บบ  บบ บบ ึถบ ำฝบบำฝ }This program created by Me anly for testing with IJE.
{ บบ  บบ บบึฝบบ   บบ   }
{ บบ  บบ บวฝ บบ   บบ   }If you don't agree with terms of this License Agreement, please, format
{ ำฝ  ำฝ ำฝ  ำฝ   ำฝ   }your hard drive!
{ ึาฤฤาท ึท  ึท ึาาาาท }
{ บบ  บบ บบ ึถบ ำฝบบำฝ }P.S. Call me (8-312)02 to register this product.
{ บบ  บบ บบึฝบบ   บบ   }
{ บบ  บบ บวฝ บบ   บบ   }                                         Ostaph Ibragimovich Bender
{ ำฝ  ำฝ ำฝ  ำฝ   ำฝ   }                                         Samuil Kazimirovich Panikovsky
{ ึาฤฤาท ึท  ึท ึาาาาท }                                         Alexander Balaganoff
{ บบ  บบ บบ ึถบ ำฝบบำฝ }                                         Adam Kozlevich
{ บบ  บบ บบึฝบบ   บบ   }}
{ บบ  บบ บวฝ บบ   บบ   }program ANTILOPA_GNU;
{ ำฝ  ำฝ ำฝ  ำฝ   ำฝ   }const inf='input.txt';
{ ึาฤฤาท ึท  ึท ึาาาาท }      ouf='output.txt';
{ บบ  บบ บบ ึถบ ำฝบบำฝ }var n,j,i,sp:integer;
{ บบ  บบ บบึฝบบ   บบ   }    m:array[1..200,1..200]of byte;
{ บบ  บบ บวฝ บบ   บบ   }    aw,ws:array[1..200]of byte;
{ ำฝ  ำฝ ำฝ  ำฝ   ำฝ   }procedure BABUINAS_MUST_DIE;
{ ึาฤฤาท ึท  ึท ึาาาาท } var fp:text;
{ บบ  บบ บบ ึถบ ำฝบบำฝ } begin
{ บบ  บบ บบึฝบบ   บบ   }  assign(fp,inf);
{ บบ  บบ บวฝ บบ   บบ   }  reset(fp);
{ ำฝ  ำฝ ำฝ  ำฝ   ำฝ   }  readln(fp,n);
{ ึาฤฤาท ึท  ึท ึาาาาท }  for j:=1 to n do
{ บบ  บบ บบ ึถบ ำฝบบำฝ }   begin
{ บบ  บบ บบึฝบบ   บบ   }    for i:=1 to n do
{ บบ  บบ บวฝ บบ   บบ   }     read(fp,m[j,i]);
{ ำฝ  ำฝ ำฝ  ำฝ   ำฝ   }    readln(fp);
{ ึาฤฤาท ึท  ึท ึาาาาท }   end;
{ บบ  บบ บบ ึถบ ำฝบบำฝ }  close(fp);
{ บบ  บบ บบึฝบบ   บบ   } end;
{ บบ  บบ บวฝ บบ   บบ   }procedure SLAVA_KPSS;
{ ำฝ  ำฝ ำฝ  ำฝ   ำฝ   } var fp:text;
{ ึาฤฤาท ึท  ึท ึาาาาท } begin
{ บบ  บบ บบ ึถบ ำฝบบำฝ }  assign(fp,ouf);
{ บบ  บบ บบึฝบบ   บบ   }  rewrite(fp);
{ บบ  บบ บวฝ บบ   บบ   }  writeln(fp,sp);
{ ำฝ  ำฝ ำฝ  ำฝ   ำฝ   }  for j:=1 to sp do
{ ึาฤฤาท ึท  ึท ึาาาาท }   write(fp,aw[j],#$20);
{ บบ  บบ บบ ึถบ ำฝบบำฝ }  close(fp);
{ บบ  บบ บบึฝบบ   บบ   }  halt;
{ บบ  บบ บวฝ บบ   บบ   } end;
{ ำฝ  ำฝ ำฝ  ำฝ   ำฝ   }procedure MUST_DIE(prd,crn:byte);
{ ึาฤฤาท ึท  ึท ึาาาาท } var j:byte;
{ บบ  บบ บบ ึถบ ำฝบบำฝ } begin
{ บบ  บบ บบึฝบบ   บบ   }  ws[crn]:=1;
{ บบ  บบ บวฝ บบ   บบ   }  inc(sp);
{ ำฝ  ำฝ ำฝ  ำฝ   ำฝ   }  aw[sp]:=crn;
{ ึาฤฤาท ึท  ึท ึาาาาท }  for j:=1 to n do
{ บบ  บบ บบ ึถบ ำฝบบำฝ }   if (j<>crn)and(j<>prd)and(m[crn,j]=1) then
{ บบ  บบ บบึฝบบ   บบ   }    if ws[j]=1 then
{ บบ  บบ บวฝ บบ   บบ   }     SLAVA_KPSS
{ ำฝ  ำฝ ำฝ  ำฝ   ำฝ   }               else
{ ึาฤฤาท ึท  ึท ึาาาาท }     MUST_DIE(crn,j);
{ บบ  บบ บบ ึถบ ำฝบบำฝ }  dec(sp);
{ บบ  บบ บบึฝบบ   บบ   }  ws[crn]:=0;
{ บบ  บบ บวฝ บบ   บบ   } end;
{ ำฝ  ำฝ ำฝ  ำฝ   ำฝ   }procedure DAS_IST_FANTASTISH;
{ ึาฤฤาท ึท  ึท ึาาาาท } begin
{ บบ  บบ บบ ึถบ ำฝบบำฝ }  fillchar(ws,sizeof(ws),0);
{ บบ  บบ บบึฝบบ   บบ   }  sp:=0;
{ บบ  บบ บวฝ บบ   บบ   }  for j:=1 to n do
{ ำฝ  ำฝ ำฝ  ำฝ   ำฝ   }   MUST_DIE(0,j);
{ ึาฤฤาท ึท  ึท ึาาาาท } end;
{ บบ  บบ บบ ึถบ ำฝบบำฝ }begin
{ บบ  บบ บบึฝบบ   บบ   } BABUINAS_MUST_DIE;
{ บบ  บบ บวฝ บบ   บบ   } DAS_IST_FANTASTISH;
{ ำฝ  ำฝ ำฝ  ำฝ   ำฝ   }end.










