class ForceRegistry {
  ArrayList<ForceRegistration> registrations;
  
  ForceRegistry() {
    registrations = new ArrayList();
  }
  
  void add(Rigid_Body r, ForceGenerator fg) {
    registrations.add(new ForceRegistration(r, fg)); 
  }
  
  void remove(Rigid_Body r) {
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
  
  void updateForces() {
    Iterator<ForceRegistration> itr = registrations.iterator() ;
    while(itr.hasNext()) {
      ForceRegistration fr = itr.next() ;
      fr.forceGenerator.updateForce(fr.r) ;
    }
  }
}
