abstract class Interactable {
  PVector position;
  boolean active;
  
  Interactable(float x, float y) {
      position = new PVector(x, y);
      active = true;
  }
  
  abstract void onCollision(Player p);
  
  abstract Boolean collision(Player p);
  
  abstract void draw();
}
