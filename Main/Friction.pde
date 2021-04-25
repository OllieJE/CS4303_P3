public class Friction extends ForceGenerator {
  private float c;
  
  Friction (float c) {
    this.c = c;
  }
  
  public void updateForce(Rigid_Body r) {
    if (r.velocity.mag() != 0.0) {
      float normal = 1.0f;  // If adding sloped movement, change this 
      float dragMagnitude = c * normal;
      
      PVector friction = r.velocity.copy();
      friction.normalize();
      friction.mult(-1);
      friction.mult(dragMagnitude);
      
      r.addForce(friction);
    }
  }
   
    
    //PVector force = r.velocity.copy();
    
    //float c = force.mag();
    //c = k1*c + k2*c*c;
    
    //force.normalize();
    //force.mult(-c);
    //r.addForce(force);
      

}
