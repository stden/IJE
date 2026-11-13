<?
/* This file is part of IJE: the Integrated Judging Environment system 
   (C) Kalinin Petr 2002-2008
   $Id: stats.php 202 2008-04-19 11:24:40Z *KAP* $ */
function ShowAddStats(){
global $mon,$cfg;
$sstat=array("Total submits"=>"0");
$lsucid=0;
$lstat=array();
$ostat=array();
foreach($mon["parties"] as $parid=>$party)
  foreach($party as $probid=>$prob) if (is_array($prob))
    foreach($prob as $id=>$submit) if (is_array($submit)){
      $sstat["Total submits"]++;
      
      if (($submit["outcome"]=="accepted")and($id>$lsucid)){
         $lsucid=$id;
         $lsuc=$submit;
         $lsucparty=$parid;
         $lsucproblem=$probid;
      }
      
      if (!isset($lstat[$submit["language-id"]]))
         $lstat[$submit["language-id"]]=0;
      $lstat[$submit["language-id"]]++;
      
      if (!isset($ostat[$submit["outcome"]]))
         $ostat[$submit["outcome"]]=0;
      $ostat[$submit["outcome"]]++;
    }
$lstat2=array();
foreach($lstat as $l=>$s){
  $ln=$l;
  foreach($cfg["languages"] as $id=>$lang){
    if (strtoupper($id)==strtoupper($l))
       $ln=$lang["name"];
  }
  $lstat2[$ln]=$s;
}
if ($lsucid<>0){
   $sstat["Last success"]=$lsuc["time"].", ".$lsucproblem.", ".$lsucparty;
}

showstat("Submits",$sstat);
showstat("Languages",$lstat2);
showstat("Outcomes",$ostat);
}

function AddCStats(&$cstat){
global $acms,$lang;
$cstat[$lang["PenaltyTimeForRejectedSubmit"]]=sprintf($lang["NMin"],$acms["penalty"]);
}
?>