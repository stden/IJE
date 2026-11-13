<?
/* This file is part of IJE: the Integrated Judging Environment system 
   (C) Kalinin Petr 2002-2008
   $Id: submit.php 202 2008-04-19 11:24:40Z *KAP* $ */

include_once("ije.php");

req_login();

$error=false;
$proberror="";
$langerror="";
$texterror="";
if ($_SERVER["REQUEST_METHOD"]=="POST"){
  $prob=$_POST["prob"];
  $language=$_POST["language"];
  $text=$_POST["text"];
  $fname=$_POST["fname"];
  if (($prob=="_no")or(!isset($acms["problems"][$prob]))
        or(isset($acms["problems"][$prob]["hidden"])and $acms["problems"][$prob]["hidden"])) {
     $error=true;
     $proberror=$lang["SelectTheProblemFirst"];
  }
  if (($language=="_no")or(!isset($cfg["languages"][$language]))){
     $error=true;
     $langerror=$lang["SelectTheLanguageFirst"];
  }
  if (!$error){
     $logf=fopen("submit_log.txt","a");
     fprintf($logf,"%s   %s:%s:%s:\n",date("H:i:s, j.m.Y"),$_SERVER["REMOTE_ADDR"],$_SESSION["login"],$prob,$lang);
     fclose($logf);
     startije("$lang[Submit]: $acms[title]","/main.css","Submit results");
     //The following text was translated from Pascal
     gettaskinfo($prob,$nd,$np);
     $fnew=subs($cfg["solutions-format"],$_SESSION["login"],$nd,$np);
     $fpath=$mlcfg["ije-dir"].$cfg["acm-solutions-path"].$fnew.".".$language;
     if ($text<>""){
        $f=fopen($fpath,"w");
        fputs($f,$text);
        fclose($f);
        $logf=fopen("submit_log.txt","a");
        fprintf($logf,"    Text recieved\n");
        fclose($logf);
     } else {
       if (!move_uploaded_file($_FILES["file"]['tmp_name'],$fpath)){
          $logf=fopen("submit_log.txt","a");
          fprintf($logf,"    =>FL: Error upload file\n");
          fclose($logf);
          writeln($lang["ErrorUploadedFile..."]);
          endije();
          die();
       }
       $logf=fopen("submit_log.txt","a");
       fprintf($logf,"    File: '%s'('%s') -> '%s'\n",$_FILES["file"]["name"],$_REQUEST["fname"],$_FILES["file"]["tmp_name"]);
       fclose($logf);
     }
     $reppath=$mlcfg["ije-dir"].$acmcfg["reports-path"].$fnew.".xml";
     $t=time();
     while (!file_exists($reppath)and(time()<$t+5))
           usleep(50000);//¬ªá
     if (!file_exists($reppath)){
        unlink($fpath);
        $logf=fopen("submit_log.txt","a");
        fprintf($logf,"    =>FL: No response from IJE\n");
        fclose($logf);
        writeln("<h1>$lang[SubmitFailed]</h1>");
        writeln($lang["NoResponseFromIJE"]);
        endije();
        die();
     }
     loadxml($reppath,$aa);
     foreach ($aa as $t);
     $aa=$t;
     $logf=fopen("submit_log.txt","a");
     fprintf($logf,"    =>OK: id=%s\n",$aa["id"]);
     fclose($logf);
     writeln("<h1>$lang[SubmitSuccessfull]</h1>");
     writeln("{$lang["YourSolutionHasBeen..."]}<P>");
     writeln(sprintf($lang["YouCanSee..."],"<a href=/messages.php>$lang[Messages]</a>"));
     unlink($reppath);
     endije();
     die();
     //end
  }
} 
startije("$lang[Submit]: $acms[title]","/main.css","Submit");

writeln("<h1>$lang[Submit]</h1>");

if ($error)
   writeln("<font class=att>$lang[AnErrorOccured]:</font>");

writeln("<form enctype=\"multipart/form-data\" method=POST action=/submit.php>");
writeln("<table>");

writeln("<tr>");
writeln("<td>$lang[Problem]:</td>");
writeln("</td><td>");
writeln("<select name=prob>");
writeln("<option value=_no selected>$lang[SelectTheProblem]</option>");
foreach($acms["problems"] as $pid=>$prob) if ((!isset($prob["hidden"]))or(!$prob["hidden"]))
  writeln("<option value=\"$pid\">$pid: $prob[name]</option>");
writeln("</selected>");
writeln("</td>");
writeln("<td><font class=att>$proberror</font></td>");
writeln("</tr>");

writeln("<tr>");
writeln("<td>$lang[Language]:</td>");
writeln("</td><td>");
writeln("<select name=language>");
writeln("<option value=_no selected>$lang[SelectTheLanguage]</option>");
foreach($cfg["languages"] as $id=>$language)
  writeln("<option value=\"$id\">$id: $language[name]</option>");
writeln("</selected>");
writeln("</td>");
writeln("<td><font class=att>$langerror</font></td>");
writeln("</tr>");
writeln("</table>");

writeln("$lang[ProgramText]:<br>");
writeln("<textarea name=text cols=80 rows=15 wrap=off></textarea>");
writeln("<br><b>$lang[OR]</b></br>");
writeln("$lang[FileWithSolution]:");
writeln("<input name=file id=fileinput type=file><BR>");
writeln("<input name=fname type=hidden value=\"\" id=fnameinput>");
writeln("<P/><input type=submit value=\"Submit!\" onclick=\"fnameinput.value=fileinput.value;\">");
writeln("</form>");

endije();

?>