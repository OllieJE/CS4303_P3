class Springpad extends Interactable {
  float size;
  
  Springpad(float x, float y, Level level, float tile_size) {
    super(x+tile_size/2, y+tile_size/2, level);
    size = tile_size/2;
  }
  
  void draw() {
    stroke(0);
    fill(100);
    strokeWeight(1);
    
    circle(position.x, position.y, size);
  }
  
  void onCollision(Player p) {
    player.jump();
  }
  
  Boolean collision(Player p) {
    return (position.dist(player.position) <= size/2);
  }
}
