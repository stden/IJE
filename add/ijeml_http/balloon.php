<?
/* This file is part of IJE: the Integrated Judging Environment system 
   (C) Kalinin Petr 2002-2008
   $Id: balloon.php 202 2008-04-19 11:24:40Z *KAP* $ */

include_once("ije.php");

$id=$_GET["id"];

$im=imagecreatefrompng("balloon.png");

$sx=imagesx($im);
$sy=imagesy($im);

$white=imagecolorallocate($im,255,255,255);
imagecolortransparent($im,$white);

if (!isset($col0)){
   $col0=0;
   for ($i=strlen($id)-1;$i>=0;$i--){
       $col0=$col0*37+ord($id[$i]);
   }
}

$badcol=array(0,21,22,23,42,43,46,63);
while(in_array($col0 & 63,$badcol))
   $col0+=7;
   
$col0=$col0 & 63;

$r00=($col0 & 3)/4;
$g00=(($col0>>2)&3)/4;
$b00=($col0>>4)/4;
$r0=$r00;
$g0=$g00;
$b0=$b00;

$black=imagecolorallocate($im,0,0,0);
for ($i=0;$i<$sx;$i++)
    for ($j=0;$j<$sy;$j++){
        $col=imagecolorat($im,$i,$j);
        $r = ($col>> 16) & 0xFF;
        $g = ($col>> 8) & 0xFF;
        $b = $col& 0xFF;
        if (($r>$g)and($r>$b)){
           $r=255-$b;
           $color=imagecolorallocate($im,255-$r0*$r,255-$b0*$r,255-$g0*$r);
           imagesetpixel($im,$i,$j,$color);
        }
    }
    
gettaskinfo($id,$d,$p);

if ((!isset($noletter))or(!$noletter))
   imagestring($im,5,0,19,$p,$black);

//imagegif($im);
header("Content-type: image/png");

imagepng($im);
imagedestroy($im);

?>