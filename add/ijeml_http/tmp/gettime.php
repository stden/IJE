<?
import_request_variables('cpg');
if (!isset($hour)) {$t=time();}
else $t=mktime($hour,$minute,$second,$month,$day,$year);
print("<PRE>");
print("$t is ".date("G:i:s d.m.Y",$t));


?>