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
    orientation = 0.0;  // forward facing by default
    targetOrientation = 0.0;
  }
  
  float getMass() {
    return mass;
  }
  
  void integrate() {
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
  
  void addForce(PVector force) {
    forceAccumulator.add(force);
  }
  
}
