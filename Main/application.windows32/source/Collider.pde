class Collider extends Interactable {
  float centred;
  Animation animation;
  float hit;
  
  Collider(int x, int y, boolean centred, float tile_size, float proportionalSize, float shift) {
    super(x, y, tile_size, proportionalSize, shift);
    this.centred = centred ? 0.5 : 0;
    this.position.x += tile_size*this.centred;
    this.position.y += tile_size*this.centred;
    hit = 0f;
    animation= new Animation("collider", COLLIDER_ANIMATION_FRAMES);
  }
  
  void draw() {
    //strokeWeight(0);
    //fill(50,168,82);
    //stroke(50,168,82);
    //circle(position.x, position.y, size);
    animation.display(position.x-size/2, position.y-size/2, size, size, hit > 0);
    
    if (hit > 0) hit--;
  }
  
  String getEntityData() {
    String[] entityData = new String[4];
    entityData[0] = "C";
    entityData[1] = Integer.toString((int)tilePosition.x);
    entityData[2] = Integer.toString((int)tilePosition.y);
    entityData[3] = centred > 0 ? "1" : "0";
    
    String csvData = String.join(",", entityData);
    return csvData;
  }
  
  void secondClick(int x, int y, float centred){};
  
  void onCollision(Player p) {
    playSound("audio/boing.mp3");
   
    
    // if the player is boosting there's a chance they get stuck insid ethe collider
    if (player.boostTime > 0) {
      player.boostTime = 0;
      player.position.x -= player.boostDir.x*(size/4);
      player.position.y -= player.boostDir.y*(size/4);
      //player.velocity.mult(0);
    } 
      PVector distance = p.position.copy();
      distance.sub(position);
      distance.normalize();
      contacts.add(new Contact(this, p, 1.0, distance));
      hit = COLLIDER_ANIMATION_FRAMES*3;
    
  }
  
  Boolean collision(float x, float y, float objectSize) {
    return position.dist(new PVector(x, y)) <= size/2+objectSize/2;
  }
  
}
