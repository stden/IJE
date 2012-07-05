<?
/* This file is part of IJE: the Integrated Judging Environment system 
   (C) Kalinin Petr 2002-2008
   $Id: messages.php 202 2008-04-19 11:24:40Z *KAP* $ */

include_once("ije.php");
include_once($qdll."/messages.php");

req_login();

if (!isset($_SESSION["sort"]))
   $_SESSION["sort"]="time";
if (isset($_GET["sort"]) and in_array($_GET["sort"],array("time","prob")))
   $_SESSION["sort"]=$_GET["sort"];
$sort=$_SESSION["sort"];

$msg=array();
foreach($mon["parties"][$_SESSION["login"]] as $pid=>$prob) if (is_array($prob))
  foreach($prob as $sid=>$s) if (is_array($s)){
    $msg[$s["id"]]=array("time"=>$s["time"], "prob"=>$pid, "id"=>$s["id"]);
    FormMessage($s,$msg[$s["id"]]);
  }
  
uasort($msg,$qacm["msg-sort-function"]);

if (isset($_GET["detail"])){
   if (isset($msg[$_GET["detail"]])) {
      startije("$lang[MessageDetails]: $acms[title]",array("/main.css","messages.css",$qdll."/messages.css"),"Message details");
      writeln("<h1>$lang[MessageDetails]</h1>");
      WriteMsgDetails($msg[$_GET["detail"]]);
      endije();
      die();   
   }
}

startije("$lang[Messages]: $acms[title]",array("/main.css","messages.css",$qdll."/messages.css"),"Messages");

writeln("<h1>$lang[Messages]</h1>");

if ($qacm["msgdetails"])
   write("<font class=msgdetails>{$lang["ClickOnMessageTime..."]}</font>");
   
writeln("<div class=sort>");
write("$lang[SortBy]: ");
if ($sort=="time") write("<b>$lang[time]</b>");
else write("<a href=\"/messages.php?sort=time\">$lang[time]</a>");
write(" / ");
if ($sort=="prob") write("<b>$lang[problem]</b>");
else write("<a href=\"/messages.php?sort=prob\">$lang[problem]</a>");
writeln("\n</div>");


function WriteMessage($m){
      global $was,$qacm;
      $was=true;
      if ($qacm["msgdetails"])
         $time="<a href=\"messages.php?detail=$m[id]\">$m[time]</a>";
      else $time=$m["time"];
      writeln("<tr><td class=time_>$time</td><td class=prob_>$m[prob]</td>");
      WriteAddMessage_($m);
      writeln("</tr>");
}

if ($sort=="time"){
  writeln("<table class=tests cellspacing=0>");
  write("<tr><td class=time>$lang[Time]</td><td class=prob>$lang[Problem]</td>");
  WriteAddHeader();
  writeln("</tr>");
  $was=false;
  foreach($msg as $m)
     WriteMessage($m);
  if (!$was)
     writeln("<tr><td colspan=$qacm[colspan] class=nosubmissions>$lang[NoSubmissions]</td></tr>");
  writeln("</table>");
} else {
  writeln("<table class=tests_ cellspacing=0>");
  write("<tr><td class=time>$lang[Time]</td><td class=prob>$lang[Problem]</td>");
  WriteAddHeader();
  writeln("</tr>");
  writeln("</table>");
  foreach($acms["problems"] as $prob=>$ppp){
    WriteProbHeader($prob,$ppp);
    writeln("<table class=tests cellspacing=0>");
    $was=false;
    foreach($msg as $m) if ($m["prob"]==$prob)
       WriteMessage($m);
    if (!$was)
       writeln("<tr><td colspan=$qacm[colspan] class=nosubmissions>$lang[NoSubmissions]</td></tr>");
    writeln("</table>");
  }
}

endije();

?>
