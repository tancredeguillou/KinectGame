import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;

ArrayList<Integer> colors = new ArrayList<Integer>();

//====================================================================================================
/**
 * @brief detects the blobs of an image, based on their connected pixels
 *
 * @param input : black & white image to detect the blobs
 * @param onlyBiggest : condition to return only the biggest blob (if true) or all of them (if false)
 *
 * @return a new image with either only the biggest blob filled in biggestBlobColor, or all blobs filled in random colors
 */
PImage findConnectedComponents(PImage input, boolean onlyBiggest, color biggestBlobColor) {
    
  PImage result = createImage(img.width, img.height, RGB);
    
  input.loadPixels();
    
  // First pass: label the pixels and store labels' equivalences
  int [] labels = new int [input.width * input.height];
  List<TreeSet<Integer>> labelsEquivalences = new ArrayList<TreeSet<Integer>>();
    
  int currentLabel = 1;
    
  // iterate through the pixels of the image
  for (int x = 0; x < input.width; x++) {
    for (int y = 0; y < input.height; y++) {
      int index = y * input.width + x;
      // if the pixel is white, we check for neighbours
      if (input.pixels[index] != black) {
          
        int[] neighbors = new int[4];
        neighbors[0] = (x > 0) ? labels[index - 1] : 0;
        neighbors[1] = (x > 0 && y > 0) ? labels[index - input.width - 1] : 0;
        neighbors[2] = (y > 0) ? labels[index - input.width] : 0;
        neighbors[3] = (x < input.width - 1 && y > 0)? labels[index - input.width + 1] : 0;
          
        // check if we can update the equivalences
        updateEquivalences(labelsEquivalences, neighbors);
        // assign the pixel a new label and increment currentLabel (as if none of the neighbors have a label)
        labels[index] = currentLabel++;
        for (int label : neighbors) {
          // if one of the neighbor as a label, set its value to the pixel if its the minimum
          if (label != 0 && label < labels[index]) {
            labels[index] = label;
          }
        }
        // if the pixel label has changed it means there were valid neighbors, so decrement current label
        if (labels[index] != currentLabel - 1) {
          --currentLabel;
        // if not it means that we created a new label, so we add a TreeSet in equivalenceLabels
        } else {
          TreeSet<Integer> tree = new TreeSet<Integer>();
          tree.add(currentLabel - 1);
          labelsEquivalences.add(tree);
        }
      }
    }
  }
  // Second pass: re-label the pixels by their equivalent class
  // if onlyBiggest==true, count the number of pixels for each label
  int [] countLabels = new int[currentLabel - 1];
  for (int x = 0; x < input.width; x++) {
    for (int y = 0; y < input.height; y++) {
      int index = y * input.width + x;
      if (input.pixels[index] != black) {
        labels[index] = labelsEquivalences.get(labels[index] - 1).first();
        countLabels[labels[index] - 1]++;
      }
    }
  }
  // Finally:
  // if onlyBiggest==true, output an image with the biggest blob in white and others in black
  if (onlyBiggest) {
    int indexMax = 0;
    int max = 0;
    for (int i = 0; i < currentLabel - 1; i++) {
      if (countLabels[i] > max) {
        max = countLabels[i];
        indexMax = i;
      }
    }
    for (int index = 0; index < input.width * input.height; index++) {
      result.pixels[index] = (labels[index] - 1 == indexMax) ? biggestBlobColor : black;
    }
  // if onlyBiggest==false, output an image with each blob colored in one uniform color
  } else {
    if (colors.size() != currentLabel - 1) {
      colors.clear();
      for(int i = 0; i < currentLabel - 1; i++) {
        colors.add(color(random(0,255), random(0,255), random(0,255)));
      }
    }
    for(int i = 0; i < input.width * input.height; i++){
      result.pixels[i] = (labels[i] != 0) ? colors.get(labels[i] - 1) : black;
    }
  }
    
  result.updatePixels();
  return result;
    
}

//====================================================================================================
/**
 * @brief computes the new equivalences classes, based on a pixel's neighbors
 *
 * @param labelsEquivalences : the current list of label equivalences to be updated
 * @param neighbors : the array of the pixel's neighbors
 */
void updateEquivalences(List<TreeSet<Integer>> labelsEquivalences, int[] neighbors) {
  // iterate through the neighbors
  for (int neighbor : neighbors) {
    // if he has a label (i.e non zero)
    if (neighbor != 0) {
      // iterate again through the neighbors
      for (int neighbor2 : neighbors) {
        // check that this neighbor is valid and is different from the first neighbor
        if (neighbor2 != 0 && neighbor2 != neighbor) {
        
          // there is an equivalence between neighbor1 and neighbor2 labels (which are different)
          // so each label which has an equivalence with neighbor1, also must have an equivalence with neighbor2
          for (TreeSet equivalence : labelsEquivalences) {
            if (equivalence.contains(neighbor)) {
              equivalence.add(neighbor2);
            }
          }
        }
      }
    }
  }
}
