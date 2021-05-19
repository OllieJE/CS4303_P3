class TutorialScreen {
  PImage tutorial;
  
  TutorialScreen() {
    tutorial = loadImage("images/tutorial/tutorial.png");
  }
  
  void draw() {
    image(tutorial, 0, 0, displayWidth, displayHeight);
  }
  
}
