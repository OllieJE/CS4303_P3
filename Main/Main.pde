import java.util.*;

final int PLAYER_ANIMATION_FRAMES = 6;
final int PLAYER_SIZE_PROPORTION = 60;
final float PLAYER_INIT_X_PROPORTION = 4.0;

final float PLAYER_TURNING_SPEED = PI/64;  // base turning speed, should be slowre on lower friction areas

final float ENEMY_INIT_X_PROPORTION = 1;

final int SPIKES_PER_TILE = 5;  

final float UI_HEIGHT_PROPORTION = 0.2;

final float FRICTION_PROPORTION = 500000;  // base friction. surface friction is multiplied by this

final float PUSH_FORCE_PROPORTION = 32000;

final int fps = 60;  
float ui_height;

int lives;
int level;

Player player;
List<Obstacle> obstacles;
List<Key> keys;
List<Gate> gates;
List<UiElement> ui_elements;
Goal goal;

final HashMap<String, Float> TILE_FRICTIONS = new HashMap<String, Float>() {{
    put("1", 1.0);
    put("2", 7.0);
}};

final HashMap<String, int[]> COLOURS = new HashMap<String, int[]>() {{
    put("o", new int[]{255, 160, 0});
}};

float coeffFriction;

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
  
  lives = 3;
  ui_height = UI_HEIGHT_PROPORTION*displayHeight;
  //player = new Player(displayWidth/2, displayHeight/2, 0.8);
  
  coeffFriction = displayWidth/FRICTION_PROPORTION;   
  forceRegistry = new ForceRegistry();
  friction = new Friction(coeffFriction, coeffFriction);
  //forceRegistry.add(player, friction);
  
  level = 1;
  
  current_level = new Level(1);
 
}

void keyPressed() {
  if (key == CODED) {
     switch (keyCode) {
       case LEFT :
         movingLeft = true ;
         movingRight = false;
         break ;
       case RIGHT :
         movingRight = true ;
         movingLeft = false;
         break ;
         
       case UP :
         movingUp = true ;
         movingDown = false;
         break ;
       case DOWN :
         movingDown = true ;
         movingUp = false;
         break ;
       
     }
  } else {
    if (key == '1') {
      player.boost();
      
    } else if (key == '2') {
      player.jump();
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

//void getOverlapping() {
  
//  float tile_size = current_level.tile_size;
  
//  // get tile the center of the player is on, as well as the position of the player's center
//  float player_pos_x = player.position.x;
//  float player_pos_y = player.position.y;
  
//  int tile_x = int(player_pos_x/tile_size);
//  int tile_y = int(player_pos_y/tile_size);
  
//  // TODO: FIX THIS TO HANDLE LEVEL CENTERING
//  // check if player is out-of-bounds
//  // check if player has gone too far left
//  if (player_pos_x - player.size/2 <= 0) {
//    current_level.create_entities();
//    return;
//  }
//  // check if player has gone too far right
//  else if (player_pos_x + player.size/2 >= current_level.tilesX*tile_size) {
//    current_level.create_entities();
//    return;
//  }
//  // check if player has gone too far up
//  if (player_pos_y - player.size/2 <= 0) {
//    current_level.create_entities();
//    return;
//  }
//  // check if player has gone too far down
//  else if (player_pos_y + player.size/2 >= current_level.tilesY*tile_size) {
//    current_level.create_entities();
//    return;
//  }
  
//  // want to get the highest-friction tile the player is on
//  float highest_friction = 1.0;
  
//  // iterate through the nine tiles the player could be colliding with
//  for (int i = (tile_y-1 >= 0 ? tile_y-1 : 0) ; i <= (tile_y+1 < current_level.tilesY ? tile_y+1 : current_level.tilesY-1); i++) {
//    // if the player goes off the left or right edges of the level
//    if (i < 0 || i >= current_level.tilesY) {
//      current_level.create_entities();
//    }
    
//    for (int j = (tile_x-1 >= 0 ? tile_x-1 : 0) ; j <= (tile_x+1 < current_level.tilesX ? tile_x+1 : current_level.tilesX-1); j++) {
//      if (j < 0 || j >= current_level.tilesX) {
//        current_level.create_entities();
//      }
      
//      //if (current_level.level_data[i][j].equals("0")) {
      
//      float closest_x = player_pos_x;
//      float closest_y = player_pos_y;
      
//      // if player is to the left of the tile, check left edge
//      if (tile_x < j) {
//        closest_x = j*tile_size;
//      }
//      // if player it to the right of the tile, check right edge
//      else if (tile_x > j) {
//        closest_x = j*tile_size+tile_size;
//      }
//      // if player is above tile, check top edge
//      if (tile_y < i) {
//        closest_y = i*tile_size;
//      }
//      // if player is below tile, check bottom edge
//      else if (tile_y > i) {
//        closest_y =  i*tile_size+tile_size;
//      }
      
//      float dist_x = player_pos_x - closest_x;
//      float dist_y = player_pos_y - closest_y;
//      float distance = (float)Math.sqrt((dist_x*dist_x) + (dist_y*dist_y));
      
//      String tile_type = current_level.level_data[i][j];
      
//      // && current_level.level_data[i][j].equals("0")
//      if (distance < player.size/2)  {
//        if (tile_type.equals("0")) {
//          current_level.create_entities();
//        } else if (TILE_FRICTIONS.keySet().contains(tile_type)) {
//          if (TILE_FRICTIONS.get(tile_type) > highest_friction) {
//            highest_friction = TILE_FRICTIONS.get(tile_type);
//          }
          
//        }
//      }
      
//    }
    
//  }
//  player.player_friction.c = coeffFriction*highest_friction;
//}

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
  if (!player.inAir) {
  
    //current_level.getOverlapping();
      
    for (Obstacle o : obstacles) {
      if (o.collision(player)) {
        player.position.x += player.velocity.x*-1;
        player.position.y += player.velocity.y*-1;
        player.velocity.mult(0);
        player.acceleration.mult(0);
      }
      //if (o.collision(player)) {
      //  current_level.create_entities();
      //}
    }
    
    for (Key k : keys) {
      if (k.collision(player)) {
        for (Gate g : gates) {
          if (g.colourString.equals(k.colourString)) {
            g.active = false;
            
          }
        }
        k.active = false;
      }
    }
    
    if (goal.collision(player)) {
      // TODO: DONT JUST HAVE IT GO TO LEVEL 2 EVERY TIME 
      current_level = new Level(2);
    }
  }
}

void draw() {
  background(0, 100, 200);
  update();
  current_level.draw();
  player.draw();
  
  
  
}
