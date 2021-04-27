class Level {
  
  // 0 = wall
  // 1 = default path
  // 2 = high-friction ground
  // p = player start
  // g = goal
  
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
          player = new Player(tile_size*x_pos+tile_size/2, tile_size*y_pos+tile_size/2, 0.8);
          break;
        case "s":
          obstacles.add(new Spikes(tile_size*x_pos, tile_size*y_pos, tile_size));
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
            stroke(20);
            fill(20);
            break;
          case "1":
            stroke(50, 180, 50);
            fill(50, 180, 50);
            break;
            
        }
        rect(j*tile_size, i*tile_size, tile_size, tile_size);
      }
    }
  }
  
}
