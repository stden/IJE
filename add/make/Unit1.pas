{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O-,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ This file is part of IJE: the Integrated Judging Environment system }
{ (C) Kalinin Petr 2002-2008 }
{ $Id: Unit1.pas 202 2008-04-19 11:24:40Z *KAP* $ }
unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Spin, xmlije,crt32, AppEvnts;
const MaxTests=100;
type tEdPoints=class(TSpinEdit)
          procedure Change(Sender: TObject);
     end;
type
  TForm1 = class(TForm)
    Label1: TLabel;
    edId: TEdit;
    Label2: TLabel;
    edName: TEdit;
    GroupBox1: TGroupBox;
    Panel1: TPanel;
    Panel2: TPanel;
    Label3: TLabel;
    edInputName: TEdit;
    Label4: TLabel;
    edOutputName: TEdit;
    Label5: TLabel;
    edInputHref: TEdit;
    edAnswerHref: TEdit;
    Label6: TLabel;
    edTL: TEdit;
    Label7: TLabel;
    edML: TEdit;
    Label8: TLabel;
    Panel3: TPanel;
    Panel4: TPanel;
    gbTests: TGroupBox;
    Label9: TLabel;
    edNTests: TSpinEdit;
    Label10: TLabel;
    Label11: TLabel;
    edTotal: TStaticText;
    Panel5: TPanel;
    btSave: TButton;
    btLoad: TButton;
    OpenDialog1: TOpenDialog;
    Label12: TLabel;
    edScriptType: TEdit;
    SaveDialog1: TSaveDialog;
    ApplicationEvents1: TApplicationEvents;
    procedure edNTestsChange(Sender: TObject);
    procedure btSaveClick(Sender: TObject);
    procedure Panel4Resize(Sender: TObject);
    procedure Panel5Resize(Sender: TObject);
    procedure btLoadClick(Sender: TObject);
    procedure ApplicationEvents1ShortCut(var Msg: TWMKey;
      var Handled: Boolean);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    edPoints:array[1..MaxTests] of TEdPoints;
    lbPoints:array[1..MaxTests] of TLabel;
    NeedCheck:boolean;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

function CheckEd(a:TEdit):boolean;
begin
result:=true;
if a.text='' then begin
   a.SetFocus;
   beep;
   result:=false;
end;
end;

function Check:boolean;
begin
with form1 do begin
    result:=true;
    result:=result and CheckEd(edId);
    result:=result and CheckEd(edName);
    result:=result and CheckEd(edinputname);
    result:=result and CheckEd(edOutputname);
    result:=result and CheckEd(edinputhref);
    result:=result and CheckEd(edAnswerHref);
    result:=result and CheckEd(edTL);
    result:=result and CheckEd(edMl);
    result:=result and CheckEd(edscripttype);
    if (result)and(edTL.text='0ms') then begin
       edTL.setfocus;
       beep;
       result:=false;
    end;
end;
end;

procedure LoadFile(fname:string);
var p:tproblem;
    t:ptest;
    i:integer;
begin
with form1 do begin
   try
     LoadProblem(FName,p,'%ioi');
     edScripttype.text:='%ioi';
   except
      try
        LoadProblem(FName,p,'%outputs');
        edScripttype.text:='%outputs';
      except
        MessageBox(0,'Can''t load problem: see console for details','Load problem.xml',mb_ok+mb_iconerror);
        exit;
      end;
   end;
   edId.text:=p.id;
   edName.Text:=p.name;
   edInputName.Text:=p.input_name;
   edOutputName.Text:=p.output_name;
   edInputHref.Text:=p.input_href;
   edAnswerHref.Text:=p.answer_href;
   edTL.Text:=inttostr(p.time_limit)+'ms';
   edML.Text:=inttostr(p.memory_limit)+'b';
   edNTests.Text:=inttostr(p.ntests);
   t:=p.tests;
   for i:=1 to edNTests.value do begin
       if t=nil then
          edPoints[i].Text:=''
       else begin
            if t^.points[0]<>0 then
               edPoints[i].Text:=inttostr(t^.points[0]);
            t:=t^.next;
       end;
   end;
   if check then
      edNTests.SetFocus;
end;
end;

procedure TForm1.edNTestsChange(Sender: TObject);
var i:integer;
    c:integer;
begin
val(edNTests.Text,i,c);
if c=0 then begin
    for i:=1 to edNTests.Value do begin
        edPoints[i].Visible:=true;
        edPoints[i].Enabled:=true;
        lbPoints[i].Visible:=true;
        lbPoints[i].Enabled:=true;
    end;
    for i:=edNTests.Value+1 to maxtests do begin
        edPoints[i].Visible:=false;
        edPoints[i].Enabled:=false;
        lbPoints[i].Visible:=false;
        lbPoints[i].Enabled:=false;
    end;
    edPoints[1].Change(edPoints[1])
end;
end;

procedure tEdPoints.Change(Sender: TObject);
var i:integer;
    s:integer;
    c,cc:integer;
begin
s:=0;
with Form1 do begin
     for i:=1 to edNTests.Value do begin
         val(edPoints[i].text,cc,c);
         if c=0 then
            s:=s+edPoints[i].Value;
     end;
     edTotal.caption:=inttostr(s);
end;
end;

procedure TForm1.btSaveClick(Sender: TObject);
var f:textFile;
    i:integer;
begin
if not Check then
   exit;
if SaveDialog1.Execute then begin
    assignFile(f,SaveDialog1.FileName);rewrite(f);
    writeln(f,'<problem id="',edId.text,'">');
    writeln(f,'  <name value="',edName.text,'" />');
    writeln(f,'  <judging>');
    writeln(f,'    <script type="',edScriptType.text,'">');
    writeln(f,'      <verifier type="%testlib">');
    writeln(f,'        <binary executable-id="x86.exe.win32" href="test.exe" />');
    writeln(f,'      </verifier>');
    writeln(f,'      <testset');
    writeln(f,'         input-name="',edInputName.text,'"');
    writeln(f,'         output-name="',edOutputName.text,'"');
    writeln(f,'         input-href="',edInputHref.text,'"');
    writeln(f,'         answer-href="',edAnswerHref.text,'"');
    writeln(f,'         time-limit="',edTL.text,'"');
    writeln(f,'         memory-limit="',edML.text,'"');
    writeln(f,'      >');
    for i:=1 to edNTests.value do begin
        writeln(f,'        <test points="',edPoints[i].value,'" />');
    end;
    writeln(f,'      </testset>');
    writeln(f,'    </script>');
    writeln(f,'  </judging>');
    writeln(f,'</problem>');
    closeFile(f);
end;
end;

procedure TForm1.Panel4Resize(Sender: TObject);
begin
edTotal.Left:=Panel4.width-82;
label11.Left:=Panel4.Width-130;
end;

procedure TForm1.Panel5Resize(Sender: TObject);
begin
btSave.Left:=Panel5.Width-104;
btLoad.Left:=Panel5.Width-208;
end;

procedure TForm1.btLoadClick(Sender: TObject);
begin
if OpenDialog1.Execute then
   LoadFile(OpenDialog1.FileName);
end;

procedure TForm1.ApplicationEvents1ShortCut(var Msg: TWMKey;
  var Handled: Boolean);
begin
if msg.CharCode=vk_F3 then begin
   btLoad.Click;
   handled:=true;
end;
if msg.CharCode=vk_F2 then begin
   btSave.Click;
   handled:=true;
end;
if GetKeyState(vk_CONTROL)<0 then begin
    if msg.CharCode in [ord('O'),ord('L'),vk_F3] then begin
       btLoad.Click;
       handled:=true;
    end;
    if msg.CharCode in [ord('S'),vk_F2] then begin
       btSave.Click;
       handled:=true;
    end;
end;
end;

procedure TForm1.FormShow(Sender: TObject);
var fname:string;
begin
if not needcheck then
   exit;
NeedCheck:=false;
fname:=ExtractFileDir(paramstr(0))+'\problem.xml';
LoadFile(fname);
end;

procedure TForm1.FormCreate(Sender: TObject);
var i:integer;
begin
NeedCheck:=true;
AllocConsole;
InitConsole;
for i:=1 to maxtests do begin
    edPoints[i]:=TEdPoints.Create(Form1);
    edPoints[i].Parent:=gbTests;
    edPoints[i].Width:=43;
    edPoints[i].height:=22;
    edPoints[i].Left:=16+(43+5)*((i-1) mod 20);
    edPoints[i].top:=90+50*((i-1) div 20);
    edPoints[i].Visible:=false;
    edPoints[i].Enabled:=false;
    edPoints[i].OnChange:=edPoints[i].change;
    edPoints[i].text:='1';

    lbPoints[i]:=TLabel.Create(Form1);
    lbPoints[i].Parent:=gbTests;
    lbPoints[i].Width:=43;
    lbPoints[i].height:=13;
    lbPoints[i].Left:=26+(43+5)*((i-1) mod 20);
    lbPoints[i].top:=70+50*((i-1) div 20);
    lbPoints[i].Caption:=inttostr(i);
    lbPoints[i].Visible:=false;
    lbPoints[i].Enabled:=false;
end;
edNTestschange(edNTests);
OpenDialog1.InitialDir:=GetCurrentDir;
SaveDialog1.InitialDir:=GetCurrentDir;
end;

end.
