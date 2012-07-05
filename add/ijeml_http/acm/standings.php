<?
/* This file is part of IJE: the Integrated Judging Environment system 
   (C) Kalinin Petr 2002-2008
   $Id: standings.php 202 2008-04-19 11:24:40Z *KAP* $ */
$qacm["canshowtime"]=true;

function WriteTableHeaders(){
global $mon,$login,$lang;
  
  $SelfSolved=array();
  foreach($mon["parties"] as $p=>$pp)
      if ($p==$login)
         foreach($pp as $probid=>$prob) if (is_array($prob))
           if ($prob["solved"]>0)
              $SelfSolved[$probid]=1;
  
  foreach($mon["problems"] as $id=>$p){
      write('  <TD class=ProblemHead>');
      if (isset($SelfSolved[$id]))
         write("<img alt=\"$id\" src=\"balloon.php?id=$id\">");
      else write($id);
      writeln('</TD>');
  }
  writeln('  <td class="SolvedHead">=</td>');
  writeln('  <td class="PenaltyHead">'.$lang["Penalty"].'</td>');
  writeln('  <td class="PlaceHead">'.$lang["Pl"].'</td>');
}        

function FormSortedTable(&$table){
global $mon,$acms;
  $table=array();
  $nn=-1;
  foreach($mon["parties"] as $i=>$p){
      $nn++;
      if (isset($acms["parties"][$i]["hidden"]) and $acms["parties"][$i]["hidden"])
         $table[$nn]["hidden"]=1;
      $table[$nn]["id"]=$i;
      $table[$nn]["name"]=$p["name"];
      foreach($mon["problems"] as $prob=>$tmp){
          $table[$nn][$prob]["solved"]=$p[$prob]["solved"];
          $table[$nn][$prob]["time"]=$p[$prob]["time"];
      } 
      $table[$nn]["solved"]=$p["solved"];
      $table[$nn]["time"]=$p["time"];
  }
  
  function cmp($a,$b){
  if ($a["solved"]<>$b["solved"])
     return $b["solved"]-$a["solved"];
  else return $a["time"]-$b["time"];
  }
  
  usort($table,"cmp");
  
  $n1=0;$n2=-1;$pl=1;$rpl=1;
  foreach ($table as $nn=>$p){
      if (isset($prev)) {
         if ($prev["solved"]<>$p["solved"])  {
            if (!isset($p["hidden"]))
               $n1++;
            $pl=$rpl;
         } else
         if ($prev["time"]<>$p["time"]){
            $pl=$rpl;
         }
      }
      if (!isset($p["hidden"])){
         $rpl++;
         $n2++;
         $n1=$n1&1;
         $n2=$n2&1;
         $prev=$p;
      }
      $table[$nn]["place"]=$pl;
      $table[$nn]["n1"]=$n1;
      $table[$nn]["n2"]=$n2;
  }
}

function TeamClass($p){
return 'team'.$p["n1"].$p["n2"];
}

function WriteAddInfo($p){
global $mon;
 foreach($mon["problems"] as $prob=>$tmp){
     $ps=$p[$prob]["solved"];
     $pt=$p[$prob]["time"];
     write('  <TD class=');
     if ($ps==0)
        write('NoSubmissions>.');
     else if ($ps<0) 
          write('Rejected>'.$ps);
     else {
          write('Accepted>+');
          if ($ps<>1)
             write($ps-1);
          if ($_SESSION["showtime"])
             write('<BR><font size=1>'.$pt.'</font>');
     }
     writeln('</TD>');
 }
 writeln('  <td class="Solved">'.$p["solved"].'</td>');
 writeln('  <td class="Penalty">'.$p["time"].'</td>');
 writeln('  <td class="Place">'.$p["place"].'</td>');
}
?>