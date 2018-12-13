class PlayerSon {
  
  PApplet parent;
  APMediaPlayer     player_son;              // player son

  int audio_a_jouer;
  String fichier_audio = "";

  // tout un tas de trucs pour vérifier que l'audio est fini...
  int audio_start_millis;
  int audio_length = 0;
  boolean audio_tested = false;
  
  boolean on;
  
  PlayerSon(PApplet parent) {
    player_son = new APMediaPlayer(parent);
  }
  
  void lancer() {

    if (audio_start_millis > 0) player_son.pause();
    player_son.setMediaFile(fichier_audio); //set the file (files are in data folder)
    player_son.setLooping(false); //restart playback end reached
    player_son.setVolume(1.0, 1.0); //Set left and right volumes. Range is from 0.0 to 1.0
    player_son.start();
    on = true;
    
    // controle de l'affichage du player_container
    audio_start_millis = millis();
    audio_tested = false;
    audio_a_jouer = 0;
    audio_length = 0;
  }
  
  void tester() {
    if ((millis() - audio_start_millis > 3000) && (!audio_tested)) {
      //println("ps1.tester() etape 1 " + audio_length);
      
      try {
        audio_length = player_son.getDuration();
        if (audio_length > 0) audio_tested = true;
      } catch (IllegalStateException ils) {
        System.err.println("IllegalStateException : " + ils.getMessage());
      } 
      //println("ps1.tester() etape 2 " + audio_length);
      //println("audio_length " + audio_length);
      
    }
    
    if (audio_length > 0) {
      //println("ps1.tester() test passé");
      /*
      textAlign(LEFT); textSize(18); fill(255);
      text(  "position : " + nf(player_son.getCurrentPosition(), 7)
           + " / "         + nf(player_son.getDuration(), 7), 650, 170); */
          
      if (millis() - audio_start_millis > audio_length + 1000) {
        //println("stop");
        stopper();
      }
    }
  }
  
  void stopper() {
    if (audio_start_millis > 0) {
        player_son.pause();
        audio_length = 0;
        audio_start_millis = 0;
        fichier_audio = "";
        audio_tested = false;
        on = false;
    }
  }
  
  boolean isPlaying() {
     return on;
  }
}


