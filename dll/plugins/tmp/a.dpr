library a;
uses SysUtils,WinSock,iPlugin,sock;

procedure log(s:string);
var f:text;
begin
assign(f,'_plg.tst');
if fileexists('_plg.tst') then
   append(f)
else rewrite(f);
writeln(f,s);
close(f);
end;

procedure TestCB(sock:tSocket;id:tSockCbid;len:integer;var msg);
var typ:integer absolute msg;
begin
log(format('%d %d %d %d',[sock,ord(id),len,typ]));
raise exception.create('TestCB!!!');
end;

function init(data:tPluginData):boolean;
var id:tSockCBid;
begin
log('init '+data.selfname);
{for id:=SOCKCB_CONNECT to SOCKCB_RECVFILE do
    data.SetSockCB(id,TestCB);}
result:=false;
end;

procedure free;
begin
log('free');
end;

exports init,free;

end.