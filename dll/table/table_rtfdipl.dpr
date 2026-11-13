{$A-,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O-,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y+,Z1}
{$ifdef release}
{$D-,L-}
{$endif}
{ This file is part of IJE: the Integrated Judging Environment system }
{ (C) Kalinin Petr 2002-2008 }
{ $Id: table_rtfdipl.dpr 202 2008-04-19 11:24:40Z *KAP* $ }
library table_rtfdipl;
uses ShareMem,sysutils,
     xmlije,ijeconsts,ije_main,io;


procedure init(var cfg:tSettings);
begin
ije_main.cfg:=cfg;
end;


procedure save(fname:string;var table:ttable);
const MaxAddInfo=20;
var i,j,k:integer;
    s:integer;
    max:integer;
    was:array[1..maxboys] of byte;
    maxj:integer;
    f:text;
    addi:array[1..MaxBoys] of record 
      n:string;
      i:array[1..MaxAddInfo] of string; 
    end;
    AddIName:array[1..MaxAddInfo] of string;
    naddin:integer;
    naddi:integer;
    hasai:boolean;
    st:integer;
    sst:string;
    nnn:array[1..3] of integer;
    name,name1,name2:string;
    school:string;
    cl:string;
    
procedure LoadAddInfo;
var f:text;
    i:integer;
begin
try
assign(f,'data\addinfo_rtfdipl.txt');reset(f);
readln(f,naddin);
for i:=1 to naddin do begin
    readln(f,AddIName[i]);
    AddIName[i]:=trim(AddIName[i]);
end;
naddi:=0;
while not seekeof(f) do begin
      inc(naddi);
      readln(f,addi[naddi].n);
      addi[naddi].n:=trim(addi[naddi].n);
      for i:=1 to naddin do begin
          readln(f,addi[naddi].i[i]);
          addi[naddi].i[i]:=trim(addi[naddi].i[i]);
      end;
end;
close(f);
except
  on e:exception do
     raise exception.create(e.message+' in addinfo_rtfdipl.txt');
end;
try
assign(f,'data\nodipl.txt');reset(f);
read(f,nnn[1],nnn[2],nnn[3]);
close(f);
except
  on e:exception do
     raise exception.create(e.message+' in nodipl.txt');
end;
end;

begin
try
with table do begin
LoadAddinfo;
if ExtractFileExt(fname)='' then
   fname:=fname+'.dipl.rtf';
   
assign(f,fname);rewrite(f);
writeln(f,'{\rtf1\ansi\ansicpg1251\uc1\deff0\stshfdbch0\stshfloch0\stshfhich0\stshfbi0\deflang1049\deflangfe1049{\fonttbl{\f0\froman\fcharset204\fprq2{\*\panose 02020603050405020304}Times New Roman;}{\f141\froman\fcharset0\fprq2 Times New Roman;}');
writeln(f,'{\f139\froman\fcharset238\fprq2 Times New Roman CE;}{\f142\froman\fcharset161\fprq2 Times New Roman Greek;}{\f143\froman\fcharset162\fprq2 Times New Roman Tur;}{\f144\froman\fcharset177\fprq2 Times New Roman (Hebrew);}');
writeln(f,'{\f145\froman\fcharset178\fprq2 Times New Roman (Arabic);}{\f146\froman\fcharset186\fprq2 Times New Roman Baltic;}{\f147\froman\fcharset163\fprq2 Times New Roman (Vietnamese);}}{\colortbl;\red0\green0\blue0;\red0\green0\blue255;\red0\green255\blue255;');
writeln(f,'\red0\green255\blue0;\red255\green0\blue255;\red255\green0\blue0;\red255\green255\blue0;\red255\green255\blue255;\red0\green0\blue128;\red0\green128\blue128;\red0\green128\blue0;\red128\green0\blue128;\red128\green0\blue0;\red128\green128\blue0;');
writeln(f,'\red128\green128\blue128;\red192\green192\blue192;}{\stylesheet{\ql \li0\ri0\widctlpar\aspalpha\aspnum\faauto\adjustright\rin0\lin0\itap0 \fs24\lang1049\langfe1049\cgrid\langnp1049\langfenp1049 \snext0 Normal;}{\*\cs10 \additive \ssemihidden ');
writeln(f,'Default Paragraph Font;}{\*\ts11\tsrowd\trftsWidthB3\trpaddl108\trpaddr108\trpaddfl3\trpaddft3\trpaddfb3\trpaddfr3\trcbpat1\trcfpat1\tscellwidthfts0\tsvertalt\tsbrdrt\tsbrdrl\tsbrdrb\tsbrdrr\tsbrdrdgl\tsbrdrdgr\tsbrdrh\tsbrdrv ');
writeln(f,'\ql \li0\ri0\widctlpar\aspalpha\aspnum\faauto\adjustright\rin0\lin0\itap0 \fs20\lang1024\langfe1024\cgrid\langnp1024\langfenp1024 \snext11 \ssemihidden Normal Table;}}{\*\rsidtbl \rsid8440\rsid2650474\rsid2846725\rsid4011070\rsid4352360\rsid5511596');
writeln(f,'\rsid5719122\rsid6034059\rsid7357822\rsid7757495\rsid8802289\rsid9517147\rsid11599892\rsid12932042\rsid13117702\rsid13382871\rsid15101949\rsid15996549\rsid16454022}{\*\generator Microsoft Word 10.0.2627;}{\info');
writeln(f,'{\title \''d0\''e0\''e7\''e5\''ed\''f8\''f2\''e5\''e9\''ed}{\author \''ca\''e0\''eb\''e8\''ed\''e8\''ed}{\operator \''ca\''e0\''eb\''e8\''ed\''e8\''ed}{\creatim\yr2005\mo2\dy8\hr20\min49}{\revtim\yr2005\mo2\dy8\hr20\min51}{\printim\yr2005\mo2\dy8\hr20\min50}{\version6}{\edmins1}');
writeln(f,'{\nofpages4}{\nofwords15}{\nofchars122}{\*\company \''cd\''e5\''f2}{\nofcharsws135}{\vern16437}}\paperw16838\paperh11906\margl1134\margr1134\margt1701\margb851 ');
writeln(f,'\deftab708\widowctrl\ftnbj\aenddoc\noxlattoyen\expshrtn\noultrlspc\dntblnsbdb\nospaceforul\hyphcaps0\formshade\horzdoc\dgmargin\dghspace6\dgvspace6\dghorigin1134\dgvorigin1701\dghshow1\dgvshow1');
writeln(f,'\jexpand\viewkind1\viewscale50\pgbrdrhead\pgbrdrfoot\splytwnine\ftnlytwnine\htmautsp\nolnhtadjtbl\useltbaln\alntblind\lytcalctblwd\lyttblrtgr\lnbrkrule\nobrkwrptbl\snaptogridincell\allowfieldendsel\wrppunct\asianbrkrule\rsidroot15996549 \fet0\sectd ');
writeln(f,'\lndscpsxn\linex0\headery709\footery709\colsx708\endnhere\sectlinegrid360\sectdefaultcl\sectrsid13382871\sftnbj {\*\pnseclvl1\pnucrm\pnstart1\pnindent720\pnhang {\pntxta .}}{\*\pnseclvl2\pnucltr\pnstart1\pnindent720\pnhang {\pntxta .}}{\*\pnseclvl3');
writeln(f,'\pndec\pnstart1\pnindent720\pnhang {\pntxta .}}{\*\pnseclvl4\pnlcltr\pnstart1\pnindent720\pnhang {\pntxta )}}{\*\pnseclvl5\pndec\pnstart1\pnindent720\pnhang {\pntxtb (}{\pntxta )}}{\*\pnseclvl6\pnlcltr\pnstart1\pnindent720\pnhang {\pntxtb (}{\pntxta )}}');
writeln(f,'{\*\pnseclvl7\pnlcrm\pnstart1\pnindent720\pnhang {\pntxtb (}{\pntxta )}}{\*\pnseclvl8\pnlcltr\pnstart1\pnindent720\pnhang {\pntxtb (}{\pntxta )}}{\*\pnseclvl9\pnlcrm\pnstart1\pnindent720\pnhang {\pntxtb (}{\pntxta )}}\pard\plain ');
writeln(f,'\ql \li0\ri0\widctlpar\aspalpha\aspnum\faauto\adjustright\rin0\lin0\itap0 \fs24\lang1049\langfe1049\cgrid\langnp1049\langfenp1049 {\lang1033\langfe1049\langnp1033\insrsid4352360 ');
writeln(f,'\par }\pard \qc \li0\ri0\widctlpar\aspalpha\aspnum\faauto\adjustright\rin0\lin0\itap0\pararsid13382871 {\insrsid13382871 ');

fillchar(was,sizeof(was),0);
for st:=1 to 3 do begin
    sst:='';
    for i:=1 to st do
        sst:=sst+'I';
    for i:=1 to nnn[st] do begin
        max:=-1;
        for j:=1 to nboy do if was[j]=0 then begin
            s:=0;
            for k:=1 to ntask do s:=s+get(table,j,k);
            if s>max then begin
               max:=s;
               maxj:=j;
            end;
        end;
        was[maxj]:=1;
        //name school class
        hasai:=false;
        for j:=1 to naddi do
            if addi[j].n=boy[maxj] then begin
               hasai:=true;
               name:=addi[j].i[1];
               school:=addi[j].i[2];
               cl:=addi[j].i[3];
            end;
        if not hasai then
           raise exception.create('Additional info not found for contestant '+boy[maxj]);
        name1:=copy(name,1,pos(' ',name)-1);
        name2:=copy(name,pos(' ',name)+1,length(name)-pos(' ',name));
        writeln(f,'{\lang1033\langfe1049\langnp1033\insrsid12932042 ');
        writeln(f,'\par }\pard \qc \li0\ri0\widctlpar\aspalpha\aspnum\faauto\adjustright\rin0\lin0\itap0\pararsid12932042 {\insrsid12932042 ');
        writeln(f,'\par ');
        writeln(f,'\par ');
        writeln(f,'\par ');
        writeln(f,'\par }{\fs72\lang1033\langfe1049\langnp1033\insrsid1974601 '+sst+'}{\fs72\insrsid1974601\charrsid6562830  }{\fs72\insrsid1974601 степени}{\fs72\insrsid12932042\charrsid1974601 ');
        writeln(f,'\par }{\insrsid12932042 ');
        writeln(f,'\par }{\fs96\insrsid12932042\charrsid13382871 ',name1);
        writeln(f,'\par ',name2);
        writeln(f,'\par }{\insrsid12932042 ');
        writeln(f,'\par }{\fs36\lang1033\langfe1049\langnp1033\insrsid12932042\charrsid13117702 '+cl+' класс, '+school+'}{\fs36\lang1033\langfe1049\langnp1033\insrsid12932042 ');
        writeln(f,'\par }\pard \ql \li0\ri0\widctlpar\aspalpha\aspnum\faauto\adjustright\rin0\lin0\itap0\pararsid12932042 {\lang1033\langfe1049\langnp1033\insrsid12932042 \page ');
        writeln(f,'}');
    end;
end;
writeln(f,'}}');
close(f);
end;
except
on e:exception do
   raise exception.create('Main error');
end;
end;
          
function about:string;//it is not guaranteed that init proc will be called before it
begin
about:='(save only)';
end;

exports
  init,save,about;

begin
end.