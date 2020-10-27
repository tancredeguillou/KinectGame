//====================================================================================================
/**
 * @brief tresholding function on the three channels HSB
 *
 * @param input : the image we want to apply the treshold
 * @param minH, maxH : max and min inputs for the Hue value
 * @param minS, maxS : max and min inputs for the Saturation value
 * @param minB, maxB : max and min inputs for the Brightness value
 *
 * @return : a new thresholded image
 */
PImage tresholdHSB(PImage input, float minH, float maxH, float minS, float maxS, float minB, float maxB) {
    PImage newImage = createImage(input.width, input.height, HSB);
    
    input.loadPixels();
    for (int i = 0; i < input.width * input.height; i++) {
      int p = input.pixels[i];
      newImage.pixels[i] = inside(hue(p), minH, maxH) && inside(brightness(p), minB, maxB) && inside(saturation(p), minS, maxS) ? white : black;
    }
    newImage.updatePixels();
    
    return newImage;
}

//====================================================================================================
/**
 * @brief checks if a value is inside given bounds
 *
 * @param value : the value we want to check
 * @param min : the lower bound
 * @param max : the higher bound
 *
 * @return : true if the value is inside the bounds
 */
boolean inside(float value, float min, float max) {
  return min <= value && value <= max;
}

//====================================================================================================
/**
 * @brief computes the gaussian blur of an image
 *
 * @param input : the image we want to apply the gaussian blur to
 *
 * @return : the result of the convolution of the image with the gaussian kernel
 */
PImage gaussianBlur(PImage input) {
  
  float[][] gaussianKernel = { {9, 12, 9},
                               {12, 15, 12},
                               {9, 12, 9} };
  float normFactor = 99;
    
  PImage result = createImage(input.width, input.height, ALPHA);
  
  // clear the image
  for (int i = 0; i < input.width * input.height; i++) {
    result.pixels[i] = color(0);
  }
  
  // ******************* Implementation of the convolution *********************
  input.loadPixels();
  for (int y = 1; y < input.height - 1; y++) { // Skip top and bottom edges
    for (int x = 1; x < input.width - 1; x++) { // Skip left and right
      result.pixels[y * input.width + x] = color(pixelConvolution(input, gaussianKernel, normFactor, x, y));
    }
  }
  result.updatePixels();
  // **********************************************************************************
    
  return result;
}

//====================================================================================================
/**
 * @brief : computes the convolution of a given pixel
 *
 * @param input : the image we are applying the convolution to
 * @param kernel : the kernel we are using
 * @param weight : the normalization factor of the kernel (i.e the sum of all its elements)
 * @param pixelX : the x component of the pixel
 * @param pixelY : the y component of the pixel
 *
 * return the new value of the pixel after the convolution
 */
float pixelConvolution(PImage input, float[][] kernel, float normFactor, int pixelX, int pixelY) {
  float updated = 0;
  
  for (int x = -1; x <= 1; x++) { // iterate through the elements of a 3x3 matrix (the kernel)
    for (int y = -1; y <= 1; y++) {
      updated += brightness(input.pixels[(pixelY + y) * input.width + (pixelX + x)]) * kernel[x + 1][y + 1];
    }
  }
  return updated/normFactor;
}

//====================================================================================================
/**
 * @brief : Performs the edge detection using the Scharr Operator
 *
 * @param input : the image we want to detect the edges
 *
 * @return a new black and white image, where edges are visible in white
 */
PImage scharr(PImage input) {
  final float[][] vKernel = { { 3, 0, -3 }, 
                            { 10, 0, -10 }, 
                            { 3, 0, -3 } };
                            
  final float[][] hKernel = { { 3, 10, 3 }, 
                            { 0, 0, 0 }, 
                            { -3, -10, -3 } };
                            
  PImage result = createImage(input.width, input.height, ALPHA);
    
  // clear the image
  for (int i = 0; i < input.width * input.height; i++) {
    result.pixels[i] = color(0);
  }

  float max=0;
  float[] buffer = new float[input.width * input.height];
  
  // ******************* Implementation of the double convolution *********************
  img.loadPixels();
  for (int y = 1; y < input.height - 1; y++) { // Skip top and bottom edges
    for (int x = 1; x < input.width - 1; x++) { // Skip left and right
      int index = y * input.width + x;
      float sum_h = pixelConvolution(input, hKernel, 1, x, y);
      float sum_v = pixelConvolution(input, vKernel, 1, x, y);
      float sum = sqrt(pow(sum_h, 2) + pow(sum_v, 2));
      buffer[index] = sum;
      max = max(max, sum);
    }
  }
  result.updatePixels();
  // **********************************************************************************
    
  for (int y = 1; y < input.height - 1; y++) { // Skip top and bottom edges
    for (int x = 1; x < input.width - 1; x++) { // Skip left and right
      int val=(int) ((buffer[y * input.width + x] / max)*255);
      result.pixels[y * input.width + x]=color(val);
    }
  }
    
  return result;
}

//====================================================================================================
/**
 * @brief : computes the threshold binary operation on a given image
 *
 * @param input : the image we want to compute the threshold
 * @param threshold : the value we will use for the threshold operation
 *
 * @return an new image corresponding to the image after the threshold
 */
PImage thresholdBinary(PImage input, int threshold) {
  // create a new, initially transparent, 'result' image
  PImage result = createImage(input.width, input.height, RGB);
  
  for(int i = 0; i < input.width * input.height; i++) {
    result.pixels[i] = (brightness(input.pixels[i]) >= threshold) ? color(255, 255, 255) : color(0, 0, 0);
  }
  return result;
}
