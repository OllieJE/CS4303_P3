class LevelSelect {
  FilenameFilter filter;
  String[] pathnames;
  
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
  }
  
  String getLevelName(int levelNum) {
    if (levelNum >= 0 && levelNum < pathnames.length) { 
      return pathnames[levelNum];
    }
    return "levelNotFoundException";
  }
  
  void draw() {
    background(0, 100, 200);
    fill(255);
    textSize(displayWidth/TEXT_SIZE_PROPORTION);
    textAlign(LEFT);
    
    for (int i = 0; i < pathnames.length; i++) {
      String pathname = pathnames[i];
      text(i + ": " + pathname, displayWidth/20, (displayHeight/10)*(i+1));
    }
    
  }
  
}
