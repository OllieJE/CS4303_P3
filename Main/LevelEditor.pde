class LevelEditor {
  ArrayList<ArrayList<String>> levelData;
  float tile_size;
  int rowCount;
  int columnCount;
  ArrayList<String[]> entityData;
  float horizontalShift;

  int activeTile;

  PImage sawIcon;
  PImage gateKeyIcon;
  PImage orbiterCWIcon;
  PImage orbiterACWIcon;
  PImage springpadIcon;
  PImage spikeIcon;
  PImage colliderIcon;
  
  ArrayList<PImage> entityImages;

  LevelEditor() {
    interactables = new ArrayList<Interactable>();
    activeTile = 1;
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

    sawIcon = loadImage("images/saw/saw0001.png");
    gateKeyIcon  = loadImage("images/gatekey/gatekey0000.png");
    orbiterCWIcon = loadImage("images/orbiter/orbiterCW.png");
    orbiterACWIcon = loadImage("images/orbiter/orbiterACW.png");
    springpadIcon = loadImage("images/jumppad/jumppad0000.png");
    spikeIcon = loadImage("images/spikes/spikes0000.png");
    colliderIcon = loadImage("images/collider/collider0000.png");
    
    entityImages = new ArrayList<PImage>() {{
      add(sawIcon);
      add(gateKeyIcon);
      add(orbiterCWIcon);
      add(orbiterACWIcon);
      add(springpadIcon);
      add(spikeIcon);
      add(colliderIcon);
    }};
    
  }

  void changeTile(int x, int y) {
    String newTile = "0";
    switch (activeTile) {
      case 0:
        newTile = "0";
        break;
      case 1:
        newTile = "1";
        break;
      case 2:
        newTile = "2";
        break;
      case 3:
        newTile = "3";
        break;
      case 4:
        break;
      default:
        newTile = "0";
    }
    levelData.get(y).set(x, newTile);
    
  }

  int[] getTilePos(float x, float y) {
    int[] tilePos = new int[2];

    // ternary operators are there as java rounds -1 < x < 0 to 0
    tilePos[0] = (int) (((x - horizontalShift)/tile_size) >= 0 ? (x - horizontalShift)/tile_size : -100);
    tilePos[1] = (int) ((y)/tile_size >= 0 ? y/tile_size : -100);
    return tilePos;
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
    // not an exact check since tile_size changes but it'll do
    if ((columnCount+1)*tile_size <= displayWidth) {
      for (int i = 0; i < rowCount; i++) {
        levelData.get(i).add("0");
      }
      columnCount++;
      updateTileSize();
    }
  }

  void removeRow() {
    if (rowCount > 1) {
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
  }

  void removeColumn() {
    if (columnCount  > 1) {
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
        levelData.get(i).remove(levelData.get(i).size()-1);
      }
      updateTileSize();
    }
  }
  
  void handleClick(float x, float y) {
    // check if mouse was clicked in UI bar or above it
    if (y <= (displayHeight-ui_height)) {
      int[] xy = getTilePos(x, y);
      
      if (xy[0] >= 0 && xy[0] < columnCount && xy[1] >= 0 && xy[1] < rowCount) {
        changeTile(xy[0], xy[1]);
      }
    } else {
      // check if one of the four tile types was clicked
      // dont need to check y value of mouse as we already have 
      for (int i = 0; i < 5; i++) {
        float boundLeft = i*(displayWidth/TILE_TYPES);
        float boundRight = boundLeft + ui_height;
        if (x >= boundLeft && x <= boundRight) {
          activeTile = i;
        }
      }
      
    }
  }

  void draw() {
    strokeWeight(1);
    stroke(0);
    fill(0);

    for (int i = 0; i < rowCount; i++) {
      for (int j = 0; j < columnCount; j++) {
        switch(levelData.get(i).get(j)) {
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

    pushMatrix();
    translate(0, displayHeight-ui_height);
    strokeWeight(0);
    stroke(0);
    fill(0);
    rect(0, 0, displayWidth, ui_height);

    // draw the UI
    String[] tiles = new String[]{"darkblue", "lightblue", "yellow", "white"};
    int offset = 0;
    int[] colorRGB;

    strokeWeight(3);
    // draw the four tile types
    for (String t : tiles) {
      if (activeTile == offset) {
        colorRGB = COLOURS.get("red");
      } else {
        colorRGB = COLOURS.get("grey");
      }
      stroke(colorRGB[0], colorRGB[1], colorRGB[2]);
      colorRGB = COLOURS.get(t);
      fill(colorRGB[0], colorRGB[1], colorRGB[2]);
      //stroke(colorRGB[0], colorRGB[1], colorRGB[2]);
      rect(offset*(displayWidth/TILE_TYPES), 0, ui_height, ui_height); 
      offset++;
    }

    // draw the six entity types
    for (PImage p : entityImages) {
      if (activeTile == offset) {
        colorRGB = COLOURS.get("red");
      } else {
        colorRGB = COLOURS.get("grey");
      }
      stroke(colorRGB[0], colorRGB[1], colorRGB[2]);
      fill(0,0,0,0);
      rect(offset*(displayWidth/TILE_TYPES), 0, ui_height, ui_height);  
      //stroke(colorRGB[0], colorRGB[1], colorRGB[2]);
      image(p, (float) offset*(displayWidth/TILE_TYPES)+3f, 3f, ui_height-6f, ui_height-6f);
      offset++;
    }
        
       
    popMatrix();
  }
}
