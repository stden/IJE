<?
/* This file is part of IJE: the Integrated Judging Environment system 
   (C) Kalinin Petr 2002-2008
   $Id: logout.php 202 2008-04-19 11:24:40Z *KAP* $ */

include_once("ije.php");

unset($_SESSION["login"]);
unset($_SESSION["password"]);
check_login();

startije("$lang[LogOut]: $acms[title]","/main.css","Logout");

writeln("<h1>$lang[LogoutSuccessfull]</h1>");

endije();

?>