class Fire {
  PVector position;
  PVector velocity;
  PVector acceleration;
  PVector initPos;
  float lifeSpan;
  
  float maxRadius;
  float red;
  float green;
  float blue;

  Fire(PVector pos) {
    position = pos.copy();
    float v = random(0, 3);
    float r = random(TWO_PI);
    velocity = new PVector(v * cos(r), v * sin(r) - 1);
    acceleration = new PVector(0, 0.01);
    lifeSpan = 255;
    
    maxRadius = random(100, 220);
    initPos = pos.copy();
    red = random(25, 230);
    green = random(25, 230);
    blue = random(25, 230);
  }
  
  void run() {
    update();
    display();
  }
    
  void update() {
    velocity.add(acceleration);
    position.add(velocity);
    lifeSpan--;
  }
  
  void display() {
    winSurface.noStroke();
    //stroke(255, lifeSpan);
    winSurface.fill(red, green, blue, lifeSpan);
    winSurface.ellipse(position.x, position.y, 4, 4);
  }
  
  boolean isDead() {
    return lifeSpan < 0 || dist(initPos.x, initPos.y, position.x, position.y) > maxRadius;
  }
  
}
