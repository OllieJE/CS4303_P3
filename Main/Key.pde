class Key extends Interactable {
  color colour;
  String colourString;
  float size;
  float centred;
  
  Key(int x, int y, String colour, boolean centred, float tile_size, float proportionalSize, float shift) {
    super(x, y, tile_size, proportionalSize, shift);
    int[] colourRGB = COLOURS.get(colour);
    colourString = colour;
    this.colour = color(colourRGB[0], colourRGB[1], colourRGB[2]);
    size = tile_size*0.4;
    active = true;
    this.centred = centred ? 0.5 : 0;
    this.position.x += tile_size*this.centred;
    this.position.y += tile_size*this.centred;
  }
  
  String getEntityData() {
    String[] entityData = new String[5];
    entityData[0] = "k";
    entityData[1] = Integer.toString((int)tilePosition.x);
    entityData[2] = Integer.toString((int)tilePosition.y);
    entityData[3] = colourString;
    entityData[4] = centred > 0 ? "1" : "0";
    
    String csvData = String.join(",", entityData);
    return csvData;
  }
  
  void onCollision(Player p) {
    for (Gate g : gates) {
        if (g.colourString.equals(colourString)) {
          g.active = false;
          
        }
      }
      active = false;
  }
  
  void secondClick(int x, int y, float centred){};
  
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
