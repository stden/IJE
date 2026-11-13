<?
/* This file is part of IJE: the Integrated Judging Environment system 
   (C) Kalinin Petr 2002-2008
   $Id: stats.php 202 2008-04-19 11:24:40Z *KAP* $ */
function ShowAddStats(){
global $mon,$cfg,$lang;
$sstat=array($lang["TotalSubmits"]=>"0");
$lstat=array();
foreach($mon["parties"] as $parid=>$party)
  foreach($party as $probid=>$prob) if (is_array($prob))
    foreach($prob as $id=>$submit) if (is_array($submit)){
      $sstat[$lang["TotalSubmits"]]++;
      
      if (!isset($lstat[$submit["language-id"]]))
         $lstat[$submit["language-id"]]=0;
      $lstat[$submit["language-id"]]++;
    }
$lstat2=array();
foreach($lstat as $l=>$s){
  $ln=$l;
  foreach($cfg["languages"] as $id=>$language){
    if (strtoupper($id)==strtoupper($l))
       $ln=$language["name"];
  }
  $lstat2[$ln]=$s;
}

showstat($lang["Submits"],$sstat);
showstat($lang["Languages"],$lstat2);
}

function AddCStats(&$cstat){
global $acms,$lang;
$cstat[$lang["ExtraSubmissionPenalty"]]=$acms["penalty"]." $lang[pts]";
}

?>