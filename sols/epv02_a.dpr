{ ����ҷ ַ  ַ ����ҷ }{$A+,B-,D+,E-,F-,G-,I+,L+,N+,O-,P-,Q+,R+,S+,T-,V-,X+,Y+}
{ ��  �� �� ֶ� ӽ��ӽ }{$M 65520,0,655360}
{ ��  �� ��ֽ��   ��   }{�������������������ͻ}
{ ��  �� �ǽ ��   ��   }{� LICENSE AGREEMENT �}
{ ӽ  ӽ ӽ  ӽ   ӽ   }{�������������������ͼ}
{ ����ҷ ַ  ַ ����ҷ }{
{ ��  �� �� ֶ� ӽ��ӽ }This program created by Me anly for testing with IJE.
{ ��  �� ��ֽ��   ��   }
{ ��  �� �ǽ ��   ��   }If you don't agree with terms of this License Agreement, please, format
{ ӽ  ӽ ӽ  ӽ   ӽ   }your hard drive!
{ ����ҷ ַ  ַ ����ҷ }
{ ��  �� �� ֶ� ӽ��ӽ }P.S. Call me (8-312)02 to register this product.
{ ��  �� ��ֽ��   ��   }
{ ��  �� �ǽ ��   ��   }                                         Ostaph Ibragimovich Bender
{ ӽ  ӽ ӽ  ӽ   ӽ   }                                         Samuil Kazimirovich Panikovsky
{ ����ҷ ַ  ַ ����ҷ }                                         Alexander Balaganoff
{ ��  �� �� ֶ� ӽ��ӽ }                                         Adam Kozlevich
{ ��  �� ��ֽ��   ��   }}
{ ��  �� �ǽ ��   ��   }program ANTILOPA_GNU;
{ ӽ  ӽ ӽ  ӽ   ӽ   }const inf='input.txt';
{ ����ҷ ַ  ַ ����ҷ }      ouf='output.txt';
{ ��  �� �� ֶ� ӽ��ӽ }var n,j,i,sp:integer;
{ ��  �� ��ֽ��   ��   }    m:array[1..200,1..200]of byte;
{ ��  �� �ǽ ��   ��   }    aw,ws:array[1..200]of byte;
{ ӽ  ӽ ӽ  ӽ   ӽ   }procedure BABUINAS_MUST_DIE;
{ ����ҷ ַ  ַ ����ҷ } var fp:text;
{ ��  �� �� ֶ� ӽ��ӽ } begin
{ ��  �� ��ֽ��   ��   }  assign(fp,inf);
{ ��  �� �ǽ ��   ��   }  reset(fp);
{ ӽ  ӽ ӽ  ӽ   ӽ   }  readln(fp,n);
{ ����ҷ ַ  ַ ����ҷ }  for j:=1 to n do
{ ��  �� �� ֶ� ӽ��ӽ }   begin
{ ��  �� ��ֽ��   ��   }    for i:=1 to n do
{ ��  �� �ǽ ��   ��   }     read(fp,m[j,i]);
{ ӽ  ӽ ӽ  ӽ   ӽ   }    readln(fp);
{ ����ҷ ַ  ַ ����ҷ }   end;
{ ��  �� �� ֶ� ӽ��ӽ }  close(fp);
{ ��  �� ��ֽ��   ��   } end;
{ ��  �� �ǽ ��   ��   }procedure SLAVA_KPSS;
{ ӽ  ӽ ӽ  ӽ   ӽ   } var fp:text;
{ ����ҷ ַ  ַ ����ҷ } begin
{ ��  �� �� ֶ� ӽ��ӽ }  assign(fp,ouf);
{ ��  �� ��ֽ��   ��   }  rewrite(fp);
{ ��  �� �ǽ ��   ��   }  writeln(fp,sp);
{ ӽ  ӽ ӽ  ӽ   ӽ   }  for j:=1 to sp do
{ ����ҷ ַ  ַ ����ҷ }   write(fp,aw[j],#$20);
{ ��  �� �� ֶ� ӽ��ӽ }  close(fp);
{ ��  �� ��ֽ��   ��   }  halt;
{ ��  �� �ǽ ��   ��   } end;
{ ӽ  ӽ ӽ  ӽ   ӽ   }procedure MUST_DIE(prd,crn:byte);
{ ����ҷ ַ  ַ ����ҷ } var j:byte;
{ ��  �� �� ֶ� ӽ��ӽ } begin
{ ��  �� ��ֽ��   ��   }  ws[crn]:=1;
{ ��  �� �ǽ ��   ��   }  inc(sp);
{ ӽ  ӽ ӽ  ӽ   ӽ   }  aw[sp]:=crn;
{ ����ҷ ַ  ַ ����ҷ }  for j:=1 to n do
{ ��  �� �� ֶ� ӽ��ӽ }   if (j<>crn)and(j<>prd)and(m[crn,j]=1) then
{ ��  �� ��ֽ��   ��   }    if ws[j]=1 then
{ ��  �� �ǽ ��   ��   }     SLAVA_KPSS
{ ӽ  ӽ ӽ  ӽ   ӽ   }               else
{ ����ҷ ַ  ַ ����ҷ }     MUST_DIE(crn,j);
{ ��  �� �� ֶ� ӽ��ӽ }  dec(sp);
{ ��  �� ��ֽ��   ��   }  ws[crn]:=0;
{ ��  �� �ǽ ��   ��   } end;
{ ӽ  ӽ ӽ  ӽ   ӽ   }procedure DAS_IST_FANTASTISH;
{ ����ҷ ַ  ַ ����ҷ } begin
{ ��  �� �� ֶ� ӽ��ӽ }  fillchar(ws,sizeof(ws),0);
{ ��  �� ��ֽ��   ��   }  sp:=0;
{ ��  �� �ǽ ��   ��   }  for j:=1 to n do
{ ӽ  ӽ ӽ  ӽ   ӽ   }   MUST_DIE(0,j);
{ ����ҷ ַ  ַ ����ҷ } end;
{ ��  �� �� ֶ� ӽ��ӽ }begin
{ ��  �� ��ֽ��   ��   } BABUINAS_MUST_DIE;
{ ��  �� �ǽ ��   ��   } DAS_IST_FANTASTISH;
{ ӽ  ӽ ӽ  ӽ   ӽ   }end.










