void lireDonnees(Table zones_gps) {
  
  for (TableRow row : zones_gps.rows()) {
    
    int    id        = row.getInt("id");
    float  latitude  = row.getFloat("latitude");
    float  longitude = row.getFloat("longitude");
    float  rayon     = row.getFloat("rayon");
    int    type      = row.getInt("type");
    int    actif     = row.getInt("actif");
    String titre     = row.getString("titre");
    
    gzones.add(new GeoZone(id, latitude, longitude, titre, rayon, type, actif));

  }
}


double roundToDecimals(double d, int c) {  
  
   // d = number to round;   
   // c = number of decimal places 
   
   int temp = (int)(d * Math.pow(10 , c));  
   return ((double)temp)/Math.pow(10 , c);  
   
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


void dessinerTrajet(int _mp) {
  if (positions.size() > 1) {
    int max_positions = _mp;
    int etapes_max = min(positions.size() - 1, max_positions);
    int etapes = positions.size() - 1;
    int etapes_min;
    
    if (positions.size() - 1 > max_positions) etapes_min = positions.size() - 1 - max_positions;
    else etapes_min = 1;
    
    while (etapes >= etapes_min) {
      stroke(0, 0, 0, 130); 
      strokeWeight(2);
      line( positions.get(etapes).x + xoffset, 
            positions.get(etapes).y + yoffset, 
            positions.get(etapes - 1).x + xoffset, 
            positions.get(etapes - 1).y + yoffset);
      etapes --;
    }
  }
}


void dessinerPosition() {
  fill(0, 0, 0, 120); 
  noStroke(); 
  ellipse(carte_extrait_w / 2 + carte_extrait_x, carte_extrait_h / 2 + carte_extrait_y, 5, 5);
}


void dessinerFleches() {
  for (int i = 0; i < gzones.size(); i++) { 
        
    // calculer et afficher les guides (lignes et flèches)
    float df = 50; // distance flèche
    float aaa = atan2(gzones.get(i).y + yoffset - carte_extrait_h / 2 - carte_extrait_y, 
                      gzones.get(i).x + xoffset - carte_extrait_w / 2 - carte_extrait_x);
    float ddd = dist(vx, vy, gzones.get(i).x, gzones.get(i).y);

    float xxx = (carte_extrait_w / 2 + carte_extrait_x ) + df * cos(aaa); // probleme ici
    float yyy = (carte_extrait_h / 2 + carte_extrait_y) + df * sin(aaa);  // probleme ici

    if ((ddd > gzones.get(i).diametre_pixels) && (ddd < 200)) {
      
      fleche(xxx, yyy, aaa, 2, gzones.get(i).c);
      
      // dessiner la ligne vers la zone
      stroke(gzones.get(i).c);
      strokeWeight(1);
      line(xxx, yyy, gzones.get(i).x + xoffset, gzones.get(i).y + yoffset );
    }
  }
}

void colorerEcran() {
  for (int i = 0; i < gzones.size(); i++) { 
    if (dist(vx, vy, gzones.get(i).x, gzones.get(i).y) < (gzones.get(i).diametre_pixels / 2)) {
      noStroke();
      fill(red(gzones.get(i).c), green(gzones.get(i).c), blue(gzones.get(i).c), 20);
      rect(0, 0, width, height);
    }    
  }
}

void fleche(float x, float y, float a, float t, color c) {
  pushMatrix();
  noStroke();
  fill(c);
  translate(x ,y);
  rotate(a);
  beginShape();
  vertex(0, -3*t);
  vertex(10*t, 0);
  vertex(0, 3*t);
  endShape(CLOSE);
  popMatrix();
}
