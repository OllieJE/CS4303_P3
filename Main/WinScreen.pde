class WinScreen {
  void draw() {
    int[] bg = COLOURS.get("darkblue");
    background(bg[0], bg[1], bg[2]);
    textSize(text_size*2);
    
    textAlign(CENTER);
    fill(225);
    text("You win!", displayWidth/2, displayHeight/3);
    
    StringBuilder time = new StringBuilder();
    time.append("\nYour time: " );
    time.append(Long.toString((runTime/1000)/60));
    time.append(" minutes and ");
    time.append(Long.toString((runTime/1000)%60));
    time.append(" seconds.");
    
    text(time.toString(), displayWidth/2, displayHeight/3);
    
    textSize(text_size);
    text("\n\n\n\nPress enter to continue", displayWidth/2, displayHeight/3);
  }
}
