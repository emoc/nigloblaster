class GeoZone {
  
  int id;                        // identifiant de zone, fixé dans le .kml / .csv
  float latitude, longitude;     // signed decimal degrees
  float x = 0, y = 0;            // cinversion de latitude et longitude dans le repère de la carte
  float rayon_metres;            // rayon de la zone en metres
  float diametre_pixels_h, diametre_pixels_w;  // rayons de la zone convertis en pixels TODO supprimer
  float diametre_pixels;         // rayon de la zone convertis en pixels
  int type;                      // type de la zone : 1:vidéo, 2:boucle vidéo, 3:son
  int actif;                     // zone prise en compte sur la carte ?
  String titre = "";             // titre de la zone
  String fichier_media = "";     // fichier .mp4 pour les vidéos, ou .mp3 pour les sons
  int gzxoffset, gzyoffset;      // offset pour adapter l'affichage
  color c;                       // couleur de la zone
  
  GeoZone( int _id, float _latitude, float _longitude, String _titre, float _rayon, int _type, int _actif) {
    id = _id;
    latitude = _latitude;
    longitude = _longitude;
    titre = _titre;
    rayon_metres = _rayon;
    type = _type;
    actif = _actif;
    switch(type) {
        case 1: 
          c = color(255, 0, 0, 255);  
          break;
        case 2: 
          c = color(255, 255, 0, 255);  
          break;
        case 3: 
          c = color(0, 0, 255, 255);  
          break;
      }
  }
  
  void fixerOffset(int _gzx, int _gzy) {
    gzxoffset = _gzx;
    gzyoffset = _gzy;
  }
  
  void printer() {
    println("  id "                  + id + "\n" +
            "  lat : "               + latitude +  "\n" +
            "  lon : "               + longitude + "\n" +
            "  x : "                 + x + 
            "  y : "                 + y + "\n" +
            "  rayon_metres : "      + rayon_metres + "\n" +
            "  type : "              + type + "\n" +
            "  actif : "             + actif + "\n" +
            "  titre : "             + titre + "\n" +
            "  fichier media : "     + fichier_media + "\n");
  }
  
  void adapterCoordonnees(float hlat, float hlon, float blat, float blon, int fond_de_carte_w, int fond_de_carte_h, float px_to_m_h, float px_to_m_w) {
    y = map(latitude,  hlat, blat, 0, fond_de_carte_h) + gzyoffset; 
    x = map(longitude, hlon, blon, 0, fond_de_carte_w) + gzxoffset; 
    diametre_pixels_h = rayon_metres / px_to_m_h * 2;        // TODO peut-être pas nécessaire d'avoir les deux vu l'échelle
    diametre_pixels_w = rayon_metres / px_to_m_w * 2;
    diametre_pixels = diametre_pixels_h;
  }
  
  void definirFichierMedia(String _fm) {
    fichier_media = _fm;
  }
  
}
