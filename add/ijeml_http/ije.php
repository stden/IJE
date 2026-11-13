<?
/* This file is part of IJE: the Integrated Judging Environment system 
   (C) Kalinin Petr 2002-2008
   $Id: ije.php 215 2010-03-12 17:42:01Z Стандартный $ */

$mlver="2.0";

include_once("ijeconsts.php");

if (get_magic_quotes_gpc()==1){
  foreach ($_GET as $key=>$val) 
    if (is_string($_GET[$key]))
       $_GET[$key]=stripslashes($val);
  foreach ($_POST as $key=>$val) 
    if (is_string($_POST[$key]))
       $_POST[$key]=stripslashes($val);
}

//Disable magic quotes runtime
set_magic_quotes_runtime(0);
//Import variables
ini_set("session.use_cookies",0);
ini_set("session.use_trans_sid",1);
ini_set("session.gc_maxlifetime",300);
ini_set("session.gc_divisor",20);
//
include_once("xml.php");
loadxml("cfg.xml",$mlcfg);$mlcfg=$mlcfg["ijeml-configuration"];

session_start();
if (isset($_SESSION["ip"])and($_SERVER["REMOTE_ADDR"]<>$_SESSION["ip"])){
   print("hack attack");
   die();
}
$_SESSION["ip"]=$_SERVER["REMOTE_ADDR"];
init_language();
include("lang_$_SESSION[lang].php");

loadxml("{$mlcfg['ije-dir']}\\ije_cfg.xml",$cfg);$cfg=$cfg["ije-configuration"];
loadxml("{$mlcfg['ije-dir']}\\acm.xml",$acmcfg);$acmcfg=$acmcfg["acm-contests"];
//

if (!isset($_SESSION["contest"])) {
   foreach ($acmcfg as $i=>$c) if (is_array($c)){
     $_SESSION["contest"]=$i;
     break;
   }
}
if (!isset($_SESSION["contest"])){
   startije("$lang[NoContestsRunning]","/main.css","Home");
   writeln("<h1>$lang[NoContestsRunning]</h1>");
   endije();
   die();
}

function init_qdll(){
global $acmcfg,$qdll,$qdllsettings,$lang;
$error=false;
if (!isset($acmcfg[$_SESSION['contest']])){
   unset($_SESSION["contest"]);
   unset($_SESSION["login"]);
   unset($_SESSION["pwd"]);
   $error=true;
}
if (!isset($_SESSION["contest"])){
   foreach ($acmcfg as $i=>$c) if (is_array($c)){
     $_SESSION["contest"]=$i;
     break;
   }
}
$qdll=$acmcfg[$_SESSION['contest']]['qacm-dll'];
$qdllsettings=$acmcfg[$_SESSION['contest']]['settings'];
if ($error){
   include("$qdll/lang_$_SESSION[lang].php");
   startije($lang["LoginError"],"/main.css","Login");
   writeln("<h1>$lang[Error]</h1>");
   writeln("$lang[UnknownContest]. ".sprintf($lang["TryToDo"],"<a href=/login.php>$lang[relogin]</a>"));
   endije();
   die();
}
}

init_qdll();
   
include("$qdll/lang_$_SESSION[lang].php");
include_once("$qdll/common.php");
//

check_login();
//

function write($s){
print($s);
}

function writeln($s){
write($s."\n");
}

function checkmontime(){
global $mon,$mlcfg,$acms,$qacm;
$curtime=time();
if (!$qacm["needglobaltime"]){
   $curtime=getdate($curtime);
   $curtime=$curtime["hours"]*60+$curtime["minutes"]-$acms["start"];
} else 
   $curtime=(int)(time()/60)-$acms["start"];
if (isset($mlcfg["dst"])and($mlcfg["dst"])) 
   $curtime-=60*$mlcfg["dst"];//dst one hour
return(($mon["time"]<$curtime+1)and($mon["time"]>$curtime-3));
}

function startije($title,$css,$page)
{
global $acms,$mon,$logged,$lang,$av_language;
writeln("<html>");
writeln("<head>");
writeln("<title>$title</title>");
if (!is_array($css))
   $css=array($css);
foreach($css as $c){
  writeln("<LINK rel=\"stylesheet\" href=\"$c\"/>");
}
writeln("</head>");
writeln("<body>");
writeln("<table width=100% class=\"top\">");
writeln("<tr>");
writeln("<td align=left width=33%>");
writeln("IJE: the Integrated Judging Environment");
writeln("</td>");
writeln("<td align=center width=34%>");
writeln("<font size=+1>qACM contest<br><b>$acms[title]</b></font>");
writeln("</td>");
writeln("<td width=33% align=right>");
if (isset($acms)){//else no contests running
   if (!checkmontime()){
      $status="<b>$lang[StatusUnknown]</b>";
      $tmp='*';
   }else{
      $status=$mon["status"];
      $tmp='';
   }
   writeln("$status, $tmp".sprintf($lang["TimeOfTime"],$mon["time"],$mon["length"]));
}
writeln("</td>");
writeln("</table>");

$hrefs=array(
             array("text"=>"Home","href"=>"/index.php","nol"=>true),
             array("text"=>"Submit","href"=>"/submit.php","nol"=>false),
             array("text"=>"Standings","href"=>"/standings.php","nol"=>isset($acms)),//if no contests running the no standings
             array("text"=>"Messages","href"=>"/messages.php","nol"=>false)
            ); 
$w=floor(100/(count($hrefs)+4));

writeln("<table width=100% class=hrefs cellspacing=0>");
writeln("<tr>");
foreach($hrefs as $h){
  writeln("<td align=center width=$w% class=href>");
  if ($h["text"]==$page)
     write("<b>");
  else if (!($h["nol"] or $logged))
       write("<font class=disabled>");
  else
     write("<a href=\"$h[href]\">");
  write($lang[$h["text"]]);
  if ($h["text"]==$page)
     write("</b>");
  else if (!($h["nol"] or $logged))
       write("</font>");
  else
     write("</a>");
  writeln("");
  writeln("</td>");
}
writeln("<td class=login width=\"".(3*$w)."%\" align=center>");
if (!$logged){
   write("$lang[NotLoggedIn]");
   if (isset($acms)) write(" [<a href=/login.php>$lang[LogIn]</a>] [<a href=/change_contest.php>$lang[ChangeContest]</a>]");
   writeln("");
}else
   writeln(sprintf($lang["LoggedAsSbToSth"],"<b>$_SESSION[login]</b>","<b>$acms[title]</b>")." [<a href=/logout.php>$lang[LogOut]</a>]");
writeln("</td><td class=lang width=* align=center>");
write("<font size=-1>Language: ");
foreach ($av_language as $li=>$ln){
        write("<a href=/index.php?newlang=$li>$ln</a>&nbsp;");
}
writeln("</td>");
writeln("</tr>");
writeln("</table>");

writeln("<table width=100% class=main><tr><td>");
write("\n<!--  Main start-->\n\n");
}

function endije(){
global $mon,$mlver,$lang;
write("\n<!--  Main end  -->\n\n");
writeln("</td></tr></table>");
writeln("<div class=sub>");

writeln(sprintf($lang["ThisIs..."],$mlver,$mon["ije-version"],"<a href=\"http://$_SERVER[SERVER_NAME]:$_SERVER[SERVER_PORT]\">http://$_SERVER[SERVER_NAME]:$_SERVER[SERVER_PORT]</a>"));

write(sprintf($lang["PageGeneratedAtTime"],date("H:i:s, D j.m.Y"))); 

writeln("</body>");
writeln("</html>");
}

function check_login(){
global $logged,$PHPSESSID,$acms,$lang;
$logged=false;
if (!isset($_SESSION["login"])){
   return;
}
if (!isset($acms["parties"][$_SESSION["login"]])){
   unset($_SESSION["login"]);
   unset($_SESSION["pwd"]);
   startije($lang["LoginError"],"/main.css","Login");
   writeln("<h1>$lang[Error]</h1>");
   writeln("$lang[UnknownTeamName]. ".sprintf($lang["TryToDo"],"<a href=/login.php>$lang[relogin]</a>"));
   endije();
   die();
}
if ($acms["parties"][$_SESSION["login"]]["password"]<>$_SESSION["pwd"]){
   unset($_SESSION["login"]);
   unset($_SESSION["pwd"]);
   startije($lang["LoginError"],"/main.css","Login");
   writeln("<h1>$lang[Error]</h1>");
   writeln("$lang[WrongLoginPassword]. ".sprintf($lang["TryToDo"],"<a href=/login.php>$lang[relogin]</a>"));
   endije();
   die();
}
$logged=true;
}

function req_login(){
global $lang;
if (!isset($_SESSION["login"])){
   startije("Login required","/main.css","Login required");
   writeln("<h1>$lang[Error]</h1>");
   writeln(sprintf($lang["SthRequiredToAccess..."],"<a href=\"/login.php\">$lang[LoginForReq]</a>"));
   endije();
   die();
}
}

function init_language(){
global $av_language,$mlcfg;
$deflang='';
$langlist=glob("lang_*.php");
foreach ($langlist as $lf){
        include($lf);
        $ln=substr($lf,5,-4);
        $av_language[$ln]=$lang["name"];        
        if ($deflang=='')
           $deflang=$ln;
}
if (count($av_language)==0)
   die("Can't fing any language");
if (!isset($_SESSION["lang"]))
   $_SESSION["lang"]=$deflang;
if (isset($_REQUEST["newlang"]))
   $_SESSION["lang"]=$_REQUEST["newlang"];
if (!isset($av_language[$_SESSION["lang"]]))
   $_SESSION["lang"]=$deflang;
}

?>