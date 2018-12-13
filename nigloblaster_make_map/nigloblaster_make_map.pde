/*
  Rouen, atelier d'Echelle Inconnue
  Le 8 juillet 2015
  développé sur : processing 2.1.2 / debian / (zibu) ordinateur lenovo X200
  
  basé sur sk_20150708_zones_gps_014_android
      
  Système de cartographie pour le nigloblaster 2
    Chargement de deux fichiers .csv :
      - nigloblaster2.csv (infos sur les zones : id,latitude,longitude,titre,rayon,type,actif)
         - (int)    id
         - (float)  latitude
         - (float)  longitude
         - (String) titre
         - (float)  rayon
         - (int)    type (1:vidéo, 2:boucle vidéo, 3:son)
         - (int)    actif
      - nigloblaster2_fichiers.csv (id zone,fichier media)
         - (int)    id
         - (String) fichier_media
    Création d'une carte d'après un fond de carte 
      !! Fond de carte créé grâce à http://www.gpsvisualizer.com/kml_overlay

  Clavier
    touche 'S' : enregistrer la carte annotée avec les zones en haute définition
  
  ---------------------------------------------------------------------------------
  version 001 : avec le fond de carte original
  version 002 : avec lenouveau fond de carte, hlat, hlon, blat, blon changent!

*/

// fonctions de dates pour l'export d'images
import java.util.Date;
import java.text.SimpleDateFormat;
import java.text.DateFormat;
// variables utilisées pour les fonctions communes
String SKETCH_NAME = getClass().getSimpleName();

Table zones_gps;                      // contenu du fichier .kml/.csv dans une table
Table fichiers;                       // contenu du fichier média .csv dans une table (.mp3, .mp4)
ArrayList<GeoZone> gzones;            // liste de toutes les zones avec leurs paramètres
// pour une largeur de carte de 4000px : gzxoffset = 24, gzyoffset = -150
// pour une largeur de carte de 2000px : gzxoffset = 12, gzyoffset = -75
int gzxoffset =  12;       //  12      // offsets nécessaires pour faire coordonner le fond de carte aux données géo
int gzyoffset = -75;      // -75      // ---- "" -------------------------------------------------(mais pourquoi ?)

Carte niglomap;
float rapport_echelle = 0.125;        // rapport d'échelle entre la carte et l'affichage 



void setup() {
  size(1000, 600);
  frameRate(25);
  background(255);
  
  // créer la carte *************************************************************
  niglomap = new Carte();
  
  // peupler les zones **********************************************************
  zones_gps = loadTable("nigloblaster2.csv", "header");
  fichiers  = loadTable("nigloblaster2_fichiers.csv");
  gzones    = new ArrayList<GeoZone>();
  lireDonnees(zones_gps);
  
  println(zones_gps.getRowCount());
  println(fichiers.getRowCount());
  println(gzones.size());
  
  for (TableRow row : fichiers.rows()) {
    println(row.getInt(0) + "       " + row.getString(1));
  }
  
  for (int i = 0; i < gzones.size(); i++) { 
    gzones.get(i).fixerOffset(gzxoffset, gzyoffset);
    gzones.get(i).adapterCoordonnees(niglomap.hlat, niglomap.hlon, 
                                     niglomap.blat, niglomap.blon, 
                                     niglomap.fond_de_carte.width, niglomap.fond_de_carte.height, 
                                     niglomap.pxtomh, niglomap.pxtomw);
    gzones.get(i).definirFichierMedia(fichiers.getString(gzones.get(i).id, 1));
  }
  
  
  // ajouter les zones à la carte
  niglomap.ajouterZones(gzones);

}




void draw() {
  image(niglomap.getCarte(), 0, 0);
  noLoop();
}


void keyPressed() {

  if (key == 'S') { // enregistrer la carte avec les zones en haute définition
    niglomap.saveCarteAnnotee();
  }
}


