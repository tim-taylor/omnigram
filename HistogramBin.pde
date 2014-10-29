class HistogramBin {
  
  // relationship to owning Node object
  Node m_node; // reference to associated node
  int m_idx;   // 0-based index to this bin, as used in m_node.m_hgBins
  
  // info on the sampleIDs held in this bin
  ArrayList<Integer> m_sampleIDs; // IDs (zero-based array indices in m_node.m_model.m_data) of data samples in this bin
  int m_numSamples;               // a convenience variable (DERIVED = m_sampleIDs.length())
  
  int m_sNumBrushes = 3; // the number of different brush colors to show

  // color definitions
  color m_strokeColor = 0xFF000000;
  color m_focalInRangeSelFillColor = 0xFF880000;
  color m_focalOutsideRangeSelFillColor = 0xFFFFFFFF;
  color m_nonFocalNonBrushedFillColor = 0xFFFFFFFF;
  //color m_binBackgroundColor = 
  color[] m_brushColors;
  
  int[] m_numBrushedSamples; // records number of brush samples in bin, where index is number of 
                             // near misses. So idx 0 is samples that exactly match selected range
                             // idx 1 is samples with one near miss, etc.
                                                              // [
  int m_x; // x pos of bottom-left corner of bin, relative to left edge of histogram window
  int m_y; // y pos of bottom-left corner of bin, relative to top edge of histogram window
  int m_w; // width of bin
  int m_h; // height of bin
  
  HistogramBin(Node node, int idx, int numSamples, ArrayList<Integer> sampleIDs, int x, int y) {
    m_node = node;
    m_idx = idx;
    m_sampleIDs = sampleIDs;
    m_numSamples = sampleIDs.size();
    m_brushColors = new color[m_sNumBrushes];
    m_numBrushedSamples = new int[m_sNumBrushes];

    for (int i=0; i<m_sNumBrushes; i++) {
      m_numBrushedSamples[i] = 0;
      switch (i) {
        case 0:  m_brushColors[i] = 0xFF000088; break; // brush color for exact match
        case 1:  m_brushColors[i] = 0xFFB0E0B0; break; // brush color for one misses
        case 2:  m_brushColors[i] = 0xFFE0B0B0; break; // brush color for two misses
        default: m_brushColors[i] = 0xFFFFFFFF; break; // brush color for three or more misses
      }
    }
    
    m_x = x;
    m_y = y;
    setBinDimensions(); // set m_w and m_h according to visualisation mode
  }
  
  
  void setBinDimensions() {
    int dh = m_node.m_hgDefaultMaxBinH;
    int dw = m_node.m_hgDefaultBinW;
    //int bhs = m_node.m_model.m_sStandardHistBinSampleHeight;
    
    switch (m_node.m_model.m_visualisationMode) {
      case FullAutoHeightAdjust: {
        m_h = (int)(0.01*(float)(dh * m_numSamples));  // TO DO.. sort out some proper scaling factor
        m_w = dw;
        // TO DO: need to potentially adjust m_node.m_hgH, plus adjust positions of other nodes
        break;
      }
      case Scaled: {
        int maxs = m_node.getMaxSamplesPerBin();
        m_h = (dh * m_numSamples) / maxs;
        m_w = dw;
        break;
      }
      case FullAreaConserved:
      default: {
        // TO DO...
        break;
      }
    }
  }
  
  
  void setY(int y) {
    m_y = y;
  }
  
  
  int getH() {
    return m_h;
  }
  
  
  int getW() {
    return m_w;
  }
  
  
  int getLX() {
    // return the x pos of the left hand side of the bin
    return m_x;
  }
  
  
  int getRX() {
    // return the x pos of the right hand side of the bin
    return m_x + m_w;
  }
  
   
  void draw() {
    pushStyle();
    switch (m_node.m_model.m_visualisationMode) {
    case FullAutoHeightAdjust: {
      drawFullAutoHeightAdjust();
      break;
    }
    case Scaled: {
      drawScaled();
      break;
    }
    case FullAreaConserved:
    default: {
      drawFullAreaConserved();
    }
    }
    popStyle();
  }
  
  
  void drawFullAutoHeightAdjust() {
    // draw the bin
    if (m_h > 0) {
      stroke(m_strokeColor);
      
      switch (m_node.m_model.m_interactionMode) {
        case SingleNodeBrushing: 
        case MultiNodeBrushing: {
          if (m_node.m_bHasFocus) {
            // this is the focal node for single-node brushing
            if (inSelectedRange()) {
              fill(m_focalInRangeSelFillColor);
            }
            else {
              fill(m_focalOutsideRangeSelFillColor);
            }
            rect(m_x, m_y-m_h, m_w, m_h);
          }
          else {
            // this is a non-focal node for single-node brushing
            drawBrushedBin((m_node.m_model.m_interactionMode == InteractionMode.SingleNodeBrushing) ? 1 : m_sNumBrushes);
          }
          break;
        }
        case Unassigned:
        default: {
          println("Unexpected case found in HistogramBin::drawFullAutoHeightAdjust!");
          exit();
        }
      }
    }
    
    // draw the base under each bin
    stroke(m_node.m_hgBaseColor);
    int baseY = m_y + (m_node.m_hgFootH / 2);
    line(m_x, baseY, m_x+m_w, baseY);
  }
  
  
  void drawBrushedBin(int numBrushes) {
    // helper method for drawing
    // draws the various sections of an individual bin according to the current brushing of the bin
    
    int cumH = 0; // cumulative count of height of brushes considered so far 
    int cumB = 0; // cumulative count of total number of brushed samples
    
    for (int b=0; b<numBrushes; b++) {
      float brushFrac = (float)m_numBrushedSamples[b] / (float)m_numSamples;
      int brushH = round(brushFrac*(float)m_h);
      cumB += m_numBrushedSamples[b];
      
      // add brush height to cumulative total, but check we don't overshoot or undershoot the
      // max total height of the bin because of rounding errors 
      if (cumH + brushH > m_h) {
        brushH = m_h - cumH;
        cumH = m_h;
      }
      else if (cumB == m_numSamples) {
        brushH = m_h - cumH;
        cumH = m_h;
      }
      else {
        cumH += brushH;
      }

      // draw brushed section
      if (brushH > 0) {
        fill(m_brushColors[b]);
        rect(m_x, m_y-cumH, m_w, brushH);
      }
    }

    // draw unbrushed section
    fill(m_nonFocalNonBrushedFillColor);
    rect(m_x, m_y-m_h, m_w, m_h-cumH);
  }
  
  
  void drawScaled() {
    // TO DO...
  }
  
  
  void drawFullAreaConserved() {
    // TO DO...
  }
  
  /*
  void equaliseCols() {
    // balance the height of each column in this histogram bin
    int nCols = m_tilesPerCol.size();
    if (nCols < 2) {
      return;
    }
    int lastColH = m_tilesPerCol.get(nCols-1);
    int d = m_sMaxTileStack - lastColH;
    if (d > 0) {
      int d1 = ceil((float)d / (float)nCols);
      for (int i=0; i<nCols-1; i++) {
        m_tilesPerCol.set(i, m_tilesPerCol.get(i)-d1);
      }
      m_tilesPerCol.set(nCols-1, m_tilesPerCol.get(nCols-1)+(d1*(nCols-1)));
    }
  }
  */
  
  boolean inSelectedRange() {
    // is this bin within the range currently selected by the Range Selector slider?
    return ((m_idx >= m_node.m_rsLow) && (m_idx <= m_node.m_rsHigh));
  }
  
  
  void brushSamples(ArrayList<Integer> samples) {
    // For single-node brushing
    // Calculate which of the samples passed in are members of this bin, and record that number
    // in m_numBrushedSamples[0]
    
    ArrayList<Integer> smallList;
    ArrayList<Integer> bigList;
    
    if (samples.size() > m_sampleIDs.size()) {
      smallList = m_sampleIDs;
      bigList = samples;
    }
    else {
      smallList = samples;
      bigList = m_sampleIDs;
    }
    
    int matches = 0;
    
    for (Integer sampleID : smallList) {
      if (bigList.contains(sampleID)) {
        matches++;
      }
    }
    
    m_numBrushedSamples[0] = matches;
    
    //float matchFrac = (float)matches / (float)m_sampleIDs.size();
    //int numTiles = ceil((((float)m_sampleIDs.size()) * matchFrac) / (float)m_sNumSamplesPerTile);
    //int nCols = m_tilesPerCol.size();
    //int nTilesPerCol = ceil((float)numTiles / (float)nCols);
    //println("matchFrac="+matchFrac+", numTiles="+numTiles+", nCols="+nCols+", nTilesPerCol="+nTilesPerCol);
    //brushTiles(0, numTiles);
  }
  
  
  /*
  void brushTiles(int numTiles) {
    int tilesLeft = numTiles;
    for (int i=0; i<m_brushedTilesPerCol.size(); i++) {
      int numBrushed = min(tilesLeft, m_tilesPerCol.get(i));
      m_brushedTilesPerCol.set(i, numBrushed);
      tilesLeft -= numBrushed;
    }    
  }
  */
  
  
  /*
  void brushTiles(int numMisses, int numTiles) {
    //
    // brush the specified number of tiles in this bin, distributed over the various columns
    // in the bin if necessary
    assert(numMisses >= 0);
    if (numMisses <= m_sMaxBrushNearMisses) {
      int tilesLeft = numTiles;
      for (int i=0; i<m_brushedTilesPerCol.get(numMisses).size(); i++) {
        int numBrushed = min(tilesLeft, m_tilesPerCol.get(i));
        m_brushedTilesPerCol.get(numMisses).set(i, numBrushed);
        tilesLeft -= numBrushed;
      }
    }
    //
  }
  */  
  
  
  int numSamples() {
    return m_sampleIDs.size();
  }
  
  
  /*
  int numTilesBrushed() {
    int n = 0;
    for (int i=0; i<m_brushedTilesPerCol.size(); i++) {
      n += m_brushedTilesPerCol.get(i);
    }     
    return n;
  }
  */


  int numTilesBrushed(int numMisses) {
    /*
    assert(numMisses >= 0);
    int n = 0;
    if (numMisses <= m_sMaxBrushNearMisses) {
      for (int i=0; i<m_brushedTilesPerCol.get(numMisses).size(); i++) {
        n += m_brushedTilesPerCol.get(numMisses).get(i);
      }
    }
    return n;
    */
    return 0;
  }  
  
  
  ///
  /*
  void brushSample(int sampleID) {
   
    resetBrushing();
    
    if (m_sampleIDs.contains(sampleID)) {
      
      m_brushedTilesPerCol.set(0,1);
    
      /*
      float matchFrac = 1.0;
      int numTiles = ceil((((float)m_sampleIDs.size()) * matchFrac) / (float)m_sNumSamplesPerTile);
      int nCols = m_tilesPerCol.size();
      int nTilesPerCol = ceil((float)numTiles / (float)nCols);
      //println("matchFrac="+matchFrac+", numTiles="+numTiles+", nCols="+nCols+", nTilesPerCol="+nTilesPerCol);
      
      int tilesLeft = numTiles;
      for (int i=0; i<m_brushedTilesPerCol.size(); i++) {
        int numBrushed = min(tilesLeft, m_tilesPerCol.get(i));
        m_brushedTilesPerCol.set(i, numBrushed);
        tilesLeft -= numBrushed;
      }
      * /
    
    }
  }
  */
  
  
  /*
  void brushSampleAdd(int sampleID) {
    if (m_sampleIDs.contains(sampleID)) {
      brushTiles(numTilesBrushed() + 1);
    }
  }
 */ 


  void brushSampleAdd(int sampleID, int numMisses) {
    // If the sample passed in is in this bin, increment the relevant count of brushed tiles
    assert((numMisses >= 0) && (numMisses < m_sNumBrushes));
    
    if (m_sampleIDs.contains(sampleID)) {
      //brushTiles(numMisses, numTilesBrushed(numMisses) + 1);
      m_numBrushedSamples[numMisses]++;
    }
  }   
  
  
  void resetBrushing() {
    /*
    for (int i=0; i<m_brushedTilesPerCol.size(); i++) {
      ///m_brushedTilesPerCol.set(i, 0);
      for (int j=0; j<m_brushedTilesPerCol.size(); j++) {
        m_brushedTilesPerCol.get(j).set(i,0);
      }
    }
    */   
    for (int i=0; i<m_sNumBrushes; i++) {
      m_numBrushedSamples[i] = 0;
    }
  }
  
  boolean sampleInBin(int sampleID) {
    return m_sampleIDs.contains(sampleID);
  }
  
}
