class Goal {
  PVector position;
  float size;
  float angle;
  PImage img;
  
  Goal(float x, float y, float tile_size) {
    position = new PVector(x+tile_size/2, y+tile_size/2);
    size = tile_size*0.6;
    angle = 0;
    img = loadImage("images/goal/goal.png");
  }
  
  Boolean collision(Player p) {
    return position.dist(p.position) <= size/2+player.size/2;
  }
  
  void draw() {
    pushMatrix();
    translate(position.x, position.y);
    rotate(angle);
    angle += PI/128;
    if (angle >= TWO_PI) {
      angle = TWO_PI-angle;
    }
    image(img, -size/2, -size/2, size, size);
    popMatrix();
  }
  
}
