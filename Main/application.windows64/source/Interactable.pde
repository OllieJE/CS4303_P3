abstract class Interactable {
  PVector position;
  PVector tilePosition;
  boolean active;
  float size;
  float proportionalSize;
  float tile_size;
  float shift;
  
  Interactable(int x, int y, float tile_size, float proportionalSize, float shift) {
      tilePosition = new PVector(x, y);
      active = true;
      this.proportionalSize = proportionalSize;
      position = new PVector();
      updateSize(tile_size, shift);
  }
  
  abstract String getEntityData();
    
  void updateSize(float tile_size, float shift) {    
    this.tile_size = tile_size;
    this.shift = shift;
    size = proportionalSize*this.tile_size;
    position.x = this.tile_size*tilePosition.x + this.shift;
    position.y = this.tile_size*tilePosition.y;
    
  }
    
  abstract void secondClick(int x, int y, float centred);
    
  abstract void onCollision(Player p);
  
  abstract Boolean collision(float x, float y, float objectSize);
  
  abstract void draw();
}
