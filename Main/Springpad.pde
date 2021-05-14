class Springpad extends Interactable {
  float centred;
  
  Springpad(int x, int y, boolean centred, float tile_size, float proportionalSize, float shift) {
    
    super(x, y, tile_size, proportionalSize, shift);
        
    this.centred = centred ? 0.5 : 0;
    this.position.x += tile_size*this.centred;
    this.position.y += tile_size*this.centred;
    
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
  
  void secondClick(int x, int y, float centred){};
  
  Boolean collision(float x, float y, float objectSize) {
    return (position.dist(new PVector(x, y)) <= objectSize/2);
  }
}
