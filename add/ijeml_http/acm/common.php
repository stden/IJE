<?
/* This file is part of IJE: the Integrated Judging Environment system 
   (C) Kalinin Petr 2002-2008 
   $Id: common.php 202 2008-04-19 11:24:40Z *KAP* $ */
loadxml($mlcfg["ije-dir"].$qdllsettings,$acms);$acms=$acms["acm-contest"];
loadxml($mlcfg["ije-dir"].$cfg['results-path'].$acms["monitor"],$mon);$mon=$mon["standings"];

$qacm["format"]=$lang["ClassicalACMcontest"];
$qacm["needglobaltime"]=0;
?>