class Level {
  
  int level_id;
  float tile_size;
  float tile_size_proportion;
  String[] level_data;
  
  Level(int level_id) {
    this.level_id = level_id;
    loadLevel();
  }
  
  
  void loadLevel() {
    String level_name = "levels/level_" + Integer.toString(level_id) + ".txt";
    level_data = loadStrings(level_name);
    tile_size_proportion = level_data.length;
    
    tile_size = displayWidth/tile_size_proportion;
    
    println("there are " + level_data.length + " lines");
    for (int i = 0 ; i < level_data.length; i++) {
      println(level_data[i]);
    }
  }
  
}
