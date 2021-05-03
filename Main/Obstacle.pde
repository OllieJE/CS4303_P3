abstract class Obstacle {
  
  PVector position;
  boolean active;
  
  Obstacle(float x, float y) {
    active = true;
    position = new PVector(x, y);
  }
  
  abstract void draw();
  
  abstract Boolean collision(Player p);
}
