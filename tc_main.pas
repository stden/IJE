{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O-,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ This file is part of IJE: the Integrated Judging Environment system }
{ (C) Kalinin Petr 2002-2008 }
{ $Id: tc_main.pas 211 2010-01-22 17:09:54Z Стандартный $ }
unit tc_main;
interface
uses WinSock,Windows,SysUtils,
     sock,sock_ije,ijeconsts,xmlije,ije_crt32,ije_main;
var tcProblem:tProblem;
    interrupted:boolean;

procedure Compile(param:tSTCtestSolution;var sock:tSocket;var tf:tTCStestingFinished);
procedure Test(param:tSTCtestSolution;var sock:tSocket;var tf:tTCStestingFinished);

implementation
var cbStatus:tTCStestingStatus;
    cbSock:tSocket;

procedure compile(param:tSTCtestSolution;var sock:tSocket;var tf:tTCSTestingFinished);
var i,c:integer;
    cmd:string;
    s:string;
    res:tresult;
    f:text;
    max:integer;
    output:string;
    outp:tTCSCompilerOutput;
    tres:tTCStestResult;
    cs:tTCScompileStarted;
    exitcode:integer;
    sourceName:string;
begin
LogEnterProc('Compile',LOG_LEVEL_MAJOR);
try
try
//Code starts
  fillchar(outp,sizeof(outp),0);
  outp.typ:=TCS_COMPILEROUTPUT;
  outp.gtid:=param.gtid;
  fillchar(tres,sizeof(tres),0);
  tres.typ:=TCS_TESTRESULT;
  tres.gtid:=param.gtid;
  fillchar(tf,sizeof(tf),0);
  tf.typ:=TCS_TESTINGFINISHED;
  tf.gtid:=param.gtid;
  fillchar(cs,sizeof(cs),0);
  cs.typ:=TCS_COMPILESTARTED;
  cs.gtid:=param.gtid;

  Writeln(format('\$0f;Compiling %s:%s...\*;',[param.fname,param.problem]));
  max:=0;
  for i:=1 to tcProblem.ntests do
      max:=max+tcProblem.test[i].points[0];

  ChDir(cfg.testingp);

  c:=FindComp(param.ext);
  if cfg.comp[c].keepname then
     sourceName:=param.fname+'.'+param.ext
  else begin
     copyfile(param.fname+'.'+param.ext,'sol.'+param.ext);
     sourceName:='sol.'+param.ext
  end;

  ForceNoFile('compile.log');
  ForceNoFile(param.fname+cfg.comp[c].compext);
  ForceNoFile('sol'+cfg.comp[c].compext);

  cmd:=subs(cfg.comp[c].cmdline,LowerCase(sourceName),'','')+' '+param.args;

  cs.fname:=param.fname;
  StrToArray(cs.cmdline,cmd,sizeof(cs.cmdline));
  SendToSocket(sock,cs,sizeof(cs));

  writeln;
  writeln('>'+cmd,false);
  if not ConsoleMode then
     AllocConsole;
  exitcode:=exec(cmd,0,300,0,#0,5,'','compile.log','compile.log');
  if not ConsoleMode then
     CloseConsole;

  if not fileexists('compile.log') then begin
     assign(f,'compile.log');
     warning('Compile log wasn''t created!');
     rewrite(f);
     close(f);
  end;
  ConvertFile10('compile.log');
  assign(f,'compile.log');
  reset(f);
  output:='';
  while not eof(f) do begin
        readln(f,s);
        writeln(s);
        output:=output+s+#13#10;
        if (pos('Error',s)<>0)and(outp.output='') then
           StrToArray(tres.text,s,sizeof(tres.text));
  end;
  StrToArray(outp.output,output,sizeof(outp.output));
  close(f);

  if (exitcode<>0)or (not (fileexists('sol'+cfg.comp[c].compext) or fileexists(param.fname+cfg.comp[c].compext)) ) then begin
     res:=_CE;
     tres.text:='Compiled file not created';
  end else begin
      res:=_CP;
      if not cfg.comp[c].keepname then
         MoveFile('sol'+cfg.comp[c].compext,param.fname+cfg.comp[c].compext);
  end;

  tres.res:=res;
  tres.pts:=0;
  tres.max:=max;
  tres.id:=1;

  writeln;
  writeln(format('*\$%x; %s \$07;* %s',[attrib(tres.res),stext(tres.res),ltext(tres.res)]));
  writeln;

  SendToSocket(sock,outp,sizeof(outp));
  SendToSocket(sock,tres,sizeof(tres));

  tf.pts:=0;
  tf.max:=max;
  tf.res:=res;

  ChDir(IJEdir);
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'Compile');
end;
finally
  LogLeaveProc('Compile',LOG_LEVEL_MAJOR);
end;
end;

function RunCB(var status:tRunStatus):boolean;
begin
try
cbStatus.time:=status.time;
cbStatus.totalTime:=status.totalTime;
cbStatus.mem:=status.mem;
cbStatus.peakMem:=status.peakMem;
SendToSocket(cbSock,cbStatus,sizeof(cbStatus));
result:=true;
except
  on e:exception do
     LogError(eIJEerror.CreateAppendPath(e,'RunCB','CallBack function error during Run'));
end;
end;

procedure Test(param:tSTCtestSolution;var sock:tSocket;var tf:tTCStestingFinished);
var tpath:string;
    max:integer;
    i:integer;
    hisres:array[1..maxtests] of tTCStestResult;
    ehisres,eHisres1:tHisResults;
    sum:word;
    cRunOutcome,vRunOutcome:tRunOutcome;
    RUNdll:THandle;
    _RUNFunc:function (prg:string;params:string;tcProblem:trunparams;s:tsettings):tRunOutcome;
    _RUNinit:procedure (cfg:tSettings);
    Runparams:trunparams;
    evalchanged:boolean;
    outpfn:string;
    ts:tTCStestingStarted;
    rez:tOutcome;
    timestring:string;
    ub:tALLuserBreak;
    es:tTCSevalStarted;
    st:tTCStestingStatus;
    compId:integer;
    runCmdLine:string;
label 1;

function RUNFunc(prg:string;params:string;tcProblem:trunparams;s:tsettings):tRunOutcome;
begin
try
  result:=_RUNFunc(prg,params,tcProblem,s);
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'RUNfunc');
end;
end;

procedure RUNinit(cfg:tSettings);
begin
try
  _RUNinit(cfg);
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'RUNinit');
end;
end;

procedure MakePoints(i:integer);
begin
 if hisres[i].res=_ok then
      hisres[i].pts:=tcProblem.test[i].points[0]
 else if hisres[i].res<=_pcbase then //some other result, such as WA
      hisres[i].pts:=0
 else if (hisres[i].res>_pcbase)and(hisres[i].res<=_pcbase+maxpc) then begin
      hisres[i].pts:=tcProblem.test[i].points[hisres[i].res-_pcbase];
      if hisres[i].pts=-1 then begin
         StrToArray(hisres[i].text,'No points specified for PC #'+inttostr(hisres[i].res-_pcbase),sizeof(hisres[i].text));
         hisres[i].res:=_fl;
         hisres[i].pts:=0;
      end;
 end else begin
     hisres[i].res:=_fl;
     StrToArray(hisres[i].text,'No points specified for this PC '+inttostr(hisres[i].res-_pcbase)+' (PC overflow)',sizeof(hisres[i].text));
     hisres[i].pts:=0;
 end;
end;

begin
LogEnterProc('Test',LOG_LEVEL_MAJOR);
try
try
//Code starts
fillchar(tf,sizeof(tf),0);
tf.typ:=TCS_TESTINGFINISHED;
tf.gtid:=param.gtid;
fillchar(ts,sizeof(ts),0);
ts.typ:=TCS_TESTINGSTARTED;
ts.gtid:=param.gtid;
fillchar(hisres,sizeof(hisres),0);
for i:=1 to maxtests do begin
    hisres[i].typ:=TCS_TESTRESULT;
    hisres[i].gtid:=param.gtid;
end;
fillchar(es,sizeof(es),0);
es.typ:=TCS_EVALSTARTED;
es.gtid:=param.gtid;
fillchar(st,sizeof(st),0);
st.typ:=TCS_TESTINGSTATUS;
st.gtid:=param.gtid;

compId:=FindComp(param.ext);
runCmdLine:=subs(cfg.comp[compId].runline,LowerCase(param.fname),'','');

chdir(cfg.testingp);
if not fileexists(param.fname+cfg.comp[compId].compext) then
   raise eIJEerror.Create('No compiled file for the solution','','Can''t find file %s%s',[param.fname,cfg.comp[compId].compext]);

tpath:=cfg.testp+param.problem+'\';
max:=0;
for i:=1 to tcProblem.ntests do
    max:=max+tcProblem.test[i].points[0];

settextattr($0f);
writeln('Testing...');
writeln('Solution:         '+param.fname);
writeln('Problem:          '+param.problem+' ('+tcProblem.name+'); type '+param.tasktype);
writeln('Number of tests:  '+inttostr(tcProblem.ntests));
writeln('Max points:       '+inttostr(max));
writeln('Files:            '+tcProblem.input_name+'/'+tcProblem.output_name);
writeln('Time limit:       '+inttostr(tcProblem.tl)+' ms');
writeln('Memory limit:     '+inttostr(tcProblem.ml)+' b');
writeln;
settextattr($07);

SendToSocket(sock,ts,sizeof(ts));

RUNDll:=LoadDll(cfg.dllp+'run\'+cfg.rundll+'\run.dll');
try
@_RunFunc:=LoadDllProc(RunDll,'run');
@_RUNinit:=LoadDLLproc(RunDLL,'init',false);
if @_RUNinit<>nil then
   RUNinit(cfg);

runparams.p:=tcProblem;
runparams.il:=cfg.idlelim;
runparams.idlepercent:=cfg.idlepercent;
interrupted:=false;
logwriteln('Main cycle start...',LOG_LEVEL_MAJOR);
for i:=1 to tcProblem.ntests do begin
  LogEnterProc('Test_'+inttostr(i),LOG_LEVEL_MINOR);
  try
  try
  try
  //Code starts
  st.typ:=TCS_TESTINGSTATUS;
  st.id:=i;
  st.time:=-1;
  st.totalTime:=-1;
  st.mem:=-1;
  st.peakMem:=-1;

  st.status:=_started;
  SendToSocket(sock,st,sizeof(st));
  
  write(format('N%3d * ',[i]));gotoxy(8,wherey);
  cRunOutcome.result:=_nt;
  cRunOutcome.text:='';
  cRunOutcome.time:=-1;
  cRunOutcome.mem:=-1;
  try
    if not interrupted then begin
       RecvFromSocket(Sock,ub,sizeof(ub),0,sizeof(ub),0,1000);
       if ub.typ=ALL_USERBREAK then
          interrupted:=true;
    end;
  except
    on e:exception do;
  end;
  if (i in param.testset)and(not interrupted) then begin
     if param.tasktype='P' then begin
        st.status:=_copy;
        SendToSocket(sock,st,sizeof(st));
        
        CleanDir(cfg.testingp,param.fname+cfg.comp[compId].compext);//leave .exe
        write('Copying test data...');gotoxy(8,wherey);
        LogEnterProc('copy_test_data',LOG_LEVEL_MINOR);
        try
          copyfile(tpath+tcProblem.test[i].input_href,tcProblem.input_name);
        finally
          logLeaveProc('copy_test_data',LOG_LEVEL_MINOR);
        end;

        st.status:=_run;
        SendToSocket(sock,st,sizeof(st));
        
        write('                                                                    ');gotoxy(8,wherey);
        write('Running '+runCmdLine+'...');
        LogEnterProc('Run',LOG_LEVEL_MINOR,runCmdLine);
        try
          runparams.quiet:=false;
          runparams.tl:=tcProblem.tl;
          runparams.ml:=tcProblem.ml;
          runparams.norights:=true;
          runparams.CB:=@RunCB;
          cbStatus:=st;
          cbSock:=Sock;
          cRunOutcome:=RunFunc(runCmdLine,'',runparams,cfg);
          gotoxy(8,wherey);
        finally
          logLeaveProc('Run',LOG_LEVEL_MINOR);
        end;

        if cRunOutcome.result<>_nt then begin
           hisres[i].res:=cRunOutcome.result;
           StrToArray(hisres[i].text,cRunOutcome.text,sizeof(hisres[i].text));
           goto 1;
        end;
        write('                                                                    ');gotoxy(8,wherey);
     end else begin {tasktype='O'}
         st.status:=_copyoutput;
         SendToSocket(sock,st,sizeof(st));
         
         outpfn:=format('%s\%s.%2d',[cfg.testingp,param.fname,i]);
         if not fileexists(outpfn) then begin
            hisres[i].res:=_NS;
            StrToArray(hisres[i].text,ltext(hisres[i].res),sizeof(hisres[i].text));
            goto 1;
         end;
         LogEnterproc('copy_output_file',LOG_LEVEL_MINOR);
         try
           copyfile(outpfn,tcProblem.output_name);
         finally
           LogLeaveProc('copy_output_file',LOG_LEVEL_MINOR);
         end;
     end;
     st.status:=_check;
     SendToSocket(sock,st,sizeof(st));
     
     write('Checking answer...                   ');gotoxy(8,wherey);
     LogEnterProc('check_answer',LOG_LEVEL_MINOR);
     try
       ForceNoFile('outcome.xml');
       runparams.quiet:=true;
       runparams.tl:=60000;
       runparams.ml:=-1;
       runparams.norights:=false;
       runparams.cb:=nil;
       vRunOutcome:=RunFunc(tpath+tcProblem.verifier,tpath+tcProblem.test[i].input_href+' '+tcProblem.output_name
                        +' '+tpath+tcProblem.test[i].answer_href+' outcome.xml -xml',runparams,cfg);
       if vRunOutcome.result<>_nt then begin
          hisres[i].res:=_fail;
          StrToArray(hisres[i].text,'Error while executing verifier: '+vRunOutcome.text,sizeof(hisres[i].text));
       end else begin
           loadoutcome('outcome.xml',rez);
           hisres[i].res:=rez.res;
           if rez.res>_pcbase then
              rez.text:=format('(%d) %s',[rez.res-_pcbase,rez.text]);
           StrToArray(hisres[i].text,rez.text,sizeof(hisres[i].text));
       end;
     finally
       LogLeaveProc('check_answer',LOG_LEVEL_MINOR);
     end;
 end else begin //not (i in param.testset)
     hisres[i].res:=_NT;
     hisres[i].text:='Skipped';
 end;
1:
 except
   on e:exception do begin
      LogError(e);
      hisres[i].res:=_fl;
      StrToArray(hisres[i].text,e.Message,sizeof(hisres[i].text));
   end;
 end;
 hisres[i].id:=i;
 MakePoints(i);
 hisres[i].max:=tcProblem.test[i].points[0];
 hisres[i].time:=cRunOutcome.time;
 hisres[i].mem:=cRunOutcome.mem;
 timestring:=format('%5.2fs',[hisres[i].time]);
 if hisres[i].time<0 then begin
    timestring:=StringOfChar(' ',length(timestring));
    timestring[length(timestring) div 2]:='-';
 end;

 gotoxy(8,wherey);
 settextattr($07);
 write('                                                    ');
 gotoxy(8,wherey);
 writeln(format('\$%x;%s\$07; * %2d/%-2d * %s * %s',
   [attrib(hisres[i].res),stext(hisres[i].res),hisres[i].pts,hisres[i].max,timestring,hisres[i].text]));

 SendToSocket(Sock,hisres[i],sizeof(hisres[i]));
//Code ends //test i ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'Test_'+inttostr(i));
end;
finally
  LogLeaveProc('Test_'+inttostr(i),LOG_LEVEL_MINOR,
    format('%s %d %s',[stext(hisres[i].res),hisres[i].res,hisres[i].text]));
end;
end;
if tcProblem.evaluator<>'' then begin
   LogEnterProc('Eval',LOG_LEVEL_MAJOR);
   try
   try
   //Code starts
   SendToSocket(sock,es,sizeof(es));
   writeln;
   eHisRes.ntests:=tcProblem.ntests;
   for i:=1 to tcProblem.ntests do begin
       eHisRes.test[i].res:=hisres[i].res;
       eHisRes.test[i].text:=hisres[i].text;
       eHisRes.test[i].evaltext:='';
   end;
   SaveHisResults('results.xml',eHisRes);
   runparams.quiet:=true;
   runparams.tl:=60000;
   runparams.ml:=-1;
   runparams.norights:=false;
   runparams.cb:=nil;
   vRunOutcome:=RunFunc(tpath+tcProblem.evaluator,tpath+'problem.xml'+
                       ' results.xml',runparams,cfg);
   if vRunOutcome.result<>_nt then
      raise eIJEerror.Create('','','Evaluator execution failed: '+vRunOutcome.text)
   else begin
        evalchanged:=false;
        LoadHisResults('results.xml',eHisRes1);
        if eHisRes1.ntests<>eHisRes.ntests then
           raise eIJEerror.Create('','','Test number returned by evaluator differs from test number of problem: %d/%d',[eHisRes1.ntests,eHisRes.ntests]);
        for i:=1 to tcProblem.ntests do begin
            if (eHisRes1.test[i].res<>eHisRes.test[i].res)or
               (eHisRes1.test[i].text<>eHisRes.test[i].text)or
               (eHisRes1.test[i].evaltext<>eHisRes.test[i].evaltext)
            then begin
                 HisRes[i].res:=eHisRes1.test[i].res;
                 StrToArray(HisRes[i].text,eHisRes1.test[i].text,sizeof(HisRes[i].text));
                 StrToArray(HisRes[i].evaltext,eHisRes1.test[i].evaltext,sizeof(HisRes[i].evaltext));
                 MakePoints(i);

                 if not evalchanged then begin
                    writeln('\$0f;Changed by evaluator:\*;');
                    LogWriteln('Changed by evaluator:',LOG_LEVEL_MAJOR);
                    evalchanged:=true;
                 end;
                 writeln(format('\$07;N%3d * (\$%x;%s\*;) -> \$%x;%s\$07; * %2d/%-2d * %s',
                   [i,attrib(eHisRes.test[i].res) and (not $08),stext(eHisRes.test[i].res),
                   attrib(hisres[i].res),stext(hisres[i].res),hisres[i].pts,hisres[i].max,
                   hisres[i].evaltext]));
                 LogWriteln(format('%3d : (%s) -> %s * %2d/%-2d : %s',
                   [i,stext(eHisRes.test[i].res),stext(hisres[i].res),hisres[i].pts,hisres[i].max,hisres[i].evaltext]),LOG_LEVEL_MAJOR);

                 SendToSocket(Sock,hisres[i],sizeof(hisres[i]));
            end;
        end;
   end;
   //Code ends
   except
     on e:exception do
        raise eIJEerror.CreateAppendPath(e,'Eval');
   end;
   finally
     LogLeaveProc('Eval',LOG_LEVEL_MAJOR);
   end;
end;
settextattr($07);
writeln;
write('RESULT: ');
logwrite('RESULT: ',LOG_LEVEL_MAJOR);
sum:=0;
for i:=1 to tcProblem.ntests do begin
    logwrite(stext(hisres[i].res)+' ',LOG_LEVEL_MAJOR);
    if not(hisres[i].res in [_nt,_ns]) then
       write(format('\$%x;%2d\*;+',[attrib(hisres[i].res),hisres[i].pts]))
    else write(' .+');
    sum:=sum+hisres[i].pts;
end;
write(#8' = ');
settextattr($0f);writeln(IntToStr(sum));settextattr($07);
logwriteln('= '+IntToStr(sum),LOG_LEVEL_MAJOR);

write('MAX:    ');
for i:=1 to tcProblem.ntests do
    if hisres[i].res<>_nt then
       write(format('%2d+',[tcProblem.test[i].points[0]]))
    else begin
         write(format('\$08;%2d\*;+',[tcProblem.test[i].points[0]]));
    end;
writeln(#8' = '+IntToStr(max));
if param.testset=[1..tcProblem.ntests] then begin
   if sum=max then
      writeln('\$0a;Congratulation with maximal sum!')
   else if sum>0.6*max then
       writeln('\$02;Congratulation! It''s a good result!')
   else
       writeln('\$07;So small sum?!');
end;
settextattr($07);

tf.pts:=sum;
tf.max:=max;
tf.res:=_ok;

finally
FreeLibrary(RunDll);
end;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'Test');
end;
finally
  LogLeaveProc('Test',LOG_LEVEL_MAJOR);
end;
end;

begin
end.
