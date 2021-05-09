class Key extends Interactable {
  color colour;
  String colourString;
  float size;
  
  Key(float x, float y, Level level, String colour, float tile_size) {
    super(x, y, level);
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
  
  Boolean collision(Player p) {
    if (!active) {
      return false;
    }
    return (p.position.dist(position) <= p.size || p.position.dist(position) <= size);
    
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
