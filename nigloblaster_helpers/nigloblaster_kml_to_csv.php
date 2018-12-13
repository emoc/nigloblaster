<?php

/*
	Quimper, allée Dour Ru, 11 juin 2015
	Charger un fichier .KML pour Nigloblaster 2 (des balises particulières sont insérées dans le champ 'description')
	et le transformer en fichier .CSV
	
	(d'après kml to mobio, 5 septembre 2012)
*/

error_reporting(E_ALL ^ E_NOTICE);

function ajouter_blancs($str, $ln) {
  $esp = "                             ";
  $str = substr($esp, 0, $ln) . $str;
  return $str;
}

function ajouter_zeros($str, $ln) {
  $esp = "000000000000000000000000000000";
  $str = substr($esp, 0, $ln) . $str;
  return $str;
}

function ecrire_fichier($fichier, $contenu) {
	$handle = fopen($fichier, "w+");
	fwrite($handle, $contenu);
	fclose($handle);
}



// *******************************************************************************

$FICHIER = "nigloblaster2.csv";
echo "<h1>Nigloblaster2 .KML to .CSV</h1>"; 


$MODE = $_GET["mode"];
if ($MODE == '') $MODE = 'form';



$OUTPUT = '';	
$OUTPUT .=  "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">";
$OUTPUT .=  "

<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"fr-fr\" lang=\"fr-fr\">

<head>
<meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\" />
<title>Nigloblaster 2.0 KML to CSV</title>
<style type=\"text/css\">
body {
	font-size: 12pt;
	font-family: arial;
}
pre {
	font-size: 9pt;
	font-family: courier;
	color:blue;
}
</style>

</head>

<body>";



if ($MODE == 'form') {
	echo $OUTPUT;

	echo "<form method=\"post\" enctype=\"multipart/form-data\" action=\"nigloblaster2_kml_to_csv.php?mode=action\">";
	echo "<p>";
	echo "Choisir le fichier à transformer : ";
	echo "<input type=\"file\" name=\"fichier\" size=\"30\"><br /><br />";
	echo "Rayon par défaut des zones GPS : ";
	echo "<select name='rayondef' size='1'>
			<option value='6'>6</option>
			<option value='8'>8</option>
			<option value='10'>10</option>
			<option value='12'>12</option>
			<option value='15' selected>15</option>
			<option value='20'>20</option>
			<option value='25'>25</option>
			<option value='30'>30</option>
			<option value='40'>40</option>
			<option value='50'>50</option>
			<option value='60'>60</option>
			<option value='80'>80</option>
			<option value='100'>100</option>
		  </select>\n";
	echo "<input type=\"submit\" name=\"upload\" value=\"Uploader\">";
	echo "</p>";
	echo "</form>";

}

if ($MODE == 'action') {

	if( isset($_POST['upload']) ) {// si formulaire soumis

		$tmp_file = $_FILES['fichier']['tmp_name'];
		if( !is_uploaded_file($tmp_file) ) {
		  exit("Le fichier est introuvable<br /><br /><a href='./nigloblaster2_kml_to_csv.php'>traiter un autre fichier</a>");
		}

		$XML = $tmp_file;
	}

	$rayon_defaut = $_POST["rayondef"];

	$DOM = new DOMDocument();
	if (!$DOM->load($XML)) {
		die("Impossible de charger le fichier XML<br /><br /><a href='./nigloblaster2_kml_to_csv.php'>traiter un autre fichier</a>");
	} else {
		$OUTPUT .=  "(OK : fichier chargé)";
	}


	$EVENTS = array();
    $ITEM = array();

	$itemList = $DOM->getElementsByTagName('Placemark');
	$item_number = 1;

	foreach ($itemList as $item) {

		$name = $item->getElementsByTagName('name');
		if ($name->length > 0) {
			$ITEM["$item_number"]["name"] = $name->item(0)->nodeValue;
		} else {
			$ITEM["$item_number"]["name"] = '';
		}

		$description = $item->getElementsByTagName('description');
		if ($description->length > 0) {
			$ITEM["$item_number"]["description"] = $description->item(0)->nodeValue;
		} else {
			$ITEM["$item_number"]["description"] = '';
		}

		$coordinates = $item->getElementsByTagName('coordinates');
		if ($coordinates->length > 0) {
			$ITEM["$item_number"]["coordinates"] = $coordinates->item(0)->nodeValue;
		} else {
			$ITEM["$item_number"]["coordinates"] = '';
		}

		if (strlen($ITEM["$item_number"]["coordinates"]) > 0) {
			$coord = explode(",", $ITEM["$item_number"]["coordinates"]);
			
			$ITEM["$item_number"]["lonraw"] = $coord[0]; //round($coord[0], 7);
			$ITEM["$item_number"]["latraw"] = $coord[1]; //round($coord[1], 7);
			
			//$ITEM["$item_number"]["lon"] = round($coord[0] * 100000);
			//$ITEM["$item_number"]["lat"] = round($coord[1] * 100000);
		}

		$item_number ++;
	
	}



	$NB = count($ITEM);
	//$zonelon = '';
	//$zonelat = '';
	//$zonesize = '';
	//$ttlon = '';
	//$ttlat = '';
	//$ttsize = '';
	

	//$ARDUINO_STRING = '';
	$c = 1;
	//$comment = "/*\r\n";
	$chaine_csv  = "id,latitude,longitude,titre,rayon,type,actif\n";


	foreach ($ITEM as $item_number => $ITEM_CONTENT) {
			
		$name = $ITEM_CONTENT["name"];
		$description = $ITEM_CONTENT["description"];
		$lon = $ITEM_CONTENT["lon"];
		$lat = $ITEM_CONTENT["lat"];
		
		if ($c > 1) {
		  $ttlon .= ', ';
		  $ttlat .= ', ';
		  $ttsize .= ', ';
		}

		
					
		if ($description != "") {
			$dd = preg_replace("/[\r\n]+/","|",$description);
			$tags = explode("|", $dd);
			
			$chaine_csv . "," . $titre;
			
			$ii = $tags[0];
			$rr = $tags[1];
			$tt = $tags[2];
			$aa = $tags[3];
			
			$id = substr($ii, stripos($ii, ":") + 1);
			
			$rayon = substr($rr, stripos($rr, ":") + 1);
				
			$type = substr($tt, stripos($tt, ":") + 1);
				
			$actif = substr($aa, stripos($aa, ":") + 1);		
		}
		
		//$chaine_csv .= ajouter_blancs($id, 3 - strlen($id)) . ",";
		$chaine_csv .= $id . ",";
		$chaine_csv .= ""
					. ajouter_blancs($ITEM_CONTENT["latraw"], 20 - strlen($ITEM_CONTENT["latraw"]))
					. ", " 
					. ajouter_blancs($ITEM_CONTENT["lonraw"], 20 - strlen($ITEM_CONTENT["lonraw"]))
					. "," . $name;
		$chaine_csv .= "," . $rayon;
		$chaine_csv .= "," . $type;
		$chaine_csv .= "," . $actif;
		
		$chaine_csv .= "\n";
		
		$c ++;
	}
					 
					 
	echo $OUTPUT;
	
	
	echo "<br /><br /><hr /><div style='background-color:yellow; font-weight:bold;'>Fichier .CSV ci-dessous, enregistré sous le nom $FICHIER ou <a href='./nigloblaster2_kml_to_csv.php'>traiter un nouveau fichier</a><br /><br />";
	echo "</div><hr />";	
	echo "<br /><br /><br /><br />";
	  
	echo "<pre>" . $chaine_csv . "</pre>";
	echo "<br /><br /><br /><br />";
	 
	ecrire_fichier($FICHIER, $chaine_csv);

}


echo "</body>\n</html>";
?>
