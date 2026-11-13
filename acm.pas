{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O+,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{ This file is part of IJE: the Integrated Judging Environment system }
{ (C) Kalinin Petr 2002-2008 }
{ $Id: acm.pas 202 2008-04-19 11:24:40Z *KAP* $ }
unit acm;

interface
uses SysUtils,
     ijeconsts,ije_main,xmlije;
type tQACMcontestInfo=record
        needFirstWa:boolean;
        needGlobalTIme:boolean;
        StartTime,Length:integer;
        Title:string;
        nParty,nTask:integer;
        party:tboys;
        task:ttasks;
     end;
     tacmsubmit=record
                   b,d,p,ext:string;
                   time:integer;
                   fname:string;
                   id:integer;
                  end;

procedure InitQACM;
procedure FinishQACM;
function TimeStamp(time:double):int64;

implementation
uses Windows,classes,SyncObjs,
     sock_ije,server_main,ije_crt32,ije_server_1;

type tInitProc=function (var cfg:tSettings;var acms:tQACmsettings;fname:string;var qcfg:tQACMcontestInfo):integer;
     tLoadTableProc=procedure(id:integer);
     tOnIdleProc=procedure (id:integer;time:integer);
     tSaveTableProc=procedure(id:integer);
     tRegisterSolutionProc=function(id:integer;sol:tsoldata;time:integer):integer;
     tTestedSolutionProc=procedure(id:integer;solid:integer;res:ttestresults);
     tWriteScreenTableProc=procedure(id:integer);
     tPressedKeyProc=procedure (id:integer;ch:char);
     tFinishProc=procedure(id:integer);
     tACMcontest=class
        private
          Id:integer;
          dll:tHandle;
          settings_fname:string;
          qcfg:tQACMcontestInfo;
          _InitContest:tInitProc;
          _LoadTable:tLoadTableProc;
          _OnIdle:tOnIdleProc;
          _SaveTable:tSaveTableProc;
          _RegisterSolution:tRegisterSolutionProc;
          _TestedSolution:tTestedSolutionProc;
          _WriteScreenTable:tWriteScreenTableProc;
          _PressedKey:tPressedKeyProc;
          _Finish:tFinishproc;
        public
          Lock:tCriticalSection;
          constructor Create(qdll,fname:string);
          destructor Destroy;
          function CurrentTime:integer;
          function BelongsTo(sol:tsoldata):boolean;
          function OnTime:integer;

          function InitContest(var cfg:tSettings;var acms:tQACmsettings;fname:string;var qcfg:tQACMcontestInfo):integer;
          procedure LoadTable;
          procedure OnIdle;
          procedure SaveTable;
          function RegisterSolution(sol:tsoldata;time:integer):integer;
          procedure TestedSolution(solid:integer;res:ttestresults);
          procedure WriteScreenTable;
          procedure PressedKey(ch:char);
          procedure Finish;
     end;
     tRegisterThread=class(tThread)
       procedure Execute; override;
       procedure RegisterSolution(var sol:tSolData;fname_id:integer);
     end;
     tOnIdleThread=class(tThread)
       procedure Execute; override;
     end;
     tSendToTestThread=class(tThread)
       procedure Execute; override;
       procedure SendToTest(id:integer);
     end;
     tWriteTableThread=class(tThread)
       CurrentConsoleContest:integer;
       procedure Execute; override;
       procedure ChangeCurrentContest;
     end;
var contest:array[1..MAX_ACM_CONTESTS] of tACMcontest;
    nContests:integer;
    RegisterThread:tRegisterThread;
    OnIdleThread:tOnIdleThread;
    SendToTestThread:tSendToTestThread;
    WriteTableThread:tWriteTableThread;
    submit:array[1..MAX_ACM_SUBMITS] of record
            sol:tSolData;
            ContId:integer;//идентификатор контеста
            IdInCont:integer;//идентификатор решени€ в раках контеста (как его определила dll'ка)
          end;
    nsubmit:integer;
    lsubmit:integer;
    stopped:boolean=false;//add to exception handler in ACMCB!
    qcfg:tQACMsettings;

function timestamp(time:double):int64;
begin
timestamp:=trunc((time-25569)*24*60*60-3*60*60-qcfg.dst*60*60);
end;

procedure getACMsolinfo(fname:string;var time,id:string);
var i:integer;
begin
time:='';
id:='';
for i:=1 to length(fname) do begin
  if i>length(cfg.acmsolformat) then
    break;
  case cfg.acmsolformat[i] of
    '%':time:=time+fname[i];
    '^':id:=id+fname[i];
  end;
end;
end;

function makeACMsolname(b,d,pp,time,id:string):string;
var i:integer;
    nt,nid:integer;
begin
result:=subs(cfg.acmsolformat,b,d,pp);
nt:=0;nid:=0;
for i:=1 to length(result) do
  case result[i] of
    '%':inc(nt);
    '^':inc(nid);
  end;
while length(time)<nt do time:='0'+time;
while length(id)<nid do id:='0'+id;
nid:=0;
nt:=0;
for i:=1 to length(result) do
  case result[i] of
    '%':begin inc(nt);result[i]:=time[nt]; end;
    '^':begin inc(nid);result[i]:=id[nid]; end;
  end;
end;

function CtrlHandler(var typ:dWord):bool; stdcall;
begin
result:=true;
end;

procedure InitQACM;
var i:integer;
begin
LogEnterProc('InitQACM',LOG_LEVEL_MAJOR);
try
try
//Code starts
loadQACMsettings('acm.xml',qcfg);
nContests:=qcfg.ncont;
if nContests=0 then begin
   LogWriteln('No ACM contests; exiting unit acm.',LOG_LEVEL_MAJOR);
   exit;
end;
if ACMconsoleMode then begin
   ConsoleMode:=true;
   AllocConsole;
   MaximizeConsole;
   InitConsole;
   SetConsoleCtrlHandler(@CtrlHandler,true);
   SetConsoleTitle('ACM contest - IJE: the Integrated Judging Environment');
end;
for i:=1 to nContests do
    contest[i]:=tACMcontest.Create(qcfg.cont[i].qdll,qcfg.cont[i].fname);
nsubmit:=0;lsubmit:=1;
RegisterThread:=tRegisterThread.Create(True);
RegisterThread.Priority:=tpHigher;
RegisterThread.Resume;
OnIdleThread:=tOnIdleThread.Create(false);
SendTotestThread:=tSendTotestThread.create(false);
if ACMconsoleMode then begin
   WriteTableThread:=tWriteTableThread.Create(true);
   WriteTableThread.CurrentConsoleContest:=1;
   WriteTableThread.Resume;
end;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'InitQACM');
end;
finally
  LogLeaveProc('InitQACM',LOG_LEVEL_MAJOR);
end;
end;

procedure FinishQACM;
var i:integer;
begin
LogEnterProc('FinishQACM',LOG_LEVEL_MAJOR);
try
try
//Code starts
LogWriteln('Ready to terminate WriteTablethread',LOG_LEVEL_MAJOR);
if WriteTableThread<>nil then begin
   WriteTableThread.Terminate;
   LogWriteln('Terminated WriteTable thread; waiting...'+BoolToStr(registerThread.terminated),LOG_LEVEL_MAJOR);
   WriteTableThread.WaitFor;
end;
LogWriteln('Ready to terminate register thread',LOG_LEVEL_MAJOR);
if RegisterThread<>nil then begin
   RegisterThread.Terminate;
   LogWriteln('Terminated register thread; waiting...'+BoolToStr(registerThread.terminated),LOG_LEVEL_MAJOR);
   RegisterThread.WaitFor;
end;
if OnIdleThread<>nil then begin
   OnIdleThread.Terminate;
   OnIdleThread.WaitFor;
end;
if ACMconsoleMode then begin
   CloseConsole;
   ConsoleMode:=false;
end;
for i:=1 to nContests do
    if Contest[i]<>nil then
       Contest[i].Destroy;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'FinishQACM');
end;
finally
  LogLeaveProc('FinishQACM',LOG_LEVEL_MAJOR);
end;
end;

{ tACMcontest }

function tACMcontest.RegisterSolution(sol: tsoldata;time:integer): integer;
begin
Lock.Enter;
try
try
  result:=_RegisterSolution(id,sol,time);
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'tACMcontest['+qcfg.Title+'].AddSolution');
end;
finally
  Lock.Leave;
end;
end;


function tACMcontest.BelongsTo(sol: tsoldata): boolean;
begin
result:=(FindString(qcfg.nParty,qcfg.party,sol.boy)<>0)
        and (FindString(qcfg.nTask,qcfg.Task,Maketask(sol.day,sol.task))<>0)
end;

constructor tACMcontest.Create(qdll,fname:string);
begin
LogEnterProc('tACMcontest.Create',LOG_LEVEL_MINOR,format('%s,%s',[qdll,fname]));
try
try
//Code starts
fillchar(qcfg,sizeof(qcfg),0);
Lock:=tCriticalSection.Create;
settings_fname:=fname;
dll:=LoadDll(cfg.dllp+'\qacm\qacm_'+qdll+'.dll');
_InitContest:=LoadDllproc(dll,'Init');
_LoadTable:=LoadDllproc(dll,'LoadTable');
_OnIdle:=LoadDllProc(dll,'OnIdle');
_SaveTable:=LoadDllProc(dll,'SaveTable');
_RegisterSolution:=LoadDllProc(dll,'AddSolution');
_TestedSolution:=LoadDllProc(dll,'TestedSolution');
_PressedKey:=LoadDllProc(dll,'PressedKey');
_WriteScreenTable:=LoadDllProc(dll,'WriteScreenTable');
_Finish:=LoadDllProc(dll,'Finish');
id:=InitContest(cfg,acm.qcfg,fname,qcfg);
LogWriteln('Contest '+qcfg.Title,LOG_LEVEL_MINOR);
LoadTable;
OnIdle;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'tACMcontest.Create['+qcfg.title+']');
end;
finally
  LogLeaveProc('tACMcontest.Create',LOG_LEVEL_MINOR);
end;
end;

function tACMcontest.CurrentTime: integer;
var h,m,s,ss:word;
begin
if not qcfg.needGlobalTime then begin
   gettime(h,m,s,ss);
   result:=h*60+m;
end else result:=TimeStamp(Now) div 60;
result:=result-qcfg.StartTime;
end;

destructor tACMcontest.Destroy;
begin
LogEnterProc('tACMcontest.Destroy',LOG_LEVEL_MINOR,format('[%s]',[qcfg.Title]));
try
try
//Code starts
SaveTable;
Finish;
if dll<>0 then FreeLibrary(dll);
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'tACMcontest.Destroy');
end;
finally
  LogLeaveProc('tACMcontest.Destroy',LOG_LEVEL_MINOR);
end;
end;

procedure tACMcontest.Finish;
begin
Lock.Enter;
try
try
  _Finish(id);
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'tACMcontest['+qcfg.Title+'].Finish');
end;
finally
  Lock.Leave;
end;
end;

function tACMcontest.InitContest(var cfg: tSettings; var acms: tQACMsettings; fname: string;var qcfg:tQACMcontestInfo):integer;
begin
Lock.Enter;
try
try
  result:=_InitContest(cfg,acms,fname,qcfg);
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'tACMcontest['+qcfg.Title+'].Init');
end;
finally
  Lock.Leave;
end;
end;

procedure tACMcontest.LoadTable;
begin
Lock.Enter;
try
try
  _LoadTable(id);
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'tACMcontest['+qcfg.Title+'].LoadData');
end;
finally
  Lock.Leave;
end;
end;


procedure tACMcontest.OnIdle;
begin
Lock.Enter;
try
try
  _OnIdle(id,CurrentTime);
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'tACMcontest['+qcfg.Title+'].OnIdle');
end;
finally
  Lock.Leave;
end;
end;


procedure tACMcontest.SaveTable;
begin
Lock.Enter;
try
try
  _SaveTable(id);
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'tACMcontest['+qcfg.Title+'].SaveTable');
end;
finally
  Lock.Leave;
end;
end;

procedure tACMcontest.TestedSolution(solid: integer; res: ttestresults);
begin
Lock.Enter;
try
try
  _TestedSolution(id,solid,res);
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'tACMcontest['+qcfg.Title+'].TestedSolution');
end;
finally
  Lock.Leave;
end;
end;

function tACMcontest.OnTime: integer;
begin
if CurrentTime>=qcfg.Length then
   result:=1
else if CurrentTime<0 then
     result:=-1
else result:=0;
end;

procedure tACMcontest.PressedKey(ch: char);
begin
Lock.Enter;
try
try
  _PressedKey(id,ch);
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'tACMcontest['+qcfg.Title+'].PressedKey');
end;
finally
  Lock.Leave;
end;
end;

procedure tACMcontest.WriteScreenTable;
begin
Lock.Enter;
try
try
  _WriteScreenTable(id);
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'tACMcontest['+qcfg.Title+'].WriteTable');
end;
finally
  Lock.Leave;
end;
end;

{ tRegisterThread }

procedure tRegisterThread.Execute;
var sol:tSolDatas;
    nsol:integer;
    ttime,iid:string;
    i:integer;
    nn:integer;
begin
nn:=3;
lookup(nsol,sol,cfg.acmsolp);
for i:=1 to nsol do begin
    getACMsolinfo(sol[i].fname,ttime,iid);
    if ttime<>'' then
       RegisterSolution(sol[i],StrToInt(iid));
end;
while not terminated do begin
      try
      sleep(500);
      inc(nn);
      if nn mod 4<>0 then
         continue;
      nn:=0;
      lookup(nsol,sol,cfg.acmsolp);
      for i:=1 to nsol do begin
          getACMsolinfo(sol[i].fname,ttime,iid);
          if ttime='' then
             RegisterSolution(sol[i],0);
      end;
      except
        on e:exception do begin
           LogError(e);
           ShowError(e);
           if Windows.MessageBox(0,'Terminate register thread?','IJE',MB_ICONQUESTION or MB_YESNO)=ID_NO then
              terminate;
        end;
      end;
end;
end;

procedure tRegisterThread.RegisterSolution(var sol: tSolData;fname_id:integer);
var i:integer;
    ContId:integer;
    war:string;
    id,time:integer;
    newname:string;
    sst:tSubmitStatus;
    OnTime:integer;
begin
if fname_id=0 then
   sleep(1000);//wait until solution is copied completely
ContId:=0;
for i:=1 to nContests do
    if Contest[i].BelongsTo(sol) then begin
       if ContId<>0 then begin
          war:=format('Contests conflict. Solution (%s:%s:%s:%s) belongs to contests %d (%s) and %d (%s)',
                           [sol.boy,sol.day,sol.task,sol.fname,ContId,Contest[ContId].qcfg.Title,i,Contest[i].qcfg.Title]);
          warning(war);
          NonModalMessageBox(0,PChar(war),'IJE QACM: contest conflict',MB_ICONEXCLAMATION or MB_SYSTEMMODAL);
       end;
       ContId:=i;
    end;
if ContId=0 then begin
   LogWriteln('Found solution '+sol.fname+':ignoring',LOG_LEVEL_MINOR);
   ForceNoFile(cfg.acmsolp+sol.fname+'.'+sol.ext);
   exit;
end;
if fname_id=0 then begin
   OnTime:=Contest[ContId].OnTime;
   if OnTime<>0 then begin
      sst.status:='rejected';
      if OnTime=1 then
         sst.reason:='_late';
      if OnTime=-1 then
         sst.reason:='_early';
      SaveSubmitStatus(qcfg.repp+sol.fname+'.xml',sst);
      ForceNoFile(sol.dir+sol.fname+'.'+sol.ext);
      exit;
   end;
   time:=Contest[ContId].CurrentTime;
   id:=Contest[ContId].RegisterSolution(sol,time);
   newname:=makeACMsolname(sol.boy,sol.day,sol.task,IntToStr(time),IntToStr(id));
   RenameFile(cfg.acmsolp+sol.fname+'.'+sol.ext,cfg.acmsolp+newname+'.'+sol.ext);
   sst.status:='waiting';
   sst.id:=id;
   sst.reason:='';
   SaveSubmitStatus(qcfg.repp+sol.fname+'.xml',sst);
   sol.fname:=newname;
   Contest[ContId].SaveTable;
end else
    id:=fname_id;
submit[nsubmit+1].sol:=sol;
submit[nsubmit+1].ContId:=ContId;
submit[nsubmit+1].IdInCont:=id;
inc(nsubmit);
end;

{ tOnIdleThread }

procedure tOnIdleThread.Execute;
var i:integer;
    nn:integer;
begin
nn:=119;//чтобы выполнилось первый раз сразу
while not terminated do begin
      sleep(500);
      inc(nn);
      if nn mod 20<>0 then continue;
      if nn mod 120=0 then nn:=0;
      for i:=1 to nContests do begin
          try
            Contest[i].OnIdle;
            if nn=0 then
               Contest[i].SaveTable;//nn обнул€етс€ раз в полминуты
          except
            on e:exception do begin
               LogError(e);
               ShowError(e);
               if Windows.MessageBox(0,'Terminate OnIdle thread?','IJE',MB_ICONQUESTION or MB_YESNO)=ID_NO then
                  terminate;
            end;
          end;
      end;
end;
end;

{ tSendToTestThread }

procedure tSendToTestThread.Execute;
var nn:integer;
begin
nn:=9;
while not terminated do begin
      try
      sleep(500);
      inc(nn);
      if nn mod 10<>0 then
         continue;
      nn:=0;
      if stopped then
         continue;
      while lsubmit<=nsubmit do begin
         SendToTest(lsubmit);
         inc(lsubmit);
      end;
      except
        on e:exception do begin
           LogError(e);
           ShowError(e);
           if Windows.MessageBox(0,'Terminate SendToTest thread?','IJE',MB_ICONQUESTION or MB_YESNO)=ID_NO then
              terminate;
        end;
      end;
end;
end;

type tACMCBdata=record
        testresult:tTestResults;
        id:integer;
     end;
     pACMCBdata=^tACMCBdata;

procedure ACMCB(msg:pMSGbuffer;data:pACMCBdata);
var tr:pTCStestResult absolute msg;
    err:pALLeIJEerror absolute msg;
begin
try
LogWriteln('ACMCB()'+IntToStr(Integer(msg))+' '+IntToStr(Integer(data))+' '+IntToStr(data.testresult.ntests),LOG_LEVEL_MAJOR);
case msg^.typ of
     ALL_EIJEERROR:begin
                        data.testresult.ntests:=1;
                        with data.testresult.test[1] do begin
                           res:=_fl;
                           text:=err.name+' in '+err.procpath+' '+err.text;
                           evaltext:='';
                           pts:=0;
                           max:=0;
                           time:=-1;
                           mem:=-1;
                        end;
                   end;
     TCS_TESTRESULT:begin
                      if data.testresult.ntests<tr.id then
                         data.testresult.ntests:=tr.id;
                      with data.testresult.test[tr.id] do begin //tr.id будет 1 при первом тесте после компил€ции
                           res:=tr.res;
                           text:=tr.text;
                           evaltext:=tr.evaltext;
                           pts:=tr.pts;
                           max:=tr.max;
                           time:=tr.time;
                           mem:=tr.mem;
                      end;
                    end;
     TCS_TESTINGFINISHED:begin
                       Contest[submit[data.id].ContId].TestedSolution(submit[data.id].IdInCont,data.testresult);
                       Contest[submit[data.id].ContId].SaveTable;
                       ArchiveSolution(submit[data.id].sol);
                       dispose(data);
                    end;
end;
except
  on e:exception do begin
     LogError(e);
     NonModalShowError(e);
  end;
end;
end;

procedure tSendToTestThread.SendToTest(id: integer);
var tt:tTestingTask;
    CBdata:pACMCBdata;
begin
try
//Code starts
new(CBdata);
fillchar(CBdata^,sizeof(CBdata^),0);
CBdata.testresult.ntests:=0;
CBdata.id:=id;

fillchar(tt,sizeof(tt),0);
tt.ts.typ:=UIS_TESTSOLUTION;
tt.ts.gtid:=GenerateGTID;
tt.ts.num:=-1;//it seems to be meaningless here
tt.ts.testset:=[0..255];
tt.ts.args:='';
tt.ts.synchro:=false;
tt.ts.archive:=false;//it seems to be meaningless here
tt.sock:=0;
tt.SolData:=submit[id].sol;
tt.TaskType:='P';
tt.CB:=@ACMCB;
tt.data:=CBdata;
tt.real:=true;
tt.killed:=false;


TQthread.Add(tt);
LogWriteln('!!added',LOG_LEVEL_MAJOR);
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'tSendToTestThread.SendToTest');
end;
end;

{ tWriteTableThread }

procedure tWriteTableThread.ChangeCurrentContest;
var nn:integer;
    i:integer;
begin
SetTextAttr($07);
clrscr;
writeln('\$0f;Select contest for monitoring: \*;');
for i:=1 to nContests do
    writeln(format('%d: %s',[i,Contest[i].qcfg.title]));
writeln;
writeln('0: Cancel');
writeln;
writeln('\$0f;?\*;');
SetTextAttr($0f);
readln(nn);
SetTextAttr($07);
if (nn>=1)and(nn<=nContests) then
   CurrentConsoleContest:=nn
else if nn<>0 then begin
     writeln('Wrong contest number. Press Enter...');
     readln;
end;
end;

function WinToDos(s:string):string;
var s1:pWideChar;
    s2:pChar;
begin
GetMem(s1,length(s)*4);
GetMem(s2,length(s)*4);
MultiByteToWideChar(1251,0,PChar(s),-1,s1,length(s)*2);
WideCharToMultiByte(866,0,s1,-1,s2,length(s)*4,nil,nil);
result:=s2;
FreeMem(s1);
FreeMem(s2);
end;

procedure tWriteTableThread.Execute;
const symb:array[0..3] of char='-\|/';
var nn:integer;
    ch:char;
begin
nn:=3;//чтобы при первом входе отрисовалась таблица
while not terminated do begin
      try
      write(#13'It seems that it works... '+symb[nn]);
      sleep(500);
      if keypressed then begin
         LogWriteln('keypressed',log_level_major);
         sleep(100);
         if Terminated then
            break;
         nn:=3;
         ch:=readkey;
         if (ch=#0)and(keypressed) then begin
            LogWriteLn('#0 pressed',log_level_major);
            ch:=readkey;
            if ch=#70 then//F12
               ChangeCurrentContest
            else with Contest[CurrentConsoleContest] do begin
                      PressedKey(#0);
                      PressedKey(ch);
                 end;
         end else {ch<>#0 or keypressed}
             with Contest[CurrentConsoleContest] do 
                  PressedKey(ch);
      end;
      inc(nn);
      if nn mod 4<>0 then continue;
      nn:=0;
      SetConsoleTitle(PChar(format('%s - ACM contest %d - IJE Server',[WinToDos(Contest[CurrentConsoleContest].qcfg.title),CurrentConsoleContest])));
      with Contest[CurrentConsoleContest] do begin
           WriteScreenTable;
      end;
      except
        on e:exception do begin
           LogError(e);
           ShowError(e);
           if Windows.MessageBox(0,'Terminate WriteTableThread?','IJE',MB_ICONQUESTION or MB_YESNO)=ID_NO then
              terminate;
        end;
      end;
end;
end;

end.