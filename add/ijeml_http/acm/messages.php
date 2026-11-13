<?
/* This file is part of IJE: the Integrated Judging Environment system 
   (C) Kalinin Petr 2002-2008
   $Id: messages.php 202 2008-04-19 11:24:40Z *KAP* $ */
$qacm["colspan"]=5;
$qacm["msgdetails"]=true;

function cmp($a,$b){
  global $sort;
  if ($a["time"]==$b["time"])
     return $a["id"]-$b["id"];
  else return $a["time"]-$b["time"];
}

$qacm["msg-sort-function"]="cmp";

function FormMessage($s,&$msg){
    global $acms,$ltext,$xmltext,$TextColor;
    if (isset($s["test"]) and ($acms["showtest"]=="true")and($s["outcome"]<>"accepted")and($s["outcome"]<>"not-tested"))
       $msg["test"]=$s["test"];
    else $msg["test"]="-";
    if (isset($s["comment"]) and ($acms["showcomment"]=="true")and($s["outcome"]<>"accepted")and($s["outcome"]<>"not-tested"))
       $msg["comment"]=$s["comment"];
    else $msg["comment"]="";
    $res=$msg["real_outcome"]=array_search($s["outcome"],$xmltext);
    if ($res=="OK")
       $msg["outcome"]="<b>$ltext[$res]</b>";
    else $msg["outcome"]=$ltext[$res];
    $msg["outcome"]="<font color=$TextColor[$res]>$msg[outcome]</font>";
}

function WriteAddheader(){
global $lang;
write("<td class=outcome>$lang[Outcome]</td><td class=test>$lang[Test]</td><td class=comment>$lang[Comment]</td>");
}

function WriteAddMessage($m){
writeln("<td class=outcome_>$m[outcome]</td><td class=test_>$m[test]</td><td class=comment_><pre class=comment>$m[comment]</pre></td>");
}

function WriteAddMessage_($m){
WriteAddMessage($m);
}

function WriteProbHeader($prob,$ppp){
    global $mon;
    writeln("<h2>");
    $state=$mon["parties"][$_SESSION["login"]][$prob]["solved"];
    if ($state<0) {
       $state=(string)$state;
       while (strlen($state)<3)
             $state=$state."&nbsp;";
       write("<font class=rejected>&nbsp;$state&nbsp;</font>");
    }
    if ($state==0)
       write("<font class=nosub>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font>");
    if ($state==1)
       write("<font class=accepted>&nbsp;+&nbsp;&nbsp;&nbsp;</font>");
    if ($state>1){
       $state--;
       $state=(string)$state;
       while (strlen($state)<2)
             $state=$state."&nbsp;";
       write("<font class=accepted>&nbsp;+$state&nbsp;</font>");
    }
    if ($state>0)
       write("<img alt=\"$prob\" src=\"balloon.php?id=$prob\">");
    else write("$prob:");
    writeln(" $ppp[name]</h2>");
}

function WriteMsgDetails($m){
global $lang;
$a=array($lang["Time"]=>$m["time"],
         $lang["Problem"]=>$m["prob"],
         $lang["Outcome"]=>$m["outcome"]);
if ($m["test"]<>'-') 
   $a["Test"]=$m["test"];
if (in_array($m["real_outcome"],array('CE','OK','NT')))
   unset($a["Test"]);
if ($m["comment"]<>'')
   $a["Comment"]="<font class=comment>$m[comment]</font>";
writeln("<table class=msgdetails>");
foreach ($a as $n=>$m)
  writeln("<tr><td class=msgleft>$n:</td><td class=msgright>$m</td></tr>");
writeln("</table>");
}
?>