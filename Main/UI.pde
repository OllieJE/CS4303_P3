class UI {
  float shift;
  float levelWidth;
  float elementSpacing;
  
  UI(float shift, float levelWidth) {
    this.shift = shift;
    this.levelWidth = levelWidth;
    elementSpacing = levelWidth;
    
    
  }
  
  void draw() {
    if (screen == 1) {
      fill(0);
      strokeWeight(1);
      stroke(0);
      
      rect(shift, displayHeight-ui_height, elementSpacing, ui_height);
     
    }
  }
}
