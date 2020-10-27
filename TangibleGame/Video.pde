import gab.opencv.*;
import processing.video.*;

PImage img;
final color white = color(255);
final color black = color(0);

class ImageProcessing extends PApplet {
  
Movie cam;

OpenCV opencv;
TwoDThreeD rotations;
List<PVector> bestQuad;

final int imageSize = 400;
final int verticalMargin = 50;
final int cornerCircleSize = 30;

//====================================================================================================
/**
 * @brief : initial method to set the basis : load the image and set the size of our game window accordingly
 */
void settings() {
  size(900, 500);
}

//====================================================================================================
/**
 * @brief : this method is called at the beginning of the program to set the environment : we only set a background
 */
void setup() {
  opencv = new OpenCV(this, 100, 100);
  cam = new Movie(this, "/Users/tancrede/cs211/first-repo/week12/Milestone_II_copy/testvideo.avi");
  cam.loop();
  cam.speed(0.5);
  rotations = new TwoDThreeD(width, height, 15);
}

//====================================================================================================
/**
 * @brief : main method for drawing our game
 */
void draw() {
  background(100);
  if (cam.available() == true) {
    cam.read();
  }
  img = cam.get();
  image(img, 0, 0);
  
  // STEP 1 : colour tresholding
  PImage boardDetection = tresholdHSB(img, 81, 139, 20, 255, 0, 255); /*(img, 81, 139, 20, 255, 40, 255);*/ /*(img, 81, 139, 66, 255, 40, 160);*/
  
  // STEP 2 : gaussian blur
  boardDetection = gaussianBlur(boardDetection);
  
  // STEP 3 : blob detection
  boardDetection = findConnectedComponents(boardDetection, true, white);
  
  // STEP 4 : edge detection
  boardDetection = scharr(boardDetection);
  
  // STEP 5 : thresholding to keep only pixel with values > I, ex. I = 100
  boardDetection = thresholdBinary(boardDetection, 100);
  
  // STEP 6 : hough transformation
  List<PVector> lines = hough(boardDetection, 6);
  plotLines(lines, img);
  bestQuad = findBestQuad(lines, img.width, img.height, img.width*img.height/2, img.width*img.height/8, false);
  if (!bestQuad.isEmpty()) {
    
    stroke(0);
    color[] cornerColors = { color(130, 130, 190), color(190, 230, 80), color(180, 40, 65), color(80, 160, 130) };
    for (int i = 0; i < bestQuad.size(); i++) {
      fill(cornerColors[i], 200);
      circle(bestQuad.get(i).x, bestQuad.get(i).y, cornerCircleSize);
    }
  }
}

PVector getRotations() {
  if (bestQuad.isEmpty()) {
    return null;
  }
  for(int i = 0; i < bestQuad.size(); i++) {bestQuad.get(i).z = 1;}
  return rotations.get3DRotations(bestQuad);
}

void pause() {
  cam.pause();
}

void play() {
  cam.play();
}

//====================================================================================================
/**
 * @brief plots the lines on a given image
 *
 * @param lines : the lines we want to draw
 * @param edgeImg : the image we want to draw the lines on
 */
void plotLines(List<PVector> lines, PImage edgeImg) {
  
  for (int idx = 0; idx < lines.size(); idx++) { 
    PVector line=lines.get(idx);
    float r = line.x; 
    float phi = line.y;
    
    int x0 = 0;
    int y0 = (int) (r / sin(phi));
    int x1 = (int) (r / cos(phi));
    int y1 = 0;
    int x2 = edgeImg.width;
    int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi)); int y3 = edgeImg.width;
    int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));

    // Finally, plot the lines
    stroke(204,102,0); 
    if (y0 > 0) {
      if (x1 > 0) 
        line(x0, y0, x1, y1);
      else if (y2 > 0) 
        line(x0, y0, x2, y2);
      else
        line(x0, y0, x3, y3);
    }
    else {
      if (x1 > 0) { 
         if (y2 > 0)
            line(x1, y1, x2, y2);
         else
            line(x1,y1, x3, y3);
      }
      else
          line(x2, y2, x3, y3);
    }
  }
}
}
