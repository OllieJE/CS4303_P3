class Level {
  
  int level_id;
  float tile_size;
  int tilesX;
  int tilesY;
  String[][] level_data;
  String[] entity_data_list;
    
  float horizontalShift;
  
  Level(int level_id) {
    this.level_id = level_id;
    create_ui();
    loadLevel();
  }
  
  void create_ui() {
    ui_elements = new ArrayList<UiElement>();
    ui_elements.add(new LifeIndicator(displayWidth/80, displayHeight/100, displayWidth/(PLAYER_SIZE_PROPORTION*1.2)));
  }
  
  void create_entities() {
    
    obstacles = new ArrayList<Obstacle>();
    keys = new ArrayList<Key>();
    gates = new ArrayList<Gate>();
    
    interactables = new ArrayList<Interactable>();
    
    for (String s : entity_data_list) {
      String[] entity_data = s.split(",");
      
      float x_pos = (tile_size*Integer.parseInt(entity_data[1])) + horizontalShift;
      float y_pos = tile_size*Integer.parseInt(entity_data[2]);
      
      switch (entity_data[0]) {
        case "p":
          int facing = Integer.parseInt(entity_data[3]);
          player = new Player(x_pos+tile_size/2, y_pos+tile_size/2, 0.8, friction, facing, tile_size);
          forceRegistry.add(player, friction);
          break;
        case "s":
          float seconds_alive = Float.parseFloat(entity_data[3]);
          float seconds_delay = Float.parseFloat(entity_data[4]);
          interactables.add(new Spikes(x_pos, y_pos, this, tile_size, seconds_alive, seconds_delay));
          break;
        case "o":
          float radius = Float.parseFloat(entity_data[3]);
          float init_dir = Float.parseFloat(entity_data[4]);
          float weight = Float.parseFloat(entity_data[5]);
          float speed = Float.parseFloat(entity_data[6]);
          Boolean centred = entity_data[7].equals("1");
          interactables.add(new Orbiter(x_pos, y_pos, this, radius, init_dir, weight, speed, centred, tile_size));
          break;
        case "c":
          int dx = Integer.parseInt(entity_data[3]);
          int dy = Integer.parseInt(entity_data[4]);
          float size = Float.parseFloat(entity_data[5]);
          speed = Float.parseFloat(entity_data[6]);
          float delay = Float.parseFloat(entity_data[7]);
          centred = entity_data[8].equals("1");
          interactables.add(new CircularSaw(x_pos, y_pos, this, tile_size*dx+horizontalShift, tile_size*dy, size, speed, delay, centred, tile_size));
          break;
        case "G":
          String colourString = entity_data[3];
          int edge = Integer.parseInt(entity_data[4]);
          Gate g = new Gate(x_pos, y_pos, this, colourString, edge, tile_size);
          interactables.add(g);
          gates.add(g);
          break;
        case "k":
          colourString = entity_data[3];
          interactables.add(new Key(x_pos, y_pos, this, colourString, tile_size));
          break;
        case "g":
          goal = new Goal(x_pos, y_pos, tile_size);
          break;
        case "j":
          interactables.add(new Springpad(x_pos, y_pos, this, tile_size));
          break;
      }
    }

  }
  
  void loadLevel() {
    String level_name = "levels/level_" + Integer.toString(level_id) + ".txt";
    String[] level_string_data = loadStrings(level_name);
    
    String entity_name = "levels/level_" + Integer.toString(level_id) + "_entities.txt";
    entity_data_list = loadStrings(entity_name);

    tilesX = level_string_data[0].length();
    tilesY = level_string_data.length;
    
    tile_size = (displayHeight-ui_height)/tilesY;
    horizontalShift = (displayWidth-(tile_size*tilesX))/2;
    //horizontalShift = 0;
    
    level_data = new String[tilesX][tilesY];
    
    for (int i = 0; i < level_string_data.length; i++) {
      level_data[i] = (level_string_data[i].split(""));
    }
    
    
    //entity_data = new String[tiles][tiles];
    
    //for (int i = 0; i < entity_string_data.length; i++) {
    //  entity_data[i] = (entity_string_data[i].split(""));
    //}
    
    create_entities();
    
  }
  
  //void handleCollision() {
  //  getOverlapping();
  
  //  for (Obstacle o : obstacles) {
  //    if (o.collision(player)) {
  //      current_level.create_entities();
  //    }
  //  }
    
  //  for (Key k : keys) {
  //    if (k.collision(player)) {
  //      for (Gate g : gates) {
  //        if (g.colourString.equals(k.colourString)) {
  //          g.active = false;
            
  //        }
  //      }
  //      k.active = false;
  //    }
  //  }
    
  //  if (goal.collision(player)) {
      
  //  }
  //}
  
  void draw() {
    strokeWeight(1);
    fill(0);
    
    for (int i = 0; i < tilesY; i++) {
      for (int j = 0; j < tilesX; j++) {
        switch(level_data[i][j]){
          case "0":
            stroke(0, 100, 200);
            fill(0, 100, 200);
            break;
          case "1":
            stroke(30, 203, 225);
            fill(30, 203, 225);
            break;
          case "2":
            stroke(200, 175, 120);
            fill(200, 175, 120);
            break;
          case "3":
            stroke(255);
            fill(255);
            break;
            
        }
        rect(j*tile_size+horizontalShift, i*tile_size, tile_size, tile_size);
      }
    }
    
    //for (Obstacle o : obstacles) {
    //  o.draw();
    //}
    
    //for (Key k : keys) {
    //  k.draw();
    //}
    
    for (Interactable i : interactables) {
      i.draw();
    }
    
    goal.draw();
    
    for (UiElement u : ui_elements) {
      u.draw();
    }
  }
  
  Boolean getOverlapping() {

    // get tile the center of the player is on, as well as the position of the player's center
    float player_pos_x = player.position.x;
    float player_pos_y = player.position.y;
    
    int tile_x = int((player_pos_x-horizontalShift)/tile_size);
    int tile_y = int(player_pos_y/tile_size);
    
    // TODO: FIX THIS TO HANDLE LEVEL CENTERING
    // check if player is out-of-bounds
    // check if player has gone too far left
    if (player_pos_x - player.size/2 <= horizontalShift) {
      //current_level.create_entities();
      return true;
    }
    // check if player has gone too far right
    
    else if (player_pos_x + player.size/2 >= horizontalShift+current_level.tilesX*tile_size) {
      //current_level.create_entities();
      return true;
    }
    // check if player has gone too far up
    if (player_pos_y - player.size/2 <= 0) {
      //current_level.create_entities();
      return true;
    }
    // check if player has gone too far down
    else if (player_pos_y + player.size/2 >= current_level.tilesY*tile_size) {
      //current_level.create_entities();
      return true;
    }
    
    // want to get the highest-friction tile the player is on
    float highest_friction = 1.0;
    
    // iterate through the nine tiles the player could be colliding with
    for (int i = (tile_y-1 >= 0 ? tile_y-1 : 0) ; i <= (tile_y+1 < current_level.tilesY ? tile_y+1 : current_level.tilesY-1); i++) {
      // if the player goes off the left or right edges of the level
      if (i < 0 || i >= current_level.tilesY) {
        //current_level.create_entities();
        return true;
      }
      
      for (int j = (tile_x-1 >= 0 ? tile_x-1 : 0) ; j <= (tile_x+1 < current_level.tilesX ? tile_x+1 : current_level.tilesX-1); j++) {
        if (j < 0 || j >= current_level.tilesX) {
          //current_level.create_entities();
          return true;
        }
                
        float closest_x = player_pos_x;
        float closest_y = player_pos_y;
        
        // if player is to the left of the tile, check left edge
        if (tile_x < j) {
          closest_x = j*tile_size+horizontalShift;
        }
        // if player it to the right of the tile, check right edge
        else if (tile_x > j) {
          closest_x = j*tile_size+tile_size+horizontalShift;
        }
        // if player is above tile, check top edge
        if (tile_y < i) {
          closest_y = i*tile_size;
        }
        // if player is below tile, check bottom edge
        else if (tile_y > i) {
          closest_y =  i*tile_size+tile_size;
        }
        
        float dist_x = player_pos_x - closest_x;
        float dist_y = player_pos_y - closest_y;
        float distance = (float)Math.sqrt((dist_x*dist_x) + (dist_y*dist_y));
        
        String tile_type = current_level.level_data[i][j];
        
        // && current_level.level_data[i][j].equals("0")
        if (distance < player.size/2)  {
          if (tile_type.equals("0")) {
            return true;
            //current_level.create_entities();
          } else if (TILE_FRICTIONS.keySet().contains(tile_type)) {
            if (TILE_FRICTIONS.get(tile_type) > highest_friction) {
              highest_friction = TILE_FRICTIONS.get(tile_type);
            }
            
          }
        }
        
      }
      
    }
    player.player_friction.c = coeffFriction*highest_friction;
    player.player_friction.c2 = coeffFriction*highest_friction;
    //popMatrix();
    
    return false;
  }
  
}
