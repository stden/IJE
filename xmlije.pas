{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O-,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ This file is part of IJE: the Integrated Judging Environment system }
{ (C) Kalinin Petr 2002-2008 }
{ $Id: xmlije.pas 211 2010-01-22 17:09:54Z Стандартный $ }
unit xmlije;

interface
uses sysutils,xml,ijeconsts;

type tcompilers=array[1..100] of record 
                  ext,cmdline,name,runline,compext:string; 
                  keepname:boolean;
                end;
     tProblemName=array[0..127] of char;
     tSettings=record
                  testingp:string;
                  testp:string;
                  solp:string;
                  acmsolp:string;
                  resp:string;
                  reportsp:string;
                  dllp:string;
                  macp:string;
                  archivep:string;
                  rundll:string;
                  idlelim:integer;//milliseconds
                  idlepercent:integer;{percent}
                  solformat:string;
                  acmsolformat:string;
                  taskformat:string;
                  tabledll:string;
                  ncomp:integer;
                  comp:tcompilers;
                  defcmd:record
                    server:string;
                    tc:string;
                    uic:string;
                  end;
                end;
     tEvalTypes=array[1..MaxEvalTypes] of integer;
     tPoints=array[0..MaxPC] of integer;
     tTest=record
             input_href:string;
             answer_href:string;
             points:tPoints;
             evalt:tEvalTypes;
           end;
     tProblem=record
                id:string;
                name:string;
                ntests:integer;
                test:array[1..MaxTests] of tTest;
                input_name:string;
                output_name:string;
                input_href,
                answer_href:string;
                verifier,evaluator:string;
                tl,ml:longint;
              end;
     tRunStatus=record
                      time:double;
                      totalTime:double;
                      mem:integer;
                      peakMem:integer;
                end;
     tRunParams=record
                     tl,ml,il:integer;{ms and bytes and ms!}
                     idlepercent:integer;{percent}
                     quiet:boolean;
                     norights:boolean;{Don''t give any rights to program?}
                     p:tproblem;
                     CB:function (var status:tRunStatus):boolean;
                  end;
     tRunOutcome=record
                   result:tresult;
                   text:string;
                   time:double;
                   mem:integer;
                 end;
     tOutcome=record
                    res:tResult;
                    text:string;
              end;
     tHisResults=record
                  ntests:integer;
                  test:array[1..maxtests] of record
                    res:tResult;
                    text:string;
                    evaltext:string;
                  end;
                 end;
     tSTableResult=record
                      minus:word;
                      pts:word;
                      res:tresult;
                   end;
     pSTableResult=^tsTableResult;
     tstable=array[1..maxboys,1..maxtasks+1] of tsTableResult;
     ttasks=array[1..maxtasks] of string;
     tboys=array[1..maxboys] of string;
     ttasktypes=array[1..maxtasks] of char;
     tTable=record
      t:tstable;
      nboy,ntask:integer;
      boy:tboys;
      task:ttasks;
      tasktype:ttasktypes;
      loc:array[1..maxtests] of integer;
    end;
    tReport=record
      gtid:tGTID;
      task:string;
      boy:string;
      taskname:string;
      tasktype:char;
      tl:longint;
      ml:longint;
      comp:record
            res:tResult;
            cmdline:string;
            text:string;
      end;
      ntests:integer;
      test:array[1..MAXTESTS] of record
         res:tResult;
         pts,maxpts:word;
         text,evaltext:string;
         time:double;
         mem:integer;
      end;
      pts:integer;
      maxpts:integer;
      res:tResult;
    end;
    tShowtestTestResult=record
      boy:string;
      problem:string;
      pname:string;
      id:integer;
      res:tResult;
      pts:integer;
      max:integer;
    end;
    tQACMsettings=record
      ncont:integer;
      cont:array[1..MAX_ACM_CONTESTS] of record qdll,fname:string; end;
      repp:string;
      dst:integer;
    end;
    tSubmitStatus=record
      status:string;
      id:integer;
      reason:string;
    end;
    tClassicACMsettings=record
      start:integer;
      length:integer;
      title:string;
      penalty:integer;
      showtest:boolean;
      showcomment:boolean;
      monitorFile:string;
      submitsFile:string;
      ntask:integer;
      task:array[1..maxtasks] of record id,name:string; end;
      nparty:integer;
      party:array[1..maxboys] of record id,name,pwd:string; end;
    end;
    tClassicACMsubmits=record
      nsubmit:integer;
      s:array[1..MAX_ACM_SUBMITS] of record
         party:string;
         task:string;
         lang:string;
         time:integer;
         id:integer;
         //-----------
         res:tresult;
         test:integer;
         comment:string;
      end;
    end;
    tClassicACMmonitor=record
      qcfg:tClassicACMsettings;
      submits:tClassicACMsubmits;
      solved:array[1..maxboys,0..maxtasks] of integer;
      time:array[1..maxboys,0..maxtasks]of integer;
      ije_ver:string;
      contest_time:integer;
      status:string;
    end;
    tKirovACmsettings=record
      start:integer;
      length:integer;
      title:string;
      monitorFile:string;
      submitsFile:string;
      ntask:integer;
      task:array[1..maxtasks] of record id,name:string; end;
      nparty:integer;
      party:array[1..maxboys] of record id,name,pwd:string; end;
      //----
      penalty:longint;
      showtests:boolean;
      showcomments:boolean;
    end;
    tKirovACMsubmits=record
      nsubmit:integer;
      s:array[1..MAX_ACM_SUBMITS] of record
         party:string;
         task:string;
         lang:string;
         time:integer;
         id:integer;
         //----------
         tr:ttestresults;
         pts,maxpts:word;
      end;
    end;
    tKirovACMmonitor=record
      qcfg:tKirovACmsettings;
      submits:tKirovACMsubmits;
      ije_ver:string;
      contest_time:integer;
      status:string;
      attempts,max,pts:array[1..maxboys,0..maxtasks] of integer;
    end;
    tRWACmsettings=record
      start:integer;
      length:integer;
      title:string;
      monitorFile:string;
      submitsFile:string;
      ntask:integer;
      task:array[1..maxtasks] of record id,name:string; end;
      nparty:integer;
      party:array[1..maxboys] of record id,name,pwd:string; end;
      //----
      baseresults:string;
      showtests,showcomments:boolean;
      coeff:extended;
    end;
    tRWACMsubmits=record
      nsubmit:integer;
      s:array[1..MAX_ACM_SUBMITS] of record
         party:string;
         task:string;
         lang:string;
         time:integer;
         id:integer;
         //----------
         tr:ttestresults;
         pts:word;
      end;
    end;
    tRWACMmonitor=record
      qcfg:tRWACmsettings;
      submits:tRWACMsubmits;
      ije_ver:string;
      contest_time:integer;
      status:string;
      attempts,pts:array[1..maxboys,0..maxtasks] of integer;
    end;
    tRunLauncherSettings=record
      useDefDesktop:boolean;
      user:array[false..true] of record
             name,pwd:WideString;
           end;
    end;


procedure LoadSettings(fname:string;var a:tSettings);
procedure SaveSettings(fname:string;var a:tSettings);
procedure LoadProblem(fname:string;var a:tProblem);
procedure SaveProblem(fname:string;var a:tProblem);
procedure LoadOutcome(fname:string;var a:tOutcome);
procedure SaveOutcome(fname:string;var a:tOutcome);
procedure LoadHisResults(fname:string;var a:tHisResults);
procedure SaveHisResults(fname:string;var a:tHisResults);
procedure LoadTable(fname:string;var a:tTable);
procedure SaveTable(fname:string;var a:tTable);
procedure LoadReport(fname:string;var a:tReport);
procedure SaveReport(fname:string;var a:tReport);
procedure LoadShowtestTestResult(fname:string;var a:tShowtestTestResult);
procedure SaveShowtestTestResult(fname:string;var a:tShowtestTestResult);
procedure LoadSubmitStatus(fname:string;var a:tSubmitStatus);
procedure SaveSubmitStatus(fname:string;var a:tSubmitStatus);
procedure LoadQACMsettings(fname:string;var a:tQACMsettings);
procedure SaveQACMsettings(fname:string;var a:tQACMsettings);
procedure LoadClassicACMsettings(fname:string;var a:tClassicACMsettings);
procedure SaveClassicACMsettings(fname:string;var a:tClassicACMsettings);
procedure LoadClassicACMsubmits(fname:string;var a:tClassicACMsubmits);
procedure SaveClassicACMsubmits(fname:string;var a:tClassicACMsubmits);
procedure LoadClassicACMmonitor(fname:string;var a:tClassicACMmonitor);
procedure SaveClassicACMmonitor(fname:string;var a:tClassicACMmonitor);
procedure LoadKirovACMsettings(fname:string;var a:tKirovACMsettings);
procedure SaveKirovACMsettings(fname:string;var a:tKirovACMsettings);
procedure LoadKirovACMsubmits(fname:string;var a:tKirovACMsubmits);
procedure SaveKirovACMsubmits(fname:string;var a:tKirovACMsubmits);
procedure LoadKirovACMmonitor(fname:string;var a:tKirovACMmonitor);
procedure SaveKirovACMmonitor(fname:string;var a:tKirovACMmonitor);
procedure LoadRWACMmonitor(fname:string;var a:tRWACMmonitor);
procedure SaveRWACMmonitor(fname:string;var a:tRWACMmonitor);
procedure LoadRWACMsettings(fname:string;var a:tRWACMsettings);
procedure SaveRWACMsettings(fname:string;var a:tRWACMsettings);
procedure LoadRWACMsubmits(fname:string;var a:tRWACMsubmits);
procedure SaveRWACMsubmits(fname:string;var a:tRWACMsubmits);
procedure LoadRunLauncherSettings(fname:string;var a:tRunLauncherSettings);
procedure SaveRunLauncherSettings(fname:string;var a:tRunLauncherSettings);

implementation

function OptStrToInt(s:string;def:integer):integer;
begin
if s='' then
   result:=def
else result:=StrToInt(s);
end;

function OptStrToBool(s:string;def:boolean):boolean;
begin
if s='' then
   result:=def
else result:=StrToBool(s);
end;

function StrToChar(s:string):char;
begin
if length(s)=1 then
   result:=s[1]
else raise eIJEerror.create('','','Can''t convert string "%s" to char',[s]);
end;

//Needed for LoadProblem & LoadSettings
function StringToML(s:string):longint;
var ss,sss:string;
    i:integer;
    rez:longint;
begin
LogEnterProc('StringToML',LOG_LEVEL_MINOR);
try
try
//Code starts
i:=1;ss:='';
while s[i] in ['0'..'9'] do begin
      ss:=ss+s[i];
      inc(i);
end;
sss:=copy(s,i,length(s)-i+1);
if ss='' then begin
   result:=0;
   exit;
end;
rez:=StrToInt(ss);
if (sss='M')or(sss='Mb')or(sss='MB') then
   rez:=rez*1024*1024
else if (sss='K')or(sss='Kb')or(sss='KB') then
    rez:=rez*1024
else if (sss='b')or(sss='')or(sss='B') then
else raise eIJEerror.Create('Strange unit in ML','','Strange unit in ML - %s',[sss]);
result:=rez;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'StringToML');
end;
finally
  LogLeaveProc('StringToML',LOG_LEVEL_MINOR,IntToStr(result));
end;
end;

function StringToTL(s:string):longint;
var ss,sss:string;
    i:integer;
    rez:longint;
begin
LogEnterProc('StringToTL',LOG_LEVEL_MINOR);
try
try
//Code starts
i:=1;ss:='';
while s[i] in ['0'..'9'] do begin
      ss:=ss+s[i];
      inc(i);
end;
sss:=copy(s,i,length(s)-i+1);
if ss='' then begin
   result:=0;
   exit;
end;
rez:=StrToInt(ss);
if (sss='s')or(sss='sec')or(sss='S')or(ss='Sec') then
   rez:=rez*1000
else if (sss='msec')or(sss='ms') then
else raise eIJEerror.Create('Strange unit in TL','','Strange unit in TL - %s',[sss]);
result:=rez;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'StringToTL');
end;
finally
  LogLeaveProc('StringToTL',LOG_LEVEL_MINOR,IntToStr(result));
end;
end;

//Settings starts
procedure LoadSettings(fname:string;var a:tSettings);
var root0:pXMLelement;
    root:pXMLelement;
    default_cmdline:pXMLelement;
    languages:pXMLelement;
    language:pXMLelement;
    i:integer;
begin
LogEnterProc('LoadSettings',LOG_LEVEL_MINOR,''''+fname+'''');
try
try  
fillchar(a,sizeof(a),0);
readXMlfile(fname,root0);
try
  root:=findXMLelementEC(root0,'ije-configuration');
  a.testingp:=ExpandFileName(findXMLattrEC(root,'testing-path'))+'\';
  a.testp:=ExpandFileName(findXMLattrEC(root,'problems-path'))+'\';
  a.solp:=ExpandFileName(findXMLattrEC(root,'solutions-path'))+'\';
  a.acmsolp:=ExpandFileName(findXMLattrEC(root,'acm-solutions-path'))+'\';
  a.resp:=ExpandFileName(findXMLattrEC(root,'results-path'))+'\';
  a.reportsp:=ExpandFileName(findXMLattrEC(root,'reports-path'))+'\';
  a.dllp:=ExpandFileName(findXMLattrEC(root,'dll-path'))+'\';
  a.macp:=ExpandFileName(findXMLattrEC(root,'macs-path'))+'\';
  a.archivep:=ExpandFileName(findXMLattrEC(root,'archive-path'))+'\';
  a.rundll:=XMLtoText(findXMLattrEC(root,'run-dll'));
  a.idlelim:=StringToTL(findXMLattrEC(root,'idle-limit'));
  a.idlepercent:=StrToInt(findXMLattrEC(root,'idle-percent'));
  a.solformat:=XMLtoText(findXMLattrEC(root,'solutions-format'));
  a.acmsolformat:=XMLtoText(findXMLattrEC(root,'acm-solutions-format'));
  a.taskformat:=XMLtoText(findXMLattrEC(root,'problems-format'));
  a.tabledll:=XMLtoText(findXMLattrEC(root,'table-dll'));
  default_cmdline:=findXMLelementC(root,'default-cmdline');
    a.defcmd.tc:=XMLtoText(findXMLattrEC(default_cmdline,'test-client',false));
    a.defcmd.server:=XMLtoText(findXMLattrEC(default_cmdline,'server',false));
    a.defcmd.uic:=XMLtoText(findXMLattrEC(default_cmdline,'user-interface-classic',false));
  languages:=findXMLelementCC(root,'languages');
    language:=findXMLelementCC(languages,'language');
    i:=0;
    while language<>nil do begin
      inc(i);
      a.comp[i].cmdline:=XMLtoText(findXMLattrEC(language,'command-line'));
      a.comp[i].ext:=UpperCase(XMLtoText(findXMLattrEC(language,'id')));
      a.comp[i].name:=XMLtoText(findXMLattrEC(language,'name'));
      a.comp[i].runline:=XMLtoText(findXMLattrEC(language,'run-command-line',false));
      if a.comp[i].runline='' then a.comp[i].runline:='@.exe';
      a.comp[i].compext:=XMLtoText(findXMLattrEC(language,'compiled-ext',false));
      if a.comp[i].compext='' then a.comp[i].compext:='.exe';
      a.comp[i].keepname:=OptStrToBool(findXMLattrEC(language,'keep-source-name',false),false);

      language:=findXMLelement(language^.next,'language');
    end;
    a.ncomp:=i;
finally
  XMldispose(root0);
end;
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'LoadSettings('+fname+')','Error while loading tSettings');
end;
finally
  LogLeaveProc('LoadSettings',LOG_LEVEL_MINOR);
end;
end;

procedure SaveSettings(fname:string;var a:tSettings);
var f:text;
    buf:packed array[0..8191] of byte;
    i:integer;
begin
assign(f,fname);rewrite(f);SetTextBuf(f,buf,sizeof(buf));
writeln(f,'<?xml version="1.0" encoding="Windows-1251"?>');
  write(f,'<ije-configuration');
  writeln(f);write(f,'');
  write(f,format('  testing-path="%s"',[a.testingp]));
  writeln(f);write(f,'');
  write(f,format('  problems-path="%s"',[a.testp]));
  writeln(f);write(f,'');
  write(f,format('  solutions-path="%s"',[a.solp]));
  writeln(f);write(f,'');
  write(f,format('  acm-solutions-path="%s"',[a.acmsolp]));
  writeln(f);write(f,'');
  write(f,format('  results-path="%s"',[a.resp]));
  writeln(f);write(f,'');
  write(f,format('  reports-path="%s"',[a.reportsp]));
  writeln(f);write(f,'');
  write(f,format('  dll-path="%s"',[a.dllp]));
  writeln(f);write(f,'');
  write(f,format('  macs-path="%s"',[a.macp]));
  writeln(f);write(f,'');
  write(f,format('  archive-path="%s"',[a.archivep]));
  writeln(f);write(f,'');
  write(f,format('  run-dll="%s"',[TextToXML(a.rundll)]));
  writeln(f);write(f,'');
  write(f,format('  idle-limit="%d"',[a.idlelim]));
  writeln(f);write(f,'');
  write(f,format('  idle-percent="%d"',[a.idlepercent]));
  writeln(f);write(f,'');
  write(f,format('  solutions-format="%s"',[TextToXML(a.solformat)]));
  writeln(f);write(f,'');
  write(f,format('  acm-solutions-format="%s"',[TextToXML(a.acmsolformat)]));
  writeln(f);write(f,'');
  write(f,format('  problems-format="%s"',[TextToXML(a.taskformat)]));
  writeln(f);write(f,'');
  write(f,format('  table-dll="%s"',[TextToXML(a.tabledll)]));
  writeln(f);write(f,'');
  writeln(f,'>');
    write(f,'  <default-cmdline');
    write(f,format(' test-client="%s"',[TextToXML(a.defcmd.tc)]));
    write(f,format(' server="%s"',[TextToXML(a.defcmd.server)]));
    write(f,format(' user-interface-classic="%s"',[TextToXML(a.defcmd.uic)]));
    writeln(f,'/>');
    write(f,'  <languages');
    writeln(f,'>');
    for i:=1 to a.ncomp do begin
      write(f,'    <language');
      write(f,format(' command-line="%s"',[TextToXML(a.comp[i].cmdline)]));
      write(f,format(' id="%s"',[TextToXML(a.comp[i].ext)]));
      write(f,format(' name="%s"',[TextToXML(a.comp[i].name)]));
      write(f,format(' run-command-line="%s"',[TextToXML(a.comp[i].runline)]));
      write(f,format(' compiled-ext="%s"',[TextToXML(a.comp[i].compext)]));
      write(f,format(' keep-source-name="%s"',[a.comp[i].keepname]));
      writeln(f,'/>');
    end;
    writeln(f,'  </languages>');
  writeln(f,'</ije-configuration>');
close(f);
end;
//Settings ends


procedure ExplodeArray(s:string;var a:array of integer);
var i,p:integer;
    cur:string;
begin
LogEnterProc('ExplodeArray',LOG_LEVEL_MINOR);
try
try
//Code starts
s:=s+#0;
cur:='';
p:=-1;
for i:=1 to length(s) do begin
    case s[i] of
         '0'..'9':cur:=cur+s[i];
         else if cur<>'' then begin
              inc(p);
              if p>High(a) then
                 raise eIJEerror.Create('Too long string','','Too long string: number of elements exceeds %d',[High(a)]);
              a[p]:=StrToInt(cur);
              cur:='';
         end;
    end;
end;
for i:=p+1 to High(a) do
    a[i]:=-1;
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'ExplodeArray');
end;
finally
  LogLeaveProc('ExplodeArray',LOG_LEVEL_MINOR);
end;
end;

procedure ImplodeArray(var a:array of integer;var s:string);
var i:integer;
begin
LogEnterProc('ImplodeArray',LOG_LEVEL_MINOR);
try
try
//Code starts
s:='';
for i:=High(a) downto 0 do
    if a[i]<>-1 then
       break;
if (i<0) or (a[i]=-1) then
   exit;
for i:=i downto 0 do
    s:=' '+IntToStr(a[i])+s;
delete(s,1,1);
//Code ends
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'ImplodeArray');
end;
finally
  LogLeaveProc('ImplodeArray',LOG_LEVEL_MINOR);
end;
end;

procedure MakeTestFileName(fmt:string;number:integer;var fname:string);
var s:array[1..2] of string;
    nn:integer;
    p:integer;
    ff:string;
    i:integer;
begin
s[1]:='';s[2]:='';
p:=1;
nn:=0;
for i:=1 to length(fmt) do
    if fmt[i]='#' then begin
       inc(nn);
       if p=1 then p:=2;
    end else
      s[p]:=s[p]+fmt[i];
ff:=s[1]+'%'+inttostr(nn)+'.'+inttostr(nn)+'d'+s[2];
fname:=format(ff,[number]);
end;

//Problem starts
procedure LoadProblem(fname:string;var a:tProblem);
var raw_points:array[1..maxtests] of string;
    raw_eval:array[1..maxtests] of string;
    root0:pXMLelement;
    root:pXMLelement;
    name:pXMLelement;
    judging:pXMLelement;
    script:pXMLelement;
    verifier:pXMLelement;
    binary:pXMLelement;
    evaluator:pXMLelement;
    binary1:pXMLelement;
    testset:pXMLelement;
    test:pXMLelement;
    i:integer;
begin
LogEnterProc('LoadProblem',LOG_LEVEL_MINOR,''''+fname+'''');
try
try  
fillchar(a,sizeof(a),0);
readXMlfile(fname,root0);
try
  root:=findXMLelementEC(root0,'problem');
  a.id:=XMLtoText(findXMLattrEC(root,'id'));
  name:=findXMLelementCC(root,'name');
    a.name:=XMLtoText(findXMLattrEC(name,'value'));
  judging:=findXMLelementCC(root,'judging');
    script:=findXMLelementCC(judging,'script');
      verifier:=findXMLelementCC(script,'verifier');
        binary:=findXMLelementCC(verifier,'binary');
          a.verifier:=XMLtoText(findXMLattrEC(binary,'href'));
      evaluator:=findXMLelementC(script,'evaluator');
        binary1:=findXMLelementC(evaluator,'binary');
          a.evaluator:=XMLtoText(findXMLattrEC(binary1,'href',false));
      testset:=findXMLelementCC(script,'testset');
        a.input_name:=XMLtoText(findXMLattrEC(testset,'input-name'));
        a.output_name:=XMLtoText(findXMLattrEC(testset,'output-name'));
        a.input_href:=XMLtoText(findXMLattrEC(testset,'input-href'));
        a.answer_href:=XMLtoText(findXMLattrEC(testset,'answer-href'));
        a.tl:=StringToTL(findXMLattrEC(testset,'time-limit'));
        a.ml:=StringToML(findXMLattrEC(testset,'memory-limit'));
        test:=findXMLelementCC(testset,'test');
        i:=0;
        while test<>nil do begin
          inc(i);
          raw_points[i]:=XMLtoText(findXMLattrEC(test,'points'));
          raw_eval[i]:=XMLtoText(findXMLattrEC(test,'eval-types',false));

          test:=findXMLelement(test^.next,'test');
        end;
        a.ntests:=i;
  for i:=1 to a.ntests do begin
     ExplodeArray(raw_points[i],a.test[i].points);
     ExplodeArray(raw_eval[i],a.test[i].evalt);
     MakeTestFileName(a.input_href,i,a.test[i].input_href);
     MakeTestFileName(a.answer_href,i,a.test[i].answer_href);
  end;
finally
  XMldispose(root0);
end;
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'LoadProblem('+fname+')','Error while loading tProblem');
end;
finally
  LogLeaveProc('LoadProblem',LOG_LEVEL_MINOR);
end;
end;

procedure SaveProblem(fname:string;var a:tProblem);
var raw_points:array[1..maxtests] of string;
    raw_eval:array[1..maxtests] of string;
    f:text;
    buf:packed array[0..8191] of byte;
    i:integer;
begin
assign(f,fname);rewrite(f);SetTextBuf(f,buf,sizeof(buf));
for i:=1 to a.ntests do begin
    ImplodeArray(a.test[i].points,raw_points[i]);
    ImplodeArray(a.test[i].evalt,raw_eval[i]);
end;
writeln(f,'<?xml version="1.0" encoding="Windows-1251"?>');
  write(f,'<problem');
  write(f,format(' id="%s"',[TextToXML(a.id)]));
  writeln(f,'>');
    write(f,'  <name');
    write(f,format(' value="%s"',[TextToXML(a.name)]));
    writeln(f,'/>');
    write(f,'  <judging');
    writeln(f,'>');
      write(f,'    <script');
      write(f,' type="%ioi"');
      writeln(f,'>');
        write(f,'      <verifier');
        write(f,' type="%testlib"');
        writeln(f,'>');
          write(f,'        <binary');
          write(f,' executable-id="x86.exe.win32"');
          write(f,format(' href="%s"',[TextToXML(a.verifier)]));
          writeln(f,'/>');
        writeln(f,'      </verifier>');
        write(f,'      <evaluator');
        write(f,' type="%ije"');
        writeln(f,'>');
          write(f,'        <binary');
          write(f,' executable-id="x86.exe.win32"');
          write(f,format(' href="%s"',[TextToXML(a.evaluator)]));
          writeln(f,'/>');
        writeln(f,'      </evaluator>');
        write(f,'      <testset');
        write(f,format(' input-name="%s"',[TextToXML(a.input_name)]));
        write(f,format(' output-name="%s"',[TextToXML(a.output_name)]));
        write(f,format(' input-href="%s"',[TextToXML(a.input_href)]));
        write(f,format(' answer-href="%s"',[TextToXML(a.answer_href)]));
        write(f,format(' time-limit="%d"',[a.tl]));
        write(f,format(' memory-limit="%d"',[a.ml]));
        writeln(f,'>');
        for i:=1 to a.ntests do begin
          write(f,'        <test');
          write(f,format(' points="%s"',[TextToXML(raw_points[i])]));
          write(f,format(' eval-types="%s"',[TextToXML(raw_eval[i])]));
          writeln(f,'/>');
        end;
        writeln(f,'      </testset>');
      writeln(f,'    </script>');
    writeln(f,'  </judging>');
  writeln(f,'</problem>');
close(f);
end;
//Problem ends

//Outcome starts
procedure LoadOutcome(fname:string;var a:tOutcome);
var pctype:integer;
    root0:pXMLelement;
    root:pXMLelement;
begin
LogEnterProc('LoadOutcome',LOG_LEVEL_MINOR,''''+fname+'''');
try
try  
fillchar(a,sizeof(a),0);
readXMlfile(fname,root0);
try
  root:=findXMLelementEC(root0,'result');
  a.res:=XmlToResult(findXMLattrEC(root,'outcome'));
  a.text:=XMLtoText(findXMLattrEC(root,'comment'));
  pctype:=OptStrToInt(findXMLattrEC(root,'pc-type',false),0);
  if a.res=_pc then begin
     if pctype=0 then
        raise eIJEerror.Create('','','PC type 0 for _pc')
     else a.res:=_pcbase+pctype;
  end else if (pctype<>0)and(a.res<=_pcbase) then
      raise eIJEerror.create('','','Can''t have PCtype for non-pc outcome %d',[a.res]);
finally
  XMldispose(root0);
end;
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'LoadOutcome('+fname+')','Error while loading tOutcome');
end;
finally
  LogLeaveProc('LoadOutcome',LOG_LEVEL_MINOR);
end;
end;

procedure SaveOutcome(fname:string;var a:tOutcome);
var pctype:integer;
    f:text;
    buf:packed array[0..8191] of byte;
begin
assign(f,fname);rewrite(f);SetTextBuf(f,buf,sizeof(buf));
if a.res>_pcbase then
   pctype:=a.res-_pcbase
else pctype:=0;
writeln(f,'<?xml version="1.0" encoding="Windows-1251"?>');
  write(f,'<result');
  write(f,format(' outcome="%s"',[Xmltext(a.res)]));
  write(f,format(' comment="%s"',[TextToXML(a.text)]));
  write(f,format(' pc-type="%d"',[pctype]));
  writeln(f,'/>');
close(f);
end;
//Outcome ends

//HisResults starts
procedure LoadHisResults(fname:string;var a:tHisResults);
var root0:pXMLelement;
    root:pXMLelement;
    test:pXMLelement;
    i:integer;
begin
LogEnterProc('LoadHisResults',LOG_LEVEL_MINOR,''''+fname+'''');
try
try  
fillchar(a,sizeof(a),0);
readXMlfile(fname,root0);
try
  root:=findXMLelementEC(root0,'hisresults');
  test:=findXMLelementCC(root,'test');
  i:=0;
  while test<>nil do begin
    inc(i);
    a.test[i].res:=XmlToResult(findXMLattrEC(test,'res'));
    a.test[i].text:=XMLtoText(findXMLattrEC(test,'text'));
    a.test[i].evaltext:=XMLtoText(findXMLattrEC(test,'evaltext'));

    test:=findXMLelement(test^.next,'test');
  end;
  a.ntests:=i;
finally
  XMldispose(root0);
end;
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'LoadHisResults('+fname+')','Error while loading tHisResults');
end;
finally
  LogLeaveProc('LoadHisResults',LOG_LEVEL_MINOR);
end;
end;

procedure SaveHisResults(fname:string;var a:tHisResults);
var f:text;
    buf:packed array[0..8191] of byte;
    i:integer;
begin
assign(f,fname);rewrite(f);SetTextBuf(f,buf,sizeof(buf));
writeln(f,'<?xml version="1.0" encoding="Windows-1251"?>');
  write(f,'<hisresults');
  writeln(f,'>');
  for i:=1 to a.ntests do begin
    write(f,'  <test');
    write(f,format(' res="%s"',[Xmltext(a.test[i].res)]));
    write(f,format(' text="%s"',[TextToXML(a.test[i].text)]));
    write(f,format(' evaltext="%s"',[TextToXML(a.test[i].evaltext)]));
    writeln(f,'/>');
  end;
  writeln(f,'</hisresults>');
close(f);
end;
//HisResults ends

//Table starts
procedure LoadTable(fname:string;var a:tTable);
var b:integer;
    t:integer;
    root0:pXMLelement;
    root:pXMLelement;
    problems:pXMLelement;
    problem:pXMLelement;
    i:integer;
    contestants:pXMLelement;
    contestant:pXMLelement;
    ii:integer;
    problem1:pXMLelement;
    j:integer;
    id:string;
    tmpi:integer;
    tmpj:integer;
begin
LogEnterProc('LoadTable',LOG_LEVEL_MINOR,''''+fname+'''');
try
try  
fillchar(a,sizeof(a),0);
for b:=1 to maxboys do
  for t:=1 to maxtasks do
    a.t[b,t].res:=_ns;
readXMlfile(fname,root0);
try
  root:=findXMLelementEC(root0,'results');
  problems:=findXMLelementCC(root,'problems');
    problem:=findXMLelementC(problems,'problem');
    i:=0;
    while problem<>nil do begin
      inc(i);
      a.task[i]:=XMLtoText(findXMLattrEC(problem,'id'));
      a.tasktype[i]:=StrToChar(findXMLattrEC(problem,'type'));

      problem:=findXMLelement(problem^.next,'problem');
    end;
    a.ntask:=i;
  contestants:=findXMLelementCC(root,'contestants');
    contestant:=findXMLelementC(contestants,'contestant');
    ii:=0;
    while contestant<>nil do begin
      inc(ii);
      a.boy[ii]:=XMLtoText(findXMLattrEC(contestant,'id'));
      a.loc[ii]:=OptStrToInt(findXMLattrEC(contestant,'_location',false),0);
      problem1:=findXMLelementC(contestant,'problem');
      tmpi:=0;
      while problem1<>nil do begin
        inc(tmpi);
        id:=XMLtoText(findXMLattrEC(problem1,'id'));
        tmpj:=0;
        for j:=1 to a.ntask do if a.task[j]=id then
          tmpj:=j;
        if tmpj=0 then
          raise eIJEerror.create('Can''t synchronize array','(xmlgen): ','Can''t find value %s (loop by j)',[id]);
        j:=tmpj;
        a.task[j]:=XMLtoText(findXMLattrEC(problem1,'id'));
        a.t[ii,j].pts:=StrToInt(findXMLattrEC(problem1,'points'));
        a.t[ii,j].minus:=StrToInt(findXMLattrEC(problem1,'minus'));
        a.t[ii,j].res:=XmlToResult(findXMLattrEC(problem1,'outcome'));

        problem1:=findXMLelement(problem1^.next,'problem');
      end;

      contestant:=findXMLelement(contestant^.next,'contestant');
    end;
    a.nboy:=ii;
finally
  XMldispose(root0);
end;
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'LoadTable('+fname+')','Error while loading tTable');
end;
finally
  LogLeaveProc('LoadTable',LOG_LEVEL_MINOR);
end;
end;

procedure SaveTable(fname:string;var a:tTable);
var f:text;
    buf:packed array[0..8191] of byte;
    i:integer;
    ii:integer;
    j:integer;
begin
assign(f,fname);rewrite(f);SetTextBuf(f,buf,sizeof(buf));
writeln(f,'<?xml version="1.0" encoding="Windows-1251"?>');
  write(f,'<results');
  writeln(f,'>');
    write(f,'  <problems');
    writeln(f,'>');
    for i:=1 to a.ntask do begin
      write(f,'    <problem');
      write(f,format(' id="%s"',[TextToXML(a.task[i])]));
      write(f,format(' type="%s"',[a.tasktype[i]]));
      writeln(f,'/>');
    end;
    writeln(f,'  </problems>');
    write(f,'  <contestants');
    writeln(f,'>');
    for ii:=1 to a.nboy do begin
      write(f,'    <contestant');
      write(f,format(' id="%s"',[TextToXML(a.boy[ii])]));
      write(f,format(' _location="%d"',[a.loc[ii]]));
      writeln(f,'>');
      for j:=1 to a.ntask do begin
        write(f,'      <problem');
        write(f,format(' id="%s"',[TextToXML(a.task[j])]));
        write(f,format(' points="%d"',[a.t[ii,j].pts]));
        write(f,format(' minus="%d"',[a.t[ii,j].minus]));
        write(f,format(' outcome="%s"',[Xmltext(a.t[ii,j].res)]));
        writeln(f,'/>');
      end;
      writeln(f,'    </contestant>');
    end;
    writeln(f,'  </contestants>');
  writeln(f,'</results>');
close(f);
end;
//Table ends

//Report starts
procedure LoadReport(fname:string;var a:tReport);
var root0:pXMLelement;
    root:pXMLelement;
    solution:pXMLelement;
    compiling:pXMLelement;
    testing:pXMLelement;
    results:pXMLelement;
    test:pXMLelement;
    i:integer;
begin
LogEnterProc('LoadReport',LOG_LEVEL_MINOR,''''+fname+'''');
try
try  
fillchar(a,sizeof(a),0);
readXMlfile(fname,root0);
try
  root:=findXMLelementEC(root0,'testing-report');
  a.pts:=StrToInt(findXMLattrEC(root,'points'));
  a.maxpts:=StrToInt(findXMLattrEC(root,'max'));
  a.res:=XmlToResult(findXMLattrEC(root,'outcome'));
  a.gtid:=StrToGTID(findXMLattrEC(root,'gtid'));
  solution:=findXMLelementCC(root,'solution');
    a.task:=XMLtoText(findXMLattrEC(solution,'problem'));
    a.taskname:=XMLtoText(findXMLattrEC(solution,'problem-name'));
    a.tasktype:=StrToChar(findXMLattrEC(solution,'problem-type'));
    a.boy:=XMLtoText(findXMLattrEC(solution,'contestant'));
    a.tl:=StringToTL(findXMLattrEC(solution,'time-limit'));
    a.ml:=StringToML(findXMLattrEC(solution,'memory-limit'));
  compiling:=findXMLelementCC(root,'compiling');
    a.comp.res:=XmlToResult(findXMLattrEC(compiling,'outcome'));
    a.comp.cmdline:=XMLtoText(findXMLattrEC(compiling,'command-line'));
    a.comp.text:=XMLtoText(findXMLattrEC(compiling,'compiler-output'));
  testing:=findXMLelementC(root,'testing');
    results:=findXMLelementC(testing,'results');
      test:=findXMLelementC(results,'test');
      i:=0;
      while test<>nil do begin
        inc(i);
        a.test[i].res:=XmlToResult(findXMLattrEC(test,'outcome'));
        a.test[i].pts:=StrToInt(findXMLattrEC(test,'points'));
        a.test[i].maxpts:=StrToInt(findXMLattrEC(test,'max-points'));
        a.test[i].text:=XMLtoText(findXMLattrEC(test,'comment'));
        a.test[i].evaltext:=XMLtoText(findXMLattrEC(test,'eval-comment'));
        a.test[i].time:=StrToFloat(findXMLattrEC(test,'time'));
        a.test[i].mem:=StrToInt(findXMLattrEC(test,'mem'));

        test:=findXMLelement(test^.next,'test');
      end;
      a.ntests:=i;
finally
  XMldispose(root0);
end;
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'LoadReport('+fname+')','Error while loading tReport');
end;
finally
  LogLeaveProc('LoadReport',LOG_LEVEL_MINOR);
end;
end;

procedure SaveReport(fname:string;var a:tReport);
var f:text;
    buf:packed array[0..8191] of byte;
    i:integer;
begin
assign(f,fname);rewrite(f);SetTextBuf(f,buf,sizeof(buf));
writeln(f,'<?xml version="1.0" encoding="Windows-1251"?>');
  write(f,'<testing-report');
  write(f,' version="2.0"');
  write(f,format(' points="%d"',[a.pts]));
  write(f,format(' max="%d"',[a.maxpts]));
  write(f,format(' outcome="%s"',[Xmltext(a.res)]));
  write(f,format(' gtid="%s"',[a.gtid]));
  writeln(f,'>');
    write(f,'  <solution');
    write(f,format(' problem="%s"',[TextToXML(a.task)]));
    write(f,format(' problem-name="%s"',[TextToXML(a.taskname)]));
    write(f,format(' problem-type="%s"',[a.tasktype]));
    write(f,format(' contestant="%s"',[TextToXML(a.boy)]));
    write(f,format(' time-limit="%d"',[a.tl]));
    write(f,format(' memory-limit="%d"',[a.ml]));
    writeln(f,'/>');
    write(f,'  <compiling');
    write(f,format(' outcome="%s"',[Xmltext(a.comp.res)]));
    write(f,format(' command-line="%s"',[TextToXML(a.comp.cmdline)]));
    write(f,format(' compiler-output="%s"',[TextToXML(a.comp.text)]));
    writeln(f,'/>');
    write(f,'  <testing');
    writeln(f,'>');
      write(f,'    <results');
      writeln(f,'>');
      for i:=1 to a.ntests do begin
        write(f,'      <test');
        write(f,format(' id="%d"',[i]));
        write(f,format(' outcome="%s"',[Xmltext(a.test[i].res)]));
        write(f,format(' points="%d"',[a.test[i].pts]));
        write(f,format(' max-points="%d"',[a.test[i].maxpts]));
        write(f,format(' comment="%s"',[TextToXML(a.test[i].text)]));
        write(f,format(' eval-comment="%s"',[TextToXML(a.test[i].evaltext)]));
        write(f,format(' time="%3.3f"',[a.test[i].time]));
        write(f,format(' mem="%d"',[a.test[i].mem]));
        writeln(f,'/>');
      end;
      writeln(f,'    </results>');
    writeln(f,'  </testing>');
  writeln(f,'</testing-report>');
close(f);
end;
//Report ends

//ShowtestTestResult starts
procedure LoadShowtestTestResult(fname:string;var a:tShowtestTestResult);
var root0:pXMLelement;
    root:pXMLelement;
begin
LogEnterProc('LoadShowtestTestResult',LOG_LEVEL_MINOR,''''+fname+'''');
try
try  
fillchar(a,sizeof(a),0);
readXMlfile(fname,root0);
try
  root:=findXMLelementEC(root0,'result');
  a.boy:=XMLtoText(findXMLattrEC(root,'contestant'));
  a.problem:=XMLtoText(findXMLattrEC(root,'problem'));
  a.pname:=XMLtoText(findXMLattrEC(root,'problem-name'));
  a.id:=StrToInt(findXMLattrEC(root,'test-id'));
  a.res:=XmlToResult(findXMLattrEC(root,'outcome'));
  a.pts:=StrToInt(findXMLattrEC(root,'points'));
  a.max:=StrToInt(findXMLattrEC(root,'max-points'));
finally
  XMldispose(root0);
end;
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'LoadShowtestTestResult('+fname+')','Error while loading tShowtestTestResult');
end;
finally
  LogLeaveProc('LoadShowtestTestResult',LOG_LEVEL_MINOR);
end;
end;

procedure SaveShowtestTestResult(fname:string;var a:tShowtestTestResult);
var f:text;
    buf:packed array[0..8191] of byte;
begin
assign(f,fname);rewrite(f);SetTextBuf(f,buf,sizeof(buf));
writeln(f,'<?xml version="1.0" encoding="Windows-1251"?>');
  write(f,'<result');
  write(f,format(' contestant="%s"',[TextToXML(a.boy)]));
  write(f,format(' problem="%s"',[TextToXML(a.problem)]));
  write(f,format(' problem-name="%s"',[TextToXML(a.pname)]));
  write(f,format(' test-id="%d"',[a.id]));
  write(f,format(' outcome="%s"',[Xmltext(a.res)]));
  write(f,format(' points="%d"',[a.pts]));
  write(f,format(' max-points="%d"',[a.max]));
  writeln(f,'/>');
close(f);
end;
//ShowtestTestResult ends

//SubmitStatus starts
procedure LoadSubmitStatus(fname:string;var a:tSubmitStatus);
var root0:pXMLelement;
    root:pXMLelement;
begin
LogEnterProc('LoadSubmitStatus',LOG_LEVEL_MINOR,''''+fname+'''');
try
try  
fillchar(a,sizeof(a),0);
readXMlfile(fname,root0);
try
  root:=findXMLelementEC(root0,'submit-status');
  a.status:=XMLtoText(findXMLattrEC(root,'status'));
  a.id:=StrToInt(findXMLattrEC(root,'id'));
  a.reason:=XMLtoText(findXMLattrEC(root,'reason'));
finally
  XMldispose(root0);
end;
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'LoadSubmitStatus('+fname+')','Error while loading tSubmitStatus');
end;
finally
  LogLeaveProc('LoadSubmitStatus',LOG_LEVEL_MINOR);
end;
end;

procedure SaveSubmitStatus(fname:string;var a:tSubmitStatus);
var f:text;
    buf:packed array[0..8191] of byte;
begin
assign(f,fname);rewrite(f);SetTextBuf(f,buf,sizeof(buf));
writeln(f,'<?xml version="1.0" encoding="Windows-1251"?>');
  write(f,'<submit-status');
  write(f,format(' status="%s"',[TextToXML(a.status)]));
  write(f,format(' id="%d"',[a.id]));
  write(f,format(' reason="%s"',[TextToXML(a.reason)]));
  writeln(f,'/>');
close(f);
end;
//SubmitStatus ends

//QACMsettings starts
procedure LoadQACMsettings(fname:string;var a:tQACMsettings);
var root0:pXMLelement;
    root:pXMLelement;
    acm_contest:pXMLelement;
    i:integer;
begin
LogEnterProc('LoadQACMsettings',LOG_LEVEL_MINOR,''''+fname+'''');
try
try  
fillchar(a,sizeof(a),0);
readXMlfile(fname,root0);
try
  root:=findXMLelementEC(root0,'acm-contests');
  a.repp:=ExpandFileName(findXMLattrEC(root,'reports-path'))+'\';
  a.dst:=StrToInt(findXMLattrEC(root,'dst'));
  acm_contest:=findXMLelementC(root,'acm-contest');
  i:=0;
  while acm_contest<>nil do begin
    inc(i);
    a.cont[i].qdll:=XMLtoText(findXMLattrEC(acm_contest,'qacm-dll'));
    a.cont[i].fname:=XMLtoText(findXMLattrEC(acm_contest,'settings'));

    acm_contest:=findXMLelement(acm_contest^.next,'acm-contest');
  end;
  a.ncont:=i;
finally
  XMldispose(root0);
end;
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'LoadQACMsettings('+fname+')','Error while loading tQACMsettings');
end;
finally
  LogLeaveProc('LoadQACMsettings',LOG_LEVEL_MINOR);
end;
end;

procedure SaveQACMsettings(fname:string;var a:tQACMsettings);
var f:text;
    buf:packed array[0..8191] of byte;
    i:integer;
begin
assign(f,fname);rewrite(f);SetTextBuf(f,buf,sizeof(buf));
writeln(f,'<?xml version="1.0" encoding="Windows-1251"?>');
  write(f,'<acm-contests');
  write(f,format(' reports-path="%s"',[a.repp]));
  write(f,format(' dst="%d"',[a.dst]));
  writeln(f,'>');
  for i:=1 to a.ncont do begin
    write(f,'  <acm-contest');
    write(f,format(' qacm-dll="%s"',[TextToXML(a.cont[i].qdll)]));
    write(f,format(' settings="%s"',[TextToXML(a.cont[i].fname)]));
    writeln(f,'/>');
  end;
  writeln(f,'</acm-contests>');
close(f);
end;
//QACMsettings ends

//ClassicACMsettings starts
procedure LoadClassicACMsettings(fname:string;var a:tClassicACMsettings);
var root0:pXMLelement;
    root:pXMLelement;
    problems:pXMLelement;
    problem:pXMLelement;
    i:integer;
    parties:pXMLelement;
    party:pXMLelement;
    j:integer;
begin
LogEnterProc('LoadClassicACMsettings',LOG_LEVEL_MINOR,''''+fname+'''');
try
try  
fillchar(a,sizeof(a),0);
readXMlfile(fname,root0);
try
  root:=findXMLelementEC(root0,'acm-contest');
  a.start:=StrToInt(findXMLattrEC(root,'start'));
  a.length:=StrToInt(findXMLattrEC(root,'length'));
  a.title:=XMLtoText(findXMLattrEC(root,'title'));
  a.penalty:=StrToInt(findXMLattrEC(root,'penalty'));
  a.showtest:=StrToBool(findXMLattrEC(root,'showtest'));
  a.showtest:=StrToBool(findXMLattrEC(root,'showcomment'));
  a.monitorFile:=XMLtoText(findXMLattrEC(root,'monitor'));
  a.submitsFile:=XMLtoText(findXMLattrEC(root,'submits'));
  problems:=findXMLelementCC(root,'problems');
    problem:=findXMLelementC(problems,'problem');
    i:=0;
    while problem<>nil do begin
      inc(i);
      a.task[i].id:=XMLtoText(findXMLattrEC(problem,'id'));
      a.task[i].name:=XMLtoText(findXMLattrEC(problem,'name'));

      problem:=findXMLelement(problem^.next,'problem');
    end;
    a.ntask:=i;
  parties:=findXMLelementCC(root,'parties');
    party:=findXMLelementC(parties,'party');
    j:=0;
    while party<>nil do begin
      inc(j);
      a.party[j].id:=XMLtoText(findXMLattrEC(party,'id'));
      a.party[j].name:=XMLtoText(findXMLattrEC(party,'name'));
      a.party[j].pwd:=XMLtoText(findXMLattrEC(party,'password'));

      party:=findXMLelement(party^.next,'party');
    end;
    a.nparty:=j;
finally
  XMldispose(root0);
end;
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'LoadClassicACMsettings('+fname+')','Error while loading tClassicACMsettings');
end;
finally
  LogLeaveProc('LoadClassicACMsettings',LOG_LEVEL_MINOR);
end;
end;

procedure SaveClassicACMsettings(fname:string;var a:tClassicACMsettings);
var f:text;
    buf:packed array[0..8191] of byte;
    i:integer;
    j:integer;
begin
assign(f,fname);rewrite(f);SetTextBuf(f,buf,sizeof(buf));
writeln(f,'<?xml version="1.0" encoding="Windows-1251"?>');
  write(f,'<acm-contest');
  write(f,format(' start="%d"',[a.start]));
  write(f,format(' length="%d"',[a.length]));
  write(f,format(' title="%s"',[TextToXML(a.title)]));
  write(f,format(' penalty="%d"',[a.penalty]));
  write(f,format(' showtest="%s"',[BoolToStr(a.showtest,true)]));
  write(f,format(' showcomment="%s"',[BoolToStr(a.showtest,true)]));
  write(f,format(' monitor="%s"',[TextToXML(a.monitorFile)]));
  write(f,format(' submits="%s"',[TextToXML(a.submitsFile)]));
  writeln(f,'>');
    write(f,'  <problems');
    writeln(f,'>');
    for i:=1 to a.ntask do begin
      write(f,'    <problem');
      write(f,format(' id="%s"',[TextToXML(a.task[i].id)]));
      write(f,format(' name="%s"',[TextToXML(a.task[i].name)]));
      writeln(f,'/>');
    end;
    writeln(f,'  </problems>');
    write(f,'  <parties');
    writeln(f,'>');
    for j:=1 to a.nparty do begin
      write(f,'    <party');
      write(f,format(' id="%s"',[TextToXML(a.party[j].id)]));
      write(f,format(' name="%s"',[TextToXML(a.party[j].name)]));
      write(f,format(' password="%s"',[TextToXML(a.party[j].pwd)]));
      writeln(f,'/>');
    end;
    writeln(f,'  </parties>');
  writeln(f,'</acm-contest>');
close(f);
end;
//ClassicACMsettings ends

//ClassicACMsubmits starts
procedure LoadClassicACMsubmits(fname:string;var a:tClassicACMsubmits);
var root0:pXMLelement;
    root:pXMLelement;
    submit:pXMLelement;
    i:integer;
begin
LogEnterProc('LoadClassicACMsubmits',LOG_LEVEL_MINOR,''''+fname+'''');
try
try  
fillchar(a,sizeof(a),0);
readXMlfile(fname,root0);
try
  root:=findXMLelementEC(root0,'submits');
  submit:=findXMLelementC(root,'submit');
  i:=0;
  while submit<>nil do begin
    inc(i);
    a.s[i].party:=XMLtoText(findXMLattrEC(submit,'party'));
    a.s[i].task:=XMLtoText(findXMLattrEC(submit,'problem'));
    a.s[i].lang:=XMLtoText(findXMLattrEC(submit,'language-id'));
    a.s[i].time:=StrToInt(findXMLattrEC(submit,'time'));
    a.s[i].id:=StrToInt(findXMLattrEC(submit,'id'));
    a.s[i].res:=XmlToResult(findXMLattrEC(submit,'outcome'));
    a.s[i].test:=StrToInt(findXMLattrEC(submit,'test'));
    a.s[i].comment:=XMLtoText(findXMLattrEC(submit,'comment'));

    submit:=findXMLelement(submit^.next,'submit');
  end;
  a.nsubmit:=i;
finally
  XMldispose(root0);
end;
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'LoadClassicACMsubmits('+fname+')','Error while loading tClassicACMsubmits');
end;
finally
  LogLeaveProc('LoadClassicACMsubmits',LOG_LEVEL_MINOR);
end;
end;

procedure SaveClassicACMsubmits(fname:string;var a:tClassicACMsubmits);
var f:text;
    i:integer;
begin
assign(f,fname);rewrite(f);
writeln(f,'<?xml version="1.0" encoding="Windows-1251"?>');
  write(f,'<submits');
  writeln(f,'>');
  for i:=1 to a.nsubmit do begin
    write(f,'  <submit');
    write(f,format(' party="%s"',[TextToXML(a.s[i].party)]));
    write(f,format(' problem="%s"',[TextToXML(a.s[i].task)]));
    write(f,format(' language-id="%s"',[TextToXML(a.s[i].lang)]));
    write(f,format(' time="%d"',[a.s[i].time]));
    write(f,format(' id="%d"',[a.s[i].id]));
    write(f,format(' outcome="%s"',[Xmltext(a.s[i].res)]));
    write(f,format(' test="%d"',[a.s[i].test]));
    write(f,format(' comment="%s"',[TextToXML(a.s[i].comment)]));
    writeln(f,'/>');
  end;
  writeln(f,'</submits>');
close(f);
end;
//ClassicACMsubmits ends

//ClassicACMmonitor starts
procedure LoadClassicACMmonitor(fname:string;var a:tClassicACMmonitor);
var root0:pXMLelement;
    root:pXMLelement;
    problems:pXMLelement;
    problem:pXMLelement;
    i:integer;
    parties:pXMLelement;
    party:pXMLelement;
    j:integer;
    problem1:pXMLelement;
    k:integer;
    id:string;
    tmpi:integer;
    tmpj:integer;
    submit:pXMLelement;
    l:integer;
begin
LogEnterProc('LoadClassicACMmonitor',LOG_LEVEL_MINOR,''''+fname+'''');
try
try  
fillchar(a,sizeof(a),0);
readXMlfile(fname,root0);
try
  root:=findXMLelementEC(root0,'standings');
  a.ije_ver:=XMLtoText(findXMLattrEC(root,'ije-version'));
  a.contest_time:=StrToInt(findXMLattrEC(root,'time'));
  a.status:=XMLtoText(findXMLattrEC(root,'status'));
  a.qcfg.start:=StrToInt(findXMLattrEC(root,'start'));
  a.qcfg.length:=StrToInt(findXMLattrEC(root,'length'));
  a.qcfg.title:=XMLtoText(findXMLattrEC(root,'title'));
  a.qcfg.penalty:=StrToInt(findXMLattrEC(root,'penalty'));
  a.qcfg.showtest:=StrToBool(findXMLattrEC(root,'showtest'));
  a.qcfg.showtest:=StrToBool(findXMLattrEC(root,'showcomment'));
  a.qcfg.monitorFile:=XMLtoText(findXMLattrEC(root,'monitor'));
  a.qcfg.submitsFile:=XMLtoText(findXMLattrEC(root,'submits'));
  a.submits.nsubmit:=StrToInt(findXMLattrEC(root,'nsubmits'));
  problems:=findXMLelementCC(root,'problems');
    problem:=findXMLelementC(problems,'problem');
    i:=0;
    while problem<>nil do begin
      inc(i);
      a.qcfg.task[i].id:=XMLtoText(findXMLattrEC(problem,'id'));
      a.qcfg.task[i].name:=XMLtoText(findXMLattrEC(problem,'name'));

      problem:=findXMLelement(problem^.next,'problem');
    end;
    a.qcfg.ntask:=i;
  parties:=findXMLelementCC(root,'parties');
    party:=findXMLelementC(parties,'party');
    j:=0;
    while party<>nil do begin
      inc(j);
      a.qcfg.party[j].id:=XMLtoText(findXMLattrEC(party,'id'));
      a.qcfg.party[j].name:=XMLtoText(findXMLattrEC(party,'name'));
      a.qcfg.party[j].pwd:=XMLtoText(findXMLattrEC(party,'password'));
      a.solved[j,0]:=StrToInt(findXMLattrEC(party,'solved'));
      a.time[j,0]:=StrToInt(findXMLattrEC(party,'time'));
      problem1:=findXMLelementC(party,'problem');
      tmpi:=0;
      while problem1<>nil do begin
        inc(tmpi);
        id:=XMLtoText(findXMLattrEC(problem1,'id'));
        tmpj:=0;
        for k:=1 to a.qcfg.ntask do if a.qcfg.task[k].id=id then
          tmpj:=k;
        if tmpj=0 then
          raise eIJEerror.create('Can''t synchronize array','(xmlgen): ','Can''t find value %s (loop by k)',[id]);
        k:=tmpj;
        a.qcfg.task[k].id:=XMLtoText(findXMLattrEC(problem1,'id'));
        a.solved[j,k]:=StrToInt(findXMLattrEC(problem1,'solved'));
        a.time[j,k]:=StrToInt(findXMLattrEC(problem1,'time'));
        submit:=findXMLelementC(problem1,'submit');
        l:=0;
        while submit<>nil do begin
          l:=StrToInt(findXMLattrEC(submit,'id',true));
          a.submits.s[l].id:=StrToInt(findXMLattrEC(submit,'id'));
          a.submits.s[l].party:=XMLtoText(findXMLattrEC(submit,'party'));
          a.submits.s[l].task:=XMLtoText(findXMLattrEC(submit,'problem'));
          a.submits.s[l].lang:=XMLtoText(findXMLattrEC(submit,'language-id'));
          a.submits.s[l].time:=StrToInt(findXMLattrEC(submit,'time'));
          a.submits.s[l].res:=XmlToResult(findXMLattrEC(submit,'outcome'));
          a.submits.s[l].test:=StrToInt(findXMLattrEC(submit,'test'));
          a.submits.s[l].comment:=XMLtoText(findXMLattrEC(submit,'comment'));

          submit:=findXMLelement(submit^.next,'submit');
        end;
        a.submits.nsubmit:=l;

        problem1:=findXMLelement(problem1^.next,'problem');
      end;

      party:=findXMLelement(party^.next,'party');
    end;
    a.qcfg.nparty:=j;
finally
  XMldispose(root0);
end;
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'LoadClassicACMmonitor('+fname+')','Error while loading tClassicACMmonitor');
end;
finally
  LogLeaveProc('LoadClassicACMmonitor',LOG_LEVEL_MINOR);
end;
end;

procedure SaveClassicACMmonitor(fname:string;var a:tClassicACMmonitor);
var f:text;
    buf:packed array[0..8191] of byte;
    i:integer;
    j:integer;
    k:integer;
    l:integer;
begin
assign(f,fname);rewrite(f);SetTextBuf(f,buf,sizeof(buf));
writeln(f,'<?xml version="1.0" encoding="Windows-1251"?>');
  write(f,'<standings');
  writeln(f);write(f,'');
  write(f,format('  ije-version="%s"',[TextToXML(a.ije_ver)]));
  writeln(f);write(f,'');
  write(f,format('  time="%d"',[a.contest_time]));
  writeln(f);write(f,'');
  write(f,format('  status="%s"',[TextToXML(a.status)]));
  writeln(f);write(f,'');
  write(f,format('  start="%d"',[a.qcfg.start]));
  writeln(f);write(f,'');
  write(f,format('  length="%d"',[a.qcfg.length]));
  writeln(f);write(f,'');
  write(f,format('  title="%s"',[TextToXML(a.qcfg.title)]));
  writeln(f);write(f,'');
  write(f,format('  penalty="%d"',[a.qcfg.penalty]));
  writeln(f);write(f,'');
  write(f,format('  showtest="%s"',[BoolToStr(a.qcfg.showtest,true)]));
  writeln(f);write(f,'');
  write(f,format('  showcomment="%s"',[BoolToStr(a.qcfg.showtest,true)]));
  writeln(f);write(f,'');
  write(f,format('  monitor="%s"',[TextToXML(a.qcfg.monitorFile)]));
  writeln(f);write(f,'');
  write(f,format('  submits="%s"',[TextToXML(a.qcfg.submitsFile)]));
  writeln(f);write(f,'');
  write(f,format('  nsubmits="%d"',[a.submits.nsubmit]));
  writeln(f);write(f,'');
  writeln(f,'>');
    write(f,'  <problems');
    writeln(f,'>');
    for i:=1 to a.qcfg.ntask do begin
      write(f,'    <problem');
      write(f,format(' id="%s"',[TextToXML(a.qcfg.task[i].id)]));
      write(f,format(' name="%s"',[TextToXML(a.qcfg.task[i].name)]));
      writeln(f,'/>');
    end;
    writeln(f,'  </problems>');
    write(f,'  <parties');
    writeln(f,'>');
    for j:=1 to a.qcfg.nparty do begin
      write(f,'    <party');
      write(f,format(' id="%s"',[TextToXML(a.qcfg.party[j].id)]));
      write(f,format(' name="%s"',[TextToXML(a.qcfg.party[j].name)]));
      write(f,format(' password="%s"',[TextToXML(a.qcfg.party[j].pwd)]));
      write(f,format(' solved="%d"',[a.solved[j,0]]));
      write(f,format(' time="%d"',[a.time[j,0]]));
      writeln(f,'>');
      for k:=1 to a.qcfg.ntask do begin
        write(f,'      <problem');
        write(f,format(' id="%s"',[TextToXML(a.qcfg.task[k].id)]));
        write(f,format(' solved="%d"',[a.solved[j,k]]));
        write(f,format(' time="%d"',[a.time[j,k]]));
        writeln(f,'>');
        for l:=1 to a.submits.nsubmit do 
        if ((a.submits.s[l].party=a.qcfg.party[j].id) and (a.submits.s[l].task=a.qcfg.task[k].id)) then begin
          write(f,'        <submit');
          write(f,format(' id="%d"',[a.submits.s[l].id]));
          write(f,format(' party="%s"',[TextToXML(a.submits.s[l].party)]));
          write(f,format(' problem="%s"',[TextToXML(a.submits.s[l].task)]));
          write(f,format(' language-id="%s"',[TextToXML(a.submits.s[l].lang)]));
          write(f,format(' time="%d"',[a.submits.s[l].time]));
          write(f,format(' outcome="%s"',[Xmltext(a.submits.s[l].res)]));
          write(f,format(' test="%d"',[a.submits.s[l].test]));
          write(f,format(' comment="%s"',[TextToXML(a.submits.s[l].comment)]));
          writeln(f,'/>');
        end;
        writeln(f,'      </problem>');
      end;
      writeln(f,'    </party>');
    end;
    writeln(f,'  </parties>');
  writeln(f,'</standings>');
close(f);
end;
//ClassicACMmonitor ends

//KirovACMsettings starts
procedure LoadKirovACMsettings(fname:string;var a:tKirovACMsettings);
var root0:pXMLelement;
    root:pXMLelement;
    problems:pXMLelement;
    problem:pXMLelement;
    i:integer;
    parties:pXMLelement;
    party:pXMLelement;
    j:integer;
begin
LogEnterProc('LoadKirovACMsettings',LOG_LEVEL_MINOR,''''+fname+'''');
try
try  
fillchar(a,sizeof(a),0);
readXMlfile(fname,root0);
try
  root:=findXMLelementEC(root0,'kirov-contest');
  a.start:=StrToInt(findXMLattrEC(root,'start'));
  a.length:=StrToInt(findXMLattrEC(root,'length'));
  a.title:=XMLtoText(findXMLattrEC(root,'title'));
  a.penalty:=StrToInt(findXMLattrEC(root,'penalty'));
  a.showtests:=StrToBool(findXMLattrEC(root,'showtests'));
  a.showcomments:=StrToBool(findXMLattrEC(root,'showcomments'));
  a.monitorFile:=XMLtoText(findXMLattrEC(root,'monitor'));
  a.submitsFile:=XMLtoText(findXMLattrEC(root,'submits'));
  problems:=findXMLelementCC(root,'problems');
    problem:=findXMLelementC(problems,'problem');
    i:=0;
    while problem<>nil do begin
      inc(i);
      a.task[i].id:=XMLtoText(findXMLattrEC(problem,'id'));
      a.task[i].name:=XMLtoText(findXMLattrEC(problem,'name'));

      problem:=findXMLelement(problem^.next,'problem');
    end;
    a.ntask:=i;
  parties:=findXMLelementCC(root,'parties');
    party:=findXMLelementC(parties,'party');
    j:=0;
    while party<>nil do begin
      inc(j);
      a.party[j].id:=XMLtoText(findXMLattrEC(party,'id'));
      a.party[j].name:=XMLtoText(findXMLattrEC(party,'name'));
      a.party[j].pwd:=XMLtoText(findXMLattrEC(party,'password'));

      party:=findXMLelement(party^.next,'party');
    end;
    a.nparty:=j;
finally
  XMldispose(root0);
end;
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'LoadKirovACMsettings('+fname+')','Error while loading tKirovACMsettings');
end;
finally
  LogLeaveProc('LoadKirovACMsettings',LOG_LEVEL_MINOR);
end;
end;

procedure SaveKirovACMsettings(fname:string;var a:tKirovACMsettings);
var f:text;
    buf:packed array[0..8191] of byte;
    i:integer;
    j:integer;
begin
assign(f,fname);rewrite(f);SetTextBuf(f,buf,sizeof(buf));
writeln(f,'<?xml version="1.0" encoding="Windows-1251"?>');
  write(f,'<kirov-contest');
  write(f,format(' start="%d"',[a.start]));
  write(f,format(' length="%d"',[a.length]));
  write(f,format(' title="%s"',[TextToXML(a.title)]));
  write(f,format(' penalty="%d"',[a.penalty]));
  write(f,format(' showtests="%s"',[BoolToStr(a.showtests,true)]));
  write(f,format(' showcomments="%s"',[BoolToStr(a.showcomments,true)]));
  write(f,format(' monitor="%s"',[TextToXML(a.monitorFile)]));
  write(f,format(' submits="%s"',[TextToXML(a.submitsFile)]));
  writeln(f,'>');
    write(f,'  <problems');
    writeln(f,'>');
    for i:=1 to a.ntask do begin
      write(f,'    <problem');
      write(f,format(' id="%s"',[TextToXML(a.task[i].id)]));
      write(f,format(' name="%s"',[TextToXML(a.task[i].name)]));
      writeln(f,'/>');
    end;
    writeln(f,'  </problems>');
    write(f,'  <parties');
    writeln(f,'>');
    for j:=1 to a.nparty do begin
      write(f,'    <party');
      write(f,format(' id="%s"',[TextToXML(a.party[j].id)]));
      write(f,format(' name="%s"',[TextToXML(a.party[j].name)]));
      write(f,format(' password="%s"',[TextToXML(a.party[j].pwd)]));
      writeln(f,'/>');
    end;
    writeln(f,'  </parties>');
  writeln(f,'</kirov-contest>');
close(f);
end;
//KirovACMsettings ends

//KirovACMsubmits starts
procedure LoadKirovACMsubmits(fname:string;var a:tKirovACMsubmits);
var root0:pXMLelement;
    root:pXMLelement;
    submit:pXMLelement;
    i:integer;
    test:pXMLelement;
    j:integer;
begin
LogEnterProc('LoadKirovACMsubmits',LOG_LEVEL_MINOR,''''+fname+'''');
try
try  
fillchar(a,sizeof(a),0);
readXMlfile(fname,root0);
try
  root:=findXMLelementEC(root0,'submits');
  submit:=findXMLelementC(root,'submit');
  i:=0;
  while submit<>nil do begin
    inc(i);
    a.s[i].party:=XMLtoText(findXMLattrEC(submit,'party'));
    a.s[i].task:=XMLtoText(findXMLattrEC(submit,'problem'));
    a.s[i].lang:=XMLtoText(findXMLattrEC(submit,'language-id'));
    a.s[i].time:=StrToInt(findXMLattrEC(submit,'time'));
    a.s[i].id:=StrToInt(findXMLattrEC(submit,'id'));
    a.s[i].pts:=StrToInt(findXMLattrEC(submit,'points'));
    a.s[i].maxpts:=StrToInt(findXMLattrEC(submit,'max-points'));
    test:=findXMLelementCC(submit,'test');
    j:=0;
    while test<>nil do begin
      inc(j);
      a.s[i].tr.test[j].res:=XmlToResult(findXMLattrEC(test,'outcome'));
      a.s[i].tr.test[j].text:=XMLtoText(findXMLattrEC(test,'comment'));
      a.s[i].tr.test[j].evaltext:=XMLtoText(findXMLattrEC(test,'eval-comment'));
      a.s[i].tr.test[j].pts:=StrToInt(findXMLattrEC(test,'points'));
      a.s[i].tr.test[j].max:=StrToInt(findXMLattrEC(test,'max-points'));

      test:=findXMLelement(test^.next,'test');
    end;
    a.s[i].tr.ntests:=j;

    submit:=findXMLelement(submit^.next,'submit');
  end;
  a.nsubmit:=i;
finally
  XMldispose(root0);
end;
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'LoadKirovACMsubmits('+fname+')','Error while loading tKirovACMsubmits');
end;
finally
  LogLeaveProc('LoadKirovACMsubmits',LOG_LEVEL_MINOR);
end;
end;

procedure SaveKirovACMsubmits(fname:string;var a:tKirovACMsubmits);
var f:text;
    buf:packed array[0..8191] of byte;
    i:integer;
    j:integer;
begin
assign(f,fname);rewrite(f);SetTextBuf(f,buf,sizeof(buf));
writeln(f,'<?xml version="1.0" encoding="Windows-1251"?>');
  write(f,'<submits');
  writeln(f,'>');
  for i:=1 to a.nsubmit do begin
    write(f,'  <submit');
    write(f,format(' party="%s"',[TextToXML(a.s[i].party)]));
    write(f,format(' problem="%s"',[TextToXML(a.s[i].task)]));
    write(f,format(' language-id="%s"',[TextToXML(a.s[i].lang)]));
    write(f,format(' time="%d"',[a.s[i].time]));
    write(f,format(' id="%d"',[a.s[i].id]));
    write(f,format(' points="%d"',[a.s[i].pts]));
    write(f,format(' max-points="%d"',[a.s[i].maxpts]));
    writeln(f,'>');
    for j:=1 to a.s[i].tr.ntests do begin
      write(f,'    <test');
      write(f,format(' outcome="%s"',[Xmltext(a.s[i].tr.test[j].res)]));
      write(f,format(' comment="%s"',[TextToXML(a.s[i].tr.test[j].text)]));
      write(f,format(' eval-comment="%s"',[TextToXML(a.s[i].tr.test[j].evaltext)]));
      write(f,format(' points="%d"',[a.s[i].tr.test[j].pts]));
      write(f,format(' max-points="%d"',[a.s[i].tr.test[j].max]));
      writeln(f,'/>');
    end;
    writeln(f,'  </submit>');
  end;
  writeln(f,'</submits>');
close(f);
end;
//KirovACMsubmits ends

//KirovACMmonitor starts
procedure LoadKirovACMmonitor(fname:string;var a:tKirovACMmonitor);
var root0:pXMLelement;
    root:pXMLelement;
    problems:pXMLelement;
    problem:pXMLelement;
    i:integer;
    parties:pXMLelement;
    party:pXMLelement;
    j:integer;
    problem1:pXMLelement;
    k:integer;
    id:string;
    tmpi:integer;
    tmpj:integer;
    submit:pXMLelement;
    l:integer;
    test:pXMLelement;
    m:integer;
begin
LogEnterProc('LoadKirovACMmonitor',LOG_LEVEL_MINOR,''''+fname+'''');
try
try  
fillchar(a,sizeof(a),0);
readXMlfile(fname,root0);
try
  root:=findXMLelementEC(root0,'standings');
  a.ije_ver:=XMLtoText(findXMLattrEC(root,'ije-version'));
  a.contest_time:=StrToInt(findXMLattrEC(root,'time'));
  a.status:=XMLtoText(findXMLattrEC(root,'status'));
  a.qcfg.start:=StrToInt(findXMLattrEC(root,'start'));
  a.qcfg.length:=StrToInt(findXMLattrEC(root,'length'));
  a.qcfg.title:=XMLtoText(findXMLattrEC(root,'title'));
  a.qcfg.penalty:=StrToInt(findXMLattrEC(root,'penalty'));
  a.qcfg.showtests:=StrToBool(findXMLattrEC(root,'showtests'));
  a.qcfg.showcomments:=StrToBool(findXMLattrEC(root,'showcomments'));
  a.qcfg.monitorFile:=XMLtoText(findXMLattrEC(root,'monitor'));
  a.qcfg.submitsFile:=XMLtoText(findXMLattrEC(root,'submits'));
  a.submits.nsubmit:=StrToInt(findXMLattrEC(root,'nsubmits'));
  problems:=findXMLelementCC(root,'problems');
    problem:=findXMLelementC(problems,'problem');
    i:=0;
    while problem<>nil do begin
      inc(i);
      a.qcfg.task[i].id:=XMLtoText(findXMLattrEC(problem,'id'));
      a.qcfg.task[i].name:=XMLtoText(findXMLattrEC(problem,'name'));

      problem:=findXMLelement(problem^.next,'problem');
    end;
    a.qcfg.ntask:=i;
  parties:=findXMLelementCC(root,'parties');
    party:=findXMLelementC(parties,'party');
    j:=0;
    while party<>nil do begin
      inc(j);
      a.qcfg.party[j].id:=XMLtoText(findXMLattrEC(party,'id'));
      a.qcfg.party[j].name:=XMLtoText(findXMLattrEC(party,'name'));
      a.qcfg.party[j].pwd:=XMLtoText(findXMLattrEC(party,'password'));
      a.pts[j,0]:=StrToInt(findXMLattrEC(party,'points'));
      problem1:=findXMLelementC(party,'problem');
      tmpi:=0;
      while problem1<>nil do begin
        inc(tmpi);
        id:=XMLtoText(findXMLattrEC(problem1,'id'));
        tmpj:=0;
        for k:=1 to a.qcfg.ntask do if a.qcfg.task[k].id=id then
          tmpj:=k;
        if tmpj=0 then
          raise eIJEerror.create('Can''t synchronize array','(xmlgen): ','Can''t find value %s (loop by k)',[id]);
        k:=tmpj;
        a.qcfg.task[k].id:=XMLtoText(findXMLattrEC(problem1,'id'));
        a.attempts[j,k]:=StrToInt(findXMLattrEC(problem1,'attempts'));
        a.pts[j,k]:=StrToInt(findXMLattrEC(problem1,'points'));
        a.max[j,k]:=StrToInt(findXMLattrEC(problem1,'max-points'));
        submit:=findXMLelementC(problem1,'submit');
        l:=0;
        while submit<>nil do begin
          l:=StrToInt(findXMLattrEC(submit,'id',true));
          a.submits.s[l].id:=StrToInt(findXMLattrEC(submit,'id'));
          a.submits.s[l].party:=XMLtoText(findXMLattrEC(submit,'party'));
          a.submits.s[l].task:=XMLtoText(findXMLattrEC(submit,'problem'));
          a.submits.s[l].lang:=XMLtoText(findXMLattrEC(submit,'language-id'));
          a.submits.s[l].time:=StrToInt(findXMLattrEC(submit,'time'));
          a.submits.s[l].pts:=StrToInt(findXMLattrEC(submit,'points'));
          a.submits.s[l].maxpts:=StrToInt(findXMLattrEC(submit,'max-points'));
          test:=findXMLelementCC(submit,'test');
          m:=0;
          while test<>nil do begin
            inc(m);
            a.submits.s[l].tr.test[m].res:=XmlToResult(findXMLattrEC(test,'outcome'));
            a.submits.s[l].tr.test[m].text:=XMLtoText(findXMLattrEC(test,'comment'));
            a.submits.s[l].tr.test[m].evaltext:=XMLtoText(findXMLattrEC(test,'eval-comment'));
            a.submits.s[l].tr.test[m].pts:=StrToInt(findXMLattrEC(test,'points'));
            a.submits.s[l].tr.test[m].max:=StrToInt(findXMLattrEC(test,'max-points'));

            test:=findXMLelement(test^.next,'test');
          end;
          a.submits.s[l].tr.ntests:=m;

          submit:=findXMLelement(submit^.next,'submit');
        end;
        a.submits.nsubmit:=l;

        problem1:=findXMLelement(problem1^.next,'problem');
      end;

      party:=findXMLelement(party^.next,'party');
    end;
    a.qcfg.nparty:=j;
finally
  XMldispose(root0);
end;
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'LoadKirovACMmonitor('+fname+')','Error while loading tKirovACMmonitor');
end;
finally
  LogLeaveProc('LoadKirovACMmonitor',LOG_LEVEL_MINOR);
end;
end;

procedure SaveKirovACMmonitor(fname:string;var a:tKirovACMmonitor);
var f:text;
    buf:packed array[0..8191] of byte;
    i:integer;
    j:integer;
    k:integer;
    l:integer;
    m:integer;
begin
assign(f,fname);rewrite(f);SetTextBuf(f,buf,sizeof(buf));
writeln(f,'<?xml version="1.0" encoding="Windows-1251"?>');
  write(f,'<standings');
  writeln(f);write(f,'');
  write(f,format('  ije-version="%s"',[TextToXML(a.ije_ver)]));
  writeln(f);write(f,'');
  write(f,format('  time="%d"',[a.contest_time]));
  writeln(f);write(f,'');
  write(f,format('  status="%s"',[TextToXML(a.status)]));
  writeln(f);write(f,'');
  write(f,format('  start="%d"',[a.qcfg.start]));
  writeln(f);write(f,'');
  write(f,format('  length="%d"',[a.qcfg.length]));
  writeln(f);write(f,'');
  write(f,format('  title="%s"',[TextToXML(a.qcfg.title)]));
  writeln(f);write(f,'');
  write(f,format('  penalty="%d"',[a.qcfg.penalty]));
  writeln(f);write(f,'');
  write(f,format('  showtests="%s"',[BoolToStr(a.qcfg.showtests,true)]));
  writeln(f);write(f,'');
  write(f,format('  showcomments="%s"',[BoolToStr(a.qcfg.showcomments,true)]));
  writeln(f);write(f,'');
  write(f,format('  monitor="%s"',[TextToXML(a.qcfg.monitorFile)]));
  writeln(f);write(f,'');
  write(f,format('  submits="%s"',[TextToXML(a.qcfg.submitsFile)]));
  writeln(f);write(f,'');
  write(f,format('  nsubmits="%d"',[a.submits.nsubmit]));
  writeln(f);write(f,'');
  writeln(f,'>');
    write(f,'  <problems');
    writeln(f,'>');
    for i:=1 to a.qcfg.ntask do begin
      write(f,'    <problem');
      write(f,format(' id="%s"',[TextToXML(a.qcfg.task[i].id)]));
      write(f,format(' name="%s"',[TextToXML(a.qcfg.task[i].name)]));
      writeln(f,'/>');
    end;
    writeln(f,'  </problems>');
    write(f,'  <parties');
    writeln(f,'>');
    for j:=1 to a.qcfg.nparty do begin
      write(f,'    <party');
      write(f,format(' id="%s"',[TextToXML(a.qcfg.party[j].id)]));
      write(f,format(' name="%s"',[TextToXML(a.qcfg.party[j].name)]));
      write(f,format(' password="%s"',[TextToXML(a.qcfg.party[j].pwd)]));
      write(f,format(' points="%d"',[a.pts[j,0]]));
      writeln(f,'>');
      for k:=1 to a.qcfg.ntask do begin
        write(f,'      <problem');
        write(f,format(' id="%s"',[TextToXML(a.qcfg.task[k].id)]));
        write(f,format(' attempts="%d"',[a.attempts[j,k]]));
        write(f,format(' points="%d"',[a.pts[j,k]]));
        write(f,format(' max-points="%d"',[a.max[j,k]]));
        writeln(f,'>');
        for l:=1 to a.submits.nsubmit do 
        if ((a.submits.s[l].party=a.qcfg.party[j].id) and (a.submits.s[l].task=a.qcfg.task[k].id)) then begin
          write(f,'        <submit');
          write(f,format(' id="%d"',[a.submits.s[l].id]));
          write(f,format(' party="%s"',[TextToXML(a.submits.s[l].party)]));
          write(f,format(' problem="%s"',[TextToXML(a.submits.s[l].task)]));
          write(f,format(' language-id="%s"',[TextToXML(a.submits.s[l].lang)]));
          write(f,format(' time="%d"',[a.submits.s[l].time]));
          write(f,format(' points="%d"',[a.submits.s[l].pts]));
          write(f,format(' max-points="%d"',[a.submits.s[l].maxpts]));
          writeln(f,'>');
          for m:=1 to a.submits.s[l].tr.ntests do begin
            write(f,'          <test');
            write(f,format(' outcome="%s"',[Xmltext(a.submits.s[l].tr.test[m].res)]));
            write(f,format(' comment="%s"',[TextToXML(a.submits.s[l].tr.test[m].text)]));
            write(f,format(' eval-comment="%s"',[TextToXML(a.submits.s[l].tr.test[m].evaltext)]));
            write(f,format(' points="%d"',[a.submits.s[l].tr.test[m].pts]));
            write(f,format(' max-points="%d"',[a.submits.s[l].tr.test[m].max]));
            write(f,format(' id="%d"',[m]));
            writeln(f,'/>');
          end;
          writeln(f,'        </submit>');
        end;
        writeln(f,'      </problem>');
      end;
      writeln(f,'    </party>');
    end;
    writeln(f,'  </parties>');
  writeln(f,'</standings>');
close(f);
end;
//KirovACMmonitor ends

//RWACMmonitor starts
procedure LoadRWACMmonitor(fname:string;var a:tRWACMmonitor);
var root0:pXMLelement;
    root:pXMLelement;
    problems:pXMLelement;
    problem:pXMLelement;
    i:integer;
    parties:pXMLelement;
    party:pXMLelement;
    j:integer;
    problem1:pXMLelement;
    k:integer;
    id:string;
    tmpi:integer;
    tmpj:integer;
    submit:pXMLelement;
    l:integer;
    test:pXMLelement;
    m:integer;
begin
LogEnterProc('LoadRWACMmonitor',LOG_LEVEL_MINOR,''''+fname+'''');
try
try  
fillchar(a,sizeof(a),0);
readXMlfile(fname,root0);
try
  root:=findXMLelementEC(root0,'standings');
  a.ije_ver:=XMLtoText(findXMLattrEC(root,'ije-version'));
  a.contest_time:=StrToInt(findXMLattrEC(root,'time'));
  a.status:=XMLtoText(findXMLattrEC(root,'status'));
  a.qcfg.start:=StrToInt(findXMLattrEC(root,'start'));
  a.qcfg.length:=StrToInt(findXMLattrEC(root,'length'));
  a.qcfg.title:=XMLtoText(findXMLattrEC(root,'title'));
  a.qcfg.showtests:=StrToBool(findXMLattrEC(root,'showtests'));
  a.qcfg.showcomments:=StrToBool(findXMLattrEC(root,'showcomments'));
  a.qcfg.coeff:=StrToFloat(findXMLattrEC(root,'penalty-coeff'));
  a.qcfg.monitorFile:=XMLtoText(findXMLattrEC(root,'monitor'));
  a.qcfg.submitsFile:=XMLtoText(findXMLattrEC(root,'submits'));
  a.submits.nsubmit:=StrToInt(findXMLattrEC(root,'nsubmits'));
  problems:=findXMLelementCC(root,'problems');
    problem:=findXMLelementC(problems,'problem');
    i:=0;
    while problem<>nil do begin
      inc(i);
      a.qcfg.task[i].id:=XMLtoText(findXMLattrEC(problem,'id'));
      a.qcfg.task[i].name:=XMLtoText(findXMLattrEC(problem,'name'));

      problem:=findXMLelement(problem^.next,'problem');
    end;
    a.qcfg.ntask:=i;
  parties:=findXMLelementCC(root,'parties');
    party:=findXMLelementC(parties,'party');
    j:=0;
    while party<>nil do begin
      inc(j);
      a.qcfg.party[j].id:=XMLtoText(findXMLattrEC(party,'id'));
      a.qcfg.party[j].name:=XMLtoText(findXMLattrEC(party,'name'));
      a.qcfg.party[j].pwd:=XMLtoText(findXMLattrEC(party,'password'));
      a.pts[j,0]:=StrToInt(findXMLattrEC(party,'points'));
      problem1:=findXMLelementC(party,'problem');
      tmpi:=0;
      while problem1<>nil do begin
        inc(tmpi);
        id:=XMLtoText(findXMLattrEC(problem1,'id'));
        tmpj:=0;
        for k:=1 to a.qcfg.ntask do if a.qcfg.task[k].id=id then
          tmpj:=k;
        if tmpj=0 then
          raise eIJEerror.create('Can''t synchronize array','(xmlgen): ','Can''t find value %s (loop by k)',[id]);
        k:=tmpj;
        a.qcfg.task[k].id:=XMLtoText(findXMLattrEC(problem1,'id'));
        a.attempts[j,k]:=StrToInt(findXMLattrEC(problem1,'attempts'));
        a.pts[j,k]:=StrToInt(findXMLattrEC(problem1,'points'));
        submit:=findXMLelementC(problem1,'submit');
        l:=0;
        while submit<>nil do begin
          l:=StrToInt(findXMLattrEC(submit,'id',true));
          a.submits.s[l].id:=StrToInt(findXMLattrEC(submit,'id'));
          a.submits.s[l].party:=XMLtoText(findXMLattrEC(submit,'party'));
          a.submits.s[l].task:=XMLtoText(findXMLattrEC(submit,'problem'));
          a.submits.s[l].lang:=XMLtoText(findXMLattrEC(submit,'language-id'));
          a.submits.s[l].time:=StrToInt(findXMLattrEC(submit,'time'));
          a.submits.s[l].pts:=StrToInt(findXMLattrEC(submit,'points'));
          test:=findXMLelementCC(submit,'test');
          m:=0;
          while test<>nil do begin
            inc(m);
            a.submits.s[l].tr.test[m].res:=XmlToResult(findXMLattrEC(test,'outcome'));
            a.submits.s[l].tr.test[m].text:=XMLtoText(findXMLattrEC(test,'comment'));
            a.submits.s[l].tr.test[m].evaltext:=XMLtoText(findXMLattrEC(test,'eval-comment'));
            a.submits.s[l].tr.test[m].pts:=StrToInt(findXMLattrEC(test,'points'));
            a.submits.s[l].tr.test[m].max:=StrToInt(findXMLattrEC(test,'max-points'));

            test:=findXMLelement(test^.next,'test');
          end;
          a.submits.s[l].tr.ntests:=m;

          submit:=findXMLelement(submit^.next,'submit');
        end;
        a.submits.nsubmit:=l;

        problem1:=findXMLelement(problem1^.next,'problem');
      end;

      party:=findXMLelement(party^.next,'party');
    end;
    a.qcfg.nparty:=j;
finally
  XMldispose(root0);
end;
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'LoadRWACMmonitor('+fname+')','Error while loading tRWACMmonitor');
end;
finally
  LogLeaveProc('LoadRWACMmonitor',LOG_LEVEL_MINOR);
end;
end;

procedure SaveRWACMmonitor(fname:string;var a:tRWACMmonitor);
var f:text;
    buf:packed array[0..8191] of byte;
    i:integer;
    j:integer;
    k:integer;
    l:integer;
    m:integer;
begin
assign(f,fname);rewrite(f);SetTextBuf(f,buf,sizeof(buf));
writeln(f,'<?xml version="1.0" encoding="Windows-1251"?>');
  write(f,'<standings');
  writeln(f);write(f,'');
  write(f,format('  ije-version="%s"',[TextToXML(a.ije_ver)]));
  writeln(f);write(f,'');
  write(f,format('  time="%d"',[a.contest_time]));
  writeln(f);write(f,'');
  write(f,format('  status="%s"',[TextToXML(a.status)]));
  writeln(f);write(f,'');
  write(f,format('  start="%d"',[a.qcfg.start]));
  writeln(f);write(f,'');
  write(f,format('  length="%d"',[a.qcfg.length]));
  writeln(f);write(f,'');
  write(f,format('  title="%s"',[TextToXML(a.qcfg.title)]));
  writeln(f);write(f,'');
  write(f,format('  showtests="%s"',[BoolToStr(a.qcfg.showtests,true)]));
  writeln(f);write(f,'');
  write(f,format('  showcomments="%s"',[BoolToStr(a.qcfg.showcomments,true)]));
  writeln(f);write(f,'');
  write(f,format('  penalty-coeff="%10.10f"',[a.qcfg.coeff]));
  writeln(f);write(f,'');
  write(f,format('  monitor="%s"',[TextToXML(a.qcfg.monitorFile)]));
  writeln(f);write(f,'');
  write(f,format('  submits="%s"',[TextToXML(a.qcfg.submitsFile)]));
  writeln(f);write(f,'');
  write(f,format('  nsubmits="%d"',[a.submits.nsubmit]));
  writeln(f);write(f,'');
  writeln(f,'>');
    write(f,'  <problems');
    writeln(f,'>');
    for i:=1 to a.qcfg.ntask do begin
      write(f,'    <problem');
      write(f,format(' id="%s"',[TextToXML(a.qcfg.task[i].id)]));
      write(f,format(' name="%s"',[TextToXML(a.qcfg.task[i].name)]));
      writeln(f,'/>');
    end;
    writeln(f,'  </problems>');
    write(f,'  <parties');
    writeln(f,'>');
    for j:=1 to a.qcfg.nparty do begin
      write(f,'    <party');
      write(f,format(' id="%s"',[TextToXML(a.qcfg.party[j].id)]));
      write(f,format(' name="%s"',[TextToXML(a.qcfg.party[j].name)]));
      write(f,format(' password="%s"',[TextToXML(a.qcfg.party[j].pwd)]));
      write(f,format(' points="%d"',[a.pts[j,0]]));
      writeln(f,'>');
      for k:=1 to a.qcfg.ntask do begin
        write(f,'      <problem');
        write(f,format(' id="%s"',[TextToXML(a.qcfg.task[k].id)]));
        write(f,format(' attempts="%d"',[a.attempts[j,k]]));
        write(f,format(' points="%d"',[a.pts[j,k]]));
        writeln(f,'>');
        for l:=1 to a.submits.nsubmit do 
        if ((a.submits.s[l].party=a.qcfg.party[j].id) and (a.submits.s[l].task=a.qcfg.task[k].id)) then begin
          write(f,'        <submit');
          write(f,format(' id="%d"',[a.submits.s[l].id]));
          write(f,format(' party="%s"',[TextToXML(a.submits.s[l].party)]));
          write(f,format(' problem="%s"',[TextToXML(a.submits.s[l].task)]));
          write(f,format(' language-id="%s"',[TextToXML(a.submits.s[l].lang)]));
          write(f,format(' time="%d"',[a.submits.s[l].time]));
          write(f,format(' points="%d"',[a.submits.s[l].pts]));
          writeln(f,'>');
          for m:=1 to a.submits.s[l].tr.ntests do begin
            write(f,'          <test');
            write(f,format(' outcome="%s"',[Xmltext(a.submits.s[l].tr.test[m].res)]));
            write(f,format(' comment="%s"',[TextToXML(a.submits.s[l].tr.test[m].text)]));
            write(f,format(' eval-comment="%s"',[TextToXML(a.submits.s[l].tr.test[m].evaltext)]));
            write(f,format(' points="%d"',[a.submits.s[l].tr.test[m].pts]));
            write(f,format(' max-points="%d"',[a.submits.s[l].tr.test[m].max]));
            write(f,format(' id="%d"',[m]));
            writeln(f,'/>');
          end;
          writeln(f,'        </submit>');
        end;
        writeln(f,'      </problem>');
      end;
      writeln(f,'    </party>');
    end;
    writeln(f,'  </parties>');
  writeln(f,'</standings>');
close(f);
end;
//RWACMmonitor ends

//RWACMsettings starts
procedure LoadRWACMsettings(fname:string;var a:tRWACMsettings);
var root0:pXMLelement;
    root:pXMLelement;
    problems:pXMLelement;
    problem:pXMLelement;
    i:integer;
    parties:pXMLelement;
    party:pXMLelement;
    j:integer;
begin
LogEnterProc('LoadRWACMsettings',LOG_LEVEL_MINOR,''''+fname+'''');
try
try  
fillchar(a,sizeof(a),0);
readXMlfile(fname,root0);
try
  root:=findXMLelementEC(root0,'rw-contest');
  a.start:=StrToInt(findXMLattrEC(root,'start'));
  a.length:=StrToInt(findXMLattrEC(root,'length'));
  a.title:=XMLtoText(findXMLattrEC(root,'title'));
  a.baseresults:=XMLtoText(findXMLattrEC(root,'base-results'));
  a.showtests:=StrToBool(findXMLattrEC(root,'showtests'));
  a.showcomments:=StrToBool(findXMLattrEC(root,'showcomments'));
  a.monitorFile:=XMLtoText(findXMLattrEC(root,'monitor'));
  a.submitsFile:=XMLtoText(findXMLattrEC(root,'submits'));
  a.coeff:=StrToFloat(findXMLattrEC(root,'penalty-coeff'));
  problems:=findXMLelementCC(root,'problems');
    problem:=findXMLelementC(problems,'problem');
    i:=0;
    while problem<>nil do begin
      inc(i);
      a.task[i].id:=XMLtoText(findXMLattrEC(problem,'id'));
      a.task[i].name:=XMLtoText(findXMLattrEC(problem,'name'));

      problem:=findXMLelement(problem^.next,'problem');
    end;
    a.ntask:=i;
  parties:=findXMLelementCC(root,'parties');
    party:=findXMLelementC(parties,'party');
    j:=0;
    while party<>nil do begin
      inc(j);
      a.party[j].id:=XMLtoText(findXMLattrEC(party,'id'));
      a.party[j].name:=XMLtoText(findXMLattrEC(party,'name'));
      a.party[j].pwd:=XMLtoText(findXMLattrEC(party,'password'));

      party:=findXMLelement(party^.next,'party');
    end;
    a.nparty:=j;
finally
  XMldispose(root0);
end;
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'LoadRWACMsettings('+fname+')','Error while loading tRWACMsettings');
end;
finally
  LogLeaveProc('LoadRWACMsettings',LOG_LEVEL_MINOR);
end;
end;

procedure SaveRWACMsettings(fname:string;var a:tRWACMsettings);
var f:text;
    buf:packed array[0..8191] of byte;
    i:integer;
    j:integer;
begin
assign(f,fname);rewrite(f);SetTextBuf(f,buf,sizeof(buf));
writeln(f,'<?xml version="1.0" encoding="Windows-1251"?>');
  write(f,'<rw-contest');
  write(f,format(' start="%d"',[a.start]));
  write(f,format(' length="%d"',[a.length]));
  write(f,format(' title="%s"',[TextToXML(a.title)]));
  write(f,format(' base-results="%s"',[TextToXML(a.baseresults)]));
  write(f,format(' showtests="%s"',[BoolToStr(a.showtests,true)]));
  write(f,format(' showcomments="%s"',[BoolToStr(a.showcomments,true)]));
  write(f,format(' monitor="%s"',[TextToXML(a.monitorFile)]));
  write(f,format(' submits="%s"',[TextToXML(a.submitsFile)]));
  write(f,format(' penalty-coeff="%10.10f"',[a.coeff]));
  writeln(f,'>');
    write(f,'  <problems');
    writeln(f,'>');
    for i:=1 to a.ntask do begin
      write(f,'    <problem');
      write(f,format(' id="%s"',[TextToXML(a.task[i].id)]));
      write(f,format(' name="%s"',[TextToXML(a.task[i].name)]));
      writeln(f,'/>');
    end;
    writeln(f,'  </problems>');
    write(f,'  <parties');
    writeln(f,'>');
    for j:=1 to a.nparty do begin
      write(f,'    <party');
      write(f,format(' id="%s"',[TextToXML(a.party[j].id)]));
      write(f,format(' name="%s"',[TextToXML(a.party[j].name)]));
      write(f,format(' password="%s"',[TextToXML(a.party[j].pwd)]));
      writeln(f,'/>');
    end;
    writeln(f,'  </parties>');
  writeln(f,'</rw-contest>');
close(f);
end;
//RWACMsettings ends

//RWACMsubmits starts
procedure LoadRWACMsubmits(fname:string;var a:tRWACMsubmits);
var root0:pXMLelement;
    root:pXMLelement;
    submit:pXMLelement;
    i:integer;
    test:pXMLelement;
    j:integer;
begin
LogEnterProc('LoadRWACMsubmits',LOG_LEVEL_MINOR,''''+fname+'''');
try
try  
fillchar(a,sizeof(a),0);
readXMlfile(fname,root0);
try
  root:=findXMLelementEC(root0,'submits');
  submit:=findXMLelementC(root,'submit');
  i:=0;
  while submit<>nil do begin
    inc(i);
    a.s[i].party:=XMLtoText(findXMLattrEC(submit,'party'));
    a.s[i].task:=XMLtoText(findXMLattrEC(submit,'problem'));
    a.s[i].lang:=XMLtoText(findXMLattrEC(submit,'language-id'));
    a.s[i].time:=StrToInt(findXMLattrEC(submit,'time'));
    a.s[i].id:=StrToInt(findXMLattrEC(submit,'id'));
    a.s[i].pts:=StrToInt(findXMLattrEC(submit,'points'));
    test:=findXMLelementCC(submit,'test');
    j:=0;
    while test<>nil do begin
      inc(j);
      a.s[i].tr.test[j].res:=XmlToResult(findXMLattrEC(test,'outcome'));
      a.s[i].tr.test[j].text:=XMLtoText(findXMLattrEC(test,'comment'));
      a.s[i].tr.test[j].evaltext:=XMLtoText(findXMLattrEC(test,'eval-comment'));
      a.s[i].tr.test[j].pts:=StrToInt(findXMLattrEC(test,'points'));
      a.s[i].tr.test[j].max:=StrToInt(findXMLattrEC(test,'max-points'));

      test:=findXMLelement(test^.next,'test');
    end;
    a.s[i].tr.ntests:=j;

    submit:=findXMLelement(submit^.next,'submit');
  end;
  a.nsubmit:=i;
finally
  XMldispose(root0);
end;
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'LoadRWACMsubmits('+fname+')','Error while loading tRWACMsubmits');
end;
finally
  LogLeaveProc('LoadRWACMsubmits',LOG_LEVEL_MINOR);
end;
end;

procedure SaveRWACMsubmits(fname:string;var a:tRWACMsubmits);
var f:text;
    buf:packed array[0..8191] of byte;
    i:integer;
    j:integer;
begin
assign(f,fname);rewrite(f);SetTextBuf(f,buf,sizeof(buf));
writeln(f,'<?xml version="1.0" encoding="Windows-1251"?>');
  write(f,'<submits');
  writeln(f,'>');
  for i:=1 to a.nsubmit do begin
    write(f,'  <submit');
    write(f,format(' party="%s"',[TextToXML(a.s[i].party)]));
    write(f,format(' problem="%s"',[TextToXML(a.s[i].task)]));
    write(f,format(' language-id="%s"',[TextToXML(a.s[i].lang)]));
    write(f,format(' time="%d"',[a.s[i].time]));
    write(f,format(' id="%d"',[a.s[i].id]));
    write(f,format(' points="%d"',[a.s[i].pts]));
    writeln(f,'>');
    for j:=1 to a.s[i].tr.ntests do begin
      write(f,'    <test');
      write(f,format(' outcome="%s"',[Xmltext(a.s[i].tr.test[j].res)]));
      write(f,format(' comment="%s"',[TextToXML(a.s[i].tr.test[j].text)]));
      write(f,format(' eval-comment="%s"',[TextToXML(a.s[i].tr.test[j].evaltext)]));
      write(f,format(' points="%d"',[a.s[i].tr.test[j].pts]));
      write(f,format(' max-points="%d"',[a.s[i].tr.test[j].max]));
      writeln(f,'/>');
    end;
    writeln(f,'  </submit>');
  end;
  writeln(f,'</submits>');
close(f);
end;
//RWACMsubmits ends

//RunLauncherSettings starts
procedure LoadRunLauncherSettings(fname:string;var a:tRunLauncherSettings);
var root0:pXMLelement;
    root:pXMLelement;
    user:pXMLelement;
    admin_user:pXMLelement;
begin
LogEnterProc('LoadRunLauncherSettings',LOG_LEVEL_MINOR,''''+fname+'''');
try
try  
fillchar(a,sizeof(a),0);
readXMlfile(fname,root0);
try
  root:=findXMLelementEC(root0,'launcher-configuration');
  a.useDefDesktop:=StrToBool(findXMLattrEC(root,'use-default-desktop'));
  user:=findXMLelementCC(root,'user');
    a.user[true].name:=XMLtoText(findXMLattrEC(user,'login'));
    a.user[true].pwd:=XMLtoText(findXMLattrEC(user,'password'));
  admin_user:=findXMLelementCC(root,'admin-user');
    a.user[false].name:=XMLtoText(findXMLattrEC(admin_user,'login'));
    a.user[false].pwd:=XMLtoText(findXMLattrEC(admin_user,'password'));
finally
  XMldispose(root0);
end;
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'LoadRunLauncherSettings('+fname+')','Error while loading tRunLauncherSettings');
end;
finally
  LogLeaveProc('LoadRunLauncherSettings',LOG_LEVEL_MINOR);
end;
end;

procedure SaveRunLauncherSettings(fname:string;var a:tRunLauncherSettings);
var f:text;
    buf:packed array[0..8191] of byte;
begin
assign(f,fname);rewrite(f);SetTextBuf(f,buf,sizeof(buf));
writeln(f,'<?xml version="1.0" encoding="Windows-1251"?>');
  write(f,'<launcher-configuration');
  write(f,format(' use-default-desktop="%s"',[BoolToStr(a.useDefDesktop,true)]));
  writeln(f,'>');
    write(f,'  <user');
    write(f,format(' login="%s"',[TextToXML(a.user[true].name)]));
    write(f,format(' password="%s"',[TextToXML(a.user[true].pwd)]));
    writeln(f,'/>');
    write(f,'  <admin-user');
    write(f,format(' login="%s"',[TextToXML(a.user[false].name)]));
    write(f,format(' password="%s"',[TextToXML(a.user[false].pwd)]));
    writeln(f,'/>');
  writeln(f,'</launcher-configuration>');
close(f);
end;
//RunLauncherSettings ends

begin
end.