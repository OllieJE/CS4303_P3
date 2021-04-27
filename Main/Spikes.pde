class Spikes extends Obstacle {
  
  Boolean going_up;
  int state;  // five frames of animation. 0 = all the way down, 5 = all the way up
  int max_state = 10;
  float size;
  float increment;
  
  Spikes(float x, float y, float tile_size) {
    super(x, y);
    this.size = tile_size/(SPIKES_PER_TILE*2.1);  
    this.increment = tile_size/(SPIKES_PER_TILE+1);  // how many "gaps" there are between each layer of spikes and the edges of the tile
    this.state = 5;
    going_up = false;
  }
  
  void draw() {
    stroke(0);
    fill(50);
    
    strokeWeight(1);
    
    pushMatrix();
    translate(position.x, position.y);  // top left of tile the spikes are on
        
    for (int i = 1; i <= SPIKES_PER_TILE; i++) {
      for (int j = 1; j <= SPIKES_PER_TILE; j++) {
        pushMatrix();
        translate(i*increment, j*increment);  // translate to centre of triangle
        
        float animation_state = (float) ((float)state/ (float)max_state);
        
        
        triangle((size*-1)*animation_state, size, 0, size+(size*-2*animation_state), (size)*animation_state, size);
        popMatrix();
      }
    }
    
    popMatrix();
    
    
    // TODO : REMOVE LATER. THIS IS JUST FOR TESTING
    state += going_up ? 1 : -1;
    if (state == 0) {going_up = true;};
    if (state == max_state) {going_up = false;};
    //state = (state+1)%max_state;
  }
  
  Boolean collision(Player p) {
    return false;
  }
}
