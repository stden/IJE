<?
/* This file is part of IJE: the Integrated Judging Environment system 
   (C) Kalinin Petr 2002-2008
   $Id: balloons.php 202 2008-04-19 11:24:40Z *KAP* $ */
?>
<body bgcolor=#99ccdd>
<?
for ($i=0;$i<=3;$i++){
    print("<table>");
    for ($j=0;$j<=3;$j++){
        print("<tr>");
        for ($k=0;$k<=3;$k++){
            $ii=$i*16+$j*4+$k;
            print("<td><img src=\"/balloon.php?id=02.A&col0=$ii\">".$ii."</td>");
        }
        print("</tr>");
    }
    print("</table>");
}
?>
</body>
