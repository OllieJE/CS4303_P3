import java.util.*;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.FilenameFilter;

import ddf.minim.*;

final int PLAYER_ANIMATION_FRAMES = 6;
final float PLAYER_SIZE_PROPORTION = 0.4;

final int COLLIDER_ANIMATION_FRAMES = 4;
final int JUMPPAD_ANIMATION_FRAMES = 2;

final float SAW_PROPORTION = 1.0;
final float COLLIDER_PROPORTION = 0.9;
final float GATE_PROPORTION = 1.0;
final float KEY_PROPORTION = 0.4;
final float ORBITER_PROPORTION = 1.0;
final float SPIKES_PROPORTION = 1.0;
final float SPRINGPAD_PROPORTION = 0.5;
final float GOAL_PROPORTION = 0.6;

float spawnProtection;
float maxSpawnProtection;

final int MAX_LIVES = 5;

final float PLAYER_TURNING_SPEED = PI/48;  // base turning speed, should be slowre on lower friction areas

final float ENEMY_INIT_X_PROPORTION = 1;

final int SPIKES_PER_TILE = 5;  

final float UI_HEIGHT_PROPORTION = 0.1;

//final float FRICTION_PROPORTION = 800000;  // base friction. surface friction is multiplied by this
final float FRICTION_PROPORTION = 0.000025;  // base friction. surface friction is multiplied by this. this is by tile rather than display width
// smaller tiles = higher friction

//final float PUSH_FORCE_PROPORTION = 32000;
final float PUSH_FORCE_PROPORTION = 0.0006;

float push_force;

final int TEXT_SIZE_PROPORTION = 60;

final int TILE_TYPES = 12;  // count of all tile types excluding the player (tiles includes floor and entity types)
// note that this can't go too high or the level editor UI will die
// this is an issue on lower-res computers

int text_size;

final int fps = 60;  
float ui_height;

int lives;
int level;
final int MAX_LEVELS = 7;

Player player;
List<Key> keys;
List<Gate> gates;
List<UiElement> ui_elements;
Goal goal;
WinScreen winScreen;

Minim minim;
AudioPlayer audioPlayer;
AudioInput input;

PImage tutorialImage;
PImage menuImage;

List<Interactable> interactables;
ArrayList<Contact> contacts;

boolean playingCustomGame;

final HashMap<String, Float> TILE_FRICTIONS = new HashMap<String, Float>() {{
    put("1", 1.0);
    put("2", 8.0);
    put("3", 0.0);
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

final HashMap<String, int[]> GATE_COLOURS = new HashMap<String, int[]>() {{
    put("orange", new int[]{255, 160, 0});
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

long runTime;
long startTime;
long endTime;

ForceRegistry forceRegistry;
Friction friction;

Level current_level;
LevelEditor levelEditor;
LevelSelect levelSelect;
//MainMenu mainMenu;
ContactResolver contactResolver ;
UI ui;
GameOverScreen gameOverScreen;

AudioPlayer theme;

void setup() {
  fullScreen();
  frameRate(fps);
  
  playingCustomGame = false;
  
  tutorialImage = loadImage("images/tutorial/tutorial.png");
  menuImage = loadImage("images/mainmenu/mainmenu.png");
  
  minim = new Minim(this);
  input = minim.getLineIn();
  
  //mainMenu = new MainMenu();
  gameOverScreen = new GameOverScreen();
  
  maxSpawnProtection = fps*1.0;
  
  lives = MAX_LIVES;
  ui_height = UI_HEIGHT_PROPORTION*displayHeight;
  //player = new Player(displayWidth/2, displayHeight/2, 0.8);
  textAlign(CENTER);
  text_size = displayWidth/TEXT_SIZE_PROPORTION;
  
  coeffFriction = 10.0*FRICTION_PROPORTION;   
  forceRegistry = new ForceRegistry();
  friction = new Friction(coeffFriction, coeffFriction);
  //forceRegistry.add(player, friction);
  
  level = 1;
  //current_level = new Level(1);
  screen = 0;
  
  theme=minim.loadFile("audio/seashanty2.mp3");
  theme.loop();
 
}


void deleteSave() {
  String path = sketchPath();
  
  File saveGame = new File(path + "\\savedata/savefile");
  if (saveGame.delete()) { 
    System.out.println("Save file deleted");
  } else {
    System.out.println("Failed to delete save file.");
  } 
}

void nextLevel() {
  updateRunTime();
  level++;
  
  if (level == MAX_LEVELS) {
    winScreen = new WinScreen();
    screen = 6;
  } else {
    saveGame();
    current_level = new Level("levels\\" + "level_" + level);
  }
  
}

void playSound(String sound) {
  audioPlayer = null;
  audioPlayer = minim.loadFile(sound);
  audioPlayer.setGain(-10);
  audioPlayer.play();
}

void saveGame() {
  updateRunTime();
  String[] saveData = new String[3];  // only need to save the current level, the lives and the current time of the run
  saveData[0] = Integer.toString(level);
  saveData[1] = Integer.toString(lives);
  saveData[2] = Long.toString(runTime);  
  saveStrings("savedata/savefile", saveData);
}

void loadCustomMap(String levelName) {
  lives = MAX_LIVES;
  current_level = new Level("custom_maps\\" + levelName);
  screen = 1;
}

void loadGame() {
  try {
    String[] saveData = loadStrings("savedata/savefile");
    level = Integer.parseInt(saveData[0]);
    lives = Integer.parseInt(saveData[1]);
    runTime = Long.parseLong(saveData[2]);
    current_level = new Level("levels\\" + "level_" + level);
    screen = 1;
    startTime = System.currentTimeMillis();
    playingCustomGame = false;
  } catch (NullPointerException e) {
    println("No save file found.");
  } catch (NumberFormatException e) {
    println("Save file is invalid.");
  }
}

void startNewGame() {
  lives = MAX_LIVES;
  playingCustomGame = false;
  runTime = 0;
  level = 1;
  startTime = System.currentTimeMillis();
  current_level = new Level("levels\\" + "level_" + level);
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
        playSound("audio/menu_select.mp3");
        startNewGame();
        screen = 1;
        break;
      case '2':
        playSound("audio/menu_select.mp3");
        //saveGame();
        loadGame();
        break;
      case '3':
        playSound("audio/menu_select.mp3");
        screen = 5;  
        break;
      case '4':
        playSound("audio/menu_select.mp3");
        levelEditor = new LevelEditor();
        screen = 2;
        break;
      case '5':
        playSound("audio/menu_select.mp3");
        levelSelect = new LevelSelect();
        screen = 3;
        break;
      case '6':
        exit();
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
    } else {
      if (key == RETURN || key == ENTER) {
        if (!levelEditor.enteringName) {
          if (levelEditor.checkValidity()) {
            levelEditor.enteringName = true;
          }
        } else {
          levelEditor.saveMap();
          screen = 0;
        }
      } else if (key == BACKSPACE && levelEditor.enteringName) {
        if (levelEditor.levelName.length()>0) {
          levelEditor.levelName=levelEditor.levelName.substring(0, levelEditor.levelName.length()-1);
        }
      } else {
        if (levelEditor.enteringName) {
          levelEditor.levelName += key;
        } else {
          if (key == 'p') {
            levelEditor.placePlayer();
          } else if (key == 'g') {
            levelEditor.placeGoal();
          }
        }
      }
      
    }
  } else if (screen == 3) {
    try {
      if (key == ENTER || key == RETURN) {
        playSound("audio/menu_select.mp3");
        screen = 0;
      }
      int levelNum = Character.getNumericValue(key);
      String levelName = levelSelect.getLevelName(levelNum);
      println(levelName);
      if (!levelName.equals("levelNotFoundException")) {
        playSound("audio/menu_select.mp3");
        playingCustomGame = true;
        loadCustomMap(levelName);
      }
      
    } catch (Exception e) {
      // don't need to do anything here since we can safely ignore all other key presses
    }
  } else if (screen == 4 || screen == 5 || screen == 6) {
    switch (key) {
      case ENTER:
      case RETURN:
        playSound("audio/menu_select.mp3");
        screen = 0;
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

void updateRunTime() {
  endTime = System.currentTimeMillis();
  runTime += (endTime - startTime);
  startTime = System.currentTimeMillis(); 
}


void restartLevel() {
  // TODO: add functionality
  return;
}

void loseLife() {
  lives--;
  spawnProtection = maxSpawnProtection;
  println(spawnProtection);
  
  if (!playingCustomGame) {
    saveGame();
  }
  if (lives < 0) {
    if (!playingCustomGame) {
      deleteSave();
      updateRunTime();
      screen = 4;
    } else {
      screen = 0;
    }
  }
  current_level.loadLevel();
}

void mousePressed() {
  if (screen == 2) {
    if (mouseButton == LEFT) {
      levelEditor.handleClick(mouseX, mouseY);
    } else if (mouseButton == RIGHT) {
      levelEditor.removeEntity(mouseX, mouseY);
    }
  }
}


void update() {
  if (spawnProtection > 0) {
    spawnProtection--;
  }
  if (!player.onIce && spawnProtection == 0) {
    if (movingLeft) { 
      player.addForce(new PVector(push_force*-1, 0)) ;
    }
    if (movingRight) {
      player.addForce(new PVector(push_force, 0)) ;
    }
    if (movingUp) {
      player.addForce(new PVector(0, push_force*-1));
    }
    if (movingDown) {
      player.addForce(new PVector(0, push_force));
    }
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
      if (!playingCustomGame) {
        nextLevel();
      } else {
        screen = 0;
      }
    }
    
    contacts.clear() ;
  }
 
}

void draw() {
  background(0, 100, 200);
  
  if (screen == 0) {
    image(menuImage, 0, 0, displayWidth, displayHeight);
    //mainMenu.draw();
  } else if (screen == 1) {
    update();
    current_level.draw();
    player.draw();
    ui.draw();
  } else if (screen == 2) {
    background(0);
    //updateEditor();
    levelEditor.draw();
  } else if (screen == 3 ) {
    levelSelect.draw();
  } else if (screen == 4) {
    gameOverScreen.draw();
  } else if (screen == 5) {
    image(tutorialImage, 0, 0, displayWidth, displayHeight);
  } else if (screen == 6) {
    winScreen.draw();
  }
  
  
  
  
}
