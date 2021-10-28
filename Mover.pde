class Mover {
  final float SPHERE_DIAMETER = 10;
  final float DIST_FOR_ROUND = 50.0; // 50
  final float rotationX = 0.0;
  final float rotationZ = 0.0;
  PVector location;
  PVector velocity;
  PVector gravityForce;
  PVector normalVect;
  final float gravityConstant = 0.981;
  final float weight = 20;
  final float normalForce = 1;
  final float mu = 0.01;
  final float elasticity = 0.8;
  final float frictionMagnitude = normalForce * mu; 
  PVector friction ;

  PImage img;
  PShape globe;
  
  Mover() {
    gravityForce = new PVector(0, 0, 0);
    location = new PVector(0, 0, 0);
    velocity = new PVector(0, 0, 0); 
    friction = new PVector(0, 0, 0);
    normalVect = new PVector(0, 0, 0);
    
    img = loadImage("earthmap_hires.jpg");
    globe = createShape(SPHERE, SPHERE_DIAMETER);
    globe.setStroke(false);
    globe.setTexture(img);
  }

  void update(float rx, float rz) {
    gravityForce.x = (sin(rz) * gravityConstant) / weight;
    gravityForce.z = - (sin(rx) * gravityConstant) / weight;
  
    friction = velocity.copy();
    friction.mult(-1);
    friction.normalize(); 
    friction.mult(frictionMagnitude);
    
    normVelocity = sqrt(pow(velocity.x, 2) + pow(velocity.z, 2));
  
    velocity.add(gravityForce);
    velocity.add(friction);
    location.add(velocity);
  }

  void display() {
    gameSurface.pushMatrix();
    gameSurface.noStroke();
    gameSurface.fill(127);
    gameSurface.translate(location.x, - SPHERE_DIAMETER - BOX_HEIGHT/2, location.z);
    // these are the rotations to see the ball roll. It's not very accurate but does the trick.
    gameSurface.rotateZ(map(location.x, - DIST_FOR_ROUND, DIST_FOR_ROUND, -TWO_PI, TWO_PI));
    gameSurface.rotateX(map(-location.z, - DIST_FOR_ROUND, DIST_FOR_ROUND, -TWO_PI, TWO_PI));
    gameSurface.shape(globe);
    gameSurface.popMatrix();
  }

  void checkEdges() {
    if (location.x > BOX_LENGTH/2) {
      location.x = BOX_LENGTH/2;
      velocity.x = velocity.x * - elasticity;
    } else if (location.x < - BOX_LENGTH/2) {
      location.x = - BOX_LENGTH/2;
      velocity.x = velocity.x * - elasticity;
    }
    if (location.z > BOX_LENGTH/2) {
      location.z = BOX_LENGTH/2;
      velocity.z = velocity.z * - elasticity;
    } else if (location.z < - BOX_LENGTH/2) {
      location.z = - BOX_LENGTH/2;
      velocity.z = velocity.z * - elasticity;
    }
  }
  
  // checks if the ball collides on a cyllinder. If so, we call the run method on the particles to delete the cyllinder.
  int checkCylinderCollisions() {
    int i = 0;
    // iterate on the cylinders.
    for (PVector coordinates : ps.particles) {
      // for each cylinder, if the ball is too close to the cylinder, compute the new value.
      if (!ball_out_of_cylinder(location, coordinates.x, coordinates.z)) {
        normalVect = location.copy();
        normalVect.sub(coordinates);
        normalVect.normalize();
        float dist = cylinderBaseSize + SPHERE_DIAMETER - dist(location.x, location.z, coordinates.x, coordinates.z);
        PVector nor = normalVect.copy();
        location = location.add(nor.mult(dist));
        velocity = (velocity.sub(normalVect.mult(2*(velocity.dot(normalVect))))).mult(elasticity);
        totalScore += 2*normVelocity;
        lastScore = normVelocity;
        return i;
      }
      i++;
    }
    return -1;
  }
}
