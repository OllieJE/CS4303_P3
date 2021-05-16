class LevelSelect {
  FilenameFilter filter;
  
  LevelSelect() {
    filter = new FilenameFilter() {
        @Override
        public boolean accept(File f, String name) {
            return !name.contains("_entities");
        }
    };
  }
  
  void draw() {
    background(0);
    fill(255);
    textSize(displayWidth/TEXT_SIZE_PROPORTION);
    textAlign(LEFT);
    
    String[] pathnames;
    String path = sketchPath();
    // Creates a new File instance by converting the given pathname string
    // into an abstract pathname
    File f = new File(path + "\\custom_maps");

    // Populates the array with names of files and directories
    pathnames = f.list(filter);

    for (int i = 0; i < pathnames.length; i++) {
      String pathname = pathnames[i];
      text(i + ": " + pathname, displayWidth/20, (displayHeight/10)*(i+1));
    }
    
  }
  
}
