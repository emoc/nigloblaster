class PlayerBoucleVideo {
  
  PApplet parent;
  int x, y, w, h;
  APWidgetContainer player_video_container;  // espace pour l'affichage vidéo
  APVideoView       player_video_1;          // player video principal
  int video_a_jouer;
  String fichier_video = "";
  String repertoire_stockage;
  
  // tout un tas de trucs pour vérifier que la vidéo est finie...
  int video_start_millis;
  int video_length = 0;
  boolean video_tested = false;
  
  boolean on = false;
  
  PlayerBoucleVideo (PApplet _parent, int _x, int _y, int _w, int _h, String _rs) {
    parent = _parent;
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    repertoire_stockage = _rs;
    player_video_container = new APWidgetContainer(parent); 
    player_video_1 = new APVideoView(x, y, w, h, false); 
  }
  
  void lancer() {

    player_video_1.stopPlayBack();
    player_video_container.removeWidget(player_video_1);
    player_video_container.addWidget(player_video_1); 
    player_video_1.setVideoPath(repertoire_stockage + fichier_video);
    player_video_1.setLooping(false);
    player_video_1.start(); 
    on = true;
    
    // controle de l'affichage du player_container
    video_start_millis = millis();
    video_tested = false;
    video_a_jouer = 0;
    video_length = 0;
  }
  
  void setFichierVideo(String _fv) {
    fichier_video = _fv;
  }
  
  void tester() {
    // on laisse un peu de temps pour que tout soit chargé
    if ((millis() - video_start_millis > 5000) && (!video_tested)) {
      //println("pb1.tester() etape 1 " + video_length);
      
      //println("pb1.tester() etape 2 " + video_length);
      
      try {
        video_length = player_video_1.getDuration();
        if (video_length > 0) video_tested = true;
      } catch (IllegalStateException ils) {
        System.err.println("IllegalStateException : " + ils.getMessage());
      } 
    }
  
    if (video_length > 0) {
      //println("pb1.tester() test passé");
      /*
      textAlign(LEFT);  textSize(18);  fill(255);
      text(  "position : " + nf(player_video_1.getCurrentPosition(), 7)
           + " / "         + nf(player_video_1.getDuration(), 7), 650, 190); */
         
      if (millis() - video_start_millis > video_length + 1000) {
        //println("stop");
        stopper();

      }
    }
  }
  
  void stopper() {
    if (video_start_millis > 0) {
      player_video_1.stopPlayBack();
      player_video_container.removeWidget(player_video_1);
      video_length = 0;
      video_start_millis = 0;
      fichier_video = "";
      video_tested = false;
      on = false;
    }
  }
  
  boolean isPlaying() {
     return on;
  }

}
