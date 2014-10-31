public abstract class Node {
  
  // identity
  int m_id;             // used to refer to this Node when we can't use a reference
  String m_name;        // human readable name of node
  
  // Widget appearance and position
  int m_sNodeW = 330;   // width of Node widget, same for all nodes 
  int m_sNodeH = 200;   // height of Node widget, same for all nodes
  int m_x;              // x position of top-left corner
  int m_y;              // y position of top-left corner
  int m_nodeZoom = 100;
    
  protected int m_mbH = 25;      // menu bar height
  protected int m_hgH;           // histogram height (DERIVED = m_sNodeH - m_mbH - m_rsH - m_lbH)
  protected int m_hgHeadH = 12;  // histogram header height (for drawing bin base lines): this is part of m_hgH
  protected int m_hgFootH = 7;   // histogram footer height (for drawing bin base lines): this is part of m_hgH
  protected int m_rsH = 25;      // range selector height
  protected int m_lbH = 25;      // label bar height
  
  color m_mbBackgroundColor;
  color m_hgBackgroundColor;
  color m_hgBaseColor;
  color m_rsBackgroundColor;
  color m_rsHandleColor;
  color m_rsMeanValColor;
  color m_rsHandlePressedColor;
  color m_rsSelectedRangeColor;
  color m_lbBackgroundColor;
  color m_lbForegroundColor;
  
  // Interaction
  boolean m_bNodeDragged;
  boolean m_bHasFocus;  
  boolean m_rsLeftHandlePressed;
  boolean m_rsRightHandlePressed;
  boolean m_rsBarPressed;
  int m_mousePressX;          // records x pos of where mouse was last pressed
  int m_mousePressY;          // records y pos of where mouse was last pressed
  int m_rsMousePressLLDeltaX; // records distance from m_mousePressX to left side of left handle when mouse last pressed
  int m_rsMousePressRRDeltaX; // records distance from m_mousePressX to right side of right handle when mouse last pressed
  
  // References to data associated with this Node
  Model m_model;      // reference to the associated Model
  int m_dataFileCol;  // data for this node is found in this column of the data file
                      // N.B. this is a 1-based index!
  int m_dataArrayCol; // data for this node is found in model.m_data.get(row).get(m_dataArrayCol)
                      // N.B. this is a 0-based index! (DERIVED = m_dataFileCol-1)
  
  // Histogram 
  int m_sMaxBins = 20;
  int m_hgNumBins;
  int[] m_hgBinSampleCounts;        // stores number of samples in each bin
  ArrayList<HistogramBin> m_hgBins;
  ArrayList<Number> m_hgBinMinVals; // stores the min limit of range stored in each bin
  int m_hgMinInterBinGap = 8;
  int m_hgMaxInterBinGap = 15;
  int m_hgDefaultMaxBinH;       // max allowed bin height (except for FullAutoHeightAdjust) (DERIVED = m_hgH-m_hgHeadH-m_hgFootH)
  int m_hgDefaultBinW = 8;      // standard bin width (for all but FullAreaConserved)
  int m_hgNumBrushes = 3;       // max number of different brushes/colors to use in the histogram bins
  int m_hgBaseStrokeWeight = 1; // width of base line below each bin
  
  // Range Selector
  int m_rsLow = 0;   // the (0-based) index in m_hgBins of the lowest selected histogram bin
  int m_rsHigh = 0;  // the (0-based) index in m_hgBins of the highest selected histogram bin
  
  // Links to connected Nodes
  ArrayList<Node> m_parents; // TO DO: these will have to be populated after ALL Nodes have been constructed
  ArrayList<Node> m_children;  
  ArrayList<Integer> m_parentIDs;
  
  // Abstract classes to be specialised in subclasses
  abstract int    getFullRange();
  abstract int    getSelectedRange();
  abstract void   initialiseHistogram();
  abstract int    getHistogramIndex(Number num);
  abstract Number getHistogramBinLowVal(int bin);
  abstract Number getHistogramBinHighVal(int bin);

  
  Node(Model model, int id, String name, int filecol, ArrayList<Integer> parentIDs) {
    m_model = model;
    m_id = id;
    m_name = name;
    m_dataFileCol = filecol;
    m_dataArrayCol = m_dataFileCol-1;
    m_parentIDs = parentIDs;
    m_hgNumBins = 10;
    m_hgBins = new ArrayList<HistogramBin>();
    m_hgH = m_sNodeH - m_mbH - m_rsH - m_lbH;
    m_hgDefaultMaxBinH = m_hgH - m_hgHeadH - m_hgFootH; 
    m_mbBackgroundColor    = #E0E0E0;
    m_hgBackgroundColor    = #FFFFFF;
    m_hgBaseColor          = #000000;
    m_rsBackgroundColor    = #999999;
    m_rsHandleColor        = #BBDDDD;
    m_rsMeanValColor       = #FFFFFF;
    m_rsHandlePressedColor = #DDFFFF;
    m_rsSelectedRangeColor = #99BBBB;
    m_lbBackgroundColor    = #E0E0E0;
    m_lbForegroundColor    = #101010;
    m_bHasFocus = false;
    m_bNodeDragged = false;
    m_rsLeftHandlePressed = false;
    m_rsRightHandlePressed = false;
    m_rsBarPressed = false;
    m_mousePressX = 0;
    m_mousePressY = 0;
    m_rsMousePressLLDeltaX = 0;
    m_rsMousePressRRDeltaX = 0;
    m_x = (int)random(0, width - m_sNodeW);
    m_y = (int)random(0, height - m_sNodeH);
  }
  
  
  int getH() {
    // returns the full height of the node
    return (m_mbH + m_hgH + m_rsH + m_lbH);
  }


  void setPosition(int x, int y) {
    m_x = x;
    m_y = y;
  }
  
  
  void setY(int y) {
    m_y = y;
  }

  
  void initialiseHistogramCommon() {
    
    // this is a common helper method called in the initialiseHistogram methods of
    // derived classes

    m_hgBinSampleCounts = new int[m_hgNumBins];
    m_hgBinMinVals = new ArrayList<Number>();
    
    ArrayList<ArrayList<Integer>> sampleIDs = new ArrayList<ArrayList<Integer>>();
    for (int i=0; i < m_hgNumBins; i++) {
      sampleIDs.add(new ArrayList<Integer>());
      m_hgBinMinVals.add(getHistogramBinLowVal(i));
    }
    
    int rowNum = 0;
    for (ArrayList<Number> row : m_model.m_data) {
      Number data = row.get(m_dataArrayCol); // from this data sample, get the column corresponding to this node
      int idx = getHistogramIndex(data);     // get the bin (index of m_hgBins) that this data value belongs to
      m_hgBinSampleCounts[idx]++;
      sampleIDs.get(idx).add(rowNum);
      rowNum++;
    }

    m_rsHigh = m_hgNumBins-1;
    
    int gap = (int)((float)(m_sNodeW - (m_hgNumBins * m_hgDefaultBinW)) / (float)(m_hgNumBins + 1)); 
    gap = constrain(gap, m_hgMinInterBinGap, m_hgMaxInterBinGap);
    //int binx = (m_sNodeW - (m_hgNumBins * m_sStandardHistBinWidth) - ((m_hgNumBins-1) * gap)) / 2;
    int binx = gap;
    int maxH = 0;
    
    //println("Node: "+m_name);
    for (int i=0; i<m_hgNumBins; i++) {
      HistogramBin bin = new HistogramBin(this, m_hgBins.size(), m_hgBinSampleCounts[i], sampleIDs.get(i), binx, m_hgH - m_hgFootH);
      //println(" bin "+i+", x="+binx+", gap="+gap+", m_w="+bin.m_w);
      m_hgBins.add(bin);
      maxH = max(maxH, bin.getH());
      binx += bin.m_w + gap;
    }
    
    // reset width of node according to space taken up by the bins
    m_sNodeW = binx;
    
    // if the max bin height is greater than the height allowed by the node, heighten node to fit
    int newH = m_mbH + m_rsH + m_lbH + m_hgHeadH + maxH + m_hgFootH;
    if (newH > m_sNodeH) {
      m_sNodeH = newH;
      m_hgH = m_sNodeH - m_mbH - m_rsH - m_lbH;
      for (HistogramBin bin : m_hgBins) {
        bin.setY(m_hgH - m_hgFootH);
      }      
    }
  }
  
  
  int getMaxSamplesPerBin() {
    int max = 0;
    for (HistogramBin bin : m_hgBins) {
      if (bin.m_numSamples > max) {
        max = bin.m_numSamples;
      }
    }  
    return max;
  }


  void draw(int nodeZoom) {
    
    m_nodeZoom = nodeZoom;
    
    pushMatrix();

    scale(((float)m_model.m_globalZoom)/100.0);
    
    translate(m_x, m_y);
    
    drawMenuBar();
    drawHistogram();
    drawRangeSelector();
    drawLabelBar();
         
    popMatrix();
    
  }

  
  void drawMenuBar() {
    pushMatrix();    
    fill(m_mbBackgroundColor);
    rect(0, 0, m_sNodeW, m_mbH);
    popMatrix();
  }

  
  void drawHistogram() {
    pushMatrix();
    translate(0, m_mbH);
    fill(m_hgBackgroundColor);
    rect(0, 0, m_sNodeW, m_hgH);
    
    if (m_hgBins != null) {
      for (HistogramBin bin : m_hgBins) {
        bin.draw();
      }
    }
    
    // draw labels for min and max selected values
    String lowVal = getLowValueString();
    String highVal = getHighValueString();
    int lowX = m_hgBins.get(m_rsLow).getLX();
    int highX = m_hgBins.get(m_rsHigh).getRX();
    int textY = (int)((float)m_hgHeadH * 0.8);
    textFont(m_model.m_smallFont, 11);
    fill(m_lbForegroundColor);
    textAlign(LEFT);
    text(lowVal, lowX, textY);
    if (m_rsLow != m_rsHigh) {
      textAlign(RIGHT);
      text(highVal, highX, textY);
    }    
    
    popMatrix();
  }

  
  void drawRangeSelector() {
    pushMatrix();
    translate(0, m_mbH+m_hgH);
    fill(m_rsBackgroundColor);
    rect(0, 0, m_sNodeW, m_rsH);

    if (m_hgBins != null) {
      int llx = m_hgBins.get(m_rsLow).getLX();
      int lrx = m_hgBins.get(m_rsLow).getRX();
      int hlx = m_hgBins.get(m_rsHigh).getLX();
      int hrx = m_hgBins.get(m_rsHigh).getRX();
      // draw range bar
      fill(m_rsSelectedRangeColor);
      rect(lrx, 0, hlx-lrx, m_rsH);
      // draw left handle
      fill(m_rsLeftHandlePressed ? m_rsHandlePressedColor : m_rsHandleColor);
      rect(llx, 0, lrx-llx, m_rsH);
      // draw right handle
      fill(m_rsRightHandlePressed ? m_rsHandlePressedColor : m_rsHandleColor);
      rect(hlx, 0, hrx-hlx, m_rsH);
      
      // draw the mean value of the selected range
      if (m_rsLow != m_rsHigh) {
        float meanv = getMeanSelectedValue(!m_bHasFocus); // mean value of samples that lie in the currently selected range
        float lowv  = getHistogramBinLowVal(m_rsLow).floatValue();   // low boundary of lowest bin in selected range
        float highv = getHistogramBinHighVal(m_rsHigh).floatValue(); // high boundary of highest bin in selected range
        int lmx = (llx+lrx)/2;
        int hmx = (hlx+hrx)/2;
        int meanx = lmx + (int)(((meanv-lowv)*(float)(hmx-lmx))/(highv-lowv));
        int circ = (int)(0.5 * (float)m_rsH);
        fill(m_rsMeanValColor);
        ellipse(meanx, m_rsH/2, circ, circ);
      }
      
    }
    
    
    
    popMatrix();
  }
  
  
  void drawLabelBar() {
    pushMatrix();
    translate(0, m_mbH+m_hgH+m_rsH);
    fill(m_lbBackgroundColor);
    rect(0, 0, m_sNodeW, m_lbH);    
    textFont(m_model.m_mediumFont, 16);
    fill(m_lbForegroundColor);
    textAlign(CENTER);
    text(m_name, m_sNodeW/2, m_lbH-8);
    popMatrix();
  }
  
  
  void setFullRange() {
    m_rsLow = 0;
    m_rsHigh = m_hgNumBins-1;
  }
  
  
  void mousePressed() {
    
    m_mousePressX = scaledMouseX();
    m_mousePressY = scaledMouseY();
    
    if (scaledMouseX() >= m_x && scaledMouseX() < m_x + m_sNodeW && scaledMouseY() >= m_y && scaledMouseY() <= m_y + m_sNodeH) {
      // the mouse has been pressed within this node, so figure out what we need to do about it!
      
      if (scaledMouseY() < m_y + m_mbH) {
        ///////////// MOUSE IS IN THE MENU BAR AREA ///////////////////////////////////////////////
        m_bNodeDragged = true;        
      }
      else if (scaledMouseY() >= m_y + m_mbH && scaledMouseY() < m_y + m_mbH + m_hgH) {
        ///////////// MOUSE IS IN THE HISTOGRAM AREA ///////////////////////////////////////////////
        
        switch (m_model.m_interactionMode) {
          case SingleNodeBrushing:
            m_model.setSingleFocus(m_id);
            m_model.brushAllNodesOnOneSelection(this);          
            break;
          case MultiNodeBrushing:
            m_model.toggleMultiFocus(m_id);
            m_model.brushAllNodesOnMultiSelection();          
            break;
          default:
            println("Unexpected interaction mode in Node.mousePressed()!");
        }
      }
      else if (scaledMouseY() >= m_y + m_mbH + m_hgH && scaledMouseY() <= m_y + m_mbH + m_hgH + m_rsH) {
        ///////////// MOUSE IS IN THE RANGE SELECTOR AREA //////////////////////////////////////////
        
        if (rangeSelectorActive()) {
          int llx = m_hgBins.get(m_rsLow).getLX();
          int lrx = m_hgBins.get(m_rsLow).getRX();
          int hlx = m_hgBins.get(m_rsHigh).getLX();
          int hrx = m_hgBins.get(m_rsHigh).getRX();
          
          if (m_rsLow == m_rsHigh) {
            // first deal with special case where both range selectors are in the same position
            if (scaledMouseX() >= m_x + llx && scaledMouseX() <= m_x + lrx) {
              if (scaledMouseY() <= (m_y + m_mbH + m_hgH + (m_rsH/2))) {
                // is top half of handle pressed, call it a right handle press
                m_rsRightHandlePressed = true;
              }
              else {
                // else if bottom half pressed, call it a left handle press
                m_rsLeftHandlePressed = true;
              }
            }
          }
          else {
            if (scaledMouseX() >= m_x + llx && scaledMouseX() <= m_x + lrx) {
              // left handle pressed
              m_rsLeftHandlePressed = true;
            }
            else if (scaledMouseX() >= m_x + hlx && scaledMouseX() <= m_x + hrx) {
              // right handle pressed
              m_rsRightHandlePressed = true;
            }
            else if (scaledMouseX() > m_x + lrx && scaledMouseX() < m_x + hlx) {
              // bin between the handles pressed
              m_rsBarPressed = true;
              m_rsMousePressLLDeltaX = m_mousePressX - (m_x + llx);
              m_rsMousePressRRDeltaX = (m_x + hrx) - m_mousePressX;
            }
          }
        }
        
      }
      else if (scaledMouseY() >= m_y + m_mbH + m_hgH + m_rsH) {
        ///////////// MOUSE IS IN THE LABEL BAR AREA ///////////////////////////////////////////////
        m_bNodeDragged = true;
      }
    }
  }


  void mouseReleased() {
    m_bNodeDragged = false;
    m_rsLeftHandlePressed = false;
    m_rsRightHandlePressed = false;
    m_rsBarPressed = false;
  }

  
  void mouseDragged() {
    
    int rsLowOld = m_rsLow;
    int rsHighOld = m_rsHigh;
    
    if (m_bNodeDragged) {
      ///////////// WHOLE NODE DRAGGED /////////////////////////////////////////////////
      m_x += (scaledMouseX() - scaledPMouseX());
      m_y += (scaledMouseY() - scaledPMouseY());
      constrain(m_x, 0, width - m_sNodeW);
      constrain(m_y, 0, height - m_sNodeH);      
    }
    else if (m_rsLeftHandlePressed) {
      ///////////// RANGE SELECTOR LEFT HANDLE DRAGGED /////////////////////////////////
      int llx = m_hgBins.get(m_rsLow).getLX();
      int rrx = m_hgBins.get(m_rsLow).getRX();    
      if (scaledMouseX() < m_x) {
        m_rsLow = 0;
      }
      else if ((scaledMouseX() < m_x + llx) && (m_rsLow > 0)) {
        for (int i = m_rsLow-1; i >= 0; i--) {
          if (scaledMouseX() < m_x + m_hgBins.get(i).getRX()) {
            m_rsLow = i;
          }
          else {
            break;
          }
        } 
      }
      else if ((scaledMouseX() > m_x + rrx) && (m_rsLow < m_rsHigh)) {
        for (int i = m_rsLow+1; i <= m_rsHigh; i++) {
          if (scaledMouseX() > m_x + m_hgBins.get(i).getLX()) {
            m_rsLow = i;
          }
          else {
            break;
          }
        } 
      }      
    }
    else if (m_rsRightHandlePressed) {
      ///////////// RANGE SELECTOR RIGHT HANDLE DRAGGED ////////////////////////////////
      int llx = m_hgBins.get(m_rsHigh).getLX();
      int rrx = m_hgBins.get(m_rsHigh).getRX();    
      if (scaledMouseX() < m_x) {
        m_rsHigh = m_rsLow;
      }
      else if ((scaledMouseX() < m_x + llx) && (m_rsHigh > m_rsLow)) {
        for (int i = m_rsHigh-1; i >= m_rsLow; i--) {
          if (scaledMouseX() < m_x + m_hgBins.get(i).getRX()) {
            m_rsHigh = i;
          }
          else {
            break;
          }
        } 
      }
      else if ((scaledMouseX() > m_x + rrx) && (m_rsHigh < m_hgNumBins-1)) {
        for (int i = m_rsHigh+1; i <= m_hgNumBins-1; i++) {
          if (scaledMouseX() > m_x + m_hgBins.get(i).getLX()) {
            m_rsHigh = i;
          }
          else {
            break;
          }
        } 
      }
    }
    else if (m_rsBarPressed) {
      ///////////// RANGE SELECTOR BAR BETWEEN HANDLES DRAGGED /////////////////////////
      int llx = m_hgBins.get(m_rsLow).getLX();
      int rrx = m_hgBins.get(m_rsLow).getRX(); 
      if (scaledMouseX() < m_x) {
        // moving to extreme left
        m_rsHigh -= m_rsLow;
        m_rsLow = 0;
      }
      else if ((scaledMouseX() < scaledPMouseX()) && (m_rsLow > 0)) {
        // moving left
        for (int i = m_rsLow; i >= 0; i--) {
          if ((scaledMouseX() - m_rsMousePressLLDeltaX) < (m_x + m_hgBins.get(i).getRX())) {
            m_rsHigh -= (m_rsLow-i);
            m_rsLow = i;
          }
          else {
            break;
          }
        } 
      }
      else if ((scaledMouseX() > scaledPMouseX()) && (m_rsHigh < m_hgNumBins-1)) {
        // moving right
        for (int i = m_rsHigh+1; i <= m_hgNumBins-1; i++) {
          if (scaledMouseX() + m_rsMousePressRRDeltaX > m_x + m_hgBins.get(i).getLX()) {
            m_rsLow += (i-m_rsHigh);
            m_rsHigh = i;
          }
          else {
            break;
          }
        }         
      }
    }
    
    if (m_rsLow != rsLowOld || m_rsHigh != rsHighOld) {
      switch(m_model.m_interactionMode) {
        case SingleNodeBrushing:
          m_model.brushAllNodesOnOneSelection(this);
          break;
        case MultiNodeBrushing:
          m_model.brushAllNodesOnMultiSelection();
          break;
        default:
          println("I shouldn't be here!!");
      }
    }
  }
  
  
  ArrayList<Integer> getSelectedSampleIDs() {
    ArrayList<Integer> list = new ArrayList<Integer>();
    for (int i=m_rsLow; i<=m_rsHigh; i++) {
      list.addAll(m_hgBins.get(i).m_sampleIDs);
    }
    return list;
  }
  
  
  void brushSamples(ArrayList<Integer> samples) {
    // cycle over all bins, brushing the appropriate number in each bin according to how many
    // samples in that bin are in the specified list of samples
    for (HistogramBin bin : m_hgBins) {
      bin.brushSamples(samples);
    }
  }


  void brushSampleAdd(int sampleID, int numMisses) {
    // cycle over all bins, looking for the one that contains the specified sample. When the
    // matching bin is found, add the sample to that bin's list of brushed samples according
    // to the specied numMisses
    
    for (HistogramBin bin : m_hgBins) {
      if (bin.brushSampleAdd(sampleID, numMisses)) {
        break;
      }
    }
  } 
  
  
  boolean sampleSelected(int sampleID) {
    // Returns true if the specified sample is in one of the currently selected range of bins
    boolean selected = false;
    for (int i=m_rsLow; ((i<=m_rsHigh) && (!selected)); i++) {
      selected = m_hgBins.get(i).sampleInBin(sampleID);
    }    
    return selected;
  }
  
  
  void resetBrushing() {
    for (HistogramBin bin : m_hgBins) {
      bin.resetBrushing();
    }
  }
  
  
  boolean rangeSelectorActive() {
    switch (m_model.m_interactionMode) {
      case MultiNodeBrushing:
        return m_bHasFocus;
      case SingleNodeBrushing:
        return m_bHasFocus;
      default:
        return true;
    }
  }
  
  
  String getLowValueString() {
    // Fetch the low bound of the lowest bin in the currently selected range
    // and return it as a string.
    // This copes with the fact that Node instances are either DiscreteNode or ContinuousNode
    // objects and the values will be ints or floats respectively. If the value is a float,
    // the string representation is limited to one decimal place.
    
    String val = new String(getHistogramBinLowVal(m_rsLow).toString());
    int dp = val.indexOf('.');
    if (dp >= 0) {
      val = val.substring(0, dp+2);
    }
    return val;
  }
  
  
  String getHighValueString() {
    // Fetch the high bound of the highest bin in the currently selected range
    // and return it as a string.
    // This copes with the fact that Node instances are either DiscreteNode or ContinuousNode
    // objects and the values will be ints or floats respectively. If the value is a float,
    // the string representation is limited to one decimal place.
    
    String val = new String(getHistogramBinHighVal(m_rsHigh).toString());
    int dp = val.indexOf('.');
    if (dp >= 0) {
      val = val.substring(0, dp+2);
    }
    return val;
  } 
  
  
  float getMeanSelectedValue() {
    // Calculate the mean value of samples in selected bins
    return getMeanSelectedValue(false);
  }
  
    
  float getMeanSelectedValue(boolean brushedOnly) {
    // Calculate the mean value of samples in selected bins.
    // If brushedOnly==true, only count brushed samples (with numMiss==0), otherwise count all samples.
    
    float total = 0;
    int numSamples = 0;
    for (int b = m_rsLow; b <= m_rsHigh; b++) {
      total += m_hgBins.get(b).getTotalValues(brushedOnly);
      numSamples += m_hgBins.get(b).numSamples();
    }
    return total / (float)numSamples;
  }  
  
  
  int scaledMouseX() {
    return (int)((float)(mouseX * 100.0) / m_model.m_globalZoom);
  }
  
  int scaledMouseY() {
    return (int)((float)(mouseY * 100.0) / m_model.m_globalZoom);
  }

  int scaledPMouseX() {
    return (int)((float)(pmouseX * 100.0) / m_model.m_globalZoom);
  }
  
  int scaledPMouseY() {
    return (int)((float)(pmouseY * 100.0) / m_model.m_globalZoom);
  }

  
}
