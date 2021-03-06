class Orbiter extends Interactable {
  float dir;
  float weight;
  float centred;
  float tile_size;
  float radians_per_frame;
  float clockwise;
  float radius;
  
  Orbiter(int x, int y, float init_dir, float weight, float speed, Boolean centred, boolean clockwise, float tile_size, float proportionalSize, float shift) {
    super(x, y, tile_size, proportionalSize, shift);
    this.tile_size = tile_size;
    this.dir = radians(init_dir);
    this.weight = weight;
    this.radians_per_frame = (TWO_PI/speed)/fps;
    this.centred = centred ? 0.5 : 0;
    this.position.x += tile_size*this.centred;
    this.position.y += tile_size*this.centred;
    this.clockwise = clockwise ? 1f : -1f;
    //this.size += this.centred*tile_size;
    
  }
  
  String getEntityData() {
    String[] entityData = new String[9];
    entityData[0] = "o";
    entityData[1] = Integer.toString((int)tilePosition.x);
    entityData[2] = Integer.toString((int)tilePosition.y);
    entityData[3] = Float.toString(radius);
    entityData[4] = "0";
    entityData[5] = Float.toString(weight);
    entityData[6] = "4";
    entityData[7] = centred > 0 ? "1" : "0";
    entityData[8] = clockwise > 0 ? "1" : "0";
    
    String csvData = String.join(",", entityData);
    return csvData;
  }
  
  void secondClick(int x, int y, float centred) {
    PVector endPoint = new PVector(x*tile_size + shift + centred*tile_size, y*tile_size + centred*tile_size);
    endPoint.sub(position);
    
    size = endPoint.mag();
    radius = endPoint.mag()/tile_size;
  }
  
  void draw() {
    stroke(200, 50, 0);
    strokeWeight(weight);
        
    pushMatrix();
    translate(position.x, position.y);
    
    rotate(dir);
    line(0, 0, 0, size);
    
    popMatrix();

    dir += radians_per_frame*clockwise;
    if (dir >= TWO_PI) {
      dir = 0;
    } else if (dir <= 0) {
      dir = TWO_PI;
    }
    
  }
  
  void onCollision(Player p) {
    loseLife();
  }
  
  Boolean collision (float x, float y, float objectSize) {
    
    float p1_x = position.x;
    float p1_y = position.y;
    
    float p2_x = position.x + size*cos(dir+HALF_PI);
    float p2_y = position.y + size*sin(dir+HALF_PI);
    
    return lineCircle(p1_x,p1_y, p2_x,p2_y, x,y,objectSize/2);
  
  }
}
