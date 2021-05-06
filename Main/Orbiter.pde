class Orbiter extends Interactable {
  float radius;
  float dir;
  float weight;
  float centred;
  float tile_size;
  float radians_per_frame;
  
  Orbiter(float x, float y, Level level, float radius, float init_dir, float weight, float speed, Boolean centred, float tile_size) {
    super(x, y, level);
    this.tile_size = tile_size;
    this.radius = radius*tile_size;
    this.dir = radians(init_dir);
    this.weight = weight;
    this.radians_per_frame = (TWO_PI/speed)/fps;
    this.centred = centred ? 0.5 : 0;
    this.position.x += tile_size*this.centred;
    this.position.y += tile_size*this.centred;
    
    this.radius += this.centred*tile_size;
  }
  
  void draw() {
    stroke(200, 50, 0);
    strokeWeight(weight);
        
    pushMatrix();
    translate(position.x, position.y);
    
    rotate(dir);
    line(0, 0, 0, radius);
    
    popMatrix();
    
    dir += radians_per_frame;
    if (dir >= TWO_PI) {
      dir = 0;
    }
    
  }
  
  void onCollision() {
    loseLife();
  }
  
  Boolean collision (Player p) {
    // check if the player is colliding with either end of the line
    
    float p1_x = position.x;
    float p1_y = position.y;
    
    float dist_x = player.position.x - position.x;
    float dist_y = player.position.y - position.y;
    float distance = (float)Math.sqrt((dist_x*dist_x) + (dist_y*dist_y));
    
    if (distance <= player.size) {
      return true;
    }
    
    float p2_x = position.x + radius*cos(dir+HALF_PI);
    float p2_y = position.y + radius*sin(dir+HALF_PI);
    
    dist_x = player.position.x - p2_x;
    dist_y = player.position.y - p2_y;
    distance = (float)Math.sqrt((dist_x*dist_x) + (dist_y*dist_y));
    
    if (distance <= player.size) {
      return true;
    }
    
    // get closest point on unbounded line
    float dot = ( ((player.position.x-p1_x)*(p2_x-p1_x)) + ((player.position.y-p1_y)*(p2_y-p1_y)) ) / pow(radius,2);
    float closestX = p1_x + (dot * (p2_x-p1_x));
    float closestY = p1_y + (dot * (p2_y-p1_y));
    
    // check if the point found is on the line
    float p1_dist = dist(closestX, closestY, p1_x, p1_y);
    float p2_dist = dist(closestX, closestY, p2_x, p2_y);
    
    if (p1_dist+p2_dist >= radius && p1_dist+p2_dist <= radius) {
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
