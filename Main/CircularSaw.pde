class CircularSaw extends Interactable {
  PVector target;
  
  PVector start;
  PVector end;
  
  //float size;
  float delay;
  float speed;
  float centred;
  float angle;
  PImage img;
  float waitTime;
  
  CircularSaw(int x, int y, int dx, int dy, float speed, float delay, boolean centred, float tile_size, float proportionalSize, float shift) {
    super(x, y, tile_size, proportionalSize, shift);
    this.delay = delay*fps;
    this.waitTime = 0;
    this.speed = tile_size*(speed/fps);  // how far to move every second since speed is given in tiles per second
    this.centred = centred ? 0.5 : 0;
    this.position.x += tile_size*this.centred;
    this.position.y += tile_size*this.centred;
    target = new PVector(dx*tile_size + shift + this.centred*tile_size, dy*tile_size + this.centred*tile_size);
    start = new PVector(x, y);
    end = new PVector(dx, dy);
    //start = position.copy();
    //end = target.copy();
    img = loadImage("images/saw/saw0001.png");
  }
  
  String getEntityData() {
    String[] entityData = new String[8];
    entityData[0] = "c";
    entityData[1] = Integer.toString((int)start.x);
    entityData[2] = Integer.toString((int)start.y);
    entityData[3] = Integer.toString((int)end.x);
    entityData[4] = Integer.toString((int)end.y);
    entityData[5] = Float.toString(0.8);
    entityData[6] = "1";
    entityData[7] = centred > 0 ? "1" : "0";
    
    String csvData = String.join(",", entityData);
    return csvData;
  }
  
  //voidi secondClick();
  
  void onCollision(Player p) {
    loseLife();
  }
  
  Boolean collision(float x, float y, float objectSize) {
    return position.dist(new PVector(x, y)) <= size/2+objectSize/2;
  }
  
  void secondClick(int x, int y, float centred) {
    target = new PVector(x*tile_size + shift, y*tile_size + centred*tile_size);
    end = new PVector(x, y);
  }
  
  void move() {    
    PVector dir = PVector.sub(target, position);
    PVector startPos = new PVector(start.x*tile_size + shift + this.centred*tile_size, start.y*tile_size + this.centred*tile_size);
    PVector endPos = new PVector(end.x*tile_size + shift + this.centred*tile_size, end.y*tile_size + this.centred*tile_size);
    
    if (dir.mag() <= speed) {
      position = target;
      if (waitTime >= delay) {
        if (target.x == startPos.x && target.y == startPos.y) {
          target = endPos.copy();
        } else {
          target = startPos.copy();
        }
        waitTime = 0; 
      } else {
        waitTime++;
      }
      
      return;
    }
    
    dir.normalize();
    
    position.x += speed*dir.x;
    position.y += speed*dir.y;
  }
  
  void draw() {
    move(); 
    
    pushMatrix();
    translate(position.x, position.y);
    rotate(angle);
    angle += PI/4;
    if (angle >= TWO_PI) {
      angle = 0;
    }
    image(img, -size/2, -size/2, size, size);
    popMatrix();
  }
  
}
