class LevelSelect {
  FilenameFilter filter;
  String[][] pages;
  String[] pathnames;
  int page;
  int pageCount;
  PImage left;
  PImage right;
  PImage leftEmpty;
  PImage rightEmpty;
  
  LevelSelect() {
    filter = new FilenameFilter() {
        @Override
        public boolean accept(File f, String name) {
            return !name.contains("_entities");
        }
    };
    
    String path = sketchPath();
    // Creates a new File instance by converting the given pathname string
    // into an abstract pathname
    File f = new File(path + "\\custom_maps");

    // Populates the array with names of files and directories
    pathnames = f.list(filter);
    pages = new String[(int)((float)pathnames.length/10.0)+1][10];
    
    pageCount = pages.length;
    for (int i = 0; i < pathnames.length; i++) {
      pages[(int) i/9][i%9] = pathnames[i];
    }
    
    left = loadImage("images/arrows/left.png");
    right = loadImage("images/arrows/right.png");
    leftEmpty = loadImage("images/arrows/leftempty.png");
    rightEmpty = loadImage("images/arrows/rightempty.png");
    
  }
  
  String getLevelName(int levelNum) {
    if (levelNum >= 0 && levelNum < pathnames.length) { 
      return pages[page][levelNum];
    }
    return "levelNotFoundException";
  }
  
  void pageLeft() {
    if (page > 0) page --;
  }
  
  void pageRight() {
    if (page < pageCount-1) page ++;
  }
  
  void draw() {
    background(0, 100, 200);
    fill(255);
    textSize(displayWidth/TEXT_SIZE_PROPORTION);
    textAlign(LEFT);
    
    for (int i = 0; i < pages[page].length; i++) {
      String pathname = pages[page][i];
      if (pathname != null) {
        text(i + ": " + pathname, displayWidth/20, (displayHeight/10)*(i+1));
      }
    }
    
    pushMatrix();
    translate(displayWidth-left.width*2, displayHeight-left.height);
    fill(150);
    if (page > 0) {
      image(leftEmpty, 0, 0);
    } else {
      image(left, 0, 0);
    }
    if (page < pageCount-1) {
      image(rightEmpty, leftEmpty.width, 0);
    } else {
      image(right, leftEmpty.width, 0);
    }
    popMatrix();
  }
  
}
