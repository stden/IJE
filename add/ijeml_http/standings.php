<?
/* This file is part of IJE: the Integrated Judging Environment system 
   (C) Kalinin Petr 2002-2008
   $Id: standings.php 202 2008-04-19 11:24:40Z *KAP* $ */

include_once("ije.php");
include_once($qdll."/standings.php");

if (!isset($_SESSION["showtime"]))
   $_SESSION["showtime"]=0;
if (isset($_GET["showtime"]))
   $_SESSION["showtime"]=$_GET["showtime"];
   
if (isset($_SESSION["login"]))
   $login=$_SESSION["login"];
else $login="";

startije("$lang[Standings]: $acms[title]",array("/main.css",$qdll."/standings.css","/standings.css"),"Standings");

writeln("<h1>$lang[CurrentStandings]</h1>");
writeln("<div class=timeq>");
if ($qacm["canshowtime"]){
  if ($_SESSION["showtime"])
     writeln('<a href="standings.php?showtime=0">'.$lang["HideSuccessTimes"].'</a>');
  else
     writeln('<a href="standings.php?showtime=1">'.$lang["ShowSuccessTimes"].'</a>');
}
writeln("</div>");

//The following text was translated from Pascal

writeln('<TABLE width="100%" cellspacing="0" cellpadding="0" class=monitor>');
writeln('<TR class=head>');
writeln("  <TD class=IdHead>$lang[Id]</TD>");
writeln("  <TD class=PartyHead>$lang[Party]</TD>");
WriteTableHeaders();
writeln('</TR>');

FormSortedTable($table);

foreach($table as $p){
    if (isset($p["hidden"]) and ($p["hidden"]) and ($p["id"]<>$login))
       continue;
    write('<TR class=');
    if ($p["id"]==$login)
       write('my');
    else write(TeamClass($p));
    writeln('>');
    writeln('  <TD class=Id>'.$p["id"].'</TD>');
    writeln('  <TD class=Party>'.$p["name"].'</TD>');
    WriteAddInfo($p);
    writeln('</TR>');
}
writeln('</table>');

//end of translated text

endije();

?>