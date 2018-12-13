

void calculerDistanceTrajet(int[] test_trajet, ArrayList<GeoZone> gzones, Carte niglomap) {
  float distance_test_trajet = 0;
  for (int i = 0; i < test_trajet.length - 1; i++) {
    //gzones.get(i).afficher();
    int p1 = test_trajet[i];
    int p2 = test_trajet[i+1];
    float lat1 = 0, lon1 = 0, lat2 = 0, lon2 = 0;
    int id1 = 0, id2 = 0;
    for (int j = 0; j < gzones.size(); j++) {
      if (p1 == gzones.get(j).id) {
        id1 = p1;
        lat1 = gzones.get(j).latitude;
        lon1 = gzones.get(j).longitude;
      }
      if (p2 == gzones.get(j).id) {
        id2 = p2;
        lat2 = gzones.get(j).latitude;
        lon2 = gzones.get(j).longitude;
      }
    }
    float dtp = haversineDistance(lat1, lon1, lat2, lon2);
    println("distance entre zone " + id1 + " et " + id2 + " : " + round(dtp) + " m");
    distance_test_trajet += dtp;
  }
  println("distance totale du trajet à vol d'oiseau: " + round(distance_test_trajet));
}




void calculerTrajet(int[] test_trajet, ArrayList<GeoZone> gzones, Carte niglomap, int gzxoffset, int gzyoffset) {
  int distance_test_trajet = 0;
  
  for (int i = 0; i < test_trajet.length - 1; i++) {

    int p1 = test_trajet[i];
    int p2 = test_trajet[i+1];
    float lat1 = 0, lon1 = 0, lat2 = 0, lon2 = 0;
    int id1 = 0, id2 = 0;
    
    for (int j = 0; j < gzones.size(); j++) {
      if (p1 == gzones.get(j).id) {
        id1 = p1;
        lat1 = gzones.get(j).latitude;
        lon1 = gzones.get(j).longitude;
      }
      if (p2 == gzones.get(j).id) {
        id2 = p2;
        lat2 = gzones.get(j).latitude;
        lon2 = gzones.get(j).longitude;
      }
    }
    int dtp = int(haversineDistance(lat1, lon1, lat2, lon2));
    
    for (int k = distance_test_trajet; k <= distance_test_trajet + dtp; k ++) { // augmenter d'un mètre à chaque fois
      float lat3 = (lat2 - lat1) / dtp * (k - distance_test_trajet) + lat1;
      float lon3 = (lon2 - lon1) / dtp * (k - distance_test_trajet) + lon1;
      TableRow newRow = test_velo.addRow();
      newRow.setInt("m", distance_test_trajet + k);
      newRow.setFloat("latitude",  lat3);
      newRow.setFloat("longitude", lon3);
      newRow.setFloat("x", map(lon3, niglomap.hlon, niglomap.blon, 0, niglomap.fond_de_carte.width) + gzxoffset);
      newRow.setFloat("y", map(lat3, niglomap.hlat, niglomap.blat, 0, niglomap.fond_de_carte.height) + gzyoffset);
    }
    distance_test_trajet += dtp;
  }
  //println(test_velo);
}

void afficherPositionTest(int ipx, int ipy) {
  
    fill(230); noStroke();
    rect(ipx, ipy, 180, 95);
        
    textSize(12);
    textAlign(LEFT);
    fill(0); 
    
    text(test_point + " mètres parcourus",                           ipx + 10, ipy + 15);
    text("latitude "  + test_velo.getFloat(test_point, "latitude" ), ipx + 10, ipy + 30);
    text("longitude " + test_velo.getFloat(test_point, "longitude"), ipx + 10, ipy + 45);
    text("x "         + test_velo.getFloat(test_point, "x"),         ipx + 10, ipy + 60);
    text("y "         + test_velo.getFloat(test_point, "y"),         ipx + 10, ipy + 75);
    float vvv = (float)test_point / ( (millis() - start_millis) / 1000); // en m/s
    // http://www.wesaw.it/2013/05/quelle-est-la-vitesse-moyenne-a-velo/ : 12 km/s en ville
    float kmh = vvv * 3600 / 1000;
    text("vitesse " + round(vvv) + " m/s, " + round(kmh) + "km/h (faux)", ipx + 10, ipy + 90);
}
