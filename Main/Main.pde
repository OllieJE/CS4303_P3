import java.util.Iterator;

final int PLAYER_WIDTH_PROPORTION = 20;
final int PLAYER_HEIGHT_PROPORTION = 30;
final float PLAYER_INIT_X_PROPORTION = 4.0;

final float ENEMY_INIT_X_PROPORTION = 1;

final float FORCE_PROPORTION = 9000;
final float FRICTION_PROPORTION = 10800;

final float PUSH_FORCE_PROPORTION = 9600;

final int fps = 60;

float coeffFriction;

int screen = 0;

ForceRegistry forceRegistry;
Friction friction;


void setup() {
  fullScreen();
  frameRate(fps);
   
  Level poopy = new Level(1);
  
}
