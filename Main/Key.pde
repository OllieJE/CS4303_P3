class Key extends Interactable {
  color colour;
  String colourString;
  float size;
  
  Key(int x, int y, String colour, float tile_size, float proportionalSize, float shift) {
    super(x, y, tile_size, proportionalSize, shift);
    int[] colourRGB = COLOURS.get(colour);
    colourString = colour;
    this.colour = color(colourRGB[0], colourRGB[1], colourRGB[2]);
    size = tile_size*0.4;
    active = true;
  }
  
  void onCollision(Player p) {
    for (Gate g : gates) {
        if (g.colourString.equals(colourString)) {
          g.active = false;
          
        }
      }
      active = false;
  }
  
  Boolean collision(float x, float y, float objectSize) {
    if (!active) {
      return false;
    }
    return position.dist(new PVector(x, y)) <= size/2+objectSize/2;
    
  }
  
  void draw() {
    if (active) {
      strokeWeight(0);
      stroke(colour);
      fill(colour);
      
      circle(position.x, position.y, size);
    }
  }
}
