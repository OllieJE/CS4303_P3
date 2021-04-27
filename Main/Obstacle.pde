abstract class Obstacle {
  
  PVector position;
  
  Obstacle(float x, float y) {
    position = new PVector(x, y);
  }
  
  abstract void draw();
  
  abstract Boolean collision(Player p);
}
