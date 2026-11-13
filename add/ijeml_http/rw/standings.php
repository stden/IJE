<?
/* This file is part of IJE: the Integrated Judging Environment system 
   (C) Kalinin Petr 2002-2008
   $Id: standings.php 202 2008-04-19 11:24:40Z *KAP* $ */
$qacm["canshowtime"]=false;

function WriteTableHeaders(){
global $mon,$login,$acms,$lang;
  
  $SelfSolved=array();
  foreach($mon["parties"] as $p=>$pp)
      if ($p==$login)
         foreach($pp as $probid=>$prob) if (is_array($prob))
           if (ProbSolved($prob))
              $SelfSolved[$probid]=1;
  
  foreach($mon["problems"] as $id=>$p){
      write('  <TD class=ProblemHead>');
      if (isset($SelfSolved[$id]))
         write("<img alt=\"$id\" src=\"balloon.php?id=$id&noletter=1\"><br>$id");
      else write($id);
      writeln('</TD>');
  }
  writeln('  <td class="PointsHead">'.$lang['Pts'].'</td>');
  writeln('  <td class="FullHead">'.$lang['Full'].'</td>');
  writeln('  <td class="PlaceHead">'.$lang['Pl'].'</td>');
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
      $table[$nn]["full"]=0;
      $table[$nn]["points"]=0;
      foreach($mon["problems"] as $prob=>$tmp){
          $table[$nn][$prob]["points"]=$p[$prob]["points"];
          $table[$nn][$prob]["attempts"]=$p[$prob]["attempts"];
          $table[$nn][$prob]["full"]=ProbSolved($p[$prob]);
          if ($table[$nn][$prob]["full"])
             $table[$nn]["full"]++;
          $table[$nn]["points"]+=$p[$prob]["points"];
      } 
  }
  
  function cmp($a,$b){
    return $b["points"]-$a["points"];
  }
  
  usort($table,"cmp");
  
  $n=0;$pl=1;$rpl=1;
  foreach ($table as $nn=>$p){
      if ($nn>0) {
         $prev=$table[$nn-1];
         if ($prev["points"]<>$p["points"])  {
            $pl=$rpl;
         }       
      }
      $rpl++;
      if (!isset($p["hidden"])) {
         $n++;
         $n=$n&1;
      }
      $table[$nn]["place"]=$pl;
      $table[$nn]["n"]=$n;
  }
}

function TeamClass($p){
return 'team'.$p["n"];
}

function WriteAddInfo($p){
global $mon;
 foreach($mon["problems"] as $prob=>$tmp){
     $pts=$p[$prob]["points"];
     write('  <TD class=');
     if ($p[$prob]["full"])
        write("ProbFull>$pts");
     else if ($p[$prob]["attempts"]<>0)
          write("ProbNotFull>$pts");
     else write("No>&nbsp;");
     write("<br>");
     if ($p[$prob]["attempts"]<>0){
        if ($p[$prob]["attempts"]<0)
           write($p[$prob]["attempts"]);
        else {
          write("+");
          if ($p["$prob"]["attempts"]>1)
             write($p[$prob]["attempts"]-1);
        }
     } else write(".");
     writeln('</TD>');
 }
 writeln('  <td class="Points">'.$p["points"].'</td>');
 writeln('  <td class="Full">'.$p["full"].'</td>');
 writeln('  <td class="Place">'.$p["place"].'</td>');
}
?>