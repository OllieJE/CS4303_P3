class LevelEditor {
  ArrayList<ArrayList<String>> levelData;
  float tile_size;
  int rowCount;
  int columnCount;
  ArrayList<String[]> entityData;
  float horizontalShift;
  
  LevelEditor() {
    
    rowCount = 0;
    columnCount = 0;
    levelData = new ArrayList<ArrayList<String>>();
    entityData = new ArrayList<String[]>();
    for (int i = 0; i < 10; i++) {
      addRow();
    }
    for (int i = 0; i < 10; i++) {
      addColumn();
    }
    updateTileSize();
  }
  
  void updateTileSize() {
    tile_size = (displayHeight-ui_height)/rowCount;
    horizontalShift = (displayWidth-(tile_size*columnCount))/2;
  }
  
  void addRow() {
    ArrayList newRow = new ArrayList<String>();
    for (int i = 0; i < columnCount; i++) {
      newRow.add("0");
    }
    rowCount++;
    levelData.add(newRow);
    updateTileSize();
  }
  
  void addColumn() {
    for (int i = 0; i < rowCount; i++) {
      levelData.get(i).add("0");
    }
    columnCount++;
    updateTileSize();
  }
  
  void removeRow() {
    HashSet<String[]> entitiesToRemove = new HashSet<String[]>();
    for (String[] e : entityData) {
      int yPos = Integer.parseInt(e[2]);
      // check if entity is on the row that is being deleted
      if (yPos == levelData.size()-1) {  
        entitiesToRemove.add(e);
      }
      // circular saw can move onto the deleted row
      if (e[0].equals("c")) {
        if (Integer.parseInt(e[4]) == levelData.size()-1) {
          entitiesToRemove.add(e);
        }
      }
    }
    
    for (String[] e : entitiesToRemove) {
      entityData.remove(e);
    }
    rowCount--;
    levelData.remove(levelData.size()-1);
    updateTileSize();
  }
  
  void removeColumn() {
    HashSet<String[]> entitiesToRemove = new HashSet<String[]>();
    for (String[] e : entityData) {
      int xPos = Integer.parseInt(e[1]);
      // check if entity is on the row that is being deleted
      if (xPos == levelData.get(0).size()-1) {  
        entitiesToRemove.add(e);
      }
      // circular saw can move onto the deleted row
      if (e[0].equals("c")) {
        if (Integer.parseInt(e[4]) == levelData.get(0).size()-1) {
          entitiesToRemove.add(e);
        }
      }
    }
    
    for (String[] e : entitiesToRemove) {
      entityData.remove(e);
    }
    columnCount--;
    
    for (int i = 0; i < rowCount; i++) {
      levelData.get(i).remove(levelData.get(0).size()-1);
    }
    updateTileSize();
  }
  
  void draw() {
    strokeWeight(1);
    stroke(0);
    fill(0);
    
    for (int i = 0; i < rowCount; i++) {
      for (int j = 0; j < columnCount; j++) {
        switch(levelData.get(i).get(j)){
          case "0":
            //stroke(0, 100, 200);
            fill(0, 100, 200);
            break;
          case "1":
            //stroke(30, 203, 225);
            fill(30, 203, 225);
            break;
          case "2":
            //stroke(200, 175, 120);
            fill(200, 175, 120);
            break;
          case "3":
            //stroke(255);
            fill(255);
            break;
            
        }
        rect(j*tile_size+horizontalShift, i*tile_size, tile_size, tile_size);
      }
    }
  }
  
}
