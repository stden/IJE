<?
/* (C) Kalinin Petr 2004-2006 */
/* $Id: xml.php 61 2006-05-07 17:15:25Z *KAP* $ */
$xml_data=array();

function startElement($parser, $name, $attrs) {
    if (isset($attrs["id"]) and $GLOBALS["xml_data"]["useid"])
       $name=$attrs["id"];
       
    $name0=$name;
    $nn=1;
    while (isset($GLOBALS["xml_data"]["cur"][$name])){
          $nn++;
          $name=$name0.$nn;
    }

    $GLOBALS["xml_data"]["cur"][$name]=array();
    $GLOBALS["xml_data"]["sti"]++;
    $GLOBALS["xml_data"]["st"][$GLOBALS["xml_data"]["sti"]]=&$GLOBALS["xml_data"]["cur"];
    $GLOBALS["xml_data"]["cur"]=&$GLOBALS["xml_data"]["cur"][$name];
    foreach ($attrs as $n=>$v) 
      $GLOBALS["xml_data"]["cur"][$n]=iconv("UTF-8","Windows-1251",$v);
}

function endElement($parser, $name) {
    $GLOBALS["xml_data"]["cur"]=&$GLOBALS["xml_data"]["st"][$GLOBALS["xml_data"]["sti"]];
    $GLOBALS["xml_data"]["sti"]--;
}

function loadxml($file,&$a,$enc='',$useid=true){
global $xml_data;

$a=array();

$xml_data["depth"] = array();
$xml_data["st"]=array();
$xml_data["sti"]=0;
$xml_data["cur"]=&$a;
$xml_data["useid"]=$useid;

$xml_parser = xml_parser_create("UTF-8");
xml_parser_set_option($xml_parser,XML_OPTION_CASE_FOLDING,false);
xml_set_element_handler($xml_parser, "startElement", "endElement");
$data=file_get_contents($file);
if ($enc<>''){
   $data="<?xml version=\"1.0\" encoding=\"$enc\"?>".$data;
}
if (!xml_parse($xml_parser, $data, true)) {
   die(sprintf("XML error %d while parsing file %s: %s at line %d at position %d",
                    xml_get_error_code($xml_parser),     
                    $file,
                    xml_error_string(xml_get_error_code($xml_parser)),
                    xml_get_current_line_number($xml_parser),
                    xml_get_current_column_number($xml_parser)));
}
xml_parser_free($xml_parser);
$xml_data=array();
}

?>
