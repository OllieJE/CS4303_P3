class Collider extends Interactable {
  float centred;
  
  Collider(int x, int y, boolean centred, float tile_size, float proportionalSize, float shift) {
    super(x, y, tile_size, proportionalSize, shift);
    this.centred = centred ? 0.5 : 0;
    this.position.x += tile_size*this.centred;
    this.position.y += tile_size*this.centred;
  }
  
  void draw() {
    strokeWeight(0);
    fill(50,168,82);
    stroke(50,168,82);
    circle(position.x, position.y, size);
  }
  
  void secondClick(int x, int y, float centred){};
  
  void onCollision(Player p) {
    PVector distance = p.position.copy();
    distance.sub(position);
    distance.normalize();
    contacts.add(new Contact(this, p, 1.0, distance));
  }
  
  Boolean collision(float x, float y, float objectSize) {
    return position.dist(new PVector(x, y)) <= size/2+objectSize/2;
  }
  
}
