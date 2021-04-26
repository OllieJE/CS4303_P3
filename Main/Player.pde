class Player extends Rigid_Body {
  
  float size;
  
  Player(float x, float y, float m) {
    super(x, y, m);
    this.size = displayWidth/PLAYER_SIZE_PROPORTION;
    //position.x -= this.size/2;
    //position.y -= this.size/2;
  }
  
  void draw() {
    stroke(150, 50, 50);
    fill(150, 50, 50);
    circle(position.x, position.y, size);
  }

}
