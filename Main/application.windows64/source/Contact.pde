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
  void resolve () {
    resolveVelocity() ;
  }
  
  // Calculate the separating velocity for this contact
  // This is just the simplified form of the closing velocity eqn
  float calculateSeparatingVelocity() {
    PVector relativeVelocity = new PVector() ;
    relativeVelocity.sub(p2.velocity) ;
    return relativeVelocity.dot(contactNormal) ;
  }
  
  // Handle the impulse calculations for this collision
  void resolveVelocity()  {
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
