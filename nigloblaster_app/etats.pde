void drawEtats(int x_start, int y_start) {
  
  int y_step = 15;
  
  noStroke();
  fill(200, 200, 200);
  rect(x_start - 10, y_start, 280, 175);
  y_start += y_step;
  
  textAlign(LEFT);  
  textSize(12);
  fill(0);
  
  text("zones :\nrouge : video, jaune : boucle vidéo, bleu : audio", x_start, y_start);
  
  y_start += y_step * 3;
  text("En pause (MOVE_PAUSE)        : " + MOVE_PAUSE, x_start, y_start);
  y_start += y_step;
  text("En pause (mode_pause)        : " + mode_pause, x_start, y_start);
  y_start += y_step;
  text("En mouvement (MOVE_ON)       : " + MOVE_ON, x_start, y_start);
  y_start += y_step;
  text("à l'arrêt depuis (MOVE_STOP) : " + MOVE_STOP, x_start, y_start);
  
  y_start += y_step;
  y_start += y_step;
  text("zone video        : " + VIDEO_ZONE, x_start, y_start);
  y_start += y_step; 
  text("zone audio        : " + AUDIO_ZONE, x_start, y_start);
  y_start += y_step; 
  text("zone boucle vidéo : " + BOUCLE_ZONE, x_start, y_start);
}




void drawEtatsZones(int x_start, int y_start) {

  fill(200);
  rect(x_start, y_start, 300, 50);
  
  textAlign(LEFT);  
  textSize(12);  
  fill(0);
  
  text("pv1, vidéo à jouer : " + pv1.fichier_video,  x_start + 5, y_start + 15);
  text("ps1, audio à jouer : " + ps1.fichier_audio,  x_start + 5, y_start + 30);
  text("pb1, boucle à jouer : " + pb1.fichier_video, x_start + 5, y_start + 45);
}




void drawInfoApplication(int x_start, int y_start) {

  fill(200);
  rect(x_start, y_start, 180, 200);
  
  textAlign(LEFT);  
  textSize(12);
  fill(0); 

  text("framerate : " + frameRate, x_start + 10, y_start + 15);
  text("latitude  : " + vlat,      x_start + 10, y_start + 30);
  text("longitude : " + vlon,      x_start + 10, y_start + 45);
  text("x         : " + vx,        x_start + 10, y_start + 60);
  text("y         : " + vy,        x_start + 10, y_start + 75);
  text("10 pixels : " + (10 * niglomap.pxtomw) + " m",                       x_start + 10, y_start +  90);
  text(nf(hour(), 2) + " : " + nf(minute(), 2) + " : " + nf(second(), 2),    x_start + 10, y_start + 135);
  text("distback (px) : " + distback,                                        x_start + 10, y_start + 150);
  text("maxbackdist (px) : " + maxbackdist,                                  x_start + 10, y_start + 165);
  text("maxback (px) : " + maxback,                                          x_start + 10, y_start + 180);
  text("positions enregistrées : " + positions.size(),                       x_start + 10, y_start + 195);
}
