class HistogramBin {
  
  int m_sTileDim = 8;
  int m_sMaxTileStack = 15;
  int m_sNumSamplesPerTile = 5;
  
  Node m_node; // reference to associated node
  int m_idx;   // 0-based index to this bin, as used in m_node.m_hgBins
  
  ArrayList<Integer> m_sampleIDs; // IDs (zero-based array indices in m_node.m_model.m_data) of data samples in this bin
  
  color m_tileInRangeSelection = 0xFF880000;
  color m_tileOutsideRangeSelection = 0xFFFFFFFF;
  color m_tileStrokeColor = 0xFF909090;
  
  ArrayList<Integer> m_cols; // records number of tiles in each column
  int m_x; // x pos of bottom-left corner of bin, relative to left edge of histogram window
  int m_y; // y pos of bottom-left corner of bin, relative to top edge of histogram window
  
  HistogramBin(Node node, int idx, int numSamples, ArrayList<Integer> sampleIDs, int x, int y) {
    m_node = node;
    m_idx = idx;
    m_sampleIDs = sampleIDs;
    m_cols = new ArrayList<Integer>();
    m_x = x;
    m_y = y;
    int numTiles = ceil((float)numSamples / (float)m_sNumSamplesPerTile);
    while (numTiles > 0) {
      int colSize = min(numTiles, m_sMaxTileStack);
      m_cols.add(colSize);
      numTiles -= colSize;
    }    
    equaliseCols();
  }
  
  
  int numCols() {
    return m_cols.size();
  }
  
  
  int getLColLX() {
    // return the x pos of the left hand side of the leftmost column
    return m_x;
  }
  
  
  int getRColLX() {
    // return the x pos of the left hand side of the rightmost column
    if (m_cols.isEmpty()) {
      return m_x;
    }
    else {
      return m_x + (m_cols.size()-1)*m_sTileDim;
    }
  }
  
  
  int getRColRX() {
    // return the x pos of the right hand side of the rightmost column
    if (m_cols.isEmpty()) {
      return m_x;
    }
    else {
      return m_x + (m_cols.size())*m_sTileDim;
    }
  }  
  
  
  void draw() {
    stroke(m_tileStrokeColor);

    if (inSelectedRange()) {
      fill(m_tileInRangeSelection);
    }
    else {
      fill(m_tileOutsideRangeSelection);
    }

    int x = m_x;
    for (Integer numTiles : m_cols) {
      int y = m_y;
      for (int i=0; i<numTiles; i++) {
        //println(numTiles+", "+i+", "+x+" "+y+", "+m_sTileDim);
        rect(x, y-m_sTileDim, m_sTileDim, m_sTileDim);
        y -= m_sTileDim;
      }
      x += m_sTileDim;
    }
  }
  
  
  void equaliseCols() {
    // balance the height of each column in this histogram bin
    int nCols = m_cols.size();
    if (nCols < 2) {
      return;
    }
    int lastColH = m_cols.get(nCols-1);
    int d = m_sMaxTileStack - lastColH;
    if (d > 0) {
      int d1 = ceil((float)d / (float)nCols);
      for (int i=0; i<nCols-1; i++) {
        m_cols.set(i, m_cols.get(i)-d1);
      }
      m_cols.set(nCols-1, m_cols.get(nCols-1)+(d1*(nCols-1)));
    }
  }
  
  
  boolean inSelectedRange() {
    // is this bin within the range currently selected by the Range Selector slider?
    return ((m_idx >= m_node.m_rsLow) && (m_idx <= m_node.m_rsHigh));
  }
  
}
