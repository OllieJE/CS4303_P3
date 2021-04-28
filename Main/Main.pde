import java.util.*;

final int PLAYER_SIZE_PROPORTION = 96;
final float PLAYER_INIT_X_PROPORTION = 4.0;

final float ENEMY_INIT_X_PROPORTION = 1;

final int SPIKES_PER_TILE = 5;  

final float FORCE_PROPORTION = 9000;
final float FRICTION_PROPORTION = 10000;  // base friction. surface friction is multiplied by this

final float PUSH_FORCE_PROPORTION = 16000;

final int fps = 60;  

float coeffFriction;

List<Obstacle> obstacles;

Player player;

Boolean collided = false;

int screen = 0;

boolean movingLeft = false ;
boolean movingRight = false ;
boolean movingUp = false ;
boolean movingDown = false ;

ForceRegistry forceRegistry;
Friction friction;

Level current_level;

void setup() {
  fullScreen();
  frameRate(fps);
  //player = new Player(displayWidth/2, displayHeight/2, 0.8);
  
  coeffFriction = displayWidth/FRICTION_PROPORTION;   
  forceRegistry = new ForceRegistry();
  friction = new Friction(coeffFriction);
  //forceRegistry.add(player, friction);
  current_level = new Level(1);
  
}

void keyPressed() {
  if (key == CODED) {
     switch (keyCode) {
       case LEFT :
         movingLeft = true ;
         break ;
       case RIGHT :
         movingRight = true ;
         break ;
         
       case UP :
         movingUp = true ;
         break ;
       case DOWN :
         movingDown = true ;
         break ;
     }
  }
}

void keyReleased() {
  if (key == CODED) {
     switch (keyCode) {
       case LEFT :
         movingLeft = false ;
         break ;
       case RIGHT :
         movingRight = false ;
         break ;
         
       case UP :
         movingUp = false ;
         break ;
       case DOWN :
         movingDown = false ;
         break ;
     }
  
  }
}


void restartLevel() {
  // TODO: add functionality
  return;
}

void getOverlapping() {
  
  float tile_size = current_level.tile_size;
  
  // get tile the center of the player is on, as well as the position of the player's center
  float player_pos_x = player.position.x;
  float player_pos_y = player.position.y;
  
  int tile_x = int(player_pos_x/tile_size);
  int tile_y = int(player_pos_y/tile_size);
  
  // TODO: FIX THIS TO HANDLE LEVEL CENTERING
  // check if player is out-of-bounds
  // check if player has gone too far left
  if (player_pos_x - player.size/2 <= 0) {
    current_level.create_entities();
    return;
  }
  // check if player has gone too far right
  else if (player_pos_x + player.size/2 >= current_level.tiles*tile_size) {
    current_level.create_entities();
    return;
  }
  // check if player has gone too far up
  if (player_pos_y - player.size/2 <= 0) {
    current_level.create_entities();
    return;
  }
  // check if player has gone too far down
  else if (player_pos_y + player.size/2 >= current_level.tiles*tile_size) {
    current_level.create_entities();
    return;
  }
  
  // iterate through the nine tiles the player could be colliding with
  for (int i = (tile_y-1 >= 0 ? tile_y-1 : 0) ; i <= (tile_y+1 < current_level.tiles ? tile_y+1 : current_level.tiles-1); i++) {
    // if the player goes off the left or right edges of the level
    if (i < 0 || i >= current_level.tiles) {
      restartLevel();
    }
    
    for (int j = (tile_x-1 >= 0 ? tile_x-1 : 0) ; j <= (tile_x+1 <= current_level.tiles ? tile_x+1 : current_level.tiles-1); j++) {
      if (j < 0 || j >= current_level.tiles) {
        restartLevel();
      }
      
      //if (current_level.level_data[i][j].equals("0")) {
      
      float closest_x = player_pos_x;
      float closest_y = player_pos_y;
      
      // if player is to the left of the tile, check left edge
      if (tile_x < j) {
        closest_x = j*tile_size;
      }
      // if player it to the right of the tile, check right edge
      else if (tile_x > j) {
        closest_x = j*tile_size+tile_size;
      }
      // if player is above tile, check top edge
      if (tile_y < i) {
        closest_y = i*tile_size;
      }
      // if player is below tile, check bottom edge
      else if (tile_y > i) {
        closest_y =  i*tile_size+tile_size;
      }
      
      float dist_x = player_pos_x - closest_x;
      float dist_y = player_pos_y - closest_y;
      float distance = (float)Math.sqrt((dist_x*dist_x) + (dist_y*dist_y));
      // && current_level.level_data[i][j].equals("0")
      if (distance < player.size/2 && current_level.level_data[i][j].equals("0"))  {
        current_level.create_entities();
      }
      //}
      
    }
    
  }
  //exit();
}

void update() {
  if (movingLeft) { 
    player.addForce(new PVector(displayWidth/PUSH_FORCE_PROPORTION*-1, 0)) ;
  }
  if (movingRight) {
    player.addForce(new PVector(displayWidth/PUSH_FORCE_PROPORTION, 0)) ;
  }
  if (movingUp) {
    player.addForce(new PVector(0, displayWidth/PUSH_FORCE_PROPORTION*-1));
  }
  if (movingDown) {
    player.addForce(new PVector(0, displayWidth/PUSH_FORCE_PROPORTION));
  }
  
  forceRegistry.updateForces();
  player.integrate();
  
  getOverlapping();
  
  for (Obstacle o : obstacles) {
    if (o.collision(player)) {
      current_level.create_entities();
    }
  }
}

void draw() {
  background(0);
  update();
  current_level.draw();
  player.draw();
  
  for (Obstacle o : obstacles) {
    o.draw();
  }
  
}
