class ParticleSystem {
  ArrayList<PVector> particles;
  PVector origin;
  final float particleRadius = cylinderBaseSize;
  
  ParticleSystem() {
    particles = new ArrayList();
  }
  
  ParticleSystem(PVector origin) {
    this.origin = origin.copy();
    particles = new ArrayList();
    particles.add(origin);
  }
  
  void addParticle() {
    PVector center;
    int numAttempts = 100;
    for (int i=0; i < numAttempts; i++) {
      // Pick a cylinder and its center.
      int index = int(random(particles.size()));
      center = particles.get(index).copy();
      // Try to add an adjacent cylinder.
      float angle = random(TWO_PI);
      center.x += sin(angle) * 2 * particleRadius;
      center.z += cos(angle) * 2 * particleRadius;
      if (checkPosition(center)) {
        particles.add(center);
        totalScore -= 1;
        lastScore = -1;
        break;
      }
    }
  }
  
  // Check if a position is available
  boolean checkPosition(PVector center) {
    // we first check that it would not overlap with particles that are already created
    for (int i=0; i< particles.size(); ++i) {
      if (!checkOverlap(center, particles.get(i) )) {
        return false;
      }
    }
    // then we need to check it's inside the board boundaries
    float bound = BOX_LENGTH / 2.0;
    return ((center.x - particleRadius) > - bound && (center.x + particleRadius) < bound
            && (center.z - particleRadius) > - bound && (center.z + particleRadius) < bound);
  }
  
  // Check if a particle with center c1
  // and another particle with center c2 overlap.
  boolean checkOverlap(PVector c1, PVector c2) {
    float distance = PVector.dist(c1,c2);
    return distance > 2.0 * particleRadius;
  }
  
  // Iteratively update and display every particle,
  // and remove them from the list if their lifetime is over.
  void run(int index) {
    if (index == 0) {
      particles.clear();
      if (totalScore > 10) {
        won = true;
      }
    } else {
      particles.remove(index);
    }
  }
}
