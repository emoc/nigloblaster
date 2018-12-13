/*
  Rouen, atelier d'Echelle Inconnue
  Le 29 juillet 2015
  développé sur : processing 2.1.2 / debian / (zibu) ordinateur lenovo X200
  pour  : processing 2.1.2 / Galaxy Tab 4 10.1 / 1280x800 / android kitkat 4.4.2
  libraries utilisées : apwidgets, ketai
  dernière version laptop : 008 / première version android : 009
  
  Permissions android à cocher :
    ACCESS_COARSE_LOCATION
    ACCESS_FINE_LOCATION
    ACCESS_LOCATION_EXTRA_COMMANDS
    ACCESS_MOCK_LOCATION
    WRITE_EXTERNAL_STORAGE
  
  Ou sont les fichiers média ? 
    vidéos : dans {repertoire_stockage} de la carte SD externe
    sons : dans le répertoire data
    
  Système de navigation pour le nigloblaster 2
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
    Création d'une carte d'après un fond de carte (dieppe_map_2000px_nb.png)
      !! Fond de carte créé grâce à http://www.gpsvisualizer.com/kml_overlay
    Affichage d'un extrait de la carte basé sur la position géolocalisée
    Affichage de flèches de direction vers les zones proches
    Affichage des x dernières positions du trajet
    Colorisation de la fenêtre quand on est dans une zone
    
  Options
    test_mode = true, pour réaliser un trajet sans bouger!
  
  Clavier
    touche 's' : enregistrer une copie d'écran
    touche 'S' : enregistrer la carte avec les zones en haute définition
    touche ' ' : arrêter le déplacement
    
  Ketai  
   * Ketai Sensor Library for Android: http://KetaiProject.org
   * Ketai Location Features:
   * Uses GPS location data (latitude, longitude, altitude (if available)
   * Updates if location changes by 1 meter, or every 10 seconds
   * If unavailable, defaults to system provider (cell tower or WiFi network location)
  
  APWidgets
   
  
  ---------------------------------------------------------------------------------
  version 012 :
    ajout des coordonnées réelles GPS avec ketai
    nettoyage
  version 013 :
    affichage du trajet plus long
    test pour savoir si on reste dans une zone
  version 014 : affinage du placement sur la carte (redéfinition des offset)
  version 015 : remplacement du fond de carte, affinage à refaire...
  version 016 (ne fonctionne pas correctement) :
  version 017 quimper : corrections de bugs logiques
  version 017 dieppe : avec carte définitive juillet
  version 018 dieppe : 
    corrections de bug de dernière minute pour que seules les zones actives déclenchent
    les zones inactives sont quand même affichées...
    affichage de debug sur la tablette supprimé    

  ----------------------------------------------------------------------------------
  TODO : 
    004 : des ajustements manuels sont à faire en fonction du fond de carte, pourquoi ?
      -> enlever les ajustements manuels gzxoffset, gzyoffset
    008 : doublons entre mode_pause et MOVE_ON
    008 : voir classe Carte pour des améliorations qui permettent de réaliser l'application 
      avec n'importe quelle carte, lieux
    009 : problème avec le buffer de carte, trop important, essaie avec un buffer de 2000 x 1568
      -> voir si on ne peut pas agrandir l'extrait de zone ?
    009 : il manque le haut de carte, cadrage de coordonnées à refaire
    009 : classe Carte : la taille de police ne s'adapte pas au changement d'échelle
      gzxoffset et gzyoffset non plus
    011 : pourquoi la musique ne s'arrête pas quand on ferme l'appli depuis processing ?
    011 : dans les players vidéo et boucles, repertoire de stockage et défini, alors qu'il est 
      fixé à la création des objets, il faudrait l'enlever de la création
    011 : les zones vidéo ne se resettent pas (VIDEO_ON reste à true...)
    011 : boucle sonore ne s'arrête pas quand on sort de la zone (elle joue jusqu'au bout)
    011 : vérifier dans la classe Carte qu'il n'y a pas uen inversion dans pxtomh, pxtomw
    011 : ça ne sert plus à rien de garder ls possibilités de sauvegarde d'images sur la version android
    013 : fixer maxback, maxbackdist en fonction de l'échelle de la carte
      et les afficher en pixels et mètres!
    016/017 : MOVE_STOP_DEC n'est plus utilisé
    017 : les petites flèches bleues pour les signaux sonores ne servent pas à grand chose
    017 : le code des players pourrait être simplifié (pour les tests isPlaying)
    017 et + : rassembler les variables (noms de fichiers, coord. extremes, offsets en début de programme)    
*/

// fonctions de dates pour l'export d'images
import java.util.Date;
import java.text.SimpleDateFormat;
import java.text.DateFormat;
// variables utilisées pour les fonctions communes
String SKETCH_NAME = getClass().getSimpleName();

// accès au capteur GPS
import ketai.sensors.*; 
double latitude, longitude, altitude; // stockage des valeurs reçues par ketai, altitude n'est pas utilisé
//double latitude_last, longitude_last;
KetaiLocation location;
int gps_update_time = 1000;         // en millisecondes
int gps_update_distance = 1;        // en mètres

// players et stockage des fichiers média
import apwidgets.*;
String repertoire_stockage = "/storage/extSdCard/nigloblaster2ok/";
PlayerVideo pv1;
PlayerBoucleVideo pb1;
PlayerSon ps1;

// options d'application 
boolean video_small   = false;        // si true, affiche les players video en petit en bas à droite, sinon plein écran
boolean debug_console = false;        // affichages sur la console
boolean debug_display = false;         // affichages sur l'écran
boolean debug_real    = false;        // affichages de debug geoloc sur la console pour le mode réel
boolean test_mode     = false;        // pseudo-trajet sans bouger

Table zones_gps;                      // contenu du fichier .kml/.csv dans une table
Table fichiers;                       // contenu du fichier média .csv dans une table (.mp3, .mp4)
ArrayList<GeoZone> gzones;            // liste de toutes les zones avec leurs paramètres
int gzxoffset =  12;  //  12 (dieppe) 10 (quimper) // offsets nécessaires pour faire coordonner le fond de carte aux données géo
int gzyoffset = -75;  // -75 (dieppe) 80 (quimper) // ---- "" -------------------------------------------------(mais pourquoi ?)

Carte niglomap;
float rapport_echelle = 0.125;        // rapport d'échelle entre la carte et l'affichage 

PImage carte_extrait;                 // l'extrait de carte à afficher

// affichage des éléments d'interface (placement varie selon qu'on eset en android ou non)
int carte_extrait_w;                  // dimensions d'affichage de l'extrait de carte, largeur
int carte_extrait_h;                  // dimensions d'affichage de l'extrait de carte, hauteur
int carte_extrait_x;                  // coordonnées d'affichage de l'extrait de carte
int carte_extrait_y;                  // _______________________""____________________
int ipx, ipy;                         // coordonnées d'affichage du tableau de position
int icx, icy;                         // coordonnées d'affichage des commentaires
int inx, iny;                         // coordonnées d'affichage des niveaux
int ivx, ivy;                         // coordonnées d'affichage des vidéos
int iax, iay;                         // coordonnées d'affichage des infos de l'application
int izx, izy;                         // coordonnées d'affichage des infos de zone

// coordonnées 
float vlat, vlon;                     // coordonnées du point dans le repère WGS84
float vx, vy;                         // coordonnées du point qui se déplace dans le repère de la carte
String vtimestamp;                    // timestamp du relevé de position
DateFormat timestamp_formatter = new SimpleDateFormat("yyyyMMddHHmmss");
float xoffset, yoffset;               // décalage entre le repère de la carte et le repère de la fenêtre d'affichage
ArrayList<Position> positions;        // liste des différents points du trajet du voyageur
int max_positions;                    // nombre de positions affichées (30 en mode test, 300 en mode réel) 

// variables pour les tests sans bouger (test_mode = true);
int[] test_trajet = { 24, 2, 3, 4, 5, 21, 25, 14, 17, 18, 19, 7, 27, 13, 11, 12, 10, 9, 8, 20, 26, 6, 24 };
Table test_velo;                      // contient pour chaque mètre du test_trajet, les valeurs de lat. et lon.
int test_point = 0;                   // index de départ dans la table test_velo

// gestion du temps qui passe
int start_millis;                     // moment du départ
int checkpoint = 0;                   // un metronome qui ticke toutes les 100 millisecondes
int checkpoint_last = 0;              // dernière valeur du métronome
int checkpoint_tempo = 100;           // x millisecondes
int tempo_update = 10;                // rafraichir l'écran toutes les (x * checkpoint) millisecondes
int tempo_updategeoloc = 10;          // ajouter un point à ArrayList positions toutes les (x * checkpoint) millisecondes 
int tempo_updategeoloctest = 5;       // modifier la position toutes les (x * checkpoint) millisecondes
boolean update_screen = false;        // recalculer la carte, rafraichir l'écran, etc.
boolean update_geoloc = false;        // chercher de nouvelles coordonnées
boolean mode_pause = false;           // pause dans le déplacement

// mesure en mode réel de la distance parcourue sur les dernières positions
int maxback = 20;       // 5 (dieppe) // dernières positions à additionner
int maxbackdist = 20;   // 5 (dieppe) // distance maximum (en pixels) sur les {maxback} dernières positions pour être considéré à l'arrêt
float distback = 0;                   // distance additionnée (en pixels) des {maxback} dernières positions

// logique de déclenchement des players
boolean MOVE_ON       = true;         // true, si le vélo est en mouvement
boolean MOVE_PAUSE    = false;        // true, si le vélo est considéré en arrêt (au bout de ...)
float   MOVE_STOP     = 0;            // le vélo est en arrêt depuis ... secondes
float   MOVE_STOP_LAST= 0;            // dernières millis, utilisé pour calculer le temps d'arrêt   
float   MOVE_STOP_DEC = 10000;        // combien de millisecondes avant le déclenchement de la lecture

boolean VIDEO_ON    = false;           // la vidéo est en lecture
int     VIDEO_ZONE  = -1;              // id de la zone vidéo
boolean AUDIO_ON    = false;           // le son est en lecture
int     AUDIO_ZONE  = -1;              // id de la zone audio
boolean BOUCLE_ON   = false;           // la boucle de son est en lecture
int     BOUCLE_ZONE = -1;              // id de la zone de boucle vidéo

boolean VIDEO_ON_LAST  = false;         // état précédent de VIDEO_ON
boolean AUDIO_ON_LAST  = false;         // état précédent de AUDIO_ON
boolean BOUCLE_ON_LAST = false;         // état précédent de BOUCLE_ON

//String  comportement;                 // un message clair pour dire ce qui se passe

// bout de code pour empêcher la tablette de se mettre en veille ********************************
// d'apres http://forum.processing.org/two/discussion/1744/how-do-you-keep-your-app-from-sleeping-while-it-is-running
import android.view.WindowManager;
 
//Override onCreate()
@ Override
public void onCreate(android.os.Bundle icicle) {
  super.onCreate(icicle);
  //This is the magic pixie dust
  getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
}
// ************************************************************************************************



void setup() {
  
  size(displayWidth, displayHeight, P2D);
  orientation(LANDSCAPE);
  frameRate(25);
  background(255);
  
  // définition du layout
  carte_extrait_w = 1280; carte_extrait_h = 800; 
  carte_extrait_x = 0;    carte_extrait_y = 0;
  ipx = 20;    ipy = 300; // tableau de position
  icx = 10;    icy = 400; // commentaires
  inx = 350;   iny = 400; // niveaux
  ivx = 0;     ivy = 0;   // vidéos
  iax = 5;     iay = 600; // infos application
  izx = 900;   izy = 720; // infos de zone
  
  // initialiser ketai
  location = new KetaiLocation(this);
  location.setUpdateRate(gps_update_time, gps_update_distance);

  // initialiser les players ***************************************************
  if (video_small) {
    pv1 = new PlayerVideo(this,       800, 530, 480, 270, repertoire_stockage);
    pb1 = new PlayerBoucleVideo(this, 800, 530, 480, 270, repertoire_stockage);
  } else {
    pv1 = new PlayerVideo(      this, 0, 0, 1280, 720, repertoire_stockage);
    pb1 = new PlayerBoucleVideo(this, 320, 0, 640, 360, repertoire_stockage);
  }
  ps1 = new PlayerSon(this);
  
  // créer la carte *************************************************************
  niglomap = new Carte();
  
  // peupler les zones **********************************************************
  zones_gps = loadTable("nigloblaster2.csv", "header");
  fichiers  = loadTable("nigloblaster2_fichiers.csv");
  gzones    = new ArrayList<GeoZone>();
  lireDonnees(zones_gps);

  for (int i = 0; i < gzones.size(); i++) { 
    gzones.get(i).fixerOffset(gzxoffset, gzyoffset);
    gzones.get(i).adapterCoordonnees(niglomap.hlat, niglomap.hlon, 
                                     niglomap.blat, niglomap.blon, 
                                     niglomap.fond_de_carte.width, niglomap.fond_de_carte.height, 
                                     niglomap.pxtomh, niglomap.pxtomw);
    gzones.get(i).definirFichierMedia(fichiers.getString(gzones.get(i).id, 1));
  }
  
  // DEBUG : affichage pour vérification des zones *******************************
  if (debug_console) {
    for (int i = 0; i < gzones.size(); i++) {
      gzones.get(i).printer();
    }
  }
  
  // ajouter les zones à la carte
  niglomap.ajouterZones(gzones, debug_display);
  
  // initialiser les positions ****************************************************
  positions = new ArrayList<Position>();

  if (test_mode) {
    // pour les essais sans bouger ************************************************
    calculerDistanceTrajet(test_trajet, gzones, niglomap);
    test_velo = new Table();
    test_velo.addColumn("m");
    test_velo.addColumn("latitude");
    test_velo.addColumn("longitude");
    test_velo.addColumn("x");
    test_velo.addColumn("y");
    calculerTrajet(test_trajet, gzones, niglomap, gzxoffset, gzyoffset);
  }
  
  initialiser();
}

void initialiser() {
  if (test_mode) {
    max_positions = 30;
  } else {
    max_positions = 100;
  }
}


void draw() {
   
  if (frameCount == 0) {
    start_millis = millis();
    // pour éviter le bug d'affichage quand la tablette est rallumée
    niglomap = new Carte();
    niglomap.ajouterZones(gzones, debug_display);
  }
  
  // *************************************************************************************************
  // tempo / metronome / on marque le temps **********************************************************
  update_screen = false;
  update_geoloc = false;
  
  checkpoint = int(millis() / checkpoint_tempo);
  
  if (checkpoint > checkpoint_last) {
    checkpoint_last = checkpoint;
    if (checkpoint%tempo_update == 0) update_screen = true;
    if (checkpoint%tempo_updategeoloc == 0) update_geoloc = true;
  }
  if (mode_pause) update_geoloc = false;
  

  // *************************************************************************************************
  if (update_geoloc) {
    
    // récupérer les coordonnées *********************************************************************
    if ((test_mode) && (!mode_pause)) {
      
      vx   = test_velo.getFloat(test_point, "x");
      vy   = test_velo.getFloat(test_point, "y");
      vlat = test_velo.getFloat(test_point, "latitude");
      vlon = test_velo.getFloat(test_point, "longitude");
      
    } else {
      
      vlat = (float)latitude;
      vlon = (float)longitude;
      vy = map(vlat, niglomap.hlat, niglomap.blat, 0, niglomap.fond_de_carte.height) + gzyoffset; 
      vx = map(vlon, niglomap.hlon, niglomap.blon, 0, niglomap.fond_de_carte.width) + gzxoffset; 
      
      if (debug_real) {
        println("données captées par le GPS : vlat " + vlat + " vlon " + vlon + " vx " + vx + " vy " + vy);
      }
      // ajouter la position au trajet *****************************************************************
      if (!(vlat + vlon == 0)) {
        positions.add(new Position(vx, vy, vlat, vlon, timestamp_formatter.format(new Date())));
        if (debug_real) println("position ajoutée");
      } else {
        if (debug_real) println("rien");
      }
    }
   
    // calculer l'offset entre le repère de la carte et le repère de la fenêtre ************************
    xoffset = (carte_extrait_w / 2) - vx + carte_extrait_x;
    yoffset = (carte_extrait_h / 2) - vy + carte_extrait_y;
    
    // ajouter la position au trajet *******************************************************************
    // positions.add(new Position(vx, vy, vlat, vlon, timestamp_formatter.format(new Date())));
    
    // réduire la liste des positions si elle devient trop importante    
    if (positions.size() > max_positions) positions.remove(0);
  }
  
  
  
  
  if (update_screen) { 
    
    // afficher l'extrait de carte *********************************************************************
    carte_extrait = niglomap.extraireCarte(carte_extrait_w, carte_extrait_h, int(vx), int(vy));
    image(carte_extrait, carte_extrait_x, carte_extrait_y);
    
    // mise à jour de la carte : dessiner le trajet sur la fenêtre principale **************************
    dessinerTrajet(max_positions);
    
    // dessiner la position ****************************************************************************
    dessinerPosition();
    
    // afficher les flèches guides vers les différentes zones ******************************************
    dessinerFleches();
       
    // colorer l'écran si la position est dans le diamètre d'une zone **********************************
    colorerEcran();
    
    // afficher la position
    if (test_mode) afficherPositionTest(ipx, ipy);
    
  //} // fin de update_screen = true;
  
  // if (update_screen) {
    
    AUDIO_ON = false;
    VIDEO_ON = false;
    BOUCLE_ON = false;
    
    //tester les zones video rencontrées *************************************************
    boolean video_done = false;
    VIDEO_ZONE = -1;
    while (!video_done) {
      for (int i = 0; i < gzones.size(); i ++) {
        GeoZone gz = gzones.get(i);
        if ((dist(vx, vy, gz.x, gz.y) < gz.diametre_pixels / 2) && (gz.type == 1) && (gz.actif == 1)) { 
          VIDEO_ZONE = gz.id;
          VIDEO_ON = true;
          video_done = true;
        }
      }
      video_done = true; // on n'a rien trouvé
    }
  
    // tester les zones audio rencontrées *************************************************
    boolean audio_done = false;
    AUDIO_ZONE = -1;
    while (!audio_done) {
      for (int i = 0; i < gzones.size(); i ++) {
        GeoZone gz = gzones.get(i);   
        if ((dist(vx, vy, gz.x, gz.y) < gz.diametre_pixels / 2) && (gz.type == 3) && (gz.actif == 1)) {
          AUDIO_ZONE = gz.id;
          AUDIO_ON = true;
          audio_done = true;
        }
      }
      audio_done = true; // on n'a rien trouvé
    }
  
    // tester les zones audio rencontrées *************************************************
    boolean boucle_done = false;
    BOUCLE_ZONE = -1;
    while (!boucle_done) {
      for (int i = 0; i < gzones.size(); i ++) {
        GeoZone gz = gzones.get(i);   
        if ((dist(vx, vy, gz.x, gz.y) < gz.diametre_pixels / 2) && (gz.type == 2) && (gz.actif == 1)) {
          BOUCLE_ZONE = gz.id;
          BOUCLE_ON = true;
          boucle_done = true;
        }
      }
      boucle_done = true; // on n'a rien trouvé
    }
  
    // Est on à l'arrêt ? *****************************************************************
  
    if (test_mode) { // cette première partie est peut-être inutile
      if (!MOVE_ON) {
        MOVE_STOP += millis() - MOVE_STOP_LAST;
        MOVE_STOP_LAST = millis(); 
        if (MOVE_STOP > MOVE_STOP_DEC) {
          MOVE_PAUSE = true;
          //MOVE_STOP = 0;
        } else {
          MOVE_PAUSE = false;
        }
      } else {
        MOVE_STOP = 0;
        MOVE_STOP_LAST = millis();
        MOVE_PAUSE = false;
      }
    } else {
      // rechercher si on a bougé depuis x - maxback positions
      if (positions.size() >= maxback) {

        int etapes_max = min(positions.size() - 1, maxback);
        int etapes = positions.size() - 1;
        int etapes_min;
        
        if (positions.size() - 1 > maxback) etapes_min = positions.size() - 1 - maxback;
        else etapes_min = 1;
        
        distback = 0;
        while (etapes >= etapes_min) {
          distback += dist( positions.get(etapes).x, 
                            positions.get(etapes).y,
                            positions.get(etapes - 1).x,
                            positions.get(etapes - 1).y);
          etapes --;
        }
        if (distback < maxbackdist) {
          MOVE_PAUSE = true;
        } else {
          MOVE_PAUSE = false;
        }
      }
    }
  
    // logique des déclenchements de players **************************************************************
    
    if (debug_console){
      println(frameCount + " LAST (V/A/B)  " + VIDEO_ON_LAST + " " + AUDIO_ON_LAST + " " + BOUCLE_ON_LAST);
      println(frameCount + " NOW  (V/A/B)  " + VIDEO_ON +      " " + AUDIO_ON +      " " + BOUCLE_ON + " MOVE_PAUSE " + MOVE_PAUSE);
      print("avant : " + " v " + pv1.video_a_jouer + " s " + ps1.audio_a_jouer + " b " + pb1.video_a_jouer
             + " VZ " + VIDEO_ZONE + " AZ " + AUDIO_ZONE + " BZ " + BOUCLE_ZONE);
    }  
    
    if (AUDIO_ON) {
      if (!ps1.isPlaying()) ps1.audio_a_jouer = AUDIO_ZONE;
    } else {
      ps1.audio_a_jouer = 0;
      ps1.stopper();
    }
    if (BOUCLE_ON) {
      if (!pb1.isPlaying()) pb1.video_a_jouer = BOUCLE_ZONE;
    } else {
      pb1.video_a_jouer = 0;
      pb1.stopper();
    }      
    
    if (MOVE_PAUSE) {
      if ((VIDEO_ON) && (VIDEO_ON != VIDEO_ON_LAST)) {
        pv1.video_a_jouer = VIDEO_ZONE;
        ps1.audio_a_jouer = 0;
        pb1.video_a_jouer = 0;
        AUDIO_ON = false;
        BOUCLE_ON = false;
      }
    } else {
      pv1.stopper();
      pv1.video_a_jouer = 0;
      VIDEO_ON = false;
    }
    
    if (pv1.isPlaying()) {
      AUDIO_ON = false;
      BOUCLE_ON = false;
      pb1.video_a_jouer = 0;
      ps1.audio_a_jouer = 0;
    }
    
    if (debug_console) {
      print("après : " + " v " + pv1.video_a_jouer + " s " + ps1.audio_a_jouer + " b " + pb1.video_a_jouer
            + " VZ " + VIDEO_ZONE + " AZ " + AUDIO_ZONE + " BZ " + BOUCLE_ZONE);
    }    
    
    VIDEO_ON_LAST  = VIDEO_ON;
    AUDIO_ON_LAST  = AUDIO_ON;
    BOUCLE_ON_LAST = BOUCLE_ON;

          
    // ************************************************************************************
    // video *****************************************************************
    if (pv1.video_a_jouer > 0) { // lecture déclenchée par un bouton
    
      for (int i = 0; i < gzones.size(); i ++) {
          GeoZone gz = gzones.get(i);   
          if (gz.id == VIDEO_ZONE) pv1.fichier_video = gz.fichier_media;
      }
      
      ps1.stopper();             // on commence par couper le son
      pb1.stopper();             // puis on stoppe la boucle
      pv1.lancer();              // puis on lance la vidéo
    }
    pv1.tester();                // le conteneur sera enlevé à la fin de la vidéo
    if (!pv1.isPlaying()) VIDEO_ON = false;
    // ***********************************************************************
  
  
    // audio *****************************************************************
    if (ps1.audio_a_jouer > 0) { // lecture déclenchée par un bouton
    
      for (int i = 0; i < gzones.size(); i ++) {
        GeoZone gz = gzones.get(i);   
        if (gz.id == AUDIO_ZONE) ps1.fichier_audio = gz.fichier_media;
      }
      
      //pv1.stopper();             // on commence par couper la vidéo 
      ps1.lancer();              // puis on lance le son
    }
    ps1.tester();                // le player sera mis en pause à la fin du morceau
    if (!ps1.isPlaying()) AUDIO_ON = false;
    // ***********************************************************************
    
    
    // boucle ****************************************************************  
    if (pb1.video_a_jouer > 0) { // lecture déclenchée par un bouton
      
      for (int i = 0; i < gzones.size(); i ++) {
        GeoZone gz = gzones.get(i);   
        //println("i : " + gz.fichier_media); 
        if (gz.id == BOUCLE_ZONE) pb1.fichier_video = gz.fichier_media;
      }
      
      //pv1.stopper();             // on commence par couper la vidéo 
      pb1.lancer();              // puis on lance le son
    }
    pb1.tester();                // 
    if (!pb1.isPlaying()) BOUCLE_ON = false;
    // ***********************************************************************
    
  }
  
  
  // infos texte ***********************************************************
  if ((debug_display) && (update_screen)) {
    drawEtatsZones(izx, izy);
    drawEtats(icx, icy);
    drawInfoApplication(iax, iay);
  }
  
  
  // mise à jour de la localisation en mode test *******************************************************
  if ((test_mode) && (update_geoloc) && (!mode_pause)) {
    test_point += int(tempo_updategeoloc);
    if (test_point > test_velo.getRowCount() - 2) {
        test_point = 0;
        start_millis = millis();
    }
  }
  
  
  
  // *************************************************************************************************
}


// *******************************************************************************

void onLocationEvent(double _latitude, double _longitude, double _altitude) {
  longitude = _longitude;
  latitude  = _latitude;
}

// *******************************************************************************
/*
void keyPressed() {
  if (key == 's') { // enregistrer une image de l'écran
    Date now = new Date();
    SimpleDateFormat formater = new SimpleDateFormat("yyyyMMdd_HHmmss");
    System.out.println(formater.format(now));
    saveFrame(SKETCH_NAME + "_" + formater.format(now) + ".png");
  }
  if (key == 'S') { // enregistrer la carte avec les zones en haute définition
    niglomap.saveHR();
  }
  if (key == ' ') { // mettre en pause le mouvement (utilisé en mode test)
    mode_pause = !mode_pause;
    MOVE_ON = !MOVE_ON;
  }
}*/

void mousePressed() { // pour réagir au tapotis d'écran en mode test
  if (test_mode) {
    mode_pause = !mode_pause;
    MOVE_ON = !MOVE_ON;
  }
}

