class Spikes extends Obstacle {
  
  int state;  
  int max_state = 5;
  float size;
  float increment;
  float time_alive;
  float time_delay;
  Boolean active;
  int timer;
  
  Spikes(float x, float y, float tile_size, float seconds_alive, float seconds_delay) {
    super(x, y);
    this.size = tile_size/(SPIKES_PER_TILE*2.2);  
    this.increment = tile_size/(SPIKES_PER_TILE+1);  // how many "gaps" there are between each layer of spikes and the edges of the tile
    time_alive = fps*seconds_alive;
    time_delay = fps*seconds_delay;
    active = true;
    state = max_state;
    timer = 0;
  }
  
  void draw() {
    stroke(0);
    fill(50);
    
    strokeWeight(1);
    
    pushMatrix();
    translate(position.x, position.y);  // top left of tile the spikes are on
    
    if (active && state < max_state) {
      state++;
    } else if (!active && state > 0) {
      state--;
    }
        
    for (int i = 1; i <= SPIKES_PER_TILE; i++) {
      for (int j = 1; j <= SPIKES_PER_TILE; j++) {
        pushMatrix();
        translate(i*increment, j*increment);  // translate to centre of triangle
        
        float animation_state = (float) ((float)state/ (float)max_state);
        
        
        triangle((size*-1)*animation_state, size, 0, size+(size*-2*animation_state), (size)*animation_state, size);
        //line(size*-1, size, size, size); // lines signifying the spikes are there. Makes the game look kinda bad, so keeping them out.
        popMatrix();
      }
    }
    
    popMatrix();
    
    timer++;
    if (active) {
      if (timer >= time_alive) {
        active = false;
        timer = 0;
      }
    } else {
      if (timer >= time_delay) {
        active = true;
        timer = 0;
      }
    }
    //// TODO : REMOVE LATER. THIS IS JUST FOR TESTING
    //state += going_up ? 1 : -1;
    //if (state == 0) {going_up = true;};
    //if (state == max_state) {going_up = false;};
    ////state = (state+1)%max_state;
  }
  
  Boolean collision(Player p) {
    return false;
  }
}
