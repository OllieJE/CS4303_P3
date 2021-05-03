class Player extends Rigid_Body {
    
  Animation animation;
  float size;
  Friction player_friction;
  
  int boostTime;
  int boostCooldown;
  PVector boostDir;
  
  Player(float x, float y, float m, Friction f, int facing) {
    super(x, y, m);
    this.size = displayWidth/PLAYER_SIZE_PROPORTION;
    animation= new Animation("crab", PLAYER_ANIMATION_FRAMES);
    orientation = HALF_PI*facing;
    targetOrientation = orientation;
    player_friction = f;
    
    boostDir = new PVector();
    boostTime = 0;
    boostCooldown = 0;
  }
  
  float get_target_dir() {
    
    if (movingLeft && movingUp) {
      return PI+HALF_PI+QUARTER_PI;
    } else if (movingUp && movingRight) {
      return QUARTER_PI;
    } else if (movingRight && movingDown) {
      return HALF_PI+QUARTER_PI;
    } else if (movingDown && movingLeft) {
      return PI+QUARTER_PI;
    }
    
    if (movingLeft) {
      return PI + HALF_PI;
    } else if (movingRight) {
      return HALF_PI;
    } 
    if (movingUp) {
      return TWO_PI;
    } else if (movingDown) {
      return PI;
    }
    
    return orientation;
  }
  
  void boost() {
    boostTime  = 10;
    boostCooldown = 120;
    
    boostDir = new PVector(sin(orientation), -1*cos(orientation));
    boostDir.normalize();
  }
  
  void draw() {
    
    boolean button_pressed = movingLeft || movingRight || movingUp || movingDown;
        
    stroke(150, 50, 50);
    fill(150, 50, 50);
    //circle(position.x, position.y, size);
    //image(animation.images[animation.frame], position.x, position.y);
    
    
    if (boostCooldown > 0) {
      boostCooldown--;
    }
    
    if (boostTime > 0) {
      boostTime--;
      float vMag = velocity.mag();
      velocity.x = boostDir.x*vMag;
      velocity.y = boostDir.y*vMag;
      
      position.x += boostDir.x*(size/4);
      position.y += boostDir.y*(size/4);
    }
    
    pushMatrix();
    translate(position.x, position.y);
    
    float turn_speed = min(PLAYER_TURNING_SPEED*(player_friction.c/coeffFriction), PLAYER_TURNING_SPEED*4.0);
    
    if (button_pressed) {
      targetOrientation = get_target_dir();
      if (abs(targetOrientation - orientation) <= turn_speed) {
        orientation = targetOrientation ;
      } else {
        
        float diff = abs(targetOrientation - orientation);
        if (targetOrientation > orientation) {
          if (diff >= PI) {
            orientation -= turn_speed;
          } else {
            orientation += turn_speed;
          }
        } else {
          if (diff >= PI) {
            orientation += turn_speed;
          } else {
            orientation -= turn_speed;
          }
        }
      }

      if (orientation > TWO_PI) orientation = orientation - TWO_PI ;
      else if (orientation < 0) orientation = TWO_PI + orientation ;  
    }
      
    //orientation = targetOrientation;
    rotate(orientation);
    animation.display(-size/2, -size/2, size, size, button_pressed);
    
    //textAlign(CENTER);
    //text(targetOrientation, 0, -25);
    //text(orientation, 0, 25);
    
    //animation.display(position.x-size/2, position.y-size/2, size, size);
    popMatrix();
  }

}
