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
    p.position.x += p.velocity.x*-1;
    p.position.y += p.velocity.y*-1;
    p.velocity.mult(0);
    p.acceleration.mult(0);
  }
  
  Boolean collision (float x, float y, float objectSize) {
    if (!active) {
      return false;
    }
    // check if the player is colliding with either end of the line
    
    float p1_x = position.x+startPoint.x;
    float p1_y = position.y+startPoint.y;
    
    float dist_x = x - position.x;
    float dist_y = y - position.y;
    float distance = (float)Math.sqrt((dist_x*dist_x) + (dist_y*dist_y));
    
    if (distance <= objectSize) {
      return true;
    }
    
    float p2_x = position.x + endPoint.x;
    float p2_y = position.y + endPoint.y;
    
    dist_x = x - p2_x;
    dist_y = y - p2_y;
    distance = (float)Math.sqrt((dist_x*dist_x) + (dist_y*dist_y));
    
    if (distance <= objectSize) {
      return true;
    }
    
    // get closest point on unbounded line
    float dot = ( ((x-p1_x)*(p2_x-p1_x)) + ((y-p1_y)*(p2_y-p1_y)) ) / pow(gateLength,2);
    float closestX = p1_x + (dot * (p2_x-p1_x));
    float closestY = p1_y + (dot * (p2_y-p1_y));
    
    // check if the point found is on the line
    float p1_dist = dist(closestX, closestY, p1_x, p1_y);
    float p2_dist = dist(closestX, closestY, p2_x, p2_y);
    
    if (p1_dist+p2_dist >= gateLength && p1_dist+p2_dist <= gateLength) {
      dist_x = closestX - x;
      dist_y = closestY - y;
      distance = (float)Math.sqrt((dist_x*dist_x) + (dist_y*dist_y));
      if (distance <= objectSize) {  
        return true;
      }
      
    } else {
      return false;
    }
    
    return false;
  }
}
