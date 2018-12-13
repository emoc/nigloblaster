class Carte {
  
  PImage fond_de_carte;                 // fond de carte récupéré
  PGraphics carte;                      // carte à utiliser dans l'application
  //int fond_de_carte_w, fond_de_carte_h;// dimensions de la carte
  // Dieppe
  float hlat = 49.93538525337336;       // latitude extreme du point haut/gauche, utilisée pour calculer les changements de repère
  float hlon =  1.071607701143883;      // longitude extreme du point haut/gauche
  float blat = 49.91950138266164;       // latitude extreme du point bas/droite
  float blon =  1.09769212470308;       // longitude extreme du point bas/droite
  
  /* Quimper 
  float hlat = 48.00153114481313;       // latitude extreme du point haut/gauche, utilisée pour calculer les changements de repère
  float hlon =  -4.122627971075749;      // longitude extreme du point haut/gauche
  float blat = 47.99784832610649;       // latitude extreme du point bas/droite
  float blon =  -4.11479948409615;       // longitude extreme du point bas/droite
  */
  float distance_h, distance_w;         // distance calculée entre les deux points extremes en hauteur et largeur
  float pxtomh, pxtomw;                 // conversion : combien de pixels pour un mètre en hauteur, en largeur
  
  /* TODO
    inscrire les paramètres dans un fichier texte à charger : carte_parametres.txt
    hlat, hlon, blat, blon, decx, decy, fond_de_carte.png
    charger, vérifier si fond_de_carte.png existe, sinon le créer à partir d'un service WMS
  */
    
  Carte() {
    
    // créer la carte *************************************************************
    fond_de_carte   = loadImage("dieppe_map_2000px_nb.png");
    distance_h = haversineDistance(hlat, hlon, blat, hlon);
    distance_w = haversineDistance(hlat, hlon, hlat, blon);
    pxtomh     = distance_h / (float)fond_de_carte.height;
    pxtomw     = distance_w / (float)fond_de_carte.width;
    carte = createGraphics(fond_de_carte.width, fond_de_carte.height);
  }
  
  void ajouterZones(ArrayList<GeoZone> gzones, boolean debug_display) {
    carte.beginDraw();
    carte.image(fond_de_carte, 0, 0, fond_de_carte.width, fond_de_carte.height);
    for (int i = 0; i < gzones.size(); i++) { 
      if (gzones.get(i).actif == 1) {
        switch(gzones.get(i).type) {
          case 1: 
            carte.noStroke();
            carte.fill(255, 0, 0, 120);  
            break;
          case 2: 
            carte.noStroke(); 
            carte.fill(255, 255, 0, 80);  
            break;
          case 3: 
            carte.stroke(0, 0, 255, 120);  
            carte.noFill();
            carte.strokeWeight(2);
            break;
        } 
  
        //carte.noStroke();
        carte.ellipse(gzones.get(i).x, gzones.get(i).y, gzones.get(i).diametre_pixels_w , gzones.get(i).diametre_pixels_h);
        carte.fill(0); carte.stroke(0);
        if (debug_display) {
          carte.textAlign(CENTER, CENTER);
          carte.textSize(18);
          carte.text(gzones.get(i).id, gzones.get(i).x, gzones.get(i).y - 12);
          carte.text("r " + round(gzones.get(i).rayon_metres) + "m", gzones.get(i).x, gzones.get(i).y + 18);
          carte.textSize(12);
          carte.text(gzones.get(i).titre, gzones.get(i).x, gzones.get(i).y + 40);
        }
        
      } else { // 018 : ZONE INACTIVE
        switch(gzones.get(i).type) {
          case 1: 
            carte.noStroke();
            carte.fill(120, 120, 120, 60);  
            break;
          case 2: 
            carte.noStroke(); 
            carte.fill(255, 255, 0, 40);  
            break;
          case 3: 
            carte.stroke(120, 120, 120, 60);  
            carte.noFill();
            carte.strokeWeight(2);
            break;
        } 
        
        carte.ellipse(gzones.get(i).x, gzones.get(i).y, gzones.get(i).diametre_pixels_w , gzones.get(i).diametre_pixels_h);
        carte.fill(0); carte.stroke(0);
        if (debug_display) {
          carte.textAlign(CENTER, CENTER);
          carte.textSize(18);
          carte.text(gzones.get(i).id, gzones.get(i).x, gzones.get(i).y - 12);
          carte.text("r " + round(gzones.get(i).rayon_metres) + "m", gzones.get(i).x, gzones.get(i).y + 18);
          carte.textSize(12);
          carte.text(gzones.get(i).titre, gzones.get(i).x, gzones.get(i).y + 40);
        }
      }
    }
    carte.fill(255, 255, 255, 120);
    carte.rect(0, 0, carte.width, carte.height);
    carte.endDraw();
  }
  
  float haversineDistance(float lat1, float lon1, float lat2, float lon2) {
    float R = 6371000; // metres
    float phi1 = radians(lat1);
    float phi2 = radians(lat2);
    float deltaphi = radians(lat2-lat1);
    float deltalambda = radians(lon2-lon1);
    float a = sin(deltaphi/2) * sin(deltaphi/2) +
              cos(phi1) * cos(phi2) *
              sin(deltalambda/2) * sin(deltalambda/2);
    float c = 2 * atan2(sqrt(a), sqrt(1-a));
    float distance = R * c;
    return distance;
  }
  
  PGraphics getCarte() {
    return carte;
  }
  
  PImage extraireCarte(int carte_w, int carte_h, int cx, int cy) {
  
    // carte : la carte complète
    // carte_w : largeur du morceau à extraire
    // carte_h : hauteurs du morceau à extraire
    // cx : x du point pour centrer la carte
    // cy : y du point pour centrer la carte
    
    PImage minicarte;
    minicarte = carte.get(cx - (carte_w / 2), cy - (carte_h / 2), carte_w, carte_h);
    return minicarte;
  }
  
  /*
  void saveHR() { // enregistrement de la carte plein pot 
    PGraphics pg = createGraphics(carte.width, carte.height);
    pg.beginDraw();
    pg.image(carte, 0, 0, carte.width, carte.height);
    pg.save("carte_nigloblaster2.png");
    pg.endDraw();

  }*/
}
