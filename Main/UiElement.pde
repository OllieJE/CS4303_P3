abstract class UiElement {
  
  PVector position;
  
  UiElement(float x, float y) {
    position = new PVector(x, y);
  }
  
  abstract void draw();
}
