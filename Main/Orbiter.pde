class Orbiter extends Obstacle {
  float radius;
  float dir;
  float weight;
  float centred;
  float tile_size;
  float radians_per_frame;
  
  Orbiter(float x, float y, float radius, float init_dir, float weight, float speed, Boolean centred, float tile_size) {
    super(x, y);
    this.tile_size = tile_size;
    this.radius = radius*tile_size;
    this.dir = radians(init_dir);
    this.weight = weight;
    this.radians_per_frame = (TWO_PI/speed)/fps;
    this.centred = centred ? 0.5 : 0;
  }
  
  void draw() {
    stroke(200, 50, 0);
    strokeWeight(weight);
        
    pushMatrix();
    translate(position.x+tile_size*centred, position.y+tile_size*centred);
    
    rotate(dir);
    line(0, 0, 0, radius);
    
    popMatrix();
    
    dir += radians_per_frame;
    if (dir >= TWO_PI) {
      dir = 0;
    }
    
  }
  
  Boolean collision (Player p) {
    return false;
  }
}
