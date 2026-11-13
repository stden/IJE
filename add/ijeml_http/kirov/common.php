<?
/* This file is part of IJE: the Integrated Judging Environment system 
   (C) Kalinin Petr 2002-2008
   $Id: common.php 202 2008-04-19 11:24:40Z *KAP* $ */
loadxml($mlcfg["ije-dir"].$qdllsettings,$acms);$acms=$acms["kirov-contest"];
loadxml($mlcfg["ije-dir"].$cfg['results-path'].$acms["monitor"],$mon);$mon=$mon["standings"];

$qacm["format"]=$lang['KirovTeamContest'];
if ($acms["penalty"]==0)
   $qacm["format"].=" ($lang[LazurnyVersion])";

$qacm["needglobaltime"]=1;
   
function ProbSolved($p){
foreach($p as $s) if (is_array($s))
     $ns=$s;
if (!isset($ns))
   return false;
foreach ($ns as $t) if (is_array($t))
  if ($t["outcome"]<>"accepted") return false;
return true;
}

?>