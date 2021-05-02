class Level {
  
  int level_id;
  float tile_size;
  int tiles;
  String[][] level_data;
  String[] entity_data_list;
  
  Level(int level_id) {
    this.level_id = level_id;
    loadLevel();
  }
  
  void create_entities() {
    
    obstacles = new ArrayList<Obstacle>();
    
    for (String s : entity_data_list) {
      String[] entity_data = s.split(",");
      
      int x_pos = Integer.parseInt(entity_data[1]);
      int y_pos = Integer.parseInt(entity_data[2]);
      
      switch (entity_data[0]) {
        case "p":
          player = new Player(tile_size*x_pos+tile_size/2, tile_size*y_pos+tile_size/2, 0.8, friction);
          forceRegistry.add(player, friction);
          break;
        case "s":
          float seconds_alive = Float.parseFloat(entity_data[3]);
          float seconds_delay = Float.parseFloat(entity_data[4]);
          obstacles.add(new Spikes(tile_size*x_pos, tile_size*y_pos, tile_size, seconds_alive, seconds_delay));
          break;
        case "o":
          float radius = Float.parseFloat(entity_data[3]);
          float init_dir = Float.parseFloat(entity_data[4]);
          float weight = Float.parseFloat(entity_data[5]);
          float speed = Float.parseFloat(entity_data[6]);
          Boolean centred = entity_data[7].equals("1");
          obstacles.add(new Orbiter(tile_size*x_pos, tile_size*y_pos, radius, init_dir, weight, speed, centred, tile_size));
          break;
      }
    }

  }
  
  void loadLevel() {
    String level_name = "levels/level_" + Integer.toString(level_id) + ".txt";
    String[] level_string_data = loadStrings(level_name);
    
    String entity_name = "levels/level_" + Integer.toString(level_id) + "_entities.txt";
    entity_data_list = loadStrings(entity_name);

    
    tiles = level_string_data.length;
    
    tile_size = displayHeight/tiles;
    
    level_data = new String[tiles][tiles];
    
    for (int i = 0; i < level_string_data.length; i++) {
      level_data[i] = (level_string_data[i].split(""));
    }
    
    
    //entity_data = new String[tiles][tiles];
    
    //for (int i = 0; i < entity_string_data.length; i++) {
    //  entity_data[i] = (entity_string_data[i].split(""));
    //}
    
    create_entities();
    
  }
  
  void draw() {
    strokeWeight(1);
    fill(0);
    
    for (int i = 0; i < tiles; i++) {
      for (int j = 0; j < tiles; j++) {
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
            
        }
        rect(j*tile_size, i*tile_size, tile_size, tile_size);
      }
    }
  }
  
}
