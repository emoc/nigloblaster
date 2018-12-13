class Carte {
  
  PImage fond_de_carte;                 // fond de carte récupéré
  String fichier_fond_de_carte = "dieppe_map_2000px_nb.png";
  PGraphics carte;                      // carte à utiliser dans l'application
  //int fond_de_carte_w, fond_de_carte_h;// dimensions de la carte
  float hlat = 49.93538525337336;       // latitude extreme du point haut/gauche, utilisée pour calculer les changements de repère
  float hlon =  1.071607701143883;     // longitude extreme du point haut/gauche
  float blat = 49.91950138266164;       // latitude extreme du point bas/droite
  float blon =  1.09769212470308;     // longitude extreme du point bas/droite
  float distance_h, distance_w;         // distance calculée entre les deux points extremes en hauteur et largeur
  float pxtomh, pxtomw;                 // conversion : combien de pixels pour un mètre en hauteur, en largeur
  PFont police;
  
  /* TODO
    inscrire les paramètres dans un fichier texte à charger : carte_parametres.txt
    hlat, hlon, blat, blon, decx, decy, fond_de_carte.png
    charger, vérifier si fond_de_carte.png existe, sinon le créer à partir d'un service WMS
  */
    
  Carte() {
    
    // créer la carte *************************************************************
    fond_de_carte   = loadImage(fichier_fond_de_carte);
    distance_h = haversineDistance(hlat, hlon, blat, hlon);
    distance_w = haversineDistance(hlat, hlon, hlat, blon);
    pxtomh     = distance_h / (float)fond_de_carte.height;
    pxtomw     = distance_w / (float)fond_de_carte.width;
    carte = createGraphics(fond_de_carte.width, fond_de_carte.height);
    police = loadFont("LiberationMono-14.vlw");
    //textFont(police, 14);
  }
  
  void ajouterZones(ArrayList<GeoZone> gzones) {
    
    carte.beginDraw();
    carte.textFont(police, 14);
    carte.image(fond_de_carte, 0, 0, fond_de_carte.width, fond_de_carte.height);
    carte.fill(255, 255, 255, 0);
    carte.rect(0, 0, carte.width, carte.height);
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
  
        
        carte.ellipse(gzones.get(i).x, gzones.get(i).y, gzones.get(i).diametre_pixels_w , gzones.get(i).diametre_pixels_h);
        if ((gzones.get(i).type == 1) || (gzones.get(i).type == 2)) {
          carte.fill(0); carte.stroke(0);
          carte.ellipse(gzones.get(i).x, gzones.get(i).y, 18, 18);
          carte.fill(255); carte.stroke(255);
          carte.textAlign(CENTER, CENTER);
          carte.textSize(14);
          
          carte.text(gzones.get(i).id, gzones.get(i).x, gzones.get(i).y);
          carte.textAlign(LEFT, CENTER);
          carte.fill(0, 0, 0, 150);
          carte.text(round(gzones.get(i).rayon_metres) + "m", gzones.get(i).x + 6, gzones.get(i).y - 18);
        } else {
          carte.fill(0,0,255); carte.stroke(0,0,255);
          float aa = random(-PI, PI);
          float xx = gzones.get(i).x + gzones.get(i).diametre_pixels_w / 2 * cos(aa);
          float yy = gzones.get(i).y + gzones.get(i).diametre_pixels_w / 2 * sin(aa);
          carte.ellipse(xx, yy, 18, 18);
          carte.fill(255); carte.stroke(255);
          carte.textAlign(CENTER, CENTER);
          carte.textSize(14);
          
          carte.text(gzones.get(i).id, xx, yy);
          carte.textAlign(CENTER, CENTER);
          carte.fill(0, 0, 0, 150);
          carte.text(round(gzones.get(i).rayon_metres) + "m", xx + 6, yy - 18);
        } 
        carte.textSize(12);
        carte.textAlign(CENTER, CENTER);
        carte.fill(0, 0, 0, 255);
        //carte.text(gzones.get(i).titre, gzones.get(i).x, gzones.get(i).y + 12);
        //carte.text(gzones.get(i).fichier_media, gzones.get(i).x, gzones.get(i).y + 24);
        
      }
    }
    carte.fill(0);
    carte.stroke(0);
    
    carte.textAlign(LEFT, CENTER);
    int interligne = 16;
    int yy = 50;
    int xx = 50;
    
    carte.textSize(36);
    carte.text("NIGLOBLASTER 2", xx, yy);
    yy += 50;
    
    carte.textSize(12);
    for (int i = 0; i < gzones.size(); i++) {
      // System.out.format("%-5s:%10s\n", "Name", "Nemo");
      String tt = "";
      color bg = color(255, 255, 25, 0);
      switch(gzones.get(i).type) {
        case 1:
          tt = "video";
          bg = color(255, 0, 0, 90); 
          break;
        case 2:
          tt = "boucle video";
          bg = color(255, 255, 0, 60);
          break;
        case 3:
          tt = "boucle audio";
          bg = color(0, 0, 255, 90);  
          break;
      }
      carte.fill(bg);
      carte.noStroke();
      String zz = String.format("%-2d : [%-12s] %3.0f %-20s / %-10s", gzones.get(i).id, tt, gzones.get(i).rayon_metres, gzones.get(i).titre, gzones.get(i).fichier_media);
      carte.rect(xx, yy - 6, 280, 14);
      carte.fill(255, 255, 255, 180);
      carte.noStroke();
      carte.rect(xx + 280, yy - 6, 250, 14);
      carte.fill(0, 0, 0, 255);
      
      carte.text( zz, xx, yy);
      /*
      carte.text(  gzones.get(i).id + " : " 
            + gzones.get(i).titre
            + " / "
            + gzones.get(i).fichier_media, xx, yy);*/
      yy += interligne;
      
    }
    yy += 50;
    Date now = new Date();
    SimpleDateFormat formater = new SimpleDateFormat("yyyyMMdd HH:mm");
    //System.out.println(formater.format(now));
    carte.textSize(36);
    carte.text(formater.format(now), xx, yy);
    carte.textSize(14);
    yy += 20;
    carte.text(fichier_fond_de_carte, xx, yy);
    yy += interligne;
    
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
  
  void saveCarteAnnotee() { // enregistrement de la carte plein pot 
    PGraphics pg = createGraphics(carte.width, carte.height);
    pg.beginDraw();
    pg.image(carte, 0, 0, carte.width, carte.height);
    Date now = new Date();
    SimpleDateFormat formater = new SimpleDateFormat("yyyyMMdd_HHmm");
    pg.save("carte_nigloblaster2_" + formater.format(now) + ".png");
    pg.endDraw();

  }
}
