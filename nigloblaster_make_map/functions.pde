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





