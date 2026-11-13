<?         
/* This file is part of IJE: the Integrated Judging Environment system 
   (C) Kalinin Petr 2002-2008
   $Id: messages.php 202 2008-04-19 11:24:40Z *KAP* $ */
$qacm["colspan"]=($acms["showtests"]=="true")?5:4;
$qacm["msgdetails"]=true;
$qacm["msg-sort-function"]="cmp";

function cmp($a,$b){
  return $a["id"]-$b["id"];
}

function parseglobaltime($time){
global $acms;
return date("d.m.Y H:i",60*($time+$acms["start"]));
}

function FormMessage($s,&$msg){
    global $acms;
    $msg["time"]=parseglobaltime($msg["time"]);
    $msg["points"]=$s["points"];
    $msg["max-points"]=$s["max-points"];
    if ($s["points"]==$s["max-points"])
       $msg["points"]="<font class=ProbFull>$msg[points]</font>";
    if (!in_array($s[1]["outcome"],array("compilation-error")))
       $msg["points"].=" / {$s["max-points"]}";
    if ($s[1]["outcome"]=="not-tested")
       $msg["points"]="NT";
    $nn=0;
    $msg["testres"]=array();
    foreach ($s as $t=>$tt) if (is_array($tt)){
      $nn++;
      $msg["testres"][$nn]=$tt;
    }
    if (($acms["showtests"]=="true")and(!in_array($s[1]["outcome"],array("compilation-error","not-tested")))){
       $msg["tests"]=0;
       $tottests=0;
       foreach ($s as $t=>$tt) if (is_array($tt)){
         if ($tt["outcome"]=="accepted")
            $msg["tests"]++;
         $tottests++;
       }
       $msg["tests"].=" / ".$tottests;
    } else $msg["tests"]="-";
    if ($s[1]["outcome"]=="not-tested"){
       $msg["points"]="NT";
       $msg["tests"]="";
    }
}

function WriteAddheader(){
global $acms,$lang;
write("<td class=points>$lang[Points]</td>");
if ($acms["showtests"]=="true") 
   write("<td class=stests>$lang[SuccessfullTests]</td>");
}

function WriteAddMessage($m){
global $acms;
write("<td class=points_>$m[points]</td>");
if ($acms["showtests"]=="true") 
   write("<td class=stests_>$m[tests]</td>");
}

function WriteAddMessage_($m){
WriteAddMessage($m);
}

function WriteProbHeader($prob,$ppp){
    global $mon,$acms;
    writeln("<h2>");
    $pts=$mon["parties"][$_SESSION["login"]][$prob]["points"];
    $maxpts=$mon["parties"][$_SESSION["login"]][$prob]["max-points"];
    $attempts=$mon["parties"][$_SESSION["login"]][$prob]["attempts"];
    if ($attempts>0){
      if (ProbSolved($mon["parties"][$_SESSION["login"]][$prob]))
         $s="<font class=ProbFull>$pts</font>";
      else $s=(string)$pts;
      $s.=" / $maxpts ($attempts)";
    } 
    else $s='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
    write("<font class=ProbInfo>$s</font>");
    writeln("&nbsp;&nbsp;&nbsp;$prob: $ppp[name]</h2>");
}

function WriteMsgDetails($m){
global $acms,$xmltext,$TextColor,$ltext;
$a=array("Time"=>$m["time"],
         "Problem"=>"$m[prob]: {$acms["problems"][$m["prob"]]["name"]}",
         "Points"=>$m["points"],
         );
if ($acms["showtests"]=="true")
   $a["Successfull tests"]=$m["tests"];

writeln("<table class=msgdetails>");
foreach ($a as $n=>$mm)
  writeln("<tr><td class=msgleft>$n:</td><td class=msgright>$mm</td></tr>");
writeln("</table>");

if ($acms["showtests"]=="true"){
  if ($acms["showtests"]=="true"){
    writeln("<table class=dtests cellspacing=0>");
    foreach ($m["testres"] as $n=>$t){
      $res=array_search($t["outcome"],$xmltext);
      write("<tr class=".substr($res,0,2)."><td class=testid>$n</td>");
      write("<td class=doutcome><font color={$TextColor[$res]}><b>$res</b></font></td>");
      write("<td class=dpoints>$t[points] / {$t["max-points"]}</td>");
      if (!($acms["showcomments"]=="true"))
         $t["comment"]=$ltext[$res];
      write("<td class=dcomment>$t[comment]&nbsp;</td>");
      writeln("</tr>");
    }
    writeln("</table>");
  }
}
}
?>