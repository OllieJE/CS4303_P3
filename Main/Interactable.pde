abstract class Interactable {
  PVector position;
  boolean active;
  Level level;
  
  Interactable(float x, float y, Level level) {
      position = new PVector(x, y);
      active = true;
      this.level = level;
  }
  
  abstract void onCollision();
  
  abstract Boolean collision(Player p);
  
  abstract void draw();
}
