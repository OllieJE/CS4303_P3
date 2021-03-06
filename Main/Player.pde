class Player extends Rigid_Body {
    
  Animation animation;
  float size;
  float baseSize;
  Friction player_friction;
  
  int boostTime;
  int boostCooldown;
  int boostCooldownMax = fps*4;
  PVector boostDir;
  
  int sandCooldown;
  int sandCooldownMax = fps*10;
  
  boolean inAir;
  float airTime;
  PVector jumpDir;  // could use boostDir, but for clarity use a different variable
  
  float tile_size;
  
  float jumpTime;
  float jumpDistance;
  
  PVector tilePosition;
  float proportionalSize;
  float shift;
  
  boolean onIce;
  
  
  Player(int x, int y, float m, Friction f, int facing, float tile_size, float proportionalSize, float shift) {
    super(x*tile_size+tile_size/2, y*tile_size+tile_size/2, m);
    tilePosition = new PVector(x, y);
    this.proportionalSize = proportionalSize;
    updateSize(tile_size, shift);
    
    this.baseSize = size;
    animation= new Animation("crab", PLAYER_ANIMATION_FRAMES);
    orientation = HALF_PI*facing;
    targetOrientation = orientation;
    player_friction = f;
    
    boostDir = new PVector();
    boostTime = 0;
    boostCooldown = 0;
    
    jumpDir = new PVector();
    inAir = false;
    airTime = 0;
    
    jumpTime = fps*1.5;
    jumpDistance = tile_size*2.1;  // jump two tiles
    
    onIce = false;
  }
  
  String getEntityData() {
    String[] entityData = new String[4];
    entityData[0] = "p";
    entityData[1] = Integer.toString((int)tilePosition.x);
    entityData[2] = Integer.toString((int)tilePosition.y);
    entityData[3] = Integer.toString((int) (orientation/HALF_PI));
    
    String csvData = String.join(",", entityData);
    return csvData;
  }
  
  void updateSize(float tile_size, float shift) {    
    this.tile_size = tile_size;
    this.shift = shift;
    size = proportionalSize*this.tile_size;
    position.x = this.tile_size*tilePosition.x + this.shift + tile_size/2;
    position.y = this.tile_size*tilePosition.y + tile_size/2;
    
    this.baseSize = size;
    
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
  
  void useSand() {
    if (sandCooldown <= 0 && !inAir) {
      int[] playerPos = current_level.getTilePos(player.position.x, player.position.y);
      
      if (!current_level.level_data[playerPos[1]][playerPos[0]].equals("3")) {
        current_level.changeTile(playerPos[0], playerPos[1], "2");
        sandCooldown = sandCooldownMax;
      }
    }
  }
  
  void jump() {
    boostTime = 0;
    if (airTime <= 0) {
      airTime = jumpTime;  // time in air
      jumpDir = velocity.copy().normalize();
      //jumpDir = new PVector(sin(orientation), -1*cos(orientation));
    }
  }
  
  void boost() {
    if (boostCooldown <= 0 && !inAir) {
      boostTime  = fps/5;
      boostCooldown = boostCooldownMax;
      boostDir = new PVector(sin(orientation), -1*cos(orientation));
      boostDir.normalize();
    }
  }
  
  void useAbilities() {
    if (boostCooldown > 0) {
      boostCooldown--;
    }
    
    if (sandCooldown > 0) {
      sandCooldown--;
    }
    
    if (boostTime > 0) {
      boostTime--;
      float vMag = velocity.mag();
      velocity.x = boostDir.x*vMag;
      velocity.y = boostDir.y*vMag;
      
      position.x += boostDir.x*(size/4);
      position.y += boostDir.y*(size/4);
    }
    
    if (airTime > 0) {
      airTime--;
      inAir = true;
      if (airTime >= jumpTime/2) {
        this.size += baseSize*.02;
      } else {
        this.size -= baseSize*.02;
      }

      // jump over a bit more than a tile's length
      velocity.x = jumpDir.x*(jumpDistance/jumpTime);
      velocity.y = jumpDir.y*(jumpDistance/jumpTime);
      
    } else {
      inAir = false;
      //size = baseSize;  // jumping should bring size back down anyway, but just in case
    }
  }
  
  void phaseOut() {
  }
  
  void draw() {
    
    boolean button_pressed = movingLeft || movingRight || movingUp || movingDown;
        
    stroke(150, 50, 50);
    fill(150, 50, 50);
    //circle(position.x, position.y, size);
    //image(animation.images[animation.frame], position.x, position.y);
    
    
    useAbilities();
    
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

    popMatrix();
  }

}
