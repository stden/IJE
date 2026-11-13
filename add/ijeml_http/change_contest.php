<?
/* This file is part of IJE: the Integrated Judging Environment system 
   (C) Kalinin Petr 2002-2008
   $Id: change_contest.php 202 2008-04-19 11:24:40Z *KAP* $ */

include_once("ije.php");

if ($_SERVER["REQUEST_METHOD"]=="POST"){
   unset($_SESSION["login"]);
   unset($_SESSION["pwd"]);
   $_SESSION["contest"]=$_POST["contest"];
   init_qdll();
   startije("Change contest: $acms[title]","/main.css","Change contest");
   writeln("<h1>$lang[ChangeContestSuccessfull]</h1>");
   endije();
   die();
}

   
startije("$lang[ChangeContest]: $acms[title]","/main.css","Change contest");

if (!isset($login))
   $login='';
   
writeln("<table><tr>");
writeln("<td class=loginimg><img src=/login.bmp></td>");
writeln("<td>");
writeln("<h1>$lang[ChangeContest]</h1>");
writeln("<form action=\"/change_contest.php\" method=POST>");
writeln("<table>");
writeln("<tr><td>$lang[Contest]:</td><td>");
writeln("<select name=\"contest\">");
foreach ($acmcfg as $i=>$v) if (is_array($v)){
    loadxml($mlcfg["ije-dir"].$v["settings"],$tmp_settings);
    $tmp_settings=reset($tmp_settings);
    $sel=($i==$_SESSION["contest"])?' selected="selected"':'';
    write("<option value=\"$i\"$sel>{$tmp_settings['title']}</option>");
}
writeln("</select>");
writeln("</td></tr>");
writeln("</table>");
writeln("<input type=submit value=OK>");
writeln("</form>");
writeln("</td>");
writeln("</tr></table>");
endije();

?>