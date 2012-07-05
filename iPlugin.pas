{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O+,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ This file is part of IJE: the Integrated Judging Environment system }
{ (C) Kalinin Petr 2002-2008 }
{ $Id: iPlugin.pas 202 2008-04-19 11:24:40Z *KAP* $ }
unit iPlugin;
interface
uses sock,xmlije;

type tPluginData=record
       cfg:tSettings;
       selfname:string;
       SetSockCB:procedure (id:tSockCBid;f:tSockCB);
     end;

implementation

end.
