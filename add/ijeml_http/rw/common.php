<?
/* This file is part of IJE: the Integrated Judging Environment system 
   (C) Kalinin Petr 2002-2008
   $Id: common.php 202 2008-04-19 11:24:40Z *KAP* $ */
loadxml($mlcfg["ije-dir"].$qdllsettings,$acms);$acms=$acms["rw-contest"];
loadxml($mlcfg["ije-dir"].$cfg['results-path'].$acms["monitor"],$mon);$mon=$mon["standings"];
if ($cfg["table-dll"]<>"xml")
   die("Unknown table dll");
loadxml($mlcfg["ije-dir"].$cfg["results-path"].$acms["base-results"].".xml",$br);$br=$br["results"];

$qacm["format"]=$lang['RWcontest'];
$qacm["needglobaltime"]=0;
   
function ProbSolved($p){
foreach($p as $s) if (is_array($s))
  if ($s["points"]>0)
     return true;
return false;
}

?>