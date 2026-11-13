<?
/* This file is part of IJE: the Integrated Judging Environment system 
   (C) Kalinin Petr 2002-2008
   $Id: index.php 202 2008-04-19 11:24:40Z *KAP* $ */

include_once("ije.php");
include($qdll."/stats.php");

function showstat($name,$stat){
  writeln("<h1>$name:</h1>");
  writeln("<table>");
  foreach($stat as $a=>$b){
    writeln("<tr>");
    writeln("<td>$a:</td><td>$b</td>");
    writeln("</tr>");
  }
  writeln("</table>");
}

startije("$lang[Home]: $acms[title]","/main.css","Home");

$cstat=array(
            $lang["ContestName"]=>$acms["title"],
            $lang["ContestFormat"]=>$qacm["format"],
            $lang["MonitorMessagesTime"]=>(checkmontime()?"":"*").$mon["time"],
            $lang["ContestLength"]=>$mon["length"],
            $lang["ContestStatus"]=>(checkmontime()?$mon["status"]:"<b>{$lang["StrangeMonitorTime..."]}</b> ($lang[monitorStatus]: $mon[status])"),
            $lang["NumberOfProblems"]=>count($acms["problems"]),
            $lang["NumberOfTeams"]=>count($acms["parties"]),
            $lang["NumberOfAllowedLanguages"]=>count($cfg["languages"])
           );
AddCStats($cstat);

showstat($lang["Contest"],$cstat);

ShowAddStats();
endije();

?>