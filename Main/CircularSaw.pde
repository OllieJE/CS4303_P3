class CircularSaw extends Interactable {
  PVector target;
  
  PVector start;
  PVector end;
  
  float size;
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
    target = new PVector(dx, dy);
    start = position.copy();
    end = target.copy();
    
    img = loadImage("images/saw/saw0001.png");
  }
  
  void onCollision(Player p) {
    loseLife();
  }
  
  Boolean collision(float x, float y, float objectSize) {
    return position.dist(new PVector(x, y)) <= size/2+objectSize/2;
  }
  
  void move() {
    PVector targetPos = new PVector(target.x*tile_size+shift, target.y*tile_size);
    PVector dir = PVector.sub(targetPos, position);
    
    if (dir.mag() <= speed) {
      position = target;
      if (waitTime >= delay) {
        if (target.x == start.x && target.y == start.y) {
          target = end.copy();
        } else {
          target = start.copy();
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
