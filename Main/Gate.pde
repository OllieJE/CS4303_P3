class Gate extends Obstacle {
  color colour;
  String colourString;
  int edge;
  float gateLength;
  PVector startPoint;
  PVector endPoint;
  
  Gate(float x, float y, String colour, int edge, float tile_size) {
    super(x, y);
    int[] colourRGB = COLOURS.get(colour);
    colourString = colour;
    this.colour = color(colourRGB[0], colourRGB[1], colourRGB[2]);
    this.edge = edge;
    gateLength = tile_size;
    
    startPoint = new PVector((edge==0 || edge==3) ? 0 : gateLength, (edge==0 || edge==3) ? 0 : gateLength);
    endPoint = new PVector((edge==2 || edge==3) ? 0 : gateLength, (edge==0 || edge==1) ? 0 : gateLength);
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
  
  Boolean collision (Player p) {
    if (!active) {
      return false;
    }
    // check if the player is colliding with either end of the line
    
    float p1_x = position.x+startPoint.x;
    float p1_y = position.y+startPoint.y;
    
    float dist_x = player.position.x - position.x;
    float dist_y = player.position.y - position.y;
    float distance = (float)Math.sqrt((dist_x*dist_x) + (dist_y*dist_y));
    
    if (distance <= player.size) {
      return true;
    }
    
    float p2_x = position.x + endPoint.x;
    float p2_y = position.y + endPoint.y;
    
    dist_x = player.position.x - p2_x;
    dist_y = player.position.y - p2_y;
    distance = (float)Math.sqrt((dist_x*dist_x) + (dist_y*dist_y));
    
    if (distance <= player.size) {
      return true;
    }
    
    // get closest point on unbounded line
    float dot = ( ((player.position.x-p1_x)*(p2_x-p1_x)) + ((player.position.y-p1_y)*(p2_y-p1_y)) ) / pow(gateLength,2);
    float closestX = p1_x + (dot * (p2_x-p1_x));
    float closestY = p1_y + (dot * (p2_y-p1_y));
    
    // check if the point found is on the line
    float p1_dist = dist(closestX, closestY, p1_x, p1_y);
    float p2_dist = dist(closestX, closestY, p2_x, p2_y);
    
    if (p1_dist+p2_dist >= gateLength && p1_dist+p2_dist <= gateLength) {
      dist_x = closestX - player.position.x;
      dist_y = closestY - player.position.y;
      distance = (float)Math.sqrt((dist_x*dist_x) + (dist_y*dist_y));
      if (distance <= player.size) {  
        return true;
      }
      
    } else {
      return false;
    }
    
    return false;
  }
}
