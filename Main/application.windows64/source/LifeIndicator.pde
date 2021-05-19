class LifeIndicator extends UiElement {
  float size;
  PImage img;
  
  LifeIndicator(float x, float y, float size) {
    super(x, y);
    this.size = size;
    
    img = loadImage("images/crab/crab0000.png");
  }
  
  void draw() {
    float xPos = position.x;
    float yPos = position.y;
    for (int i = 0; i < lives; i++) {
      image(img, xPos, yPos, size, size);
      xPos += size + size/2;
    }
  }
}
