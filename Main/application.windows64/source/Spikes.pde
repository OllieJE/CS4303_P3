class Spikes extends Interactable {
  
  int state;  
  int max_state = 5;
  float size;
  float increment;
  float time_alive;
  float time_delay;
  float tile_size;
  Boolean active;
  int timer;
  float startTime;
  float timeUntilStart;
  
  Spikes(int x, int y, float tile_size, float seconds_alive, float seconds_delay, float proportionalSize, float shift, float startTime) {
    super(x, y, tile_size, proportionalSize, shift);
    this.size = tile_size/(SPIKES_PER_TILE*2.2);  
    this.increment = tile_size/(SPIKES_PER_TILE+1);  // how many "gaps" there are between each layer of spikes and the edges of the tile
    time_alive = fps*seconds_alive;
    time_delay = fps*seconds_delay;
    this.tile_size = tile_size;
    
    
    active = true;
    state = max_state;
    timer = 0;
    
    this.startTime = startTime;
    this.timeUntilStart = fps*startTime;
  }
  
  String getEntityData() {
    String[] entityData = new String[6];
    entityData[0] = "s";
    entityData[1] = Integer.toString((int)tilePosition.x);
    entityData[2] = Integer.toString((int)tilePosition.y);
    entityData[3] = "2";
    entityData[4] = "2";
    entityData[5] = Float.toString(startTime);
    String csvData = String.join(",", entityData);
    return csvData;
  }
  
  void secondClick(int x, int y, float centred){};
  
  void draw() {
    if (timeUntilStart > 0) timeUntilStart--;
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
    
    if (timeUntilStart == 0) {
      timer++;
      if (active) {
        if (timer >= time_alive) {
          active = false;
          timer = 0;
        }
      } else if (timer >= time_delay) {
          active = true;
          timer = 0;
        
      }
    }
  }
  
  void onCollision(Player p) {
    loseLife();
  }
  
  Boolean collision(float x, float y, float objectSize) {
    
    // only check if the spikes are active
    if (active) {
      float player_pos_x = x;
      float player_pos_y = y;
      
      float closest_x = player_pos_x;
      float closest_y = player_pos_y;
      
      // check if player is inside the spikes (i.e. spikes become active with player on top)
      if (x >= position.x && x <= position.x+tile_size && y >= position.y && y <= position.y+tile_size) {
        return true;
      }
      
      // check if player is to the left of the spikes
      if (x < position.x) {
        closest_x = position.x;
      }
      // check if player is to the right of the spikes
      else if (x > position.x+tile_size) {
        closest_x = position.x+tile_size;
      }
      // check if player is above the spikes
      if (y < position.y) {
        closest_y = position.y;
      }
      // check if player is below the spikes
      else if (y >= position.y+tile_size) {
        closest_y = position.y+tile_size;
      }
      
      float dist_x = player_pos_x - closest_x;
      float dist_y = player_pos_y - closest_y;
      float distance = (float)Math.sqrt((dist_x*dist_x) + (dist_y*dist_y));
      
      if (distance < objectSize/2)  {
        return true;
      }
    }
    return false;
  }
}
