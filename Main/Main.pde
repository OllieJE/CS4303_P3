import java.util.*;

final int PLAYER_ANIMATION_FRAMES = 6;
final float PLAYER_SIZE_PROPORTION = 0.4;

final float SAW_PROPORTION = 1.0;
final float COLLIDER_PROPORTION = 1.0;
final float GATE_PROPORTION = 1.0;
final float KEY_PROPORTION = 0.4;
final float ORBITER_PROPORTION = 1.0;
final float SPIKES_PROPORTION = 1.0;
final float SPRINGPAD_PROPORTION = 0.5;
final float GOAL_PROPORTION = 0.6;

final float PLAYER_TURNING_SPEED = PI/64;  // base turning speed, should be slowre on lower friction areas

final float ENEMY_INIT_X_PROPORTION = 1;

final int SPIKES_PER_TILE = 5;  

final float UI_HEIGHT_PROPORTION = 0.1;

final float FRICTION_PROPORTION = 700000;  // base friction. surface friction is multiplied by this

final float PUSH_FORCE_PROPORTION = 32000;

final int TEXT_SIZE_PROPORTION = 60;

final int TILE_TYPES = 11;  // count of all tile types excluding the player (tiles includes floor and entity types)
// note that this can't go too high or the level editor UI will die
// this is an issue on lower-res computers

int text_size;

final int fps = 60;  
float ui_height;

int lives;
int level;

Player player;
List<Key> keys;
List<Gate> gates;
List<UiElement> ui_elements;
Goal goal;

List<Interactable> interactables;
ArrayList<Contact> contacts;

final HashMap<String, Float> TILE_FRICTIONS = new HashMap<String, Float>() {{
    put("1", 1.0);
    put("2", 8.0);
}};

final HashMap<String, int[]> COLOURS = new HashMap<String, int[]>() {{
    put("orange", new int[]{255, 160, 0});
    put("lightblue", new int[]{30, 203, 225});
    put("darkblue", new int[]{0, 100, 200});
    put("yellow", new int[]{200, 175, 120});
    put("white", new int[]{255, 255, 255});
    put("red", new int[]{255, 0, 0});
    put("black", new int[]{0, 0, 0});
    put("grey", new int[]{100, 100, 100});
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
LevelEditor levelEditor;
MainMenu mainMenu;
ContactResolver contactResolver ;
UI ui;

void setup() {
  fullScreen();
  frameRate(fps);
  
  mainMenu = new MainMenu();
  
  lives = 3;
  ui_height = UI_HEIGHT_PROPORTION*displayHeight;
  //player = new Player(displayWidth/2, displayHeight/2, 0.8);
  textAlign(CENTER);
  text_size = displayWidth/TEXT_SIZE_PROPORTION;
  
  coeffFriction = displayWidth/FRICTION_PROPORTION;   
  forceRegistry = new ForceRegistry();
  friction = new Friction(coeffFriction, coeffFriction);
  //forceRegistry.add(player, friction);
  
  level = 1;
  //current_level = new Level(1);
  screen = 0;
 
}

void nextLevel() {
  level++;
  saveGame();
  current_level = new Level(level);
}

void saveGame() {
  String[] saveData = new String[3];  // only need to save the current level, the lives and the current time of the run
  saveData[0] = Integer.toString(level);
  saveData[1] = Integer.toString(lives);
  saveData[2] = Integer.toString(0);  // TODO: ADD TIME
  saveStrings("savedata/savefile", saveData);
}

void loadGame() {
  try {
    String[] saveData = loadStrings("savedata/savefile");
    level = Integer.parseInt(saveData[0]);
    lives = Integer.parseInt(saveData[1]);
    current_level = new Level(level);
    screen = 1;
  } catch (NullPointerException e) {
    println("No save file found.");
  } catch (NumberFormatException e) {
    println("Save file is invalid.");
  }
}

void startNewGame() {
  level = 1;
  current_level = new Level(1);
  
}

void keyPressed() {
  if (screen == 1) {
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
      switch (key) {
        case '1':
          player.boost();
          break;
        case '2':
          player.useSand();
          //int[] playerPos = current_level.getPlayerTilePos();
          //current_level.changeTile(playerPos[0], playerPos[1], "2");
      }
      
    }
  } else if (screen == 0) {
    switch (key) {
      case '1':
        startNewGame();
        screen = 1;
        break;
      case '2':
        //saveGame();
        loadGame();
        break;
      case '3':
        exit();
        break;
      case '4':
        levelEditor = new LevelEditor();
        screen = 2;
        break;
    }
  } else if (screen == 2) {
    if (key == CODED) {
       switch (keyCode) {
         case LEFT :
           levelEditor.removeColumn();
           break ;
         case RIGHT :
           levelEditor.addColumn();
           break ;
           
         case UP :
           levelEditor.removeRow();
           break ;
         case DOWN :
           levelEditor.addRow();
           break ;
         
       }
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

void loseLife() {
  lives--;
  current_level.loadLevel();
}


//void updateEditor() {

//  if (mousePressed) {
//    levelEditor.handleClick(mouseX, mouseY);
//    //int[] xy = levelEditor.getTilePos(mouseX, mouseY);
//    //levelEditor.changeTile(xy[0], xy[1]);
//  }
//}

void mousePressed() {
  if (screen == 2) {
    levelEditor.handleClick(mouseX, mouseY);
  }
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
  if (!player.inAir) {
  
    if (current_level.getOverlapping()) {
      loseLife();
    }
    
    for (Interactable i : interactables) {
      if (i.collision(player.position.x, player.position.y, player.size)) {
        i.onCollision(player);
      }
    }
    
    contactResolver.resolveContacts(contacts) ;  
    
    if (goal.collision(player.position.x, player.position.y, player.size)) {
      nextLevel();
    }
    
    contacts.clear() ;
  }
 
}

void draw() {
  background(0, 100, 200);
  
  if (screen == 0) {
    mainMenu.draw();
  } else if (screen == 1) {
    update();
    current_level.draw();
    player.draw();
    ui.draw();
  } else if (screen == 2) {
    background(0);
    //updateEditor();
    levelEditor.draw();
  }
  
  
  
  
}
