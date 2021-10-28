PImage background;

final float BOX_LENGTH = 200;
final float BOX_HEIGHT = 10;
final float depth = 400;
float speed = 1.0;
float prev_rx = 0.0;
float prev_rz = 0.0;
float rx = 0.0;
float rz = 0.0;
float iMouseX = 0.0;
float iMouseY = 0.0;
Mover mover;

final float cylinderBaseSize = 15;
final float cylinderHeight = 30;
final int cylinderResolution = 40;

PShape borderCylinder = new PShape();
PShape topCylinder = new PShape();
PShape bottomCylinder = new PShape();

boolean shift = false;
boolean mouseLocation = false;
boolean rotationEnable = false;
ParticleSystem ps;

PImage texture;
PShape robot;

HScrollbar scroll;

ImageProcessing imgproc;

//==================== SURFACES ====================//
PGraphics gameSurface;
PGraphics backgroundData;
final float dataHeight = 120;
PGraphics topView;
final float windowFactor = 4.0 / 5.0;
PGraphics score;
double totalScore = 0;
double lastScore = 0;
double normVelocity = 0;
ArrayList<Float> scores;
PGraphics barChart;
final float maxNumberOfRectangles = 20;
int barNumber = 0;
boolean running = false;
int startChart = 0;
int startTime = 0;
float rectWidth = 5;
PGraphics winSurface;
Firework firework;
boolean won = false;

/**
 * Initial method to set the size of our game window
 */
void settings() {
  size(1000, 600, P3D);
  imgproc = new ImageProcessing();
  String []args = {"Image processing window"};
  PApplet.runSketch(args, imgproc);
}

/**
 * This method is called at the beginning of the program to set the environment and the first instances
 */
void setup() {
  // CREATING THE SURFACES
  int windowSize = (int) (dataHeight * windowFactor);
  gameSurface = createGraphics(width, height - (int)dataHeight, P3D);
  backgroundData = createGraphics(width, (int)dataHeight);
  topView = createGraphics(windowSize, windowSize, P2D);
  score = createGraphics(windowSize, windowSize, P2D);
  scores = new ArrayList<Float>();
  scroll = new HScrollbar(score.width + windowSize + 50, height -25, 300, 20);
  barChart = createGraphics(width - score.width - windowSize - 50, windowSize - 25, P2D);
  winSurface = createGraphics(width, height, P2D);
  firework = new Firework();
  // SETTING THE BACKGROUND, LOADING IMAGES
  noStroke();
  mover = new Mover();
  ps = new ParticleSystem();
  background = loadImage("background.jpg");
  background.resize(gameSurface.width, gameSurface.height);
  texture = loadImage("robotnik.png");
  robot = loadShape("robotnik.obj");
  robot.setStroke(false);
  robot.setTexture(texture);
  robot.scale(30);
  robot.rotateX(PI);
  robot.rotateY(PI);

  // CREATING THE CYLINDER SHAPES
  createCylinders();
}

/**
 * main method for drawing our game
 */
void draw() {
  if (!won) {
    drawGame();
    image(gameSurface, 0, 0);
  
    drawBackgroundData();
    image(backgroundData, 0, height - dataHeight);
  
    drawTopView();
    image(topView, dataHeight/10, height - dataHeight + dataHeight/10);
  
    drawScore();
    image(score, 2 * dataHeight/10 + dataHeight * windowFactor, height - dataHeight + dataHeight/10);
  
    drawBarChart();
    image(barChart, 3*dataHeight/10 + dataHeight * windowFactor + score.width, height - dataHeight + dataHeight/10);
    scroll.update();
    scroll.display();
  } else {
    drawWon();
    image(winSurface, 0, 0);
  }
  
}

/**
 * behaviour of the game when the mouse is wheeled
 */
void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  speed = ((speed >= 0.0 && e >= 0.0) || speed >= 0.1) ? speed + e/10000 : 0.0;
}

/**
 * behaviour of the game when the mouse is pressed
 */
void mousePressed() {
  float w = gameSurface.width/2;
  float h = gameSurface.height/2;
  iMouseX = mouseX - w;
  iMouseY = mouseY - h;
  float length = BOX_LENGTH/2;
  // if SHIFT is pressed we check for a valid new cylinder
  if (shift && mouseX - w < length &&  mouseX -  w > - length && mouseY - h > - length && mouseY - h < length
      // check that we are not setting a cylinder on top of the ball.
      && ball_out_of_cylinder(mover.location, mouseX - w, mouseY - h)) {
    mouseLocation = true;
  }
  // if not, the mouse must initially be inside the game pane to be able to move the box
  else if (mouseY <= h * 2) {
    rotationEnable = true;
  }
}

/**
 * behaviour of the game when a key is pressed
 */
void keyPressed() {
  shift = (keyCode == SHIFT) ? true : false;
}

/**
 * behaviour of the game when a key is resleased
 */
void keyReleased() {
  shift = false;
}





//================================================== UTILITY METHODS ==================================================//





/**
 * this method is used in the setup to create the cylinder shape
 */
void createCylinders() {
  float angle;
  float[] x = new float[cylinderResolution + 1]; 
  float[] y = new float[cylinderResolution + 1];

  //get the x and y position on a circle for all the sides.
  for (int i = 0; i < x.length; i++) {
    angle = (TWO_PI / cylinderResolution) * i; 
    x[i] = sin(angle) * cylinderBaseSize;
    y[i] = cos(angle) * cylinderBaseSize;
  }
  
  ambientLight(25, 44, 166);
  fill(255, 212, 121);
  stroke(60);
  borderCylinder = createShape();
  borderCylinder.beginShape(QUAD_STRIP);
  topCylinder = createShape();
  topCylinder.beginShape(TRIANGLE_FAN);
  bottomCylinder = createShape();
  bottomCylinder.beginShape(TRIANGLE_FAN);
  
  bottomCylinder.vertex(0, 0, 0);
  topCylinder.vertex(0, cylinderHeight, 0);
  for (int i = 0; i < x.length; i++) { 
    borderCylinder.vertex(x[i], 0, y[i]);
    borderCylinder.vertex(x[i], cylinderHeight, y[i]);
    bottomCylinder.vertex(x[i], 0, y[i]);
    topCylinder.vertex(x[i], cylinderHeight, y[i]);
  }
  bottomCylinder.vertex(x[0], 0, y[0]);
  topCylinder.vertex(x[0], cylinderHeight, y[0]);
  borderCylinder.endShape();
  bottomCylinder.endShape();
  topCylinder.endShape();
}

/**
 * clamps a given value into the given bounds
 */
float clamp(float f, float low_bound, float high_bound) {
  if (f < low_bound) {
    return low_bound;
  } else if (f > high_bound) {
    return high_bound;
  } else 
  return f;
}

/**
 * draws the principal window of the game
 */
void drawGame() {
  gameSurface.beginDraw();
  // set the background and the lights.
  gameSurface.directionalLight(240, 189, 68, 0, 1, 0);
  gameSurface.ambientLight(25, 44, 166);
  gameSurface.background(background);
  
  // display the rotation, the speed, velocity and location
  gameSurface.pushMatrix();
  gameSurface.lights();
  gameSurface.textSize(10);
  gameSurface.fill(255, 255, 0);
  gameSurface.text(String.format("RotationX : %.2f", (rx * 180/PI)), 0, 10, 0);
  gameSurface.text(String.format("RotationY : %.2f", (rz * 180/PI)), 100, 10, 0);
  gameSurface.text(String.format("Speed : %.2f", speed), 200, 10, 0);
  gameSurface.text(String.format("Ball Location :    %.2f  %.2f  %.2f", mover.location.x, mover.location.y, mover.location.z), 0, 20, 0);
  gameSurface.text(String.format("Ball Velocity :    %.2f  %.2f  %.2f",
                                    abs(mover.velocity.x) < 0.01 ? 0.00 : mover.velocity.x,
                                    abs(mover.velocity.y) < 0.01 ? 0.00 : mover.velocity.y,
                                    abs(mover.velocity.z) < 0.01 ? 0.00 : mover.velocity.z), 0, 30, 0);
  gameSurface.popMatrix();

  float w = gameSurface.width/2;
  float h = gameSurface.height/2;
  // depending on shift/no shift, set the camera, display the ball and check for new cylinders.
  gameSurface.pushMatrix();
  if (!shift) {
    imgproc.play();
    gameSurface.camera(w, h, depth, w, h, 0, 0, 1, 0);
    gameSurface.translate(w, h, 0);
    PVector rot = imgproc.getRotations();
    if (rot != null) {
      float x = degrees(rot.y);
      float z = degrees(rot.x);
      if (x < -90) { x += 180; }
      if (z < -90) { z += 180; }
      if (x > 90) { x -= 180; }
      if (z > 90) { z -= 180; }
      rz = -clamp(speed*map(x, -90, 90, -PI/2, PI/2), -PI/3, PI/3);
      rx = -clamp(speed*map(z, -90, 90, -PI/2, PI/2), -PI/3, PI/3);
      gameSurface.rotateX(rx); // rotate X axis.
      gameSurface.rotateZ(rz); // rotate Z axis.
      prev_rx = rx;
      prev_rz = rz;
    } else {
      gameSurface.rotateX(prev_rx); // rotate X axis.
      gameSurface.rotateZ(prev_rz); // rotate Z axis.
    }
    // draw the box.
    gameSurface.stroke(125);
    gameSurface.fill(137, 191, 231);
    gameSurface.box(BOX_LENGTH, BOX_HEIGHT, BOX_LENGTH);
    // display and move the ball.
    gameSurface.lights();
    mover.update(rx, rz);
    mover.checkEdges();
    int collision_index = mover.checkCylinderCollisions();
    if (collision_index != -1) {
      ps.run(collision_index);
    }
    mover.display();
    //adds a new cylinder each 0.5 seconds
    if (!ps.particles.isEmpty() && frameCount % 30 == 0) {
      ps.addParticle();
    }
    if(!ps.particles.isEmpty()){
      gameSurface.pushMatrix();
      gameSurface.translate(ps.particles.get(0).x, - BOX_HEIGHT / 2 - cylinderHeight, ps.particles.get(0).z);
      float angle = (mover.location.x - ps.particles.get(0).x) / 
                dist(ps.particles.get(0).x, ps.particles.get(0).z, mover.location.x, mover.location.z);
      if (mover.location.z < ps.particles.get(0).z) {
        gameSurface.rotateY(PI - map(asin(angle), -PI/2, PI/2, -PI/2, PI/2));
      } else {
        gameSurface.rotateY(map(asin(angle), -PI/2, PI/2, -PI/2, PI/2));
      }
      gameSurface.shape(robot);
      gameSurface.popMatrix();
    }
  } else {
    imgproc.pause();
    gameSurface.camera(w, -depth/2, 0, w, h, 0, 0, 0, 1);
    gameSurface.translate(w, h, 0);
    // draw the box.
    gameSurface.stroke(125);
    gameSurface.fill(137, 191, 231);
    gameSurface.box(BOX_LENGTH, BOX_HEIGHT, BOX_LENGTH);
    gameSurface.lights();
    mover.display(); // draw the ball.
    // check for new cylinders.
    if (mouseLocation) {
      PVector origin = new PVector(iMouseX, 0, iMouseY);
      ps = new ParticleSystem(origin);
      // if mouseLocation was true we must immediately set it back to false.
      mouseLocation = false;
    }
  }

  // draw the cylinders
  for (PVector coordinates : ps.particles) {
    gameSurface.pushMatrix();
    gameSurface.translate(coordinates.x, - cylinderHeight - BOX_HEIGHT / 2.0, coordinates.z);
    gameSurface.shape(borderCylinder);
    gameSurface.shape(bottomCylinder);
    gameSurface.shape(topCylinder);
    gameSurface.popMatrix();
  }
  gameSurface.popMatrix();
  
  gameSurface.endDraw();
}

/**
 * draws the background data pane
 */
void drawBackgroundData() {
  backgroundData.beginDraw();
  backgroundData.background(220, 217, 162);
  backgroundData.endDraw();
}

/**
 * draws the top view pane
 */
void drawTopView() {
  topView.beginDraw();
  topView.background(30);
  topView.noStroke();
  topView.fill(137, 191, 231);
  float diam = mover.SPHERE_DIAMETER;
  float rad = diam/2;
  topView.square(rad, rad, dataHeight * windowFactor - diam);

  topView.fill(255, 255, 0);
  topView.circle(m(mover.location.x), m(mover.location.z), diam);

  for (int i = 0; i < ps.particles.size(); i++) {
    //draw the first cylinder in red and the other in white
    int color_int = (i == 0) ? 0 : 255;
    topView.fill(255, color_int, color_int);
    topView.circle(m(ps.particles.get(i).x), m(ps.particles.get(i).z), cylinderBaseSize * 0.9);
  }
  topView.endDraw();
}

/**
 * helper method for the drawing of the top view. Calulate the maping for a given coordinate
 */
float m(float coord) {
  return map(coord, -BOX_LENGTH/2, BOX_LENGTH/2, mover.SPHERE_DIAMETER / 2, dataHeight * windowFactor - mover.SPHERE_DIAMETER / 2);
}

/**
 * draws the score pane
 */
void drawScore() {
  score.beginDraw();
  score.stroke(255);
  score.background(57);
  int margin = score.width/10 ;
  int spacing = score.height/7;
  score.textAlign(0, CENTER);
  score.text("Total Score :", margin, spacing);
  score.text(String.format("%.3f", totalScore), margin, 2 * spacing);
  score.text("Velocity :", margin, 3 * spacing);
  score.text(String.format("%.3f", normVelocity), margin, 4 * spacing);
  score.text("Last Score :", margin, 5 * spacing);
  score.text(String.format("%.3f", lastScore), margin, 6 * spacing);
  score.endDraw();
}

/**
 * checks whether the ball is outside the bounds of a given cylinder
 */
boolean ball_out_of_cylinder(PVector ball_coord, float cylinder_coord_x, float cylinder_coord_z) {
  // we need to check that the distance between the mover and the mouse is large enough.
  float distance = dist(ball_coord.x, ball_coord.z, cylinder_coord_x, cylinder_coord_z);
  return distance > mover.SPHERE_DIAMETER + cylinderBaseSize ? true : false;
}

/**
 * draws the bar chart
 */
void drawBarChart() {
  barChart.beginDraw();
  barChart.background(255);
  float abscisse = barChart.height/2;
  
  // we draw the bars if we have some scores, or if we have a first score
  if(totalScore != 0 || !scores.isEmpty()) {
    // if we are starting the chart, we store the time of the beginning of the simulation
    if(!running) {
      startTime = millis();
      running = true;
    }
    // every second we add a new bar
    if ( (millis()-startTime) / 1000 != scores.size()) {
      scores.add((float)totalScore);
    }
    float barNumber = 0;
    
    float rectHeight = barChart.height / maxNumberOfRectangles;

    float scrollWidth = (scroll.getPos() < 0.5) ? rectWidth * map(scroll.getPos(), 0, 0.5, 0.1, 1) : rectWidth * map(scroll.getPos(), 0.5, 1, 1, 5);
    
    barChart.fill(70, 130, 180);
    barChart.stroke(0);
    barChart.strokeWeight( (scrollWidth < 3) ? 0.5 : 1 );
    
    for (float score : scores) {
      for (int i = 0; i < Math.abs(score) / 2; i++) {
        barChart.rect(barNumber * scrollWidth, (score > 0) ?
                                        abscisse - (i+1) * rectHeight
                                      : abscisse + i * rectHeight, scrollWidth, rectHeight);
      }
      barNumber++;
    }
  }
  barChart.stroke(255, 0, 0);
  barChart.line(0, abscisse, barChart.width, abscisse);
  barChart.endDraw();
}

/**
 * draws the winning window
 */
void drawWon() {
  winSurface.beginDraw();
  winSurface.background(0);
  if (frameCount % 120 == 0) {
    firework.fire(new PVector(random(width/2 - 100, width/2 + 100), random(height/2 - 50, height/2 + 50)));
  }
  firework.run();
  winSurface.endDraw();
}
