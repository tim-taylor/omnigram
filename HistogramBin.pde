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
  
  ArrayList<Integer> m_tilesPerCol;         // records number of tiles in each column
  ArrayList<Integer> m_brushedTilesPerCol;
  int m_x; // x pos of bottom-left corner of bin, relative to left edge of histogram window
  int m_y; // y pos of bottom-left corner of bin, relative to top edge of histogram window
  
  HistogramBin(Node node, int idx, int numSamples, ArrayList<Integer> sampleIDs, int x, int y) {
    m_node = node;
    m_idx = idx;
    m_sampleIDs = sampleIDs;
    m_tilesPerCol = new ArrayList<Integer>();
    m_brushedTilesPerCol = new ArrayList<Integer>();
    m_x = x;
    m_y = y;
    int numTiles = ceil((float)numSamples / (float)m_sNumSamplesPerTile);
    while (numTiles > 0) {
      int colSize = min(numTiles, m_sMaxTileStack);
      m_tilesPerCol.add(colSize);
      m_brushedTilesPerCol.add(0);
      numTiles -= colSize;
    }    
    equaliseCols();
  }
  
  
  int numCols() {
    return m_tilesPerCol.size();
  }
  
  
  int getLColLX() {
    // return the x pos of the left hand side of the leftmost column
    return m_x;
  }
  
  
  int getRColLX() {
    // return the x pos of the left hand side of the rightmost column
    if (m_tilesPerCol.isEmpty()) {
      return m_x;
    }
    else {
      return m_x + (m_tilesPerCol.size()-1)*m_sTileDim;
    }
  }
  
  
  int getRColRX() {
    // return the x pos of the right hand side of the rightmost column
    if (m_tilesPerCol.isEmpty()) {
      return m_x;
    }
    else {
      return m_x + (m_tilesPerCol.size())*m_sTileDim;
    }
  }  
  
  
  void draw() {
    stroke(m_tileStrokeColor);

    

    int x = m_x;
    int c = 0;
    for (Integer numTiles : m_tilesPerCol) {
      int y = m_y;
      for (int i=0; i<numTiles; i++) {
        //println(numTiles+", "+i+", "+x+" "+y+", "+m_sTileDim);
        if (i < m_brushedTilesPerCol.get(c)) {
          fill(0xFF2222DD);
        }
        else if (inSelectedRange()) {
          fill(m_tileInRangeSelection);
        }
        else {
          fill(m_tileOutsideRangeSelection);
        }
        rect(x, y-m_sTileDim, m_sTileDim, m_sTileDim);
        y -= m_sTileDim;
      }
      x += m_sTileDim;
      c++;
    }
  }
  
  
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
  
  
  boolean inSelectedRange() {
    // is this bin within the range currently selected by the Range Selector slider?
    return ((m_idx >= m_node.m_rsLow) && (m_idx <= m_node.m_rsHigh));
  }
  
  
  void brushSamples(ArrayList<Integer> samples) {
    // highlight a fraction of the tiles in this bin according to how many
    // of this bin's samples are in the selected set passed into this method
    
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
    
    float matchFrac = (float)matches / (float)m_sampleIDs.size();
    int numTiles = ceil((((float)m_sampleIDs.size()) * matchFrac) / (float)m_sNumSamplesPerTile);
    int nCols = m_tilesPerCol.size();
    int nTilesPerCol = ceil((float)numTiles / (float)nCols);
    int tilesLeft = numTiles;
    
    for (int i=0; i<m_brushedTilesPerCol.size(); i++) {
      m_brushedTilesPerCol.set(i, min(nTilesPerCol, tilesLeft));
      tilesLeft -= nTilesPerCol;
    }
   
  }
  
}
