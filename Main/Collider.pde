class Collider extends Interactable {
  float size;
  float centred;
  
  Collider(float x, float y, Level level, float size, boolean centred) {
    super(x, y, level);
    this.centred = centred ? 0.5 : 0;
    this.size = size*level.tile_size;
    this.position.x += level.tile_size*this.centred;
    this.position.y += level.tile_size*this.centred;
  }
  
  void draw() {
    strokeWeight(0);
    fill(50,168,82);
    stroke(50,168,82);
    circle(position.x, position.y, size);
  }
  
  void onCollision(Player p) {
    PVector distance = p.position.copy();
    distance.sub(position);
    distance.normalize();
    contacts.add(new Contact(this, p, 1.0, distance));
  }
  
  Boolean collision(Player p) {
    return position.dist(player.position) <= size/2+player.size/2;
  }
  
}
