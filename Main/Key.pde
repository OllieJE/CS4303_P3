class Key {
  PVector position;
  color colour;
  String colourString;
  float size;
  boolean active;
  
  Key(float x, float y, String colour, float tile_size) {
    position = new PVector(x+tile_size/2, y+tile_size/2);
    int[] colourRGB = COLOURS.get(colour);
    colourString = colour;
    this.colour = color(colourRGB[0], colourRGB[1], colourRGB[2]);
    size = tile_size*0.4;
    active = true;
  }
  
  boolean collision(Player p) {
    if (!active) {
      return false;
    }
    return (p.position.dist(position) <= p.size/2 || p.position.dist(position) <= size/2);
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
