public abstract class Node {
  
  // identity
  int m_id;             // used to refer to this Node when we can't use a reference
  String m_name;        // human readable name of node
  
  // Widget appearance and position
  int m_nodeW;          // width of Node widget
  int m_nodeH;          // height of Node widget
  int m_referenceH;     // reference height of Node, used when rescaling
  int m_x;              // x position of top-left corner
  int m_y;              // y position of top-left corner
  int m_nodeZoom = 100;
    
  protected int m_mbH = 25;       // menu bar height
  protected int m_mbWidgetW = 25; // width of a widget in the menu bar
  protected int m_hgH;            // histogram height (DERIVED = m_nodeH - m_mbH - m_rsH - m_lbH)
  protected int m_hgHeadH = 12;   // histogram header height (for drawing bin base lines): this is part of m_hgH
  protected int m_hgFootH = 7;    // histogram footer height (for drawing bin base lines): this is part of m_hgH
  protected int m_rsH = 25;       // range selector height
  protected int m_lbH = 25;       // label bar height
  
  color m_mbBackgroundColor;
  color m_mbFocusColor;
  color m_mbRootColor;
  color m_mbInterColor;
  color m_mbLeafColor;
  color m_mbMinWidgetBackgroundColor;
  color m_mbMinWidgetForegroundColor;
  color m_hgBackgroundColor;
  color m_hgBaseColor;
  color m_rsBackgroundColor;
  color m_rsHandleColor;
  color m_rsFocalMeanValColor;
  color m_rsNonFocalMeanValColor;
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
  boolean m_lbNodeResizeHandlePressed;
  int m_mousePressX;          // records x pos of where mouse was last pressed
  int m_mousePressY;          // records y pos of where mouse was last pressed
  int m_rsMousePressLLDeltaX; // records distance from m_mousePressX to left side of left handle when mouse last pressed
  int m_rsMousePressRRDeltaX; // records distance from m_mousePressX to right side of right handle when mouse last pressed
  int m_lbNodeResizeDeltaX;   // records distance from from mouse press to left edge of node when mouse pressed to resize node
  int m_lbNodeResizeDeltaY;   // records distance from from mouse press to bottom edge of node when mouse pressed to resize node
  
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
  
  // Links to causally connected Nodes
  ArrayList<Integer> m_parentIDs; // list of IDs (Node.m_id) of this node's causal parents 
  int m_role;                     // specifies whether this node is a Root (0), Intermediate (1) or Leaf node (2)
  
  // Information about BrushLinks associated with this node
  boolean m_brushLinkUnderConstruction; // flag to indicate if user is in process of constructing a new brush link on this node
  
  // Abstract classes to be specialised in subclasses
  abstract int    getFullRange();
  abstract int    getSelectedRange();
  abstract void   initialiseHistogram();
  abstract int    getHistogramIndex(Number num);
  abstract Number getHistogramBinLowVal(int bin);
  abstract Number getHistogramBinHighVal(int bin);

  
  Node(Model model, int id, String name, int filecol, int datacol, int role, ArrayList<Integer> parentIDs) {
    m_model = model;
    m_id = id;
    m_name = name;
    m_dataFileCol = filecol;
    m_dataArrayCol = datacol;
    m_role = constrain(role, 0, 2);
    m_parentIDs = parentIDs;
    m_nodeW = getDefaultW();
    m_nodeH = getDefaultH();
    m_referenceH = m_nodeH;
    m_hgNumBins = 10;
    m_hgBins = new ArrayList<HistogramBin>();
    m_hgH = m_nodeH - m_mbH - m_rsH - m_lbH;
    m_hgDefaultMaxBinH = m_hgH - m_hgHeadH - m_hgFootH; 
    m_mbBackgroundColor      = #E0E0E0;
    m_mbFocusColor           = #EE2222;
    colorMode(HSB, 360, 100, 100);
    m_mbRootColor            = color(120, 35, 80);
    m_mbInterColor           = color(170, 35, 80);
    m_mbLeafColor            = color(220, 35, 80);
    colorMode(RGB);
    m_mbMinWidgetBackgroundColor = #CCCCCC;
    m_mbMinWidgetForegroundColor = #101010;   
    m_hgBackgroundColor      = #FFFFFF;
    m_hgBaseColor            = #000000;
    m_rsBackgroundColor      = #999999;
    m_rsHandleColor          = #BBDDDD;
    m_rsFocalMeanValColor    = #880000;
    m_rsNonFocalMeanValColor = #000088;
    m_rsHandlePressedColor   = #DDFFFF;
    m_rsSelectedRangeColor   = #99BBBB;
    m_lbBackgroundColor      = #E0E0E0;
    m_lbForegroundColor      = #101010;
    m_bHasFocus = false;
    m_bNodeDragged = false;
    m_rsLeftHandlePressed = false;
    m_rsRightHandlePressed = false;
    m_rsBarPressed = false;
    m_lbNodeResizeHandlePressed = false;
    m_mousePressX = 0;
    m_mousePressY = 0;
    m_rsMousePressLLDeltaX = 0;
    m_rsMousePressRRDeltaX = 0;
    m_lbNodeResizeDeltaX = 0;
    m_lbNodeResizeDeltaY = 0;
    m_x = (int)random(0, width - m_nodeW);
    m_y = (int)random(0, height - m_nodeH);
    m_brushLinkUnderConstruction = false;
  }
  
  
  int getDefaultW() {
    return m_model.m_nodeDefaultWidth;
  }
  
  
  int getDefaultH() {
    return m_model.m_nodeDefaultHeight;
  }
  
  
  void setH(int h, boolean resizeBins, boolean resetReferenceH) {
    // Set the height of the node, and also resize the histogram bins if requested.
    // A node has a concept of a reference height, which is used for calculating scale factors when
    // resizing histogram bins. This solves the problem of accumulating rounding errors in bin heights
    // after multiple resizes, which might otherwise occur.
     
    int nonHistH = m_mbH + m_rsH + m_lbH + m_hgHeadH + m_hgFootH; // combined height of everything except main histogram area
    int oldHistH = m_referenceH - nonHistH;
    int newHistH = h - nonHistH;
    float histSF = (float)newHistH / (float)oldHistH;
    
    m_nodeH = h;
    m_hgH = m_nodeH - m_mbH - m_rsH - m_lbH;
    
    if (resetReferenceH) {
      m_referenceH = h;
    }
    
    for (HistogramBin bin : m_hgBins) {
      bin.setY(m_hgH - m_hgFootH);
    }
 
    if (resizeBins) {
      for (HistogramBin bin : m_hgBins) {
        bin.scaleH(histSF, resetReferenceH);
      }      
    }
    
  }
  
  
  void setW(int w) {
    // Attempt to change the node's width to the value specified.
    // The width of individual bins is not changed, so the minimum width allowed is
    // determined by the number of bins and their widths.

    if (w > 0) {
      // work out the inter-bin gap that the specified width would entail
      int gap = (int)((float)(w - m_hgNumBins*m_hgDefaultBinW) / (float)(m_hgNumBins+1));
      gap = constrain(gap, 0, 100); // now constrain the gap to a sensible number
      
      // adjust the x position of each bin
      int binx = gap;   
      for (HistogramBin bin : m_hgBins) {
        bin.setX(binx);
        binx += bin.m_w + gap;
      }
      
      // and finally set the node width according to how the bins are now spaced
      // (which should be equal to w unless the gap was constrained)
      m_nodeW = binx;
    }
  }
  
  
  void setPosition(int x, int y) {
    m_x = x;
    m_y = y;
  }

  void setX(int x) {
    m_x = x;
  }


  void setY(int y) {
    m_y = y;
  }


  int getH() {
    // returns the full height of the node
    return (m_mbH + m_hgH + m_rsH + m_lbH);
  }
  
  int getW() {
    // returns the width of the node
    return m_nodeW;
  }
  
  
  int getCentreX() {
    // returns the x position of the centre of the node
    return (m_x + (m_nodeW / 2));
  }


  int getCentreY() {
    // returns the y position of the centre of the node
    return (m_y + (getH() / 2));
  }
  
  
  boolean hasFocus() {
    return m_bHasFocus;
  }

  
  void initialiseHistogramCommon() {
    // This is a common helper method called in the initialiseHistogram methods of derived classes

    m_hgBinSampleCounts = new int[m_hgNumBins];
    m_hgBinMinVals = new ArrayList<Number>();
    
    // for each bin in the histogram, record the minimum value of its range
    ArrayList<ArrayList<Integer>> sampleIDs = new ArrayList<ArrayList<Integer>>();
    for (int i=0; i < m_hgNumBins; i++) {
      sampleIDs.add(new ArrayList<Integer>());
      m_hgBinMinVals.add(getHistogramBinLowVal(i));
    }
    
    // for each sample of data, add it to the appropriate bin
    int rowNum = 0;
    for (ArrayList<Number> row : m_model.m_data) {
      Number data = row.get(m_dataArrayCol); // from this data sample, get the column corresponding to this node
      int idx = getHistogramIndex(data);     // get the bin (index of m_hgBins) that this data value belongs to
      //println(m_name+": rowNum="+rowNum+", m_dataArrayCol="+m_dataArrayCol+", data="+data+", idx="+idx);
      m_hgBinSampleCounts[idx]++;
      sampleIDs.get(idx).add(rowNum);
      rowNum++;
    }

    m_rsHigh = m_hgNumBins-1;
    
    // work out the appropriate spacing between bins in the histogram
    int gap = (int)((float)(m_nodeW - (m_hgNumBins * m_hgDefaultBinW)) / (float)(m_hgNumBins + 1)); 
    gap = constrain(gap, m_hgMinInterBinGap, m_hgMaxInterBinGap);
    int binx = gap;
    int maxH = 0;
    
    
    println("Node "+m_name+": number of samples per bin:");
    // create a new HistogramBin object for each bin
    for (int i=0; i<m_hgNumBins; i++) {
      HistogramBin bin = new HistogramBin(this, m_hgBins.size(), m_hgBinSampleCounts[i], sampleIDs.get(i), binx, m_hgH - m_hgFootH);
      m_hgBins.add(bin);
      maxH = max(maxH, bin.getH());
      binx += bin.m_w + gap;
      println("  bin "+(i+1)+": "+m_hgBinSampleCounts[i]);
    }
    
    // reset width of node according to space taken up by the bins
    m_nodeW = binx;
    
    // if the max bin height is greater than the height allowed by the node, increase height of node to fit
    int newH = m_mbH + m_rsH + m_lbH + m_hgHeadH + maxH + m_hgFootH;
    if (newH > m_nodeH) {
      setH(newH, false, true);    
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
    pushStyle();

    scale(((float)m_model.m_globalZoom)/100.0);
    
    translate(m_x, m_y);
    
    drawMenuBar();
    drawHistogram();
    drawRangeSelector();
    drawLabelBar();
    
    if (m_brushLinkUnderConstruction) {
      // draw a border around the node to indicate that this has been selected as the first node of
      // a new brush link
      pushStyle();
      strokeWeight(2);
      stroke(#FF0000); // TO DO: define this (and weight) as class variables
      noFill();
      rect(0, 0, m_nodeW, m_nodeH);
      popStyle();
    }    
    
    popStyle();
    popMatrix();
  }

  
  void drawMenuBar() {
    pushStyle();
    pushMatrix();
    
    int gap = 7;

    // draw background
    fill(m_mbBackgroundColor);
    rect(0, 0, m_nodeW, m_mbH);
    
    // draw root/inter/leaf indication
    switch (m_role) {
      case 0: fill(m_mbRootColor);  break;
      case 1: fill(m_mbInterColor); break;
      case 2: fill(m_mbLeafColor);  break;
      default: fill(m_mbBackgroundColor);
    }
    rect(0, 0, m_nodeW, gap /*m_mbH/3*/);
    
    // draw focus indicator
    if (m_bHasFocus) {
      stroke(m_mbFocusColor);
      fill(m_mbFocusColor);
      rect(gap-1, gap, m_mbWidgetW-(2*gap)+1, m_mbH-(2*gap)+1);
    }    
    
    // draw minimize widget
    fill(m_mbMinWidgetBackgroundColor);
    stroke(m_mbMinWidgetForegroundColor);
    rect(m_nodeW-m_mbWidgetW+gap, gap, m_mbWidgetW-(2*gap), m_mbH-(2*gap));
    strokeWeight(2);
    strokeCap(SQUARE);
    line(m_nodeW-m_mbWidgetW+(1*gap), m_mbH-(1*gap)-1, m_nodeW-(1*gap), m_mbH-(1*gap)-1);
    
    popMatrix();
    popStyle();
  }

  
  void drawHistogram() {
    pushMatrix();
    translate(0, m_mbH);
    fill(m_hgBackgroundColor);
    rect(0, 0, m_nodeW, m_hgH);
    
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
    
    pushStyle();
    pushMatrix();
    
    translate(0, m_mbH+m_hgH);
    fill(m_rsBackgroundColor);
    rect(0, 0, m_nodeW, m_rsH);

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
      //
      if (m_rsLow == m_rsHigh) {
        // left and right handles are in the same place, so
        // draw partitions on handle for expand right, drag and expand left
        stroke(m_rsBackgroundColor);
        line(llx, m_rsH/3, lrx, m_rsH/3);
        line(llx, (2*m_rsH)/3, lrx, (2*m_rsH)/3);
        noStroke();
      }
      else {
        // draw right handle
        fill(m_rsRightHandlePressed ? m_rsHandlePressedColor : m_rsHandleColor);
        rect(hlx, 0, hrx-hlx, m_rsH);
      } 
      
      // draw the mean or median value of the selected range
      if (m_rsLow != m_rsHigh) {
        float mv = (m_model.m_showMedians) ? getMedianSelectedValue(!m_bHasFocus) : getMeanSelectedValue(!m_bHasFocus);
          // mv is the mean/median value of samples that lie in the currently selected range
        float lowv  = getHistogramBinLowVal(m_rsLow).floatValue();   // low boundary of lowest bin in selected range
        float highv = getHistogramBinHighVal(m_rsHigh).floatValue(); // high boundary of highest bin in selected range
        
        if (mv < 0.0) { // getMean and getMedian return a negative number if there are no selected samples
          mv = lowv;
        }
        
        int lmx = (llx+lrx)/2;
        int hmx = (hlx+hrx)/2;
        int mx = lmx + (int)(((mv-lowv)*(float)(hmx-lmx))/(highv-lowv));
        int circ = (int)(0.5 * (float)m_rsH);
        fill(m_bHasFocus ? m_rsFocalMeanValColor : m_rsNonFocalMeanValColor);
        ellipse(mx, m_rsH/2, circ, circ);
        
        // print a mu character in the middle of the circle representing the mean value
        textFont(m_model.m_smallFont, 11);
        fill(0xFFFFFFFF);
        textAlign(CENTER);
        if (m_model.m_showMedians) {
          text(m_model.m_strXTilde, mx, (m_rsH*11)/16);
        }
        else {
          text(m_model.m_strMu, mx, (m_rsH*9)/16);
        }
      }
      
    }
    
    popMatrix();
    popStyle();
  }
  
  
  void drawLabelBar() {
    pushStyle();
    pushMatrix();
    translate(0, m_mbH+m_hgH+m_rsH);
    // draw background
    fill(m_lbBackgroundColor);
    rect(0, 0, m_nodeW, m_lbH);
    // write node name    
    textFont(m_model.m_mediumFont, 16);
    fill(m_lbForegroundColor);
    textAlign(CENTER);
    text(m_name, m_nodeW/2, m_lbH-8);
    // draw node resize graphic
    stroke(m_rsBackgroundColor); // a bit of color sharing going on here
    strokeCap(PROJECT);
    for (int l=0; l<4; l++) {
      line( m_nodeW-(((4-l)*m_lbH)/8), m_lbH, m_nodeW, 1+(((4+l)*m_lbH)/8) );
    }
    // and finally revert to previous state
    popMatrix();
    popStyle();
  }
  
  
  void setFullRange() {
    // set the high and low range selectors to their extreme values
    m_rsLow = 0;
    m_rsHigh = m_hgNumBins-1;
  }
  
  
  boolean mouseOver() {
    // Returns true if the mouse pointer is currently over this node, otherwise false.
    return (scaledMouseX() >= m_x &&
            scaledMouseX() < m_x + m_nodeW &&
            scaledMouseY() >= m_y &&
            scaledMouseY() <= m_y + m_nodeH);
  }
  
  
  void mousePressed() {
    
    m_mousePressX = scaledMouseX();
    m_mousePressY = scaledMouseY();
    
    if (mouseOver()) {
      // the mouse has been pressed within this node, so figure out what we need to do about it!
      
      if (scaledMouseY() < m_y + m_mbH) {
        ///////////// MOUSE IS IN THE MENU BAR AREA ///////////////////////////////////////////////
        m_bNodeDragged = true;        
      }
      else if (scaledMouseY() >= m_y + m_mbH && scaledMouseY() < m_y + m_mbH + m_hgH) {
        ///////////// MOUSE IS IN THE HISTOGRAM AREA ///////////////////////////////////////////////
        
        switch (m_model.m_interactionMode) {
          case SingleNodeBrushing: {
            m_model.setSingleFocus(m_id);
            m_model.brushAllNodesOnOneSelection(this);          
            break;
          }
          case MultiNodeBrushing: {
            m_model.toggleMultiFocus(m_id);
            m_model.brushAllNodesOnMultiSelection();          
            break;
          }
          case ShowSamples: {
            m_model.toggleMultiFocus(m_id);
            m_model.brushAllNodesOnMultiSelection();
            m_model.updateSelectedSampleList();
            break;
          }
          default: {
            println("Unexpected interaction mode in Node.mousePressed()!");
          }
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
              if (scaledMouseY() <= (m_y + m_mbH + m_hgH + (m_rsH/3))) {
                // is top third of handle pressed, call it a right handle press
                m_rsRightHandlePressed = true;
              }
              else if (scaledMouseY() >= (m_y + m_mbH + m_hgH + ((2*m_rsH)/3))) {
                // else if bottom third pressed, call it a left handle press
                m_rsLeftHandlePressed = true;
              }
              else {
                // else handle pressed in middle, so treat it as a press of the rs bar for dragging
                m_rsBarPressed = true;
                m_rsMousePressLLDeltaX = m_mousePressX - (m_x + llx);
                m_rsMousePressRRDeltaX = (m_x + hrx) - m_mousePressX;
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
        
        // calculate whether mouse is over the node resize button, and act accordingly
        int rl = m_lbH/2; // dimension of the resize button
        int dx = scaledMouseX() - (m_x + m_nodeW - rl);
        int dy = scaledMouseY() - (m_y + m_mbH + m_hgH + m_rsH + rl);
        if ((dx >= 0) && (dy >= 0) && ((rl-dx) <= dy)) {
          m_lbNodeResizeHandlePressed = true;
          m_lbNodeResizeDeltaX =  (m_x + m_nodeW) - scaledMouseX();
          m_lbNodeResizeDeltaY = (m_y + m_nodeH) - scaledMouseY();
        }
        else {
          m_bNodeDragged = true;
        }
      }
    }
  }


  void mouseReleased() {
    m_bNodeDragged = false;
    m_rsLeftHandlePressed = false;
    m_rsRightHandlePressed = false;
    m_rsBarPressed = false;
    m_lbNodeResizeHandlePressed = false;
  }

  
  void mouseDragged() {
    
    int rsLowOld = m_rsLow;
    int rsHighOld = m_rsHigh;
    
    if (m_bNodeDragged) {
      ///////////// WHOLE NODE DRAGGED /////////////////////////////////////////////////
      m_x += (scaledMouseX() - scaledPMouseX());
      m_y += (scaledMouseY() - scaledPMouseY());
      constrain(m_x, 0, width - m_nodeW);
      constrain(m_y, 0, height - m_nodeH);      
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
      // if this node's range selector bar has been dragged, we now need to move the range selector bars
      // of any nodes that are currently linked to this one
      m_model.adjustBrushLinkedNodes(this);
    }
    else if (m_lbNodeResizeHandlePressed) {
      ///////////// NODE RESIZE HANDLE DRAGGED /////////////////////////
      
      if ((scaledMouseX() > m_x + 0) && (scaledMouseY() > m_y + m_mbH + m_rsH + m_hgHeadH + m_hgFootH + m_lbH )) {
        setH(scaledMouseY() - m_y + m_lbNodeResizeDeltaY, true, false);
        setW(scaledMouseX() - m_x + m_lbNodeResizeDeltaX);
      }  
      
    }
    
    if (m_rsLow != rsLowOld || m_rsHigh != rsHighOld) {
      switch(m_model.m_interactionMode) {
        case SingleNodeBrushing: {
          m_model.brushAllNodesOnOneSelection(this);
          break;
        }
        case MultiNodeBrushing: {
          m_model.brushAllNodesOnMultiSelection();
          break;
        }
        case ShowSamples: {
          m_model.brushAllNodesOnMultiSelection();
          m_model.updateSelectedSampleList();
          break;
        }
        default: {
          println("I shouldn't be here!!");
          exit();
        }
      }
    }
  }
  
  
  ArrayList<Integer> getSelectedSampleIDs() {
    // return a list of sampleIDs of all samples within the selected range
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
      
      case SingleNodeBrushing:
        return m_bHasFocus;
      case MultiNodeBrushing:
        return m_bHasFocus;
      case ShowSamples:
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
    // If there are no relevant samples, return -1.0.
    
    float total = 0;
    int numSamples = 0;
    for (int b = m_rsLow; b <= m_rsHigh; b++) {
      total += m_hgBins.get(b).getTotalValues(brushedOnly);    
      numSamples += (brushedOnly ? m_hgBins.get(b).numBrushed() : m_hgBins.get(b).numSamples());
    }
    
    if (numSamples == 0) {
      return -1.0;
    }

    return total / (float)numSamples;
  }
  
  
  float getMedianSelectedValue() {
    // Calculate the median value of samples in selected bins
    return getMedianSelectedValue(false);
  }
  
  
  float getMedianSelectedValue(boolean brushedOnly) {
    // Calculate the median value of samples in selected bins.
    // If brushedOnly==true, only count brushed samples (with numMiss==0), otherwise count all samples.
    // If there are no relevant samples, return -1.0.
    
    ArrayList<Float> selectedValues = new ArrayList<Float>();

    for (int b = m_rsLow; b <= m_rsHigh; b++) {
      selectedValues.addAll(m_hgBins.get(b).getSelectedValues(brushedOnly));
    }
    
    if (selectedValues.isEmpty()) {
      return -1.0;
    }
    
    Collections.sort(selectedValues);
    
    if (selectedValues.size() % 2 == 1) {
      return selectedValues.get((selectedValues.size()+1)/2-1);
    }
    else
    {
      float lower = selectedValues.get(selectedValues.size()/2-1);
      float upper = selectedValues.get(selectedValues.size()/2);
      return ((lower + upper) / 2.0);
    }
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
  
  
  void setBrushLinkUnderConstruction(boolean flag) {
    m_brushLinkUnderConstruction = flag;
  }
  
  
  void adjustRangeSelector(Node node, float strength) {
    // Adjust this node's range selector, based upon the position of the range selector of the other
    // node passed in to this method.
    int oMax = node.m_hgNumBins - 1;
    int oLow = node.m_rsLow;
    int oHigh = node.m_rsHigh;
    float otherRSPosFrac = ((float)(oLow + oHigh) / (float)(2 * oMax));  

    float thisCurrentRSPos = (float)m_rsLow + (((float)(m_rsHigh - m_rsLow)) / 2.0);
    
    int thisMax = m_hgNumBins - 1;
    float thisTargetRSPos;
   
    if (strength >= 0.0) {
      thisTargetRSPos = strength * otherRSPosFrac * (float)thisMax;
    }
    else {
      thisTargetRSPos = (1.0 + (strength * otherRSPosFrac)) * (float)thisMax;
    }
    
    int delta = round(thisTargetRSPos - thisCurrentRSPos);
    
    m_rsLow += delta;
    m_rsHigh += delta;
    
    if (m_rsLow < 0) {
      int d = -m_rsLow;
      m_rsLow += d;
      m_rsHigh += d;
    }
    else if (m_rsHigh >= m_hgNumBins) {
      int d = m_rsHigh + 1 - m_hgNumBins;
      m_rsLow -= d;
      m_rsHigh -= d;
    }
  }
  
  
  ArrayList<Integer> getSamplesInRange() {
    // returns a list of IDs of all samples within the currently selected range of this node
    ArrayList<Integer> list = new ArrayList<Integer>();
    for (int b = m_rsLow; b <= m_rsHigh; b++) {
      list.addAll( m_hgBins.get(b).m_sampleIDs );
    }
    return list;
  }
  
  
  void matchSampleBinsToColors(ArrayList<Integer> sampleIDs, ArrayList<Integer> hues) {
    // Takes a list of sampleIDs as input, and a list of hues to be returned as output. This list of
    // hues is first emptied. Then, so through each sample, and add an entry at the corresponding
    // position in the hue list according to the bin in which that sample is found.
    
    // First, empty the list of hues to start with a clean slate
    hues.clear();
    
    // Now create a hue for each bin in the histogram
    ArrayList<Integer> binHues = new ArrayList<Integer>(m_hgNumBins);
    for (int i=0; i<m_hgNumBins; i++) {
      binHues.add((i*255)/m_hgNumBins);
    }
    Collections.shuffle(binHues);  // shuffle the hues so adjacent bins have very different hues
    
    // Finally, for each sample in the list, determine which bin it belongs to and assign
    // a hue accordingly
    for (Integer sID : sampleIDs) {
      int binIdx = findSample(sID);
      
      assert(binIdx >= 0);
      if (binIdx < 0) {
        binIdx = 0;
      }
      
      hues.add(binHues.get(binIdx));
    }
  }
  
  
  int findSample(int sampleID) {
    // Find which bin the specified sample belongs to, and return the index of the bin. If not found, return -1.
    for (HistogramBin bin : m_hgBins) {
      if (bin.sampleInBin(sampleID)) {
        return bin.m_idx;
      }
    }
    return -1;
  }

  
}
