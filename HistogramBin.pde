class HistogramBin {
  
  // relationship to owning Node object
  Node m_node; // reference to associated node
  int m_idx;   // 0-based index to this bin, as used in m_node.m_hgBins
  
  // info on the sampleIDs held in this bin
  ArrayList<Integer> m_sampleIDs;        // IDs (zero-based array indices in m_node.m_model.m_data) of data samples in this bin
  ArrayList<Integer> m_brushedSampleIDs; // IDs of currently brushed (numMisses==0) samples in this bin
  int m_numSamples;                      // a convenience variable (DERIVED = m_sampleIDs.length())
  
  // color definitions
  color m_strokeColor = 0xFF000000;
  color m_focalInRangeSelFillColor = 0xFF880000;
  color m_focalOutsideRangeSelFillColor = 0xFFFFFFFF;
  color m_nonFocalNonBrushedFillColor = 0xFFFFFFFF;
  color[] m_brushColors;
  
  int[] m_numBrushedSamples; // records number of brush samples in bin, where index is number of 
                             // near misses. So idx 0 is samples that exactly match selected range
                             // idx 1 is samples with one near miss, etc.

  int m_x; // x pos of bottom-left corner of bin, relative to left edge of histogram window
  int m_y; // y pos of bottom-left corner of bin, relative to top edge of histogram window
  int m_w; // width of bin
  int m_h; // height of bin
  
  HistogramBin(Node node, int idx, int numSamples, ArrayList<Integer> sampleIDs, int x, int y) {
    m_node = node;
    m_idx = idx;
    m_sampleIDs = sampleIDs;
    m_numSamples = sampleIDs.size();
    m_brushedSampleIDs = new ArrayList<Integer>();
    m_brushColors = new color[node.m_hgNumBrushes];
    m_numBrushedSamples = new int[node.m_hgNumBrushes];

    for (int i=0; i<node.m_hgNumBrushes; i++) {
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
    int numSamplesAll = m_node.m_model.m_data.size();
    float nodeSF = m_node.m_model.m_nodeBinScaleFactor;
    
    switch (m_node.m_model.m_visualisationMode) {
      case FullAutoHeightAdjust: {
        //m_h = (int)(0.004*(float)(dh * m_numSamples));  // TO DO.. sort out some proper scaling factor
        m_h = (int)((nodeSF * (float)(dh * m_numSamples))/((float)numSamplesAll));
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
  
  
  void scaleH(float sf) {
    m_h = (int)(((float)m_h) * sf);
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
            drawBrushedBin((m_node.m_model.m_interactionMode == InteractionMode.SingleNodeBrushing) ? 1 : m_node.m_hgNumBrushes);
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
    strokeWeight(m_node.m_hgBaseStrokeWeight);
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

  
  boolean inSelectedRange() {
    // is this bin within the range currently selected by the Range Selector slider?
    return ((m_idx >= m_node.m_rsLow) && (m_idx <= m_node.m_rsHigh));
  }
  
  
  int numSamples() {
    return m_numSamples;
    //return m_sampleIDs.size();
  }  
  
  
  int numBrushed() {
    // return the number of brushed samples (with no misses)
    assert(m_numBrushedSamples[0] == m_brushedSampleIDs.size());
    return m_numBrushedSamples[0];
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
    m_brushedSampleIDs.clear();
    
    for (Integer sampleID : smallList) {
      if (bigList.contains(sampleID)) {
        matches++;
        assert(!m_brushedSampleIDs.contains(sampleID));
        m_brushedSampleIDs.add(sampleID);
      }
    }
    
    m_numBrushedSamples[0] = matches;
  }
  

  boolean brushSampleAdd(int sampleID, int numMisses) {
    // If the sample passed in is in this bin, increment the relevant count of brushed tiles
    // and return true, otherwise return false
    
    assert((numMisses >= 0) && (numMisses < m_node.m_hgNumBrushes));
    
    if (m_sampleIDs.contains(sampleID)) {
      m_numBrushedSamples[numMisses]++;
      if (numMisses == 0) {
        m_brushedSampleIDs.add(sampleID);
      }
      return true;
    }
    else {
      return false;
    }
  }
  
  
  void resetBrushing() { 
    for (int i=0; i<m_node.m_hgNumBrushes; i++) {
      m_numBrushedSamples[i] = 0;
    }
    m_brushedSampleIDs.clear();
  }
  

  boolean sampleBrushed(int sampleID) {
    // returns true if the specified sample is brushed (numMisses==0) in this bin   
    return m_brushedSampleIDs.contains(sampleID);    
  }  
  
  
  boolean sampleInBin(int sampleID) {
    return m_sampleIDs.contains(sampleID);
  }
  
  
  float getTotalValues() {
    // Return the sum of values of samples in this bin.
    return getTotalValues(false);
  }
  
  
  float getTotalValues(boolean brushedOnly) {
    // Return the sum of values of samples in this bin.
    // If brushedOnly==true, only count brushed samples (with numMiss==0), otherwise count all samples.
  
    ArrayList<ArrayList<Number>> dataArray = m_node.m_model.m_data;
    int col = m_node.m_dataArrayCol;
    float total = 0.0;
    
    if (brushedOnly) {
      for (Integer id : m_sampleIDs) {
        if (sampleBrushed(id)) {
          total += dataArray.get(id).get(col).floatValue();
        }
      }
    }
    else {
      for (Integer id : m_sampleIDs) {
        total += dataArray.get(id).get(col).floatValue();
      }
    }
    
    return total;
  }
  
}
