{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O-,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ This file is part of IJE: the Integrated Judging Environment system }
{ (C) Kalinin Petr 2002-2008 }
{ $Id: ije_server.dpr 202 2008-04-19 11:24:40Z *KAP* $ }
program ije_server;

uses
  ShareMem,
  Forms,
  ije_server_1 in 'ije_server_1.pas' {Form1},
  sock_ije in 'sock_ije.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'IJE server';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
