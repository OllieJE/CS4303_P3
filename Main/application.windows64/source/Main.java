import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.*; 
import java.io.BufferedWriter; 
import java.io.File; 
import java.io.FileWriter; 
import java.io.IOException; 
import java.io.FilenameFilter; 
import ddf.minim.*; 
import java.util.Iterator; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Main extends PApplet {










final int PLAYER_ANIMATION_FRAMES = 6;
final float PLAYER_SIZE_PROPORTION = 0.4f;

final int COLLIDER_ANIMATION_FRAMES = 4;
final int JUMPPAD_ANIMATION_FRAMES = 2;

final float SAW_PROPORTION = 1.0f;
final float COLLIDER_PROPORTION = 0.9f;
final float GATE_PROPORTION = 1.0f;
final float KEY_PROPORTION = 0.4f;
final float ORBITER_PROPORTION = 1.0f;
final float SPIKES_PROPORTION = 1.0f;
final float SPRINGPAD_PROPORTION = 0.5f;
final float GOAL_PROPORTION = 0.6f;

float spawnProtection;
float maxSpawnProtection;

final int MAX_LIVES = 5;

final float PLAYER_TURNING_SPEED = PI/64;  // base turning speed, should be slowre on lower friction areas

final float ENEMY_INIT_X_PROPORTION = 1;

final int SPIKES_PER_TILE = 5;  

final float UI_HEIGHT_PROPORTION = 0.1f;

//final float FRICTION_PROPORTION = 800000;  // base friction. surface friction is multiplied by this
final float FRICTION_PROPORTION = 0.000025f;  // base friction. surface friction is multiplied by this. this is by tile rather than display width
// smaller tiles = higher friction

//final float PUSH_FORCE_PROPORTION = 32000;
final float PUSH_FORCE_PROPORTION = 0.0006f;

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

Player player;
List<Key> keys;
List<Gate> gates;
List<UiElement> ui_elements;
Goal goal;

Minim minim;
AudioPlayer audioPlayer;
AudioInput input;

PImage tutorialImage;
PImage menuImage;

List<Interactable> interactables;
ArrayList<Contact> contacts;

boolean playingCustomGame;

final HashMap<String, Float> TILE_FRICTIONS = new HashMap<String, Float>() {{
    put("1", 1.0f);
    put("2", 8.0f);
    put("3", 0.0f);
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

public void setup() {
  
  frameRate(fps);
  
  playingCustomGame = false;
  
  tutorialImage = loadImage("images/tutorial/tutorial.png");
  menuImage = loadImage("images/mainmenu/mainmenu.png");
  
  minim = new Minim(this);
  input = minim.getLineIn();
  
  //mainMenu = new MainMenu();
  gameOverScreen = new GameOverScreen();
  
  maxSpawnProtection = fps*1.0f;
  
  lives = MAX_LIVES;
  ui_height = UI_HEIGHT_PROPORTION*displayHeight;
  //player = new Player(displayWidth/2, displayHeight/2, 0.8);
  textAlign(CENTER);
  text_size = displayWidth/TEXT_SIZE_PROPORTION;
  
  coeffFriction = 10.0f*FRICTION_PROPORTION;   
  forceRegistry = new ForceRegistry();
  friction = new Friction(coeffFriction, coeffFriction);
  //forceRegistry.add(player, friction);
  
  level = 1;
  //current_level = new Level(1);
  screen = 0;
  
  theme=minim.loadFile("audio/seashanty2.mp3");
  theme.loop();
 
}


public void deleteSave() {
  String path = sketchPath();
  
  File saveGame = new File(path + "\\savedata/savefile");
  if (saveGame.delete()) { 
    System.out.println("Save file deleted");
  } else {
    System.out.println("Failed to delete save file.");
  } 
}

public void nextLevel() {
  updateRunTime();
  level++;
  saveGame();
  current_level = new Level("levels\\" + "level_" + level);
  
}

public void playSound(String sound) {
  audioPlayer = null;
  audioPlayer = minim.loadFile(sound);
  audioPlayer.setGain(-10);
  audioPlayer.play();
}

public void saveGame() {
  updateRunTime();
  String[] saveData = new String[3];  // only need to save the current level, the lives and the current time of the run
  saveData[0] = Integer.toString(level);
  saveData[1] = Integer.toString(lives);
  saveData[2] = Long.toString(runTime);  
  saveStrings("savedata/savefile", saveData);
}

public void loadCustomMap(String levelName) {
  lives = MAX_LIVES;
  current_level = new Level("custom_maps\\" + levelName);
  screen = 1;
}

public void loadGame() {
  try {
    String[] saveData = loadStrings("savedata/savefile");
    level = Integer.parseInt(saveData[0]);
    lives = Integer.parseInt(saveData[1]);
    runTime = Long.parseLong(saveData[2]);
    println(runTime);
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

public void startNewGame() {
  lives = MAX_LIVES;
  playingCustomGame = false;
  runTime = 0;
  level = 1;
  startTime = System.currentTimeMillis();
  current_level = new Level("levels\\" + "level_" + level);
}  

public void keyPressed() {
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
  } else if (screen == 4 || screen == 5) {
    switch (key) {
      case ENTER:
      case RETURN:
        playSound("audio/menu_select.mp3");
        screen = 0;
    }
  }
} 

public void keyReleased() {
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

public void updateRunTime() {
  endTime = System.currentTimeMillis();
  runTime += (endTime - startTime);
  startTime = System.currentTimeMillis(); 
}


public void restartLevel() {
  // TODO: add functionality
  return;
}

public void loseLife() {
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

public void mousePressed() {
  if (screen == 2) {
    if (mouseButton == LEFT) {
      levelEditor.handleClick(mouseX, mouseY);
    } else if (mouseButton == RIGHT) {
      levelEditor.removeEntity(mouseX, mouseY);
    }
  }
}


public void update() {
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

public void draw() {
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
  }
  
  
  
  
}
class Animation {
  PImage[] images;
  int imageCount;
  int frame;
    
  Animation(String imagePrefix, int count) {
    imageCount = count;
    images = new PImage[imageCount];

    for (int i = 0; i < imageCount; i++) {
      // Use nf() to number format 'i' into four digits
      String filename = "images\\" + imagePrefix + "\\" +  imagePrefix + nf(i, 4) + ".png";
      images[i] = loadImage(filename);
    }
    
  }

  
  public void display(float xpos, float ypos, float image_width, float image_height, boolean iterate_frame) {
    
    if (iterate_frame) frame = (frame+1) % imageCount;
    image(images[frame], xpos, ypos, image_width, image_height);
  }
  
  
  public int getWidth() {
    return images[0].width;
  }
}
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
    this.centred = centred ? 0.5f : 0;
    this.position.x += tile_size*this.centred;
    this.position.y += tile_size*this.centred;
    target = new PVector(dx*tile_size + shift + this.centred*tile_size, dy*tile_size + this.centred*tile_size);
    start = new PVector(x, y);
    end = new PVector(dx, dy);
    //start = position.copy();
    //end = target.copy();
    img = loadImage("images/saw/saw0001.png");
  }
  
  public String getEntityData() {
    String[] entityData = new String[8];
    entityData[0] = "c";
    entityData[1] = Integer.toString((int)start.x);
    entityData[2] = Integer.toString((int)start.y);
    entityData[3] = Integer.toString((int)end.x);
    entityData[4] = Integer.toString((int)end.y);
    entityData[5] = Float.toString(0.8f);
    entityData[6] = "1";
    entityData[7] = centred > 0 ? "1" : "0";
    
    String csvData = String.join(",", entityData);
    return csvData;
  }
  
  //voidi secondClick();
  
  public void onCollision(Player p) {
    loseLife();
  }
  
  public Boolean collision(float x, float y, float objectSize) {
    return position.dist(new PVector(x, y)) <= size/2+objectSize/2;
  }
  
  public void secondClick(int x, int y, float centred) {
    target = new PVector(end.x*tile_size + shift + this.centred*tile_size, end.y*tile_size + this.centred*tile_size);
    end = new PVector(x, y);
  }
  
  public void move() {    
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
  
  public void draw() {
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
class Collider extends Interactable {
  float centred;
  Animation animation;
  float hit;
  
  Collider(int x, int y, boolean centred, float tile_size, float proportionalSize, float shift) {
    super(x, y, tile_size, proportionalSize, shift);
    this.centred = centred ? 0.5f : 0;
    this.position.x += tile_size*this.centred;
    this.position.y += tile_size*this.centred;
    hit = 0f;
    animation= new Animation("collider", COLLIDER_ANIMATION_FRAMES);
  }
  
  public void draw() {
    //strokeWeight(0);
    //fill(50,168,82);
    //stroke(50,168,82);
    //circle(position.x, position.y, size);
    animation.display(position.x-size/2, position.y-size/2, size, size, hit > 0);
    
    if (hit > 0) hit--;
  }
  
  public String getEntityData() {
    String[] entityData = new String[4];
    entityData[0] = "C";
    entityData[1] = Integer.toString((int)tilePosition.x);
    entityData[2] = Integer.toString((int)tilePosition.y);
    entityData[3] = centred > 0 ? "1" : "0";
    
    String csvData = String.join(",", entityData);
    return csvData;
  }
  
  public void secondClick(int x, int y, float centred){};
  
  public void onCollision(Player p) {
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
      contacts.add(new Contact(this, p, 1.0f, distance));
      hit = COLLIDER_ANIMATION_FRAMES*3;
    
  }
  
  public Boolean collision(float x, float y, float objectSize) {
    return position.dist(new PVector(x, y)) <= size/2+objectSize/2;
  }
  
}
public class Contact {
  // The two particles in contact
  Interactable p1 ;
  Rigid_Body p2 ;
  
  // Coefficient of restitution
  float c ;
  
  // The direction of the contact (from p1's perspective)
  // Equivalent to normal of p1 - p2
  PVector contactNormal ;
  
  // Construct a new Contact from the given parameters
  public Contact (Interactable p1, Player p2, float c, PVector contactNormal) {
    this.p1 = p1 ;
    this.p2 = p2 ;
    this.c = c ;
    this.contactNormal = contactNormal ; 
  }
  
  // Resolve this contact for velocity
  public void resolve () {
    resolveVelocity() ;
  }
  
  // Calculate the separating velocity for this contact
  // This is just the simplified form of the closing velocity eqn
  public float calculateSeparatingVelocity() {
    PVector relativeVelocity = new PVector() ;
    relativeVelocity.sub(p2.velocity) ;
    return relativeVelocity.dot(contactNormal) ;
  }
  
  // Handle the impulse calculations for this collision
  public void resolveVelocity()  {
    //Find the velocity in the direction of the contact
    float separatingVelocity = calculateSeparatingVelocity() ;
        
    // Calculate new separating velocity
    float newSepVelocity = -separatingVelocity * c ;
    
    // Now calculate the change required to achieve it
    float deltaVelocity = newSepVelocity - separatingVelocity ;
    
    // Apply change in velocity to each object in proportion inverse mass.
    // i.e. lower inverse mass (higher actual mass) means less change to vel.
    float totalInverseMass = p2.invMass ;
    //totalInverseMass += p2.invMass ;
    
    // Calculate impulse to apply
    float impulse = deltaVelocity / totalInverseMass ;
        
    // Find the amount of impulse per unit of inverse mass
    PVector impulsePerIMass = contactNormal.copy() ;
    impulsePerIMass.mult(impulse) ;
    
    // Calculate the p1 impulse
    //PVector p1Impulse = impulsePerIMass.copy() ;
    //p1Impulse.mult(p1.invMass) ;
    
    // Calculate the p2 impulse
    // NB Negate this one because it is in the opposite direction 
    PVector p2Impulse = impulsePerIMass.copy() ;
    p2Impulse.mult(-p2.invMass) ;
    
    // Apply impulses. They are applied in the direction of contact, proportional
    //  to inverse mass
    //p1.velocity.add(p1Impulse) ;
    p2.velocity.add(p2Impulse) ;
  }
}


class ContactResolver {
 
  // Resolves a set of particle contacts
  public void resolveContacts(ArrayList contacts) {
    Iterator itr = contacts.iterator() ;
    while(itr.hasNext()) {
      Contact contact = (Contact)itr.next() ;
      contact.resolve() ;
    } 
  }
}
abstract class ForceGenerator {
  public abstract void updateForce(Rigid_Body r);
}
class ForceRegistration {
  public final Rigid_Body r;
  public final ForceGenerator forceGenerator;
  
  ForceRegistration(Rigid_Body r, ForceGenerator forceGenerator) {
    this.r = r;
    this.forceGenerator = forceGenerator;
  }
}
class ForceRegistry {
  ArrayList<ForceRegistration> registrations;
  
  ForceRegistry() {
    registrations = new ArrayList();
  }
  
  public void add(Rigid_Body r, ForceGenerator fg) {
    registrations.add(new ForceRegistration(r, fg)); 
  }
  
  public void remove(Rigid_Body r) {
    ForceRegistration toRemove = null;
    for (ForceRegistration fr : registrations) {
      if (fr.r.equals(r)) {
        toRemove = fr;
      }
    }
    if (toRemove != null) {
      registrations.remove(toRemove);
    }
  }
  
  public void updateForces() {
    Iterator<ForceRegistration> itr = registrations.iterator() ;
    while(itr.hasNext()) {
      ForceRegistration fr = itr.next() ;
      fr.forceGenerator.updateForce(fr.r) ;
    }
  }
}
public class Friction extends ForceGenerator {
  float c;
  float c2;
  
  Friction (float c, float c2) {
    this.c = c;
    this.c2 = c2;
  }
  
  public void updateForce(Rigid_Body r) {
    if (r.velocity.mag() != 0.0f) {
      PVector force = r.velocity.copy() ;
    
      //Calculate the total drag coefficient
      float dragCoeff = force.mag() ;
      dragCoeff = c * dragCoeff + c2 * dragCoeff * dragCoeff ;
      
      //Calculate the final force and apply it
      force.normalize() ;
      force.mult(-dragCoeff) ;
      r.addForce(force) ;
      
      
      //float dragMagnitude = c;
            
      //PVector friction = r.velocity.copy();
      //friction.normalize();
      //friction.mult(-1);
      //friction.mult(dragMagnitude);
      
      //r.addForce(friction);
    }
  }
   
    
    //PVector force = r.velocity.copy();
    
    //float c = force.mag();
    //c = k1*c + k2*c*c;
    
    //force.normalize();
    //force.mult(-c);
    //r.addForce(force);
      

}
class GameOverScreen {
  public void draw() {
    int[] bg = COLOURS.get("darkblue");
    background(bg[0], bg[1], bg[2]);
    textSize(text_size*2);
    
    textAlign(CENTER);
    fill(225);
    text("You died. Better luck next time!", displayWidth/2, displayHeight/3);
    
    StringBuilder time = new StringBuilder();
    time.append("\nYour time: " );
    time.append(Long.toString((runTime/1000)/60));
    time.append(" minutes and ");
    time.append(Long.toString((runTime/1000)%60));
    time.append(" seconds.");
    
    text(time.toString(), displayWidth/2, displayHeight/3);
    
    textSize(text_size);
    text("\n\n\n\nPress enter to continue", displayWidth/2, displayHeight/3);
  }
}
class Gate extends Interactable {
  int colour;
  String colourString;
  int edge;
  float gateLength;
  PVector startPoint;
  PVector endPoint;
  
  Gate(int x, int y, String colour, int edge, float tile_size, float proportionalSize, float shift) {
    super(x, y, tile_size, proportionalSize, shift);
    int[] colourRGB = COLOURS.get(colour);
    colourString = colour;
    this.colour = color(colourRGB[0], colourRGB[1], colourRGB[2]);
    this.edge = edge;
    gateLength = tile_size;
    
    startPoint = new PVector((edge==0 || edge==3) ? 0 : gateLength, (edge==0 || edge==3) ? 0 : gateLength);
    endPoint = new PVector((edge==2 || edge==3) ? 0 : gateLength, (edge==0 || edge==1) ? 0 : gateLength);
  }
  
  public void secondClick(int x, int y, float centred){};
  
  public String getEntityData() {
    String[] entityData = new String[5];
    entityData[0] = "G";
    entityData[1] = Integer.toString((int)tilePosition.x);
    entityData[2] = Integer.toString((int)tilePosition.y);
    entityData[3] = colourString;
    entityData[4] = Integer.toString(edge);
    
    String csvData = String.join(",", entityData);
    return csvData;
  }
  
  public void draw() {
    if (active) {
       stroke(colour);
       fill(colour);
       strokeWeight(3);
       
       pushMatrix();
       translate(position.x, position.y);
        
       line(startPoint.x, startPoint.y, endPoint.x, endPoint.y);
       
       popMatrix();
    }
  }
  
  public void onCollision(Player p) {
    p.position.x += p.velocity.x*-0.3f;
    p.position.y += p.velocity.y*-0.3f;
    p.position.x += p.velocity.x*-1;
    p.position.y += p.velocity.y*-1;
    p.velocity.mult(0);
    p.acceleration.mult(0);
  }
  
  public Boolean collision (float x, float y, float objectSize) {
    if (!active) {
      return false;
    }
    float p1_x = position.x + startPoint.x;
    float p1_y = position.y + startPoint.y;
    
    float dist_x = x - position.x;
    float dist_y = y - position.y;
    float distance = (float)Math.sqrt((dist_x*dist_x) + (dist_y*dist_y));
    
    if (distance <= objectSize/2) {
      return true;
    }
    
    float p2_x = position.x + endPoint.x;
    float p2_y = position.y + endPoint.y;
    
    dist_x = x - p2_x;
    dist_y = y - p2_y;
    distance = (float)Math.sqrt((dist_x*dist_x) + (dist_y*dist_y));
    
    if (distance <= objectSize/2) {
      return true;
    }
    
    // get closest point on unbounded line
    float dot = ( ((x-p1_x)*(p2_x-p1_x)) + ((y-p1_y)*(p2_y-p1_y)) ) / pow(size,2);
    float closestX = p1_x + (dot * (p2_x-p1_x));
    float closestY = p1_y + (dot * (p2_y-p1_y));
    
    // check if the point found is on the line
    float p1_dist = dist(closestX, closestY, p1_x, p1_y);
    float p2_dist = dist(closestX, closestY, p2_x, p2_y);
    
    if (p1_dist+p2_dist >= size && p1_dist+p2_dist <= size) {
      dist_x = closestX - x;
      dist_y = closestY - y;
      distance = (float)Math.sqrt((dist_x*dist_x) + (dist_y*dist_y));
      if (distance <= objectSize/2) {  
        return true;
      }
      
    } else {
      return false;
    }
    
    return false;
  }
}
class Goal {
  PVector position;
  float size;
  float angle;
  PImage img;
  
  float shift;
  float proportionalSize;
  PVector tilePosition;
  
  float tile_size;
  
  Goal(int x, int y, float tile_size, float proportionalSize, float shift) {
    tilePosition = new PVector(x, y);

    this.proportionalSize = proportionalSize;
    position = new PVector();
    updateSize(tile_size, shift);
    
    position = new PVector(position.x+tile_size/2, position.y+tile_size/2);
    angle = 0;
    img = loadImage("images/goal/goal.png");
  }
  
  public String getEntityData() {
    String[] entityData = new String[3];
    entityData[0] = "g";
    entityData[1] = Integer.toString((int)tilePosition.x);
    entityData[2] = Integer.toString((int)tilePosition.y);
    
    String csvData = String.join(",", entityData);
    return csvData;
  }
  
  public void updateSize(float tile_size, float shift) {    
    this.tile_size = tile_size;
    this.shift = shift;
    
    size = proportionalSize*this.tile_size;
    position.x = this.tile_size*tilePosition.x + this.shift;
    position.y = this.tile_size*tilePosition.y;
    
  }
  
  public Boolean collision(float x, float y, float objectSize) {
    return position.dist(new PVector(x, y)) <= size/2+objectSize/2;
  }
  
  public void draw() {
    pushMatrix();
    translate(position.x, position.y);
    rotate(angle);
    angle += PI/128;
    if (angle >= TWO_PI) {
      angle = TWO_PI-angle;
    }
    image(img, -size/2, -size/2, size, size);
    popMatrix();
  }
  
}
abstract class Interactable {
  PVector position;
  PVector tilePosition;
  boolean active;
  float size;
  float proportionalSize;
  float tile_size;
  float shift;
  
  Interactable(int x, int y, float tile_size, float proportionalSize, float shift) {
      tilePosition = new PVector(x, y);
      active = true;
      this.proportionalSize = proportionalSize;
      position = new PVector();
      updateSize(tile_size, shift);
  }
  
  public abstract String getEntityData();
    
  public void updateSize(float tile_size, float shift) {    
    this.tile_size = tile_size;
    this.shift = shift;
    size = proportionalSize*this.tile_size;
    position.x = this.tile_size*tilePosition.x + this.shift;
    position.y = this.tile_size*tilePosition.y;
    
  }
    
  public abstract void secondClick(int x, int y, float centred);
    
  public abstract void onCollision(Player p);
  
  public abstract Boolean collision(float x, float y, float objectSize);
  
  public abstract void draw();
}
class Key extends Interactable {
  int colour;
  String colourString;
  float size;
  float centred;
  
  Key(int x, int y, String colour, boolean centred, float tile_size, float proportionalSize, float shift) {
    super(x, y, tile_size, proportionalSize, shift);
    int[] colourRGB = COLOURS.get(colour);
    colourString = colour;
    this.colour = color(colourRGB[0], colourRGB[1], colourRGB[2]);
    size = tile_size*0.4f;
    active = true;
    this.centred = centred ? 0.5f : 0;
    this.position.x += tile_size*this.centred;
    this.position.y += tile_size*this.centred;
  }
  
  public String getEntityData() {
    String[] entityData = new String[5];
    entityData[0] = "k";
    entityData[1] = Integer.toString((int)tilePosition.x);
    entityData[2] = Integer.toString((int)tilePosition.y);
    entityData[3] = colourString;
    entityData[4] = centred > 0 ? "1" : "0";
    
    String csvData = String.join(",", entityData);
    return csvData;
  }
  
  public void onCollision(Player p) {
    for (Gate g : gates) {
        if (g.colourString.equals(colourString)) {
          g.active = false;
          
        }
      }
      active = false;
  }
  
  public void secondClick(int x, int y, float centred){};
  
  public Boolean collision(float x, float y, float objectSize) {
    if (!active) {
      return false;
    }
    return position.dist(new PVector(x, y)) <= size/2+objectSize/2;
    
  }
  
  public void draw() {
    if (active) {
      strokeWeight(0);
      stroke(colour);
      fill(colour);
      
      circle(position.x, position.y, size);
    }
  }
}
class Level {
  
  String levelName;
  float tile_size;
  int tilesX;
  int tilesY;
  String[][] level_data;
  String[] entity_data_list;
    
  float horizontalShift;
  
  Level(String levelName) {
    this.levelName = levelName;
    loadLevel();
    create_ui();

    coeffFriction = tile_size*FRICTION_PROPORTION;
    push_force = tile_size*PUSH_FORCE_PROPORTION;
  }
  
  public void create_ui() {
    ui_elements = new ArrayList<UiElement>();
    ui_elements.add(new LifeIndicator(displayWidth/80, displayHeight/100, tile_size*(PLAYER_SIZE_PROPORTION/1.2f)));
    
    ui = new UI(horizontalShift, tile_size*tilesX);
  }
  
  
  public void changeTile(int x, int y, String newTile) {
    level_data[y][x] = newTile;
  }
  
  public int[] getTilePos(float x, float y) {
    int[] tilePos = new int[2];
    
    tilePos[0] = (int) ((x - horizontalShift)/tile_size);
    tilePos[1] = (int) ((y)/tile_size);
    
    return tilePos;
  }
  
  
  public void create_entities() {
    
    keys = new ArrayList<Key>();
    gates = new ArrayList<Gate>();
    
    interactables = new ArrayList<Interactable>();
    
    for (String s : entity_data_list) {
      String[] entity_data = s.split(",");
      
      int x_pos = Integer.parseInt(entity_data[1]);
      int y_pos = Integer.parseInt(entity_data[2]);
      //float x_pos = (tile_size*Integer.parseInt(entity_data[1])) + horizontalShift;
      //float y_pos = tile_size*Integer.parseInt(entity_data[2]);
      
      switch (entity_data[0]) {
        case "p":
          int facing = Integer.parseInt(entity_data[3]);
          player = new Player(x_pos, y_pos, 0.8f, friction, facing, tile_size, PLAYER_SIZE_PROPORTION, horizontalShift);
          forceRegistry.add(player, friction);
          break;
        case "s":
          float seconds_alive = Float.parseFloat(entity_data[3]);
          float seconds_delay = Float.parseFloat(entity_data[4]);
          interactables.add(new Spikes(x_pos, y_pos, tile_size, seconds_alive, seconds_delay, SPIKES_PROPORTION, horizontalShift));
          break;
        case "o":
          float radius = Float.parseFloat(entity_data[3]);
          float init_dir = Float.parseFloat(entity_data[4]);
          float weight = Float.parseFloat(entity_data[5]);
          float speed = Float.parseFloat(entity_data[6]);
          Boolean centred = entity_data[7].equals("1");
          boolean clockwise = entity_data[8].equals("1");
          interactables.add(new Orbiter(x_pos, y_pos, init_dir, weight, speed, centred, clockwise, tile_size, radius, horizontalShift));
          break;
        case "c":
          int dx = Integer.parseInt(entity_data[3]);
          int dy = Integer.parseInt(entity_data[4]);
          speed = Float.parseFloat(entity_data[5]);
          float delay = Float.parseFloat(entity_data[6]);
          centred = entity_data[7].equals("1");
          interactables.add(new CircularSaw(x_pos, y_pos, dx, dy, speed, delay, centred, tile_size, SAW_PROPORTION, horizontalShift));
          break;
        case "G":
          String colourString = entity_data[3];
          int edge = Integer.parseInt(entity_data[4]);
          Gate g = new Gate(x_pos, y_pos, colourString, edge, tile_size, GATE_PROPORTION, horizontalShift);
          interactables.add(g);
          gates.add(g);
          break;
        case "k":
          colourString = entity_data[3];
          centred = entity_data[4].equals("1");
          interactables.add(new Key(x_pos, y_pos, colourString, centred, tile_size, KEY_PROPORTION, horizontalShift));
          break;
        case "g":
          goal = new Goal(x_pos, y_pos, tile_size, GOAL_PROPORTION, horizontalShift);
          break;
        case "j":
          centred = entity_data[3].equals("1");
          interactables.add(new Springpad(x_pos, y_pos, centred, tile_size, SPRINGPAD_PROPORTION, horizontalShift));
          break;
        case "C":
          centred = entity_data[3].equals("1");
          interactables.add(new Collider(x_pos, y_pos, centred, tile_size, COLLIDER_PROPORTION, horizontalShift));
          break;
      }
    }

  }
  
  public void loadLevel() {
    contacts = new ArrayList<Contact>();
    contactResolver = new ContactResolver();
    
    String path = levelName;
    String[] level_string_data = loadStrings(path);
    
    String entity_name = path + "_entities";
    entity_data_list = loadStrings(entity_name);

    tilesX = level_string_data[0].length();
    tilesY = level_string_data.length;
    
    tile_size = (displayHeight-ui_height)/tilesY;
    horizontalShift = (displayWidth-(tile_size*tilesX))/2;
    //horizontalShift = 0;
    
    level_data = new String[tilesX][tilesY];
    
    for (int i = 0; i < level_string_data.length; i++) {
      level_data[i] = (level_string_data[i].split(""));
    }

    create_entities();
    
  }
  
  public void draw() {
    strokeWeight(1);
    fill(0);
    int[] colorRGB;
    
    for (int i = 0; i < tilesY; i++) {
      for (int j = 0; j < tilesX; j++) {
        switch(level_data[i][j]){
          case "0":
            colorRGB = COLOURS.get("darkblue");
            break;
          case "1":
            colorRGB = COLOURS.get("lightblue");
            break;
          case "2":
            colorRGB = COLOURS.get("yellow");
            break;
          case "3":
            colorRGB = COLOURS.get("white");
            break;
          default:
            colorRGB = COLOURS.get("black");  // if it's black then there's been an error
            
        }
        stroke(colorRGB[0], colorRGB[1], colorRGB[2]);
        fill(colorRGB[0], colorRGB[1], colorRGB[2]);
        rect(j*tile_size+horizontalShift, i*tile_size, tile_size, tile_size);
      }
    }
    
    for (Interactable i : interactables) {
      i.draw();
    }
    
    goal.draw();
    
    for (UiElement u : ui_elements) {
      u.draw();
    }
  }
  
  public Boolean getOverlapping() {

    // get tile the center of the player is on, as well as the position of the player's center
    float player_pos_x = player.position.x;
    float player_pos_y = player.position.y;
    
    int tile_x = PApplet.parseInt((player_pos_x-horizontalShift)/tile_size);
    int tile_y = PApplet.parseInt(player_pos_y/tile_size);
    
 
    if (player_pos_x - player.size/2 <= horizontalShift) {
      return true;
    }
    // check if player has gone too far right
    else if (player_pos_x + player.size/2 >= horizontalShift+current_level.tilesX*tile_size) {
      return true;
    }
    // check if player has gone too far up
    if (player_pos_y - player.size/2 <= 0) {
      return true;
    }
    // check if player has gone too far down
    else if (player_pos_y + player.size/2 >= current_level.tilesY*tile_size) {
      return true;
    }
    
    // want to get the highest-friction tile the player is on
    float highest_friction = 0.0f;
    
    // iterate through the nine tiles the player could be colliding with
    for (int i = (tile_y-1 >= 0 ? tile_y-1 : 0) ; i <= (tile_y+1 < current_level.tilesY ? tile_y+1 : current_level.tilesY-1); i++) {
      // if the player goes off the left or right edges of the level
      if (i < 0 || i >= current_level.tilesY) {
        //current_level.create_entities();
        return true;
      }
      
      for (int j = (tile_x-1 >= 0 ? tile_x-1 : 0) ; j <= (tile_x+1 < current_level.tilesX ? tile_x+1 : current_level.tilesX-1); j++) {
        if (j < 0 || j >= current_level.tilesX) {
          //current_level.create_entities();
          return true;
        }
                
        float closest_x = player_pos_x;
        float closest_y = player_pos_y;
        
        // if player is to the left of the tile, check left edge
        if (tile_x < j) {
          closest_x = j*tile_size+horizontalShift;
        }
        // if player it to the right of the tile, check right edge
        else if (tile_x > j) {
          closest_x = j*tile_size+tile_size+horizontalShift;
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
        
        String tile_type = current_level.level_data[i][j];
        
        // && current_level.level_data[i][j].equals("0")
        if (distance < player.size/2)  {
          if (tile_type.equals("0")) {
            return true;
            //current_level.create_entities();
          } else if (TILE_FRICTIONS.keySet().contains(tile_type)) {
            if (TILE_FRICTIONS.get(tile_type) > highest_friction) {
              highest_friction = TILE_FRICTIONS.get(tile_type);
            }
            
          }
        }
        
      }
      
    }
    
    updatePlayerFriction(highest_friction);
    
    player.onIce = highest_friction < 1;

    //player.player_friction.c = coeffFriction*highest_friction;
    //player.player_friction.c2 = coeffFriction*highest_friction;
    //popMatrix();
    
    return false;
  }
  
  public void updatePlayerFriction(float frictionMult) {
    player.player_friction.c = coeffFriction*frictionMult;
    player.player_friction.c2 = coeffFriction*frictionMult;
  }
  
}
class LevelEditor {
  ArrayList<ArrayList<String>> levelData;
  float tile_size;
  int rowCount;
  int columnCount;
  ArrayList<String[]> entityData;
  float horizontalShift;

  int activeTile;

  PImage sawIcon;
  PImage gateKeyIcon;
  PImage gateKeyIcon2;
  PImage orbiterCWIcon;
  PImage orbiterACWIcon;
  PImage springpadIcon;
  PImage spikeIcon;
  PImage colliderIcon;

  ArrayList<PImage> entityImages;

  // mouse snap to grid
  PVector snap1;
  float centred;

  int gateColour;
  boolean placingKey;

  boolean enteringName;
  String levelName;
  
  float warningOpacity = 0;

  // the interactable the player needes to click again for (e.g. saw destination or orbiter endpoint)
  Interactable changing;

  LevelEditor() {
    enteringName = false;
    levelName = "default";
    placingKey = false;
    gateColour = 0;
    changing = null;
    snap1 = new PVector(0, 0);
    centred = 0f;
    updateSnap();

    interactables = new ArrayList<Interactable>();
    activeTile = 1;
    rowCount = 0;
    columnCount = 0;
    levelData = new ArrayList<ArrayList<String>>();
    entityData = new ArrayList<String[]>();
    for (int i = 0; i < 10; i++) {
      addRow();
    }
    for (int i = 0; i < 10; i++) {
      addColumn();
    }
    updateTileSize();

    sawIcon = loadImage("images/saw/saw0001.png");
    gateKeyIcon  = loadImage("images/gatekey/gatekey0000.png");
    gateKeyIcon2  = loadImage("images/gatekey/gatekey0001.png");
    orbiterCWIcon = loadImage("images/orbiter/orbiterCW.png");
    orbiterACWIcon = loadImage("images/orbiter/orbiterACW.png");
    springpadIcon = loadImage("images/jumppad/jumppad0000.png");
    spikeIcon = loadImage("images/spikes/spikes0000.png");
    colliderIcon = loadImage("images/collider/collider0000.png");

    entityImages = new ArrayList<PImage>() {
      {
        add(sawIcon);
        add(gateKeyIcon);
        add(gateKeyIcon2);
        add(orbiterCWIcon);
        add(orbiterACWIcon);
        add(springpadIcon);
        add(spikeIcon);
        add(colliderIcon);
      }
    };
  }
  
  public boolean checkValidity() {
    if (player == null || goal == null) {
      warningOpacity = 255;
      return false;
    }
    return true;
  }

  public void updateSnap() {
    centred = 0f;
    int[] tilePos = getTilePos(mouseX, mouseY);

    PVector mousePos = new PVector(mouseX-horizontalShift, mouseY);
    // check which corner mouse is closest to
    // get the displacement of the mouse in the tile
    float distX = mouseX - horizontalShift - tilePos[0]*tile_size;
    float distY = mouseY - tilePos[1]*tile_size;

    snap1.x = (distX < tile_size/2 ? tilePos[0] : (tilePos[0]+1));
    snap1.y = (distY < tile_size/2 ? tilePos[1] : (tilePos[1]+1));

    // check if distance to centre is less than distance to closest corner
    PVector centre = new PVector(tilePos[0]*tile_size + tile_size/2, tilePos[1]*tile_size + tile_size/2);

    if (mousePos.dist(centre) < mousePos.dist(new PVector(snap1.x*tile_size, snap1.y*tile_size))) {
      snap1.x = tilePos[0];
      snap1.y = tilePos[1];
      centred = 1f;
    }
  }

  public void changeTile(int x, int y) {
    String newTile = Integer.toString(activeTile);
    levelData.get(y).set(x, newTile);
  }

  public void saveMap() {
    try {
      String dirName = "custom_maps\\" + levelName;
      OutputStream o = createOutput(dirName);

      PrintWriter pr = new PrintWriter(o);    

      for (int i = 0; i < rowCount; i++) {
        for (int j = 0; j < columnCount; j++) {
          pr.print(levelData.get(i).get(j));  
        }
        pr.println();
      }
      pr.close();
      
      String eDirName = "custom_maps\\" + levelName + "_entities";
      o = createOutput(eDirName);

      pr = new PrintWriter(o);    

      for (Interactable i : interactables) {
        pr.println(i.getEntityData());
      }
      
      if (player != null) {
        pr.println(player.getEntityData());
      }
      
      if (goal != null) {
        pr.println(goal.getEntityData());
      }
      
      pr.close();
    
    }
    catch (NullPointerException e) {
      e.printStackTrace();
      System.out.println("No such file exists.");
    } 
  }

  public void placeEntity() {

    if (changing == null) {
      switch (activeTile) {
      case 4:
        // circular saw
        Interactable saw = new CircularSaw((int)snap1.x, (int)snap1.y, (int)snap1.x, (int)snap1.y, 0.8f, 1f, centred > 0, tile_size, SAW_PROPORTION, horizontalShift);
        interactables.add(saw);
        changing = saw;
        break;
      case 5:
        // vertical gate and key
        Gate vGate = new Gate((int)snap1.x, (int)snap1.y, (String) GATE_COLOURS.keySet().toArray()[gateColour], 3, tile_size, GATE_PROPORTION, horizontalShift);
        interactables.add(vGate);
        changing = vGate;
        placingKey = true;

        break;
      case 6:
        // horizontal gate and key
        Gate hGate = new Gate((int)snap1.x, (int)snap1.y, (String) GATE_COLOURS.keySet().toArray()[gateColour], 0, tile_size, GATE_PROPORTION, horizontalShift);
        interactables.add(hGate);
        changing = hGate;
        placingKey = true;
        break;
      case 7:
        // clockwise orbiter
        Interactable clockwiseOrbiter = new Orbiter((int)snap1.x, (int)snap1.y, 0f, 3, 4, centred > 0, true, tile_size, 0f, horizontalShift);
        interactables.add(clockwiseOrbiter);
        changing = clockwiseOrbiter;
        break;
      case 8:
        // anti-clockwise orbiter
        Interactable antiClockwiseOrbiter = new Orbiter((int)snap1.x, (int)snap1.y, 0f, 3, 4, centred > 0, false, tile_size, 0f, horizontalShift);
        interactables.add(antiClockwiseOrbiter);
        changing = antiClockwiseOrbiter;
        break;
      case 9:
        // jumppad
        Interactable jumppad = new Springpad((int)snap1.x, (int)snap1.y, centred > 0, tile_size, SPRINGPAD_PROPORTION, horizontalShift);
        interactables.add(jumppad);
        break;
      case 10:
        // spikes
        Interactable spikes = new Spikes((int)snap1.x, (int)snap1.y, tile_size, 2f, 2f, SPIKES_PROPORTION, horizontalShift);
        interactables.add(spikes);
        break;
      case 11:
        // collider
        Interactable collider = new Collider((int)snap1.x, (int)snap1.y, centred > 0, tile_size, COLLIDER_PROPORTION, horizontalShift);
        interactables.add(collider);
        break;
      }
    } else {
      changing.secondClick((int)snap1.x, (int)snap1.y, centred);
      if (placingKey) {
        interactables.add(new Key((int)snap1.x, (int)snap1.y, (String) GATE_COLOURS.keySet().toArray()[gateColour], centred > 0, tile_size, KEY_PROPORTION, horizontalShift));
        placingKey = false;
        gateColour = (gateColour+1)%GATE_COLOURS.size();
      }
      changing = null;
    }
  }

  public int[] getTilePos(float x, float y) {
    int[] tilePos = new int[2];

    // ternary operators are there as java rounds -1 < x < 0 to 0
    tilePos[0] = (int) (((x - horizontalShift)/tile_size) >= 0 ? (x - horizontalShift)/tile_size : -100);
    tilePos[1] = (int) ((y)/tile_size >= 0 ? y/tile_size : -100);
    return tilePos;
  }

  public void updateTileSize() {
    tile_size = (displayHeight-ui_height)/rowCount;
    horizontalShift = (displayWidth-(tile_size*columnCount))/2;

    // very difficult to get them to scale and move with a changing tilemap size, especially circular saw
    interactables.clear();
    
    player = null;
    goal = null;
  }

  public void addRow() {
    ArrayList newRow = new ArrayList<String>();
    for (int i = 0; i < columnCount; i++) {
      newRow.add("0");
    }
    rowCount++;
    levelData.add(newRow);
    updateTileSize();
  }

  public void addColumn() {
    // not an exact check since tile_size changes but it'll do
    if ((columnCount+1)*tile_size <= displayWidth) {
      for (int i = 0; i < rowCount; i++) {
        levelData.get(i).add("0");
      }
      columnCount++;
      updateTileSize();
    }
  }

  public void removeRow() {
    if (rowCount > 1) {
      HashSet<String[]> entitiesToRemove = new HashSet<String[]>();
      for (String[] e : entityData) {
        int yPos = Integer.parseInt(e[2]);
        // check if entity is on the row that is being deleted
        if (yPos == levelData.size()-1) {  
          entitiesToRemove.add(e);
        }
        // circular saw can move onto the deleted row
        if (e[0].equals("c")) {
          if (Integer.parseInt(e[4]) == levelData.size()-1) {
            entitiesToRemove.add(e);
          }
        }
      }

      for (String[] e : entitiesToRemove) {
        entityData.remove(e);
      }
      rowCount--;
      levelData.remove(levelData.size()-1);
      updateTileSize();
    }
  }

  public void removeColumn() {
    if (columnCount  > 1) {
      HashSet<String[]> entitiesToRemove = new HashSet<String[]>();
      for (String[] e : entityData) {
        int xPos = Integer.parseInt(e[1]);
        // check if entity is on the row that is being deleted
        if (xPos == levelData.get(0).size()-1) {  
          entitiesToRemove.add(e);
        }
        // circular saw can move onto the deleted row
        if (e[0].equals("c")) {
          if (Integer.parseInt(e[4]) == levelData.get(0).size()-1) {
            entitiesToRemove.add(e);
          }
        }
      }

      for (String[] e : entitiesToRemove) {
        entityData.remove(e);
      }
      columnCount--;

      for (int i = 0; i < rowCount; i++) {
        levelData.get(i).remove(levelData.get(i).size()-1);
      }
      updateTileSize();
    }
  }
  
  public void placePlayer() {
    if (mouseX < columnCount*tile_size+horizontalShift && mouseY < rowCount*tile_size) {
      player = new Player((int)snap1.x, (int)snap1.y, 0.8f, friction, 0, tile_size, PLAYER_SIZE_PROPORTION, horizontalShift);
    }
  }
  
  public void placeGoal() {
    if (mouseX < columnCount*tile_size+horizontalShift && mouseY < rowCount*tile_size) {
      goal = new Goal((int)snap1.x, (int)snap1.y, tile_size, GOAL_PROPORTION, horizontalShift);
    }
  }
  
  public void removeEntity(float x, float y) {
    ArrayList<Interactable> toRemove = new ArrayList<Interactable>();
    for (Interactable i : interactables) {
      if (i.collision(x,y,20)) {
        toRemove.add(i);
      }
    }
    
    for (Interactable i : toRemove) {
      interactables.remove(i);
    }
  }

  public void handleClick(float x, float y) {
    // check if mouse was clicked in UI bar or above it
    if (y <= (displayHeight-ui_height)) {
      int[] xy = getTilePos(x, y);

      if (xy[0] >= 0 && xy[0] < columnCount && xy[1] >= 0 && xy[1] < rowCount) {
        if (activeTile < 4) {
          changeTile(xy[0], xy[1]);
        } else {
          placeEntity();
        }
      }
    } else {
      // check if one of the four tile types was clicked
      // dont need to check y value of mouse as we already have 
      for (int i = 0; i < TILE_TYPES; i++) {
        float boundLeft = i*(displayWidth/TILE_TYPES);
        float boundRight = boundLeft + ui_height;
        if (x >= boundLeft && x <= boundRight) {
          activeTile = i;
        }
      }
    }
  }

  public void draw() {
    if (!enteringName) {
      strokeWeight(1);
      stroke(0);
      fill(0);

      for (int i = 0; i < rowCount; i++) {
        for (int j = 0; j < columnCount; j++) {
          switch(levelData.get(i).get(j)) {
          case "0":
            //stroke(0, 100, 200);
            fill(0, 100, 200);
            break;
          case "1":
            //stroke(30, 203, 225);
            fill(30, 203, 225);
            break;
          case "2":
            //stroke(200, 175, 120);
            fill(200, 175, 120);
            break;
          case "3":
            //stroke(255);
            fill(255);
            break;
          }
          rect(j*tile_size+horizontalShift, i*tile_size, tile_size, tile_size);
        }
      }

      pushMatrix();
      translate(0, displayHeight-ui_height);
      strokeWeight(0);
      stroke(0);
      fill(0);
      rect(0, 0, displayWidth, ui_height);

      // draw the UI
      String[] tiles = new String[]{"darkblue", "lightblue", "yellow", "white"};
      int offset = 0;
      int[] colorRGB;

      strokeWeight(3);
      // draw the four tile types
      for (String t : tiles) {
        if (activeTile == offset) {
          colorRGB = COLOURS.get("red");
        } else {
          colorRGB = COLOURS.get("grey");
        }
        stroke(colorRGB[0], colorRGB[1], colorRGB[2]);
        colorRGB = COLOURS.get(t);
        fill(colorRGB[0], colorRGB[1], colorRGB[2]);
        //stroke(colorRGB[0], colorRGB[1], colorRGB[2]);
        rect(offset*(displayWidth/TILE_TYPES), 0, ui_height, ui_height); 
        offset++;
      }

      // draw the entity types
      for (PImage p : entityImages) {
        if (activeTile == offset) {
          colorRGB = COLOURS.get("red");
        } else {
          colorRGB = COLOURS.get("grey");
        }
        stroke(colorRGB[0], colorRGB[1], colorRGB[2]);
        fill(0, 0, 0, 0);
        rect(offset*(displayWidth/TILE_TYPES), 0, ui_height, ui_height);  
        //stroke(colorRGB[0], colorRGB[1], colorRGB[2]);
        image(p, (float) offset*(displayWidth/TILE_TYPES)+3f, 3f, ui_height-6f, ui_height-6f);
        offset++;
      }

      popMatrix();

      for (Interactable i : interactables) {
        i.draw();
      }
      
      if (player != null) {
        player.draw();
      }
      
      if (goal != null) {
        goal.draw();
      }

      updateSnap();
      // draw snap indicator
      float circleX = snap1.x*tile_size + horizontalShift + centred*tile_size/2;
      float circleY = snap1.y*tile_size + centred*tile_size/2;
      if (activeTile >= 4 && mouseX < columnCount*tile_size+horizontalShift && mouseY < rowCount*tile_size) {
        strokeWeight(0);
        fill(0, 255, 0);
        stroke(0, 255, 0);

        circle(circleX, circleY, tile_size/10);
      }

      // draw line from snap to changing
      if (changing != null) {
        strokeWeight(2);
        stroke(0);
        line(changing.position.x, changing.position.y, circleX, circleY);
      }
      
      textAlign(CENTER);
      fill(255, 255, 255, warningOpacity);
      textSize(displayWidth/TEXT_SIZE_PROPORTION);
      text("Place the player with 'p' and a goal with 'g' before saving", displayWidth/2, displayHeight/2);
      if (warningOpacity > 0) warningOpacity-=2;
      
    } else {
      background(0);
      textAlign(CENTER);
      textSize(displayWidth/TEXT_SIZE_PROPORTION);
      fill(255);
      text("Enter level name: " + levelName, displayWidth/2, displayHeight/2);
    }
  }
}
class LevelSelect {
  FilenameFilter filter;
  String[] pathnames;
  
  LevelSelect() {
    filter = new FilenameFilter() {
        @Override
        public boolean accept(File f, String name) {
            return !name.contains("_entities");
        }
    };
    
    String path = sketchPath();
    // Creates a new File instance by converting the given pathname string
    // into an abstract pathname
    File f = new File(path + "\\custom_maps");

    // Populates the array with names of files and directories
    pathnames = f.list(filter);
  }
  
  public String getLevelName(int levelNum) {
    if (levelNum >= 0 && levelNum < pathnames.length) { 
      return pathnames[levelNum];
    }
    return "levelNotFoundException";
  }
  
  public void draw() {
    background(0, 100, 200);
    fill(255);
    textSize(displayWidth/TEXT_SIZE_PROPORTION);
    textAlign(LEFT);
    
    for (int i = 0; i < pathnames.length; i++) {
      String pathname = pathnames[i];
      text(i + ": " + pathname, displayWidth/20, (displayHeight/10)*(i+1));
    }
    
  }
  
}
class LifeIndicator extends UiElement {
  float size;
  PImage img;
  
  LifeIndicator(float x, float y, float size) {
    super(x, y);
    this.size = size;
    
    img = loadImage("images/crab/crab0000.png");
  }
  
  public void draw() {
    float xPos = position.x;
    float yPos = position.y;
    for (int i = 0; i < lives; i++) {
      image(img, xPos, yPos, size, size);
      xPos += size + size/2;
    }
  }
}
class MainMenu {
  
  public void draw() {
    textAlign(CENTER);
    textSize(text_size);
    fill(0);
    text("1- New game", displayWidth/2, displayHeight/5);
    text("2- Continue game", displayWidth/2, (displayHeight/5)*2);
    text("3- Exit", displayWidth/2, (displayHeight/5)*3);
    //text("4- Exit", displayWidth/2, (displayHeight/5)*4);
  }
}
class Orbiter extends Interactable {
  float dir;
  float weight;
  float centred;
  float tile_size;
  float radians_per_frame;
  float clockwise;
  float radius;
  
  Orbiter(int x, int y, float init_dir, float weight, float speed, Boolean centred, boolean clockwise, float tile_size, float proportionalSize, float shift) {
    super(x, y, tile_size, proportionalSize, shift);
    this.tile_size = tile_size;
    this.dir = radians(init_dir);
    this.weight = weight;
    this.radians_per_frame = (TWO_PI/speed)/fps;
    this.centred = centred ? 0.5f : 0;
    this.position.x += tile_size*this.centred;
    this.position.y += tile_size*this.centred;
    this.clockwise = clockwise ? 1f : -1f;
    //this.size += this.centred*tile_size;
    
  }
  
  public String getEntityData() {
    String[] entityData = new String[9];
    entityData[0] = "o";
    entityData[1] = Integer.toString((int)tilePosition.x);
    entityData[2] = Integer.toString((int)tilePosition.y);
    entityData[3] = Float.toString(radius);
    entityData[4] = "0";
    entityData[5] = Float.toString(weight);
    entityData[6] = "4";
    entityData[7] = centred > 0 ? "1" : "0";
    entityData[8] = clockwise > 0 ? "1" : "0";
    
    String csvData = String.join(",", entityData);
    return csvData;
  }
  
  public void secondClick(int x, int y, float centred) {
    PVector endPoint = new PVector(x*tile_size + shift + centred*tile_size, y*tile_size + centred*tile_size);
    endPoint.sub(position);
    
    size = endPoint.mag();
    radius = endPoint.mag()/tile_size;
  }
  
  public void draw() {
    stroke(200, 50, 0);
    strokeWeight(weight);
        
    pushMatrix();
    translate(position.x, position.y);
    
    rotate(dir);
    line(0, 0, 0, size);
    
    popMatrix();

    dir += radians_per_frame*clockwise;
    if (dir >= TWO_PI) {
      dir = 0;
    } else if (dir <= 0) {
      dir = TWO_PI;
    }
    
  }
  
  public void onCollision(Player p) {
    loseLife();
  }
  
  public Boolean collision (float x, float y, float objectSize) {
    // check if the player is colliding with either end of the line
    
    float p1_x = position.x;
    float p1_y = position.y;
    
    float dist_x = x - position.x;
    float dist_y = y - position.y;
    float distance = (float)Math.sqrt((dist_x*dist_x) + (dist_y*dist_y));
    
    if (distance <= objectSize) {
      return true;
    }
    
    float p2_x = position.x + size*cos(dir+HALF_PI);
    float p2_y = position.y + size*sin(dir+HALF_PI);
    
    dist_x = x - p2_x;
    dist_y = y - p2_y;
    distance = (float)Math.sqrt((dist_x*dist_x) + (dist_y*dist_y));
    
    if (distance <= objectSize) {
      return true;
    }
    
    // get closest point on unbounded line
    float dot = ( ((x-p1_x)*(p2_x-p1_x)) + ((y-p1_y)*(p2_y-p1_y)) ) / pow(size,2);
    float closestX = p1_x + (dot * (p2_x-p1_x));
    float closestY = p1_y + (dot * (p2_y-p1_y));
    
    // check if the point found is on the line
    float p1_dist = dist(closestX, closestY, p1_x, p1_y);
    float p2_dist = dist(closestX, closestY, p2_x, p2_y);
    
    if (p1_dist+p2_dist >= size && p1_dist+p2_dist <= size) {
      dist_x = closestX - x;
      dist_y = closestY - y;
      distance = (float)Math.sqrt((dist_x*dist_x) + (dist_y*dist_y));
      if (distance <= objectSize) {  
        return true;
      }
      
    } else {
      return false;
    }
    
    return false;
  }
}
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
    
    jumpTime = fps*1.5f;
    jumpDistance = tile_size*2;  // jump two tiles
    
    onIce = false;
  }
  
  public String getEntityData() {
    String[] entityData = new String[4];
    entityData[0] = "p";
    entityData[1] = Integer.toString((int)tilePosition.x);
    entityData[2] = Integer.toString((int)tilePosition.y);
    entityData[3] = Integer.toString((int) (orientation/HALF_PI));
    
    String csvData = String.join(",", entityData);
    return csvData;
  }
  
  public void updateSize(float tile_size, float shift) {    
    this.tile_size = tile_size;
    this.shift = shift;
    size = proportionalSize*this.tile_size;
    position.x = this.tile_size*tilePosition.x + this.shift + tile_size/2;
    position.y = this.tile_size*tilePosition.y + tile_size/2;
    
    this.baseSize = size;
    
  }
  
  public float get_target_dir() {
    
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
  
  public void useSand() {
    if (sandCooldown <= 0 && !inAir) {
      int[] playerPos = current_level.getTilePos(player.position.x, player.position.y);
      current_level.changeTile(playerPos[0], playerPos[1], "2");
      sandCooldown = sandCooldownMax;
    }
  }
  
  public void jump() {
    
    if (airTime <= 0) {
      airTime = jumpTime;  // time in air
      jumpDir = velocity.copy().normalize();
      //jumpDir = new PVector(sin(orientation), -1*cos(orientation));
    }
  }
  
  public void boost() {
    if (boostCooldown <= 0 && !inAir) {
      boostTime  = 10;
      boostCooldown = boostCooldownMax;
      boostDir = new PVector(sin(orientation), -1*cos(orientation));
      boostDir.normalize();
    }
  }
  
  public void useAbilities() {
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
        this.size += baseSize*.02f;
      } else {
        this.size -= baseSize*.02f;
      }

      // jump over a bit more than a tile's length
      velocity.x = jumpDir.x*(jumpDistance/jumpTime);
      velocity.y = jumpDir.y*(jumpDistance/jumpTime);
      
    } else {
      inAir = false;
      size = baseSize;  // jumping should bring size back down anyway, but just in case
    }
  }
  
  public void draw() {
    
    boolean button_pressed = movingLeft || movingRight || movingUp || movingDown;
        
    stroke(150, 50, 50);
    fill(150, 50, 50);
    //circle(position.x, position.y, size);
    //image(animation.images[animation.frame], position.x, position.y);
    
    
    useAbilities();
    
    pushMatrix();
    translate(position.x, position.y);
    
    float turn_speed = min(PLAYER_TURNING_SPEED*(player_friction.c/coeffFriction), PLAYER_TURNING_SPEED*4.0f);
    
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
class Rigid_Body {
  // remember that the normal (AKA the direction) is 1/(magnitude x vector)
  // can be done with v.normalize()
  
  PVector position;
  PVector velocity;
  PVector acceleration;
  
  PVector forceAccumulator;
  
  float targetOrientation;
  float orientation;
  
  //float damping;
  float mass;
  float invMass;
  
  Rigid_Body(float x, float   y, float m) {
    mass = m;
    invMass = 1/mass;
    position = new PVector(x, y);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    forceAccumulator = new PVector(0, 0);
    orientation = 0.0f;  // forward facing by default
    targetOrientation = 0.0f;
  }
  
  public float getMass() {
    return mass;
  }
  
  public void integrate() {
    if (invMass <= 0f) return ;
    
    position.add(velocity);
    
    acceleration = forceAccumulator.copy();
    acceleration.mult(invMass);
    
    velocity.add(acceleration);
    
    if (velocity.mag() < (push_force)/3) {
      velocity.mult(0);
    }
        
    forceAccumulator.mult(0);
    acceleration.mult(0);
  }
  
  public void addForce(PVector force) {
    forceAccumulator.add(force);
  }
  
}
class Spikes extends Interactable {
  
  int state;  
  int max_state = 5;
  float size;
  float increment;
  float time_alive;
  float time_delay;
  float tile_size;
  Boolean active;
  int timer;
  
  Spikes(int x, int y, float tile_size, float seconds_alive, float seconds_delay, float proportionalSize, float shift) {
    super(x, y, tile_size, proportionalSize, shift);
    this.size = tile_size/(SPIKES_PER_TILE*2.2f);  
    this.increment = tile_size/(SPIKES_PER_TILE+1);  // how many "gaps" there are between each layer of spikes and the edges of the tile
    time_alive = fps*seconds_alive;
    time_delay = fps*seconds_delay;
    this.tile_size = tile_size;
    
    
    active = true;
    state = max_state;
    timer = 0;
  }
  
  public String getEntityData() {
    String[] entityData = new String[5];
    entityData[0] = "s";
    entityData[1] = Integer.toString((int)tilePosition.x);
    entityData[2] = Integer.toString((int)tilePosition.y);
    entityData[3] = "2";
    entityData[4] = "2";
    String csvData = String.join(",", entityData);
    return csvData;
  }
  
  public void secondClick(int x, int y, float centred){};
  
  public void draw() {
    stroke(0);
    fill(50);
    
    strokeWeight(1);
    
    pushMatrix();
    translate(position.x, position.y);  // top left of tile the spikes are on
    
    if (active && state < max_state) {
      state++;
    } else if (!active && state > 0) {
      state--;
    }
        
    for (int i = 1; i <= SPIKES_PER_TILE; i++) {
      for (int j = 1; j <= SPIKES_PER_TILE; j++) {
        pushMatrix();
        translate(i*increment, j*increment);  // translate to centre of triangle
        
        float animation_state = (float) ((float)state/ (float)max_state);
        
        
        triangle((size*-1)*animation_state, size, 0, size+(size*-2*animation_state), (size)*animation_state, size);
        //line(size*-1, size, size, size); // lines signifying the spikes are there. Makes the game look kinda bad, so keeping them out.
        popMatrix();
      }
    }
    
    popMatrix();
    
    timer++;
    if (active) {
      if (timer >= time_alive) {
        active = false;
        timer = 0;
      }
    } else {
      if (timer >= time_delay) {
        active = true;
        timer = 0;
      }
    }
    //// TODO : REMOVE LATER. THIS IS JUST FOR TESTING
    //state += going_up ? 1 : -1;
    //if (state == 0) {going_up = true;};
    //if (state == max_state) {going_up = false;};
    ////state = (state+1)%max_state;
  }
  
  public void onCollision(Player p) {
    loseLife();
  }
  
  public Boolean collision(float x, float y, float objectSize) {
    
    // only check if the spikes are active
    if (active) {
      float player_pos_x = x;
      float player_pos_y = y;
      
      float closest_x = player_pos_x;
      float closest_y = player_pos_y;
      
      // check if player is inside the spikes (i.e. spikes become active with player on top)
      if (x >= position.x && x <= position.x+tile_size && y >= position.y && y <= position.y+tile_size) {
        return true;
      }
      
      // check if player is to the left of the spikes
      if (x < position.x) {
        closest_x = position.x;
      }
      // check if player is to the right of the spikes
      else if (x > position.x+tile_size) {
        closest_x = position.x+tile_size;
      }
      // check if player is above the spikes
      if (y < position.y) {
        closest_y = position.y;
      }
      // check if player is below the spikes
      else if (y >= position.y+tile_size) {
        closest_y = position.y+tile_size;
      }
      
      float dist_x = player_pos_x - closest_x;
      float dist_y = player_pos_y - closest_y;
      float distance = (float)Math.sqrt((dist_x*dist_x) + (dist_y*dist_y));
      
      if (distance < objectSize/2)  {
        return true;
      }
    }
    return false;
  }
}
class Springpad extends Interactable {
  float centred;
  Animation animation;
  float hit;
  
  Springpad(int x, int y, boolean centred, float tile_size, float proportionalSize, float shift) {
    
    super(x, y, tile_size, proportionalSize, shift);
        
    this.centred = centred ? 0.5f : 0;
    this.position.x += tile_size*this.centred;
    this.position.y += tile_size*this.centred;
    
    animation = new Animation("jumppad", JUMPPAD_ANIMATION_FRAMES);
  }
  
  public void draw() {
    //stroke(0);
    //fill(100);
    //strokeWeight(1);
    //circle(position.x, position.y, size);
    animation.display(position.x-size/2, position.y-size/2, size, size, hit == fps || hit == 1);
    
    if (hit > 0) hit--;
  }
  
  public String getEntityData() {
    String[] entityData = new String[4];
    entityData[0] = "j";
    entityData[1] = Integer.toString((int)tilePosition.x);
    entityData[2] = Integer.toString((int)tilePosition.y);
    entityData[3] = centred > 0 ? "1" : "0";
    String csvData = String.join(",", entityData);
    return csvData;
  }
  
  public void onCollision(Player p) {
    playSound("audio/jump.mp3");
    player.jump();
    hit = fps;
  }
  
  public void secondClick(int x, int y, float centred){};
  
  public Boolean collision(float x, float y, float objectSize) {
    return (position.dist(new PVector(x, y)) <= objectSize/2);
  }
}
class TutorialScreen {
  PImage tutorial;
  
  TutorialScreen() {
    tutorial = loadImage("images/tutorial/tutorial.png");
  }
  
  public void draw() {
    image(tutorial, 0, 0, displayWidth, displayHeight);
  }
  
}
class UI {
  float shift;
  float levelWidth;
  float elementSize;
  float elementPadding;
  
  PImage boostIcon;
  PImage sandIcon;
  
  UI(float shift, float levelWidth) {
    this.shift = shift;
    this.levelWidth = levelWidth;
    elementSize = ui_height*0.8f;
    elementPadding = ui_height*0.1f;
    boostIcon = loadImage("images/abilities/boost.png");
    sandIcon = loadImage("images/abilities/sand.png");
  }
  
  public void draw() {
    if (screen == 1) {  // regular game screen
      fill(0);
      strokeWeight(1);
      stroke(0);
      
      pushMatrix();
      translate(shift, displayHeight-ui_height);
      rect(0, 0, levelWidth, ui_height);
       
      // draw boost icon, icon border and cooldown indicator
      image(boostIcon, elementPadding, elementPadding, elementSize, elementSize);
      fill(100,100,100,100);
      strokeWeight(0);
      rect(0, 0, ui_height*((float)player.boostCooldown/ (float) player.boostCooldownMax), ui_height);
      
      noFill();
      strokeWeight(2);
      stroke(255);
      rect(0, 0, ui_height, ui_height);
      
      // draw sand icon, icon border and cooldown indicator
      image(sandIcon, ui_height+elementPadding, elementPadding, elementSize, elementSize);
      fill(100,100,100,100);
      strokeWeight(0);
      rect(ui_height, 0, ui_height*((float)player.sandCooldown/ (float) player.sandCooldownMax), ui_height);
      
      noFill();
      strokeWeight(2);
      stroke(255);
      rect(ui_height, 0, ui_height, ui_height);
      
      popMatrix();
    } 
  }
}
abstract class UiElement {
  
  PVector position;
  
  UiElement(float x, float y) {
    position = new PVector(x, y);
  }
  
  public abstract void draw();
}
  public void settings() {  fullScreen(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--present", "--window-color=#666666", "--stop-color=#cccccc", "Main" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
