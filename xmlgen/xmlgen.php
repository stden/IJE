<?
/* (C) Kalinin Petr 2005-2006 */
/* $Id: xmlgen.php 211 2010-01-22 17:09:54Z ╨б╤В╨░╨╜╨┤╨░╤А╤В╨╜╤Л╨╣ $ */
if ($argc<>2){
   print("Usage: $argv[0] <file with xml template>");
   die();
}
$xmlfilename=$argv[1];
define("MAX_ATTR",10);
$xmlije="../xmlije.pas";

function makeident($s){
return 
  preg_replace('/(\[|^|\s|\(|,|=)\./','\\1a.',$s);
}

function addvar(&$vars,$name,$type){
$name=str_replace("-","_",$name);
if (isset($vars[$name])){
   $name0=$name;
   for ($i=1;isset($vars[$name]);$i++)
       $name=$name0.$i;
}
$vars[$name]=$type;
return $name;
}

function prepare_cycle_load($parentEl,$val,$namev,$name,$indent,&$precycle,&$postcycle){
  global $varsLoad;
  if (isset($val["_array"])){
     $is=array();
     $isa=explode("=",$val["_array"]);
     foreach ($isa as $i){
       if ($i[0]==".")
          $is[]=makeident($i);//store number in returned record
       else {
         if (isset($varsLoad[$i]))
            print("\n\n! Loop variable name changed from $i\n");
         $is[]=addvar($varsLoad,$i,"integer");//make temp var
       }
     }
     
     $preiter="";
     if (isset($val["_find"])){//We need to sinchronize this _array with something else
        list($cmpwith,$attrname)=explode("=",$val["_find"],2);
        $attrvar=addvar($varsLoad,$attrname,'string');
        $preiter.="$indent  $attrvar:=XMLtoText(findXMLattrEC($namev,'$attrname'));\r\n";
        
        $findvar=$is[0];
        $is[0]=addvar($varsLoad,"tmpi","integer");//подменим главную переменную цикла
        if (!isset($val["_min"])) $min=1;
        else $min=makeident($val["_min"]);
        $max=makeident($val["_max"]);
        
        $tmpvar=addvar($varsLoad,"tmpj","integer");
        $if=makeident($cmpwith)."=$attrvar";
        $preiter.="$indent  $tmpvar:=".($min-1).";\r\n$indent  for $findvar:=$min to $max do if $if then\r\n$indent    $tmpvar:=$findvar;\r\n$indent  if $tmpvar=".($min-1)." then\r\n$indent    raise eIJEerror.create('Can''t synchronize array','(xmlgen): ','Can''t find value %s (loop by $findvar)',[$attrvar]);\r\n$indent  $findvar:=$tmpvar;\r\n";
     }
     
     $i=$is[0];
     $setvar="inc($i);";
     if (isset($val["_array_preload"])){
        $setvar="$i:=StrToInt(findXMLattrEC($namev,'$val[_array_preload]',true));";
     }
     
     $precycle="$indent$i:=0;\r\n{$indent}while $namev<>nil do begin\r\n$indent  $setvar\r\n$preiter";
     $postcycle="\r\n$indent  $namev:=findXMLelement($namev^.next,'$name');\r\n{$indent}end;\r\n";
     if (!isset($val["_find"]))//если нужна синхронизация, то к-во элементов может быть не равно полному количеству и сохранять не надо (а параметр в _array может быть нужен для save)
       foreach ($is as $ii) if ($ii<>$i) 
          $postcycle.="$indent$ii:=$i;\r\n";
  }
}

function makeLoad($a,$indent,$elName){
global $load,$varsLoad;
foreach ($a as $name=>$val){
  if (is_array($val)){
     $namev=addvar($varsLoad,$name,"pXMLelement");
     if (isset($val["_optional"]))
        $cc="C";
     else $cc="CC";
     $load.="$indent$namev:=findXMLelement$cc($elName,'$name');\r\n";
     $precycle="";$postcycle="";
     prepare_cycle_load($elName,$val,$namev,$name,$indent,$precycle,$postcycle);
     $load.=$precycle;
     makeLoad($val,$indent."  ","$namev");
     $load.=$postcycle;
  } else {
    if (preg_match('/^{[^{}]*}$/',$val)){
       $val=substr($val,1,-1);
       $valexpl=explode(":",$val);
       list($elem,$type)=$valexpl;
       if (isset($valexpl[3]) and ($valexpl[3]=="optional"))
          $raiseonerror=",false";
       else $raiseonerror="";
       if (isset($valexpl[3]) and ($valexpl[3]=="ignoreload"))
          continue;
       $conv1="";$conv2="";
       if ($type=="string"){
          if (isset($valexpl[3]) and ($valexpl[3]=="uppercase")){
             $conv1="UpperCase(";$conv2=")";
          }
          $conv1.="XMLtoText(";$conv2=")$conv2";
       } elseif ($type=="integer") {
          $conv1="StrToInt(";$conv2=")";
       } elseif ($type=="path") {
          $conv1="ExpandFileName(";$conv2=")+'\\'";
       } elseif ($type=="tl") {
          $conv1="StringToTL(";$conv2=")";
       } elseif ($type=="ml") {
          $conv1="StringToML(";$conv2=")";
       } elseif ($type=="result"){
          $conv1="XmlToResult(";$conv2=")";
       } elseif ($type=="optinteger"){
          $conv1="OptStrToInt(";$conv2=",$valexpl[4])";
       } elseif ($type=="char"){
          $conv1="StrToChar(";$conv2=")";
       } elseif ($type=="GTID"){
          $conv1="StrToGTID(";$conv2=")";
       } elseif ($type=="float"){
          $conv1="StrToFloat(";$conv2=")";
       } elseif ($type=="boolean"){
          $conv1="StrToBool(";$conv2=")";
       } elseif ($type=="optboolean"){
          $conv1="OptStrToBool(";$conv2=",$valexpl[4])";
       } else 
         die("Strange type: $type (value=$val)");
       $elem=makeident($elem);
       $load.="{$indent}$elem:={$conv1}findXMLattrEC($elName,'$name'$raiseonerror)$conv2;\r\n";
       if (($type=="string")and(isset($valexpl[3]) and ($valexpl[3]=="optional") and (isset($valexpl[4]))))
          $load.="{$indent}if $elem='' then $elem:='$valexpl[4]';\r\n";
    }
  }
}
}

function prepare_cycle_save($val,$indent,&$precycle,&$postcycle){
global $varsSave;
  if (isset($val["_array"])){
     $is=explode("=",$val["_array"]);
     foreach ($is as $ii){
       if ($ii[0]==".")
          $max=makeident($ii);
       else 
         $i=addvar($varsSave,$ii,"integer");//make temp var
     }
     $selectpart="";
     if (isset($val["_select"])) {//we need to save only some items of the array
        $selectpart="\r\n{$indent}if (".makeident($val["_select"]).") then ";
     }
     assert(isset($max));
     assert(isset($i));
     $precycle="{$indent}for $i:=1 to $max do {$selectpart}begin\r\n";
     $postcycle="{$indent}end;\r\n";
  }
}

function makeSave($elname,$a,$indent,$indent2){
global $save,$varsSave;
$attr=0;$subel=0;
foreach ($a as $name=>$val){
  if (is_array($val))
     $subel++;
  elseif ($name[0]<>"_"){
    $attr++;
//    print("$elname::$name::$val::$attr\n");
  }
}
$save.="{$indent}write(f,'$indent2<$elname');\r\n";
if ($attr>MAX_ATTR)
   $in="  ";
else $in=" ";
foreach ($a as $name=>$val) if (!is_array($val)){
    if (preg_match('/^{[^{}]*}$/',$val)){
       $val=substr($val,1,-1);
       list($elem,$type,$format)=explode(":",$val);
       $elem=makeident($elem);
       $conv1="";$conv2="";
       if ($type=="result"){
          $conv1="Xmltext(";$conv2=")";
       } elseif ($type=="string"){
          $conv1="TextToXML(";$conv2=")";
       } elseif ($type=="boolean"){
          $conv1="BoolToStr(";$conv2=",true)";
       }
       $save.="{$indent}write(f,format('$in$name=\"$format\"',[$conv1$elem$conv2]));\r\n";
    } elseif ($name[0]<>'_') {
       $save.="{$indent}write(f,'$in$name=\"$val\"');\r\n";
    }
    if ($attr>MAX_ATTR)
       $save.="{$indent}writeln(f);write(f,'$indent2');\r\n";
  }
if ($subel>0){
   $save.="{$indent}writeln(f,'>');\r\n";
   foreach ($a as $name=>$val) if (is_array($val)){
        $precycle="";
        $postcycle="";
        prepare_cycle_save($val,$indent,$precycle,$postcycle);
        $save.=$precycle;
        makeSave($name,$val,$indent."  ",$indent2."  ");
        $save.=$postcycle;
   }
   $save.="{$indent}writeln(f,'$indent2</$elname>');\r\n";
} else $save.="{$indent}writeln(f,'/>');\r\n";
}

function makereturn($s,$indent=""){
return str_replace("|","\r\n$indent",$s);
}

set_magic_quotes_runtime(0);
include("xml.php");

print("Loading file $xmlfilename...");
loadxml($xmlfilename,$a,'',false);
//var_dump($a);
print("ok\n");

reset($a);
$typename=current($a);
$mainkey=key($a);
$typename=$typename["_typename"];
if (!isset($typename)) die("Typename not found");
if (ctype_lower($typename[0])){
   $typename=ucfirst($typename);
   print("Warning: you'd better make first character of typename uppercase\n");
}

$addparamsstr='';
if (isset($a[$mainkey]["_addparams"])){
   $addparams=explode(";",$a[$mainkey]["_addparams"]);
   foreach ($addparams as $vt) if ($vt<>''){
           list($v,$t)=explode(":",$vt,2);
           if (substr($v,0,4)=='var ') 
              $v=trim(substr($v,4));
           addvar($varsLoad,$v,$t);
           addvar($varsSave,$v,$t);
           $addparamsstr.=";var $v:$t";
   }
}
if (isset($a[$mainkey]["_addvarload"])){
   $addload=$a[$mainkey]["_addvarload"];
   $addload=explode(";",$addload);
   foreach ($addload as $vt){
           list($v,$t)=explode(":",$vt,2);
           addvar($varsLoad,$v,$t);
   }
}
if (isset($a[$mainkey]["_addvarsave"])){
   $addsave=$a[$mainkey]["_addvarsave"];
   $addsave=explode(";",$addsave);
   foreach ($addsave as $vt){
           list($v,$t)=explode(":",$vt,2);
           addvar($varsSave,$v,$t);
   }
}
$BefLoad=makereturn(makeident((isset($a[$mainkey]["_befload"])?"  {$a[$mainkey]["_befload"]}\r\n":"")),"  ");
$AfterLoad=makereturn(makeident((isset($a[$mainkey]["_afterload"])?"  {$a[$mainkey]["_afterload"]}\r\n":"")),"  ");
$BefSave=makereturn(makeident((isset($a[$mainkey]["_befsave"])?"{$a[$mainkey]["_befsave"]}\r\n":"")));
$AfterSave=makereturn(makeident((isset($a[$mainkey]["_aftersave"])?"{$a[$mainkey]["_aftersave"]}\r\n":"")));
$InitType=makereturn(makeident((isset($a[$mainkey]["_inittype"])?"{$a[$mainkey]["_inittype"]}\r\n":"")));

$intpart=<<<DATA
procedure Load$typename(fname:string;var a:t$typename$addparamsstr);
procedure Save$typename(fname:string;var a:t$typename$addparamsstr);\r\n
DATA;
$intmatch=<<<DATA
|procedure Load$typename\([^)]*\);
procedure Save$typename\([^)]*\);\r\n|
DATA;

//let's form Load proc
print("Forming Load$typename proc...");
$root0=addvar($varsLoad,"root0","pXMLelement");
$root=addvar($varsLoad,"root","pXMLelement");
$loadHead=<<<DATA
begin
LogEnterProc('Load$typename',LOG_LEVEL_MINOR,''''+fname+'''');
try
try  
fillchar(a,sizeof(a),0);
{$InitType}readXMlfile(fname,$root0);
try
  $root:=findXMLelementEC($root0,'$mainkey');
$BefLoad
DATA;
//No \r\n after $befload! 

$load="";
makeLoad(current($a),"  ",$root);

$loadTrail=<<<DATA
{$AfterLoad}finally
  XMldispose($root0);
end;
except
  on e:exception do
     raise eIJEerror.CreateAppendPath(e,'Load$typename('+fname+')','Error while loading t$typename');
end;
finally
  LogLeaveProc('Load$typename',LOG_LEVEL_MINOR);
end;
end;\r\n
DATA;
//forming var-part
$varLoadPart="";
foreach ($varsLoad as $name=>$type)
        $varLoadPart.="    $name:$type;\r\n";
$varLoadPart=substr_replace($varLoadPart,"var",0,3);
$varLoadPart="procedure Load$typename(fname:string;var a:t$typename$addparamsstr);\r\n".$varLoadPart;
//formed var-part
print("ok\n");
//formed load

//Let's form save proc
print("Forming Save$typename proc...");
$varsSave["f"]="text";
$varsSave["buf"]="packed array[0..8191] of byte";
$save=<<<DATA
begin
assign(f,fname);rewrite(f);SetTextBuf(f,buf,sizeof(buf));
{$BefSave}writeln(f,'<?xml version="1.0" encoding="Windows-1251"?>');\r\n
DATA;
MakeSave(key($a),current($a),"  ","");
//var_dump($varsSave);
$save.="{$AfterSave}close(f);\r\nend;\r\n";
//forming var-part
$varSavePart="";
foreach ($varsSave as $name=>$type)
        $varSavePart.="    $name:$type;\r\n";
$varSavePart=substr_replace($varSavePart,"var",0,3);
$varSavePart="procedure Save$typename(fname:string;var a:t$typename$addparamsstr);\r\n".$varSavePart;
//formed var-part
print("ok\n");
//formed save

$impc1="//$typename starts\r\n";
$impc2="//$typename ends\r\n";

$imppart=$impc1.$varLoadPart.$loadHead.$load.$loadTrail."\r\n".$varSavePart.$save.$impc2;

//save to xmlije.pas
print("Saving to xmlije.pas...");
$backup=dirname($xmlije)."/".basename($xmlije,".pas").".old.pas";
copy($xmlije,$backup);
$s=file_get_contents($xmlije);
if (!preg_match($intmatch,$s)){
   print("Adding interface header...");
   $s=preg_replace("/\s*implementation/","\r\n$intpart\r\nimplementation",$s);
} else {
  $s=preg_replace($intmatch,$intpart,$s);
}
if (!preg_match("|$impc1.*$impc2|s",$s)){
   print("Adding implementation header...");
   $s=preg_replace("/\s*begin\s*end./","\r\n\r\n$imppart\r\nbegin\r\nend.",$s);
} else {
   $s=preg_replace("|$impc1.*$impc2|s",$imppart,$s);
} 
file_put_contents($xmlije,$s);
print("ok\n");

print("Done!");
//the end

/*
procedure loadacmsettings(fname:string;var a:tacmsettings); 
var p:pXMLelement;
    problem:pXMLelement;
    party:pXMLelement;     
    acm:pXMlelement;
    sound,acs,rejs,sfounds:pXMLelement;
    showcomment,showtest:string;

begin
LogEnterProc('LoadACMsettings',''''+fname+'''');
try
try
fillchar(a,sizeof(a),0);
writeln('Loading ACM contest information...');
readXMlfile(fname,p);
try
  acm:=findXMLelementEC(p,'acm-contest');
  a.start:=StrToInt(findXMLattrEC(acm,'start'));
  a.solformat:=findXMLattrEC(acm,'solutions-format');
  a.name:=findXMLattrEC(acm,'name');
  a.archive:=ExpandFileName(findXMLattrEC(acm,'archive-path'));
  a.length:=StrToInt(findXMLattrEC(acm,'length'));
  
  problem:=findXMLelementCC(findXMLelementCC(acm,'problems'),'problem');
  a.nproblem:=0;
  while problem<>nil do begin
        inc(a.nproblem);
        a.problem[a.nproblem].n:=findXMLattrEC(problem,'id');
        a.problem[a.nproblem].ln:=findXMLattrEC(problem,'name');
        problem:=findXMLelement(problem^.next,'problem');
  end;
  write('Found ',a.nproblem,' problems...');
    
  party:=findXMLelementCC(findXMLelementCC(acm,'parties'),'party');
  a.nparty:=0;
  while party<>nil do begin
        inc(a.nparty);
        a.party[a.nparty].n:=findXMLattrEC(party,'id');
        a.party[a.nparty].p:=findXMLattrEC(party,'password');
        a.party[a.nparty].ln:=findXMLattrEC(party,'name');
        party:=findXMLelement(party^.next,'party');
  end;
  writeln('and ',a.nparty,' parties');
finally
  XMldispose(p);
end;
except
  on e:exception do
     raise exception.Create('LoadACMsetings: '+e.Message);
end;
finally
  LogLeaveProc('LoadACMsettings');
end;
end;
*/

?>
