class Goal {
  PVector position;
  float size;
  float angle;
  PImage img;
  
  float shift;
  float proportionalSize;
  PVector tilePosition;
  
  float tile_size;
  
  Goal(int x, int y, float tile_size, float proportionalSize, float shift) {
    tilePosition = new PVector(x, y);

    this.proportionalSize = proportionalSize;
    position = new PVector();
    updateSize(tile_size, shift);
    
    position = new PVector(position.x+tile_size/2, position.y+tile_size/2);
    angle = 0;
    img = loadImage("images/goal/goal.png");
  }
  
  String getEntityData() {
    String[] entityData = new String[3];
    entityData[0] = "g";
    entityData[1] = Integer.toString((int)tilePosition.x);
    entityData[2] = Integer.toString((int)tilePosition.y);
    
    String csvData = String.join(",", entityData);
    return csvData;
  }
  
  void updateSize(float tile_size, float shift) {    
    this.tile_size = tile_size;
    this.shift = shift;
    
    size = proportionalSize*this.tile_size;
    position.x = this.tile_size*tilePosition.x + this.shift;
    position.y = this.tile_size*tilePosition.y;
    
  }
  
  Boolean collision(float x, float y, float objectSize) {
    return position.dist(new PVector(x, y)) <= size/2+objectSize/2;
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
