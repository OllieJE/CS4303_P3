class Springpad extends Interactable {
  float centred;
  Animation animation;
  float hit;
  
  Springpad(int x, int y, boolean centred, float tile_size, float proportionalSize, float shift) {
    
    super(x, y, tile_size, proportionalSize, shift);
        
    this.centred = centred ? 0.5 : 0;
    this.position.x += tile_size*this.centred;
    this.position.y += tile_size*this.centred;
    
    animation = new Animation("jumppad", JUMPPAD_ANIMATION_FRAMES);
  }
  
  void draw() {
    //stroke(0);
    //fill(100);
    //strokeWeight(1);
    //circle(position.x, position.y, size);
    animation.display(position.x-size/2, position.y-size/2, size, size, hit == fps || hit == 1);
    
    if (hit > 0) hit--;
  }
  
  String getEntityData() {
    String[] entityData = new String[4];
    entityData[0] = "j";
    entityData[1] = Integer.toString((int)tilePosition.x);
    entityData[2] = Integer.toString((int)tilePosition.y);
    entityData[3] = centred > 0 ? "1" : "0";
    String csvData = String.join(",", entityData);
    return csvData;
  }
  
  void onCollision(Player p) {
    playSound("audio/jump.mp3");
    player.jump();
    hit = fps;
  }
  
  void secondClick(int x, int y, float centred){};
  
  Boolean collision(float x, float y, float objectSize) {
    return (position.dist(new PVector(x, y)) <= objectSize/2);
  }
}
