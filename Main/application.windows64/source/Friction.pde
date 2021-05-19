public class Friction extends ForceGenerator {
  float c;
  float c2;
  
  Friction (float c, float c2) {
    this.c = c;
    this.c2 = c2;
  }
  
  public void updateForce(Rigid_Body r) {
    if (r.velocity.mag() != 0.0) {
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
