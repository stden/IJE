<?
/* This file is part of IJE: the Integrated Judging Environment system 
   (C) Kalinin Petr 2002-2008
   $Id: ijeconsts.php 202 2008-04-19 11:24:40Z *KAP* $ */

$xmltext=array(
'OK'=>'accepted',                 
'WA'=>'wrong-answer',             
'PE'=>'presentation-error',       
'TL'=>'time-limit-exceeded',      
'ML'=>'memory-limit-exceeded',    
'OL'=>'output-limit-exceeded',    
'IL'=>'idleness-limit-exceeded',  
'RE'=>'runtime-error',            
'CR'=>'crash',                    
'SV'=>'security-violation',       
'NC'=>'accepted-not-counted',     
'CE'=>'compilation-error',        
'NS'=>'not-submitted',            
'CP'=>'compiled-not-tested',      
'FL'=>'fail',                     
'NT'=>'not-tested'
);
for ($i=1;$i<=10;$i++){
    $xmltext["PC$i"]="partial-correct-$i";
}

$TextColor=array(
'OK'=>'#00aa00',
'WA'=>'#ff0000',
'PE'=>'#007777',
'TL'=>'#000077',
'ML'=>'#000077',
'OL'=>'#000077',
'IL'=>'#000077',
'RE'=>'#770000',
'CR'=>'#770000',
'SV'=>'#770000',
'NC'=>'#004400',
'CE'=>'#aa00aa',
'NS'=>'#000000',
'CP'=>'#004400',
'FL'=>'#ff00ff',
'NT'=>'#004400' 
);
for ($i=1;$i<=10;$i++){
    $TextColor["PC$i"]='#777700';
}

function gettaskinfo($dp,&$d,&$p){//translated from Pascal: ije_main.pas
global $cfg;
$sformat=$cfg["problems-format"];
$d='';$p='';
assert(strlen($dp)==strlen($sformat));
for ($i=0;$i<strlen($sformat);$i++)
    switch($sformat{$i}){
         case '#':$d=$d.$dp[$i]; break;
         case '$':$p=$p.$dp[$i]; break;
         default: assert($dp[$i]==$sformat[$i]);
    }
}

function subs($s,$s1,$s2,$s3){//translated from Pascal: ijeconsts.pas
$ss='';
$i1=0;$i2=0;$i3=0;
for ($i=0;$i<strlen($s);$i++)
    switch($s[$i]){
         case '@':
               if ($i1>=strlen($s1)) continue;    
               $ss=$ss.$s1[$i1];$i1++;
             break;
         case '#':
               if ($i2>=strlen($s2)) continue;    
               $ss=$ss.$s2[$i2];$i2++;
             break;
         case '$':
               if ($i3>=strlen($s3)) continue;
               $ss=$ss.$s3[$i3];$i3++;
             break;
         default: $ss=$ss.$s[$i];
    }
return $ss;
}
?>