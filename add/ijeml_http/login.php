<?

include_once("ije.php");

$error=false;
$loginerr='';
$pwderr='';
$contesterr='';
if ($_SERVER["REQUEST_METHOD"]=="POST"){
   $_SESSION["login"]=$_POST["login"];
   $_SESSION["pwd"]=$_POST["pwd"];
   check_login();
   startije("Login: $acms[title]","/main.css","Login");
   writeln("<h1>$lang[LoginSuccessfull]</h1>");
   endije();
   die();
}

   
startije("$lang[LogIn]: $acms[title]","/main.css","Login");

if (!isset($login))
   $login='';
   
writeln("<table><tr>");
writeln("<td class=loginimg><img src=/login.bmp></td>");
writeln("<td>");
writeln("<h1>$lang[LogIn]</h1>");
if ($error){
   writeln("<font class=att>$lang[LoginRejected]:</font>");
}
writeln("<form action=/login.php method=POST>");
writeln("<table>");
writeln("<tr><td>$lang[Login]:</td><td><input type=text length=10 name=login value=$login></td><td><font class=att>$loginerr</font></td></tr>");
writeln("<tr><td>$lang[Password]:</td><td><input type=password length=10 name=pwd></td><td><font class=att>$pwderr</font></td></tr>");
writeln("<tr><td>$lang[Contest]:</td><td>");
/*writeln("<select name=\"contest\">");
foreach ($acmcfg as $i=>$v) if (is_array($v)){
    loadxml($mlcfg["ije-dir"].$v["settings"],$tmp_settings);
    $tmp_settings=reset($tmp_settings);
    $sel=($i==$_SESSION["contest"])?' selected="selected"':'';
    write("<option value=\"$i\"$sel>{$tmp_settings['title']}</option>");
}
writeln("</select>");*/                     
writeln("<b>$acms[title]</b> [<a href=\"/change_contest.php\">$lang[ChangeContest]</a>]");
writeln("</td><td><font class=att>$contesterr</font></td></tr>");
writeln("</table>");
writeln("<input type=submit value=OK>");
writeln("</form>");
writeln("</td>");
writeln("</tr></table>");
endije();

?>