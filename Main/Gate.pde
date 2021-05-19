class Gate extends Interactable {
  color colour;
  String colourString;
  int edge;
  float gateLength;
  PVector startPoint;
  PVector endPoint;
  
  Gate(int x, int y, String colour, int edge, float tile_size, float proportionalSize, float shift) {
    super(x, y, tile_size, proportionalSize, shift);
    int[] colourRGB = COLOURS.get(colour);
    colourString = colour;
    this.colour = color(colourRGB[0], colourRGB[1], colourRGB[2]);
    this.edge = edge;
    gateLength = tile_size;
    
    startPoint = new PVector((edge==0 || edge==3) ? 0 : gateLength, (edge==0 || edge==3) ? 0 : gateLength);
    endPoint = new PVector((edge==2 || edge==3) ? 0 : gateLength, (edge==0 || edge==1) ? 0 : gateLength);
  }
  
  void secondClick(int x, int y, float centred){};
  
  String getEntityData() {
    String[] entityData = new String[5];
    entityData[0] = "G";
    entityData[1] = Integer.toString((int)tilePosition.x);
    entityData[2] = Integer.toString((int)tilePosition.y);
    entityData[3] = colourString;
    entityData[4] = Integer.toString(edge);
    
    String csvData = String.join(",", entityData);
    return csvData;
  }
  
  void draw() {
    if (active) {
       stroke(colour);
       fill(colour);
       strokeWeight(3);
       
       pushMatrix();
       translate(position.x, position.y);
        
       line(startPoint.x, startPoint.y, endPoint.x, endPoint.y);
       
       popMatrix();
    }
  }
  
  void onCollision(Player p) {
    loseLife();
    //p.position.x += p.velocity.x*-0.3;
    //p.position.y += p.velocity.y*-0.3;
    //p.position.x += p.velocity.x*-1;
    //p.position.y += p.velocity.y*-1;
    //p.velocity.mult(0);
    //p.acceleration.mult(0);
  }
  
  Boolean collision (float x, float y, float objectSize) {
    if (!active) {
      return false;
    }
    float p1_x = position.x + startPoint.x;
    float p1_y = position.y + startPoint.y;
    float p2_x = position.x + endPoint.x;
    float p2_y = position.y + endPoint.y;
    
    return lineCircle(p1_x,p1_y, p2_x,p2_y, x,y,objectSize/2);
    
  }
}
