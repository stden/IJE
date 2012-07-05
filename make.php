<?
set_magic_quotes_runtime(0);
$f=file("Addbuild.cfg");
foreach ($f as $s){
  exec($s,$outp,$c);
  print(">$s\n");
  foreach ($outp as $o)
    print("$o\n");
  print("\n");
  if ($c<>0)
     die("Error!");
}
$params='';
$list=array();
foreach ($argv as $v) {
  if (in_array($v,array("tc","server","ui")))
     $list[]=$v;
  if ($v=="release") $params="-b -drelease";
}
if ($list==array())
   $list=array("tc","server","ui");
foreach ($list as $p){
  print($p);
  if ($p=="ui") $p="ui_c";
  print(">dcc32 $params ije_$p.dpr\n");
  $outp=array();
  exec("dcc32 $params ije_$p.dpr",$outp,$c);
  foreach ($outp as $o)
    print("$o\n");
  print("\n");
  if ($c<>0)
     die("Error!");
}
print("Ok!");
?>
