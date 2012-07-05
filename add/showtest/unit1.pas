{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O-,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ This file is part of IJE: the Integrated Judging Environment system }
{ (C) Kalinin Petr 2002-2008 }
{ $Id: unit1.pas 213 2010-02-03 15:55:37Z Petr $ }
unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ExtCtrls, ComCtrls, StdCtrls,
  ijeconsts, xmlije;
type
  TForm1 = class(TForm)
    Grid: TDrawGrid;
    Timer1: TTimer;
    Legend: TDrawGrid;
    PageControl1: TPageControl;
    TestSheet: TTabSheet;
    Bevel1: TBevel;
    Panel1: TPanel;
    LogoBox: TImage;
    TotalSheet: TTabSheet;
    TotalGrid: TDrawGrid;
    ShowTestingTimer: TTimer;
    ShowTotalTimer: TTimer;
    AutoSwitch: TCheckBox;
    fpstimer: TTimer;
    ClearTable: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure GridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure Timer1Timer(Sender: TObject);
    procedure LegendDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure ShowTotalTimerTimer(Sender: TObject);
    procedure TestSheetShow(Sender: TObject);
    procedure TotalSheetShow(Sender: TObject);
    procedure ShowTestingTimerTimer(Sender: TObject);
    procedure TotalGridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure AutoSwitchClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure PageControl1DrawTab(Control: TCustomTabControl;
      TabIndex: Integer; const Rect: TRect; Active: Boolean);
    procedure fpstimerTimer(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure LoadArchive;
    procedure DeleteArchive;
    procedure LoadResult;
    procedure AddResult;
    procedure ClearTableClick(Sender: TObject);
  private
         fname:string;
         tr:tShowtestTestResult;
  public
  end;
type tRetrieveThread=class(TThread)
       protected
         procedure Execute; override;
         procedure ShowMessage;
       private
         s:string;
     end;
const MaxBoy=10000;
      MaxTest=100;
      MaxTask=100;
      SqSize=32;
      NumSqSize=72;
      NotLegend=[_ol,_ns,_fl,_nt,_ml,_sv];
var   TotalInterval:integer=1000;
var   TestingInterval:integer=10000;
var   TotalFinInterval:integer=2000;
var   TotalFirstInterval:integer=2000;{!!!must be <>TotalInterval}
var   AddTestInterval:integer=50;
const
{$define black}
{$ifdef black}
      BkCol:array[0..1] of integer=(0,$301004);
      HeadBkCol=$604030;
      TextColor=$ffffff;
      logofile='logoinv.bmp';
{$else}
      BkCol:array[0..1] of integer=($ffffff,$ffeeee);
      HeadBkCol=clBtnFace;
      TextColor=0;
      logofile='logo.bmp';
{$endif}
type tboy=record id,name:string; end;
var
  Form1: TForm1;
  nboy:integer;
  nrboy:integer;
  trboy,rboy:array[1..maxboy] of tboy;
  rbn:array[1..maxboy] of record
     id,name:string;
  end;
  rbnn:integer;
  boy:array[1..MaxBoy] of record
     b,p,pp:string;
  end;
  ttask,task:array[0..MaxTask] of record
     p,pp:string;
  end;
  ntask:integer;
  ntest:integer;
  res:array[1..Maxboy,1..MaxTest] of tresult;
  Tpts,Tmax:array[1..maxboy,1..MaxTest] of integer;
  Ppts,Pmax:array[1..maxboy] of integer;
  tspts,tsmax,Spts,Smax:array[1..maxboy] of integer;
  ncol:integer;
  RetrieveThread:tRetrieveThread;
  pic:array[minres..maxres] of tbitmap;
  LegRes:array[0..4,0..4] of tresult;
  last:integer;
  lastn:integer;
  fps:extended=-1;
  first:boolean=true;
  firloading:boolean=true;
  ScreenSaverWasActive:boolean;

implementation

uses Unit2, Unit3;

{$R *.dfm}

procedure SortTasks(l,r:integer);
var i,i1,i2,o:integer;
begin
if l>=r then
   exit;
if l=r-1 then begin
   if task[l].p>task[r].p then begin
      task[0]:=task[l];task[l]:=task[r];task[r]:=task[0];
   end;
   exit;
end;
o:=(l+r) shr 1;
sorttasks(l,o);sorttasks(o+1,r);
i1:=l;i2:=o+1;
for i:=l to r do begin
    if (i2>r)or((i1<=o)and(task[i1].p<task[i2].p)) then begin
       ttask[i]:=task[i1];
       inc(i1);
    end else begin
        ttask[i]:=task[i2];
        inc(i2);
    end;
end;
for i:=l to r do
    task[i]:=ttask[i];
end;

function less(l,r:integer):boolean;
begin
less:=true;
if SPts[l]<SPts[r] then
   exit;
if SPts[l]=SPts[r] then begin
   if rboy[l].name>rboy[r].name then
      exit;
   if rboy[l].name=rboy[r].name then
      if rboy[l].id>rboy[r].id then
         exit;
end;
less:=false;
end;

procedure SortRBoys(l,r:integer);
var i,i1,i2,o:integer;
    t:tboy;
    tt:integer;
begin
if l>=r then exit;
if l=r-1 then begin
   if less(l,r) then begin
      t:=rboy[l];rboy[l]:=rboy[r];rboy[r]:=t;
      tt:=smax[l];smax[l]:=smax[r];smax[r]:=tt;
      tt:=spts[l];spts[l]:=spts[r];spts[r]:=tt;
   end;
   exit;
end;
o:=(l+r) div 2;
sortRBoys(l,o);sortRBoys(o+1,r);
i1:=l;i2:=o+1;
for i:=l to r do
    if (i2>r)or((i1<=o)and(less(i2,i1))) then begin
       trboy[i]:=rboy[i1];
       tspts[i]:=spts[i1];
       tsmax[i]:=smax[i1];
       inc(i1);
    end else begin
        trboy[i]:=rboy[i2];
        tspts[i]:=spts[i2];
        tsmax[i]:=smax[i2];
        inc(i2);
    end;
for i:=l to r do begin
    rboy[i]:=trboy[i];
    smax[i]:=tsmax[i];
    spts[i]:=tspts[i];
end;
end;

procedure TForm1.LoadResult;
begin
LoadShowtestTestResult(fname,tr);
if tr.res>_pcbase then
   tr.res:=_pc;
AddResult;
end;

procedure TRetrieveThread.ShowMessage;
begin
//Application.MessageBox(PChar(s),'Jury message',MB_OK+MB_ICONINFORMATION);
Form3.Label1.caption:=s;
Form3.ShowModal;
end;

function findboy(b,p,pp:string;autoadd:boolean=true):integer;
begin
boy[nboy+1].b:=b;
boy[nboy+1].p:=p;
boy[nboy+1].pp:=pp;
result:=1;
while (boy[result].b<>b)or(boy[result].p<>p)or(boy[result].pp<>pp) do
      inc(result);
if result>nboy then begin
   if autoadd then
      inc(nboy)
   else
     result:=-1;
end else begin
     boy[nboy+1].b:='';
     boy[nboy+1].p:='';
     boy[nboy+1].pp:='';
end;
end;

function findrboy(s:string):integer;
var i:integer;
begin
rboy[nrboy+1].id:=s;
rboy[nrboy+1].name:='';
for i:=1 to rbnn do
    if rbn[i].id=s then
       rboy[nrboy+1].name:=rbn[i].name;
result:=1;
while rboy[result].id<>s do
      inc(result);
if result>nrboy then
   inc(nrboy)
else begin
     rboy[nrboy+1].id:='';
     rboy[nrboy+1].name:='';
end;
end;

function findtask(p,pp:string):integer;
begin
task[ntask+1].p:=p;
task[ntask+1].pp:=pp;
result:=1;
while (task[result].p<>p)or(task[result].pp<>pp) do
      inc(result);
if result>ntask then
   inc(ntask)
else begin
     task[ntask+1].p:='';
     task[ntask+1].pp:='';
end;
end;

procedure ReCountCols;
var i:integer;
begin
ncol:=ntest+1;
with form1.grid do begin
     ColCount:=ncol+2;
     RowCount:=nboy+1;
     for i:=1 to ntest do
         ColWidths[i]:=SqSize;
     ColWidths[ntest+1]:=NumSqSize;
     ColWidths[ntest+2]:=NumSqSize;
     ColWidths[0]:=ClientWidth-ntest*SqSize-2*NumSqSize-1;
     if ColWidths[0]<=50 then
        ColWidths[0]:=50;
end;
with form1.TotalGrid do begin
     ColCount:=ntask+2;
     RowCount:=nrboy+1;
     for i:=1 to ntask do
         colwidths[i]:=NumSqSize;
     colwidths[ntask+1]:=NumSqSize;
     ColWidths[0]:=ClientWidth-NumSqSize*(ntask+1);
     if ColWidths[0]<=50 then
        ColWidths[0]:=50;
end;
end;

procedure TForm1.ShowTestingTimerTimer(Sender: TObject);
begin
ShowTestingTimer.Enabled:=false;
if AutoSwitch.Checked then
   TotalSheet.show;
end;

procedure TForm1.TotalSheetShow(Sender: TObject);
begin
TotalGrid.TopRow:=0;
ShowTotalTimer.Interval:=TotalFirstInterval;
ShowTotalTimer.Enabled:=true;
end;

procedure TForm1.TestSheetShow(Sender: TObject);
begin
ShowTestingTimer.Interval:=TestingInterval;
ShowTestingTimer.Enabled:=true;
end;

procedure tForm1.AddResult;
var bn,rbn:integer;
    tt:integer;
begin
inc(lastn);
bn:=findboy(tr.boy,tr.problem,tr.pname);
rbn:=findrboy(tr.boy);
findtask(tr.problem,tr.pname);
if tr.id>ntest then begin
   ntest:=tr.id;
end;
res[bn,tr.id]:=tr.res;
if res[bn,tr.id]in [_ce,_cp] then begin
   for tt:=2 to ntest do
       res[bn,tt]:=_nt;
   Spts[rbn]:=SPts[rbn]-PPts[bn];
   PPts[bn]:=0;
   fillchar(TPts[bn],sizeof(TPts[bn]),0);

   Smax[rbn]:=Smax[rbn]-PMax[bn];
   PMax[bn]:=0;
   fillchar(Tmax[bn],sizeof(TMax[bn]),0);
end;

PPts[bn]:=PPts[bn]-Tpts[bn,tr.id];
SPts[rbn]:=SPts[rbn]-Tpts[bn,tr.id];

Tpts[bn,tr.id]:=tr.pts;
PPts[bn]:=PPts[bn]+Tpts[bn,tr.id];
SPts[rbn]:=SPts[rbn]+Tpts[bn,tr.id];

PMax[bn]:=PMax[bn]-TMax[bn,tr.id];
SMax[rbn]:=SMax[rbn]-TMax[bn,tr.id];

TMax[bn,tr.id]:=tr.max;
PMax[bn]:=PMax[bn]+TMax[bn,tr.id];
SMax[rbn]:=SMax[rbn]+TMax[bn,tr.id];

last:=bn;

if firloading then exit;

ReCountCols;
with Form1.Grid do begin
     if (bn<topRow)or(TopRow+VisibleRowCount<=bn) then begin
        if bn-VisibleRowCount+1>=0 then
           TopRow:=bn-VisibleRowCount+1
        else TopRow:=0;
     end;
     Invalidate;
end;
Form1.TotalGrid.Invalidate;
end;

procedure TRetrieveThread.Execute;
var f:text;
    rec:tSearchRec;
    tt:int64;
    mint:int64;
    minf:string;
begin
mint:=-1;
if (Form1.TestSheet.Visible)and(FindFirst('results\*.test',faAnyFile-faDirectory,rec)=0) then begin
   repeat
     tt:=int64(rec.FindData.ftCreationTime);
     if (mint=-1)or(tt<mint) then begin
        mint:=tt;
        minf:=rec.name;
     end;
   until FindNext(rec)<>0;
   FindClose(rec);
end;
if mint>=0 then begin
   sleep(50);
   Form1.fname:='results\'+minf;
   Synchronize(Form1.LoadResult);
   if fileexists('archive\'+minf) then
      DeleteFile('archive\'+minf);
   RenameFile('results\'+minf,'archive\'+minf);
end;
if FindFirst('results\*.m',faAnyFile-faDirectory,rec)=0 then begin
   repeat
     assign(f,'results\'+rec.name);reset(f);
     readln(f,s);
     close(f);
     if not RenameFile('results\'+rec.name,'old_results\'+rec.name) then
        Erase(f);
     Synchronize(ShowMessage);
   until FindNext(rec)<>0;
   FindClose(rec);
end;
form1.Timer1.enabled:=true;
end;

procedure TForm1.FormCreate(Sender: TObject);
var r:tresult;
    i,j:integer;
    f:textFile;
begin
AllocConsole;
fillchar(boy,sizeof(boy),0);
nboy:=0;
ncol:=0;
nrboy:=0;
ntest:=0;
fillchar(PMax,sizeof(PMax),0);
fillchar(PPts,sizeof(PPts),0);
fillchar(rboy,sizeof(rboy),0);
fillchar(res,sizeof(res),_nt);
fillchar(SMax,sizeof(SMax),0);
fillchar(SPts,sizeof(SPts),0);
fillchar(TMax,sizeof(TMax),0);
fillchar(TPts,sizeof(TPts),0);
grid.DefaultRowHeight:=SqSize;
TotalGrid.DefaultRowHeight:=SqSize;
Legend.DefaultRowHeight:=SqSize;
Legend.DefaultColWidth:=Legend.Width div Legend.ColCount;
Legend.Height:=SqSize*Legend.RowCount;
fillchar(LegRes,sizeof(LegRes),255);
i:=0;j:=0;
for r:=minres to maxres do
    if not (r in NotLegend) then begin
       LegRes[i,j]:=r;
       inc(i);
       if i>=Legend.RowCount then begin
          i:=0;
          inc(j);
       end;
    end;
ReCountCols;
for r:=minres to maxres do begin
    pic[r]:=TBitmap.Create;
    with pic[r] do
         if fileexists('img\'+stext(r)+'.bmp') then
            LoadFromFile('img\'+stext(r)+'.bmp')
         else begin
             Width:=SqSize-1;
             Height:=SqSize-1;
             canvas.Font:=grid.font;
             canvas.Font.color:=$ffffff;
             Canvas.textout((1+width-canvas.textwidth(stext(r))) shr 1,2,stext(r));
         end;
    pic[r].Transparent:=true;
end;

assignFile(f,'boys.txt');reset(f);
while not seekeof(f) do begin
      inc(rbnn);
      readln(f,rbn[rbnn].id);
      readln(f,rbn[rbnn].name);
end;
closefile(f);

LogoBox.Picture.Graphic:=TBitmap.Create;
LogoBox.Picture.Bitmap.LoadFromFile(logofile);
Form1.Color:=HeadBkCol;
Grid.Color:=BkCol[0];
Legend.Color:=BkCol[0];
TotalGrid.Color:=BkCol[0];
grid.Font.color:=TextColor;
Panel1.color:=HeadBkCol;
AutoSwitch.Font.Color:=TextColor;
FormResize(sender);
LogoBox.Invalidate;
SystemParametersInfo(SPI_GETSCREENSAVEACTIVE,0,@ScreenSaverWasActive,0);
SystemParametersInfo(SPI_SETSCREENSAVEACTIVE,ord(false),nil,0);
end;
  
procedure TForm1.GridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var l,r:integer;
    s:string;
begin
ReCountCols;
with grid.canvas do begin
     font:=grid.Font;
     brush.Color:=BkCol[ARow mod 2];
     fillrect(classes.rect(rect.left,rect.top,rect.Right,rect.Bottom));
     if ARow>nboy then
        exit;
     if ACol>ncol+1 then
        exit;
     if ARow=0 then begin
        font.size:=14;
        brush.Color:=HeadBkCol;
        fillrect(rect);
        pen.color:=$808080;
        moveto(rect.Left,rect.Bottom-1);
        lineto(rect.Right-1,rect.Bottom-1);
        lineto(rect.Right-1,rect.Top);
        pixels[rect.Right-1,rect.Top]:=pen.color;
        if ACol=0 then begin
           moveto(rect.Right-2,rect.top);
           lineto(rect.Right-2,rect.Bottom);
           TextOut(5,2,'Участник');
        end;
        if (ACol>0)and(ACol<=ntest) then begin
           s:=inttostr(ACol);
           l:=rect.Left;
           r:=rect.Right;
           TextOut((l+r-TextWidth(s)) shr 1,rect.top+2,s);
        end;
        if ACol=ntest+1 then begin
           s:='=';
           l:=rect.Left;
           r:=rect.Right;
           TextOut((l+r-TextWidth(s)) shr 1,rect.top+2,s);
        end;
        if ACol=ntest+2 then begin
           moveto(rect.Left,rect.top);
           lineto(rect.Left,rect.Bottom);
           l:=rect.Left;
           r:=rect.Right;
           TextOut((l+r-TextWidth('=')) shr 1,2,'=');
        end;
        exit;
     end;
     if (ARow>0)and(ARow<=nboy) then begin
        brush.Color:=BkCol[ARow mod 2];
        fillrect(rect);
        pen.color:=$808080;
        moveto(rect.Left,rect.Bottom-1);
        lineto(rect.Right-1,rect.Bottom-1);
        lineto(rect.Right-1,rect.Top);
        pixels[rect.Right-1,rect.Top]:=pen.color;
        if ACol=0 then begin
           font.size:=14;
           moveto(rect.Right-2,rect.top);
           lineto(rect.Right-2,rect.Bottom);
           l:=rect.Left;
           if ARow=last then
              s:='*'
           else s:='';
           s:=s+boy[ARow].p+': '+boy[ARow].b+': '+rboy[findrboy(boy[ARow].b)].name;
           TextOut(l+5,rect.Top+2,s);
        end;
        if (ACol>0)and(ACol<=ntest) then
//           CopyRect(rect,pic[res[arow,ACol]].Canvas,classes.Rect(0,0,SqSize,SqSize));
           Draw(rect.left,rect.Top,pic[res[ARow,ACol]]);
        if ACol=ntest+1 then begin
           font.size:=14;
           l:=rect.Left;
           r:=rect.Right;
           s:=inttostr(PPts[ARow]);
           TextOut((l+r-TextWidth(s)) shr 1,rect.Top+2,s);
        end;
        if ACol=ntest+2 then begin
           font.size:=14;
           moveto(rect.Left,rect.top);
           lineto(rect.Left,rect.Bottom);
           l:=rect.Left;
           r:=rect.Right;
           s:=inttostr(SPts[findrboy(boy[ARow].b)]);
           TextOut((l+r-TextWidth(s)) shr 1,rect.Top+2,s);
        end;
        exit;
     end;
end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
Timer1.Enabled:=false;
RetrieveThread:=TRetrieveThread.Create(false);
end;

procedure TForm1.LegendDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var r:tresult;
begin
r:=LegRes[Arow,ACol];
with Legend.Canvas do begin
     brush.color:=BkCol[0];
     fillrect(rect);
     font:=grid.Font;
     font.Size:=10;
     if (ARow=Legend.RowCount-1)and(ACol=Legend.ColCount-1) then begin
        font.color:=$808080;
        TextOut(rect.left+2,rect.top+5,Format('%2.2f tps',[fps]));
     end;
     if r=255 then
        exit;
     Draw(rect.Left,rect.top,pic[r]);
     TextOut(rect.left+SqSize+5,rect.top+13,RusText(r));
end;
end;

procedure TForm1.ShowTotalTimerTimer(Sender: TObject);
begin
if not AutoSwitch.Checked then begin
   ShowTotalTimer.Enabled:=false;
   exit;
end;
if TotalGrid.TopRow>=TotalGrid.RowCount-TotalGrid.VisibleRowCount then begin
   if ShowTotalTimer.Interval<>TotalFininterval then begin
      ShowTotalTimer.Enabled:=true;
      ShowTotalTimer.Interval:=TotalFinInterval;
   end else begin
       ShowTotalTimer.Enabled:=false;
       TestSheet.show;
   end;
end else begin
     TotalGrid.TopRow:=TotalGrid.TopRow+1;
     ShowTotalTimer.Enabled:=true;
     ShowTotalTimer.interval:=TotalInterval;
end;
end;

procedure TForm1.TotalGridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var l,r:integer;
    s:string;
    b:integer;
    pl:integer;
begin
SortTasks(1,ntask);
SortRBoys(1,nrboy);
ReCountCols;
with TotalGrid.Canvas do begin
     font:=grid.Font;
     brush.Color:=BkCol[ARow mod 2];
     fillrect(classes.rect(rect.left,rect.top,rect.Right,rect.Bottom));
     if ARow>nrboy then
        exit;
     if ACol>ntask+1 then
        exit;
     if ARow=0 then begin
        font.size:=14;
        brush.Color:=HeadBkCol;
        fillrect(rect);
        pen.color:=$808080;
        moveto(rect.Left,rect.Bottom-1);
        lineto(rect.Right-1,rect.Bottom-1);
        lineto(rect.Right-1,rect.Top);
        pixels[rect.Right-1,rect.Top]:=pen.color;
        if ACol=0 then begin
           moveto(rect.Right-2,rect.top);
           lineto(rect.Right-2,rect.Bottom);
           TextOut(5,2,'Участник');
        end;
        if (ACol>0)and(ACol<=ntask) then begin
           s:=task[ACol].p;
           l:=rect.Left;
           r:=rect.Right;
           TextOut((l+r-TextWidth(s)) shr 1,rect.top+2,s);
        end;
        if ACol=ntask+1 then begin
           moveto(rect.Left,rect.top);
           lineto(rect.Left,rect.Bottom);
           s:='=';
           l:=rect.Left;
           r:=rect.Right;
           TextOut((l+r-TextWidth(s)) shr 1,rect.top+2,s);
        end;
        exit;
     end;
     if (ARow>0)and(ARow<=nrboy) then begin
        brush.Color:=BkCol[ARow mod 2];
        fillrect(rect);
        pen.color:=$808080;
        moveto(rect.Left,rect.Bottom-1);
        lineto(rect.Right-1,rect.Bottom-1);
        lineto(rect.Right-1,rect.Top);
        pixels[rect.Right-1,rect.Top]:=pen.color;
        if ACol=0 then begin
           font.size:=14;
           moveto(rect.Right-2,rect.top);
           lineto(rect.Right-2,rect.Bottom);
           l:=rect.Left;
           pl:=ARow;
           while (pl>1)and(SPts[pl-1]=SPts[pl]) do
                 dec(pl);
           s:=inttostr(pl)+'. '+rboy[ARow].id+': '+rboy[ARow].name;
           TextOut(l+5,rect.Top+2,s);
        end;
        if (ACol>0)and(ACol<=ntask) then begin
           font.size:=14;
           b:=findboy(rboy[ARow].id,task[ACol].p,task[ACol].pp,false);
           if b<>-1 then
              s:=inttostr(PPts[b])
           else s:='.';
           l:=rect.Left;
           TextOut(l+5,rect.top+2,s);
        end;
        if ACol=ntask+1 then begin
           font.size:=14;
           moveto(rect.Left,rect.top);
           lineto(rect.Left,rect.Bottom);
           l:=rect.Left;
           r:=rect.Right;
           s:=inttostr(SPts[ARow]);
           TextOut((l+r-TextWidth(s)) shr 1,rect.Top+2,s);
        end;
        exit;
     end;
end;
end;


procedure TForm1.AutoSwitchClick(Sender: TObject);
begin
if AutoSwitch.Checked then begin
   ShowTestingTimer.Enabled:=false;
   ShowTotalTimer.Enabled:=false;
   TotalSheet.show;
   TestSheet.Show;
end else begin
    ShowTestingTimer.Enabled:=false;
    ShowTotalTimer.Enabled:=false;
end;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
PageControl1.Width:=Form1.ClientWidth;
PageControl1.Height:=Form1.ClientHeight;
Legend.height:=SqSize*Legend.RowCount;
LogoBox.Height:=Legend.Height;
LogoBox.Width:=LogoBox.Picture.Bitmap.Width*LogoBox.Height div LogoBox.Picture.Bitmap.Height;
Legend.Width:=Panel1.ClientWidth-LogoBox.Width;
Legend.DefaultColWidth:=legend.Width div Legend.ColCount;
LogoBox.Left:=Legend.Width;
AutoSwitch.Left:=PageControl1.ClientRect.Right-AutoSwitch.Width-2;
AutoSwitch.Top:=PageControl1.ClientRect.Bottom-AutoSwitch.Height-2;
ClearTable.Left:=PageControl1.ClientRect.Right-AutoSwitch.Width-ClearTable.Width-4;
ClearTable.Top:=PageControl1.ClientRect.Bottom-ClearTable.Height-2;
ReCountCols;
end;

procedure TForm1.PageControl1DrawTab(Control: TCustomTabControl;
  TabIndex: Integer; const Rect: TRect; Active: Boolean);
var l,u:integer;
    s:string;
begin
with PageControl1.Canvas do begin
     brush.color:=headBkCol;
     fillrect(rect);
     if active then
        font.Style:=[fsBold]
     else font.Style:=[];
     font.color:=TextColor;
     s:=pagecontrol1.Pages[TabIndex].Caption;
     l:=(rect.Left+rect.Right-textwidth(s)) div 2;
     u:=(rect.Top+rect.Bottom-textheight(s)) div 2;
     TextOut(l,u,s);
end;
end;

procedure TForm1.fpstimerTimer(Sender: TObject);
begin
fps:=lastn/fpstimer.Interval*1000;
lastn:=0;
Legend.Invalidate;
end;

procedure tForm1.LoadArchive;
const maxFiles=50000;
var f:array[1..maxFiles] of record fname:string;time:int64; end;
    nn,nnn:array[1..maxFiles] of integer;
    rec:TSearchRec;
    nfiles:integer;
    hFile:tHandle;
    i:integer;

procedure Sort(l,r:integer);
var i,i1,i2,o:integer;
    t:integer;

function less(i,j:integer):boolean;
begin
less:=(f[nn[i]].time<f[nn[j]].time)or
   ((f[nn[i]].time=f[nn[j]].time)and(f[nn[i]].fname<f[nn[j]].fname));
end;

begin
if (l>=r) then exit;
if l=r-1 then begin
   if less(r,l) then begin
      t:=nn[l];nn[l]:=nn[r];nn[r]:=t;
   end;
   exit;
end;
o:=(l+r) div 2;
sort(l,o);sort(o+1,r);
i1:=l;i2:=o+1;
for i:=l to r do
    if (i2>r)or((i1<=o)and(less(i1,i2))) then begin
       nnn[i]:=nn[i1];
       inc(i1);
    end else begin
        nnn[i]:=nn[i2];
        inc(i2);
    end;
for i:=l to r do
    nn[i]:=nnn[i];
end;

begin
nFiles:=0;
if FindFirst('archive\*.test',faAnyFile-faDirectory,rec)=0 then begin
   repeat
     inc(nFiles);
     f[nFiles].fname:=rec.Name;
     hFile:=CreateFile(pchar('archive\'+rec.name),GENERIC_READ or GENERIC_WRITE,0,nil,OPEN_EXISTING,0,0);
     if hFile=INVALID_HANDLE_VALUE then
        raise eIJEerror.CreateWin('Error in CreateFile','');
     if not GetFileTime(hFile,@(f[nFiles].time),nil,nil) then
        raise eIJEerror.CreateWin('Error in GetFileTime','');
     CloseHandle(hFile);
     writeln(rec.name);
   until FindNext(rec)<>0;
   FindClose(rec);
end;
for i:=1 to nFiles do
    nn[i]:=i;
Sort(1,nFiles);
for i:=1 to nFiles do begin
    fname:='archive\'+f[nn[i]].fname;
    LoadResult;
end;
end;

procedure tForm1.DeleteArchive;
var rec:TSearchRec;
begin
if FindFirst('archive\*.test',faAnyFile-faDirectory,rec)=0 then begin
   repeat
     ForceNoFile('archive\'+rec.name);
     writeln(rec.name);
   until FindNext(rec)<>0;
   FindClose(rec);
end;
end;

procedure TForm1.FormActivate(Sender: TObject);
var rec:TSearchRec;
    f:textFile;
label 1;
begin
if not first then
   exit;
first:=false;
if FindFirst('archive\*.test',faAnyFile-faDirectory,rec)=0 then begin
   Form2.ShowModal;
   case Form2.ModalResult of
        mrYes:LoadArchive;
        mrNo:DeleteArchive;
   end;
   FindClose(rec);
end;
1:
firloading:=false;
Form1.Width:=Screen.Width;
Form1.Height:=Screen.Height;
assignFile(f,'intervals.txt');
reset(f);
if not seekeof(f) then begin
   read(f,TotalInterval);
   readln(f);
   writeln('TI');
end;
if not seekeof(f) then begin
   read(f,TestingInterval);
   readln(f);
   writeln('TI');
end;
if not seekeof(f) then begin
   read(f,TotalFinInterval);
   readln(f);
   writeln('TFI');
end;
if not seekeof(f) then begin
   read(f,TotalFirstInterval{!!!must be <>TotalInterval});
   readln(f);
   writeln('TFI');
end;
if not seekeof(f) then begin
   read(f,AddTestInterval);
   readln(f);
   writeln('ATI');
end;
CloseFile(f);
Timer1.Interval:=AddTestInterval;
Timer1.Enabled:=true;
TestSheet.Show;
end;

procedure TForm1.ClearTableClick(Sender: TObject);
begin
if Application.MessageBox('Очистить таблицу?','IJE ShowTest',MB_YESNO)=idyes then begin
   fillchar(boy,sizeof(boy),0);
   nboy:=0;
   ncol:=0;
   nrboy:=0;
   ntest:=0;
   ntask:=0;
   fillchar(PMax,sizeof(PMax),0);
   fillchar(PPts,sizeof(PPts),0);
   fillchar(rboy,sizeof(rboy),0);
   fillchar(res,sizeof(res),_nt);
   fillchar(SMax,sizeof(SMax),0);
   fillchar(SPts,sizeof(SPts),0);
   fillchar(TMax,sizeof(TMax),0);
   fillchar(TPts,sizeof(TPts),0);
   TotalGrid.Invalidate;
   Grid.Invalidate;
   ReCountCols;
end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
SystemParametersInfo(SPI_SETSCREENSAVEACTIVE,ord(ScreenSaverWasActive),nil,0);
end;

end.
