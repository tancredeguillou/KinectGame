import java.util.Collections;

// pre-compute the sin and cos values
float[] tabSin;
float[] tabCos;

//====================================================================================================
/**
 * @brief computes the hough algorithm on a given image
 *
 * @param edgeImg : the black & white image we want to analyze
 *
 * @return a list of the lines that go through the maximum number of non black pixels
 */
List<PVector> hough(PImage edgeImg, int nLines) {
  
  float discretizationStepsPhi = 0.055f; /*0.055f*/
  float discretizationStepsR = 2.2f; /*2.2f*/
  int minVotes = 50;
  
  // dimensions of the accumulator
  int phiDim = (int) (Math.PI / discretizationStepsPhi +1);
  //The max radius is the image diagonal, but it can be also negative
  int rDim = (int) ((sqrt(edgeImg.width*edgeImg.width + edgeImg.height*edgeImg.height) * 2) / discretizationStepsR +1);
  
  // we store the cos and sin values in arrays to improve performance
  // if both arrays are null, it means they haven't been initialized yet and we need to do it here
  if (tabSin == null && tabCos == null) {
    tabSin = new float[phiDim];
    tabCos = new float[phiDim];
    float ang = 0;
    float inverseR = 1.f / discretizationStepsR;
    for (int accPhi = 0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++) {
      // we can also pre-multiply by (1/discretizationStepsR) since we need it in the Hough loop
      tabSin[accPhi] = (float) (Math.sin(ang) * inverseR);
      tabCos[accPhi] = (float) (Math.cos(ang) * inverseR);
    }
  }
  
  // our accumulator
  int [] accumulator = new int[phiDim * rDim];
  
  // Fill the accumulator: on edge points (ie, white pixels of the edge
  // image), store all possible (r, phi) pairs describing lines going
  // through the point.
  for (int y = 0; y < edgeImg.height; y++) {
    for (int x = 0; x < edgeImg.width; x++) {
      // Are we on an edge?
      if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
        for (int dim = 0; dim < phiDim; dim++) {
          float r = (float) ((x * tabCos[dim] + y * tabSin[dim]));
          r += rDim / 2;
          accumulator[dim * rDim + (int)r] += 1;
        }     
      }
    }
  }
  
  ArrayList<Integer> bestCandidates = new ArrayList<Integer>();
  int regionSize = 15;
  
  // fill bestCandidates with most voted lines
  ArrayList<PVector> lines = new ArrayList<PVector>();
  for (int idx = 0; idx < accumulator.length; idx++) {
    if (accumulator[idx] > minVotes) {
      int localMax = 1;
      // iterate through the neighbors to check whether it is a local maxima
      for (int n_idx = idx - regionSize; n_idx < idx + regionSize; n_idx++) {
        if (0 <= n_idx && n_idx < accumulator.length && accumulator[n_idx] > accumulator[idx]) {
          localMax = -1; }
      }
      if (localMax == 1) {
        bestCandidates.add(idx);
      }
    }
  }
  
  // sort bestCandidates by the number of votes of each line
  Collections.sort(bestCandidates, new HoughComparator(accumulator));
  
  // plot the nLines most voted lines
  for (int n = 0; n < nLines && n < bestCandidates.size(); n++) {
    // first, compute back the (r, phi) polar coordinates:
    int accPhi = (int) (bestCandidates.get(n) / (rDim));
    int accR = bestCandidates.get(n) - (accPhi) * (rDim);
    float r = (accR - (rDim) * 0.5f) * discretizationStepsR;
    float phi = accPhi * discretizationStepsPhi;
    lines.add(new PVector(r,phi));
  }
  
  return lines;
}


//====================================================================================================
/**
 * @brief class describing the comparator for the lines, used in the hough method
 */
class HoughComparator implements java.util.Comparator<Integer> {
  
  int[] accumulator;
  public HoughComparator(int[] accumulator) {
    this.accumulator = accumulator;
  }
  
  @Override
  public int compare(Integer l1, Integer l2) {
    if (accumulator[l1] > accumulator[l2] || (accumulator[l1] == accumulator[l2] && l1 < l2))
      return -1;
    return 1;
  }
}
  
  
  
 
