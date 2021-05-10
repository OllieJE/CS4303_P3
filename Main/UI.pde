class UI {
  float shift;
  float levelWidth;
  float elementSize;
  float elementPadding;
  
  PImage boostIcon;
  PImage sandIcon;
  
  UI(float shift, float levelWidth) {
    this.shift = shift;
    this.levelWidth = levelWidth;
    elementSize = ui_height*0.8;
    elementPadding = ui_height*0.1;
    boostIcon = loadImage("images/abilities/boost.png");
    sandIcon = loadImage("images/abilities/sand.png");
  }
  
  void draw() {
    if (screen == 1) {
      fill(0);
      strokeWeight(1);
      stroke(0);
      
      pushMatrix();
      translate(shift, displayHeight-ui_height);
      rect(0, 0, levelWidth, ui_height);
       
      // draw boost icon, icon border and cooldown indicator
      image(boostIcon, elementPadding, elementPadding, elementSize, elementSize);
      fill(100,100,100,100);
      strokeWeight(0);
      rect(0, 0, ui_height*((float)player.boostCooldown/ (float) player.boostCooldownMax), ui_height);
      
      noFill();
      strokeWeight(2);
      stroke(255);
      rect(0, 0, ui_height, ui_height);
      
      // draw sand icon, icon border and cooldown indicator
      image(sandIcon, ui_height+elementPadding, elementPadding, elementSize, elementSize);
      fill(100,100,100,100);
      strokeWeight(0);
      rect(ui_height, 0, ui_height*((float)player.sandCooldown/ (float) player.sandCooldownMax), ui_height);
      
      noFill();
      strokeWeight(2);
      stroke(255);
      rect(ui_height, 0, ui_height, ui_height);
      
      popMatrix();
    }
  }
}
