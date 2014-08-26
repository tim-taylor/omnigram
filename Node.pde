public abstract class Node {
  
  // identity
  int m_id;             // used to refer to this Node when we can't used a reference
  String m_name;        // human readable name of node
  
  // Widget appearance and position
  PFont m_font;  
  int m_sNodeW = 330;   // width of Node widget, same for all nodes 
  int m_sNodeH = 200;   // height of Node widget, same for all nodes 
  int m_x;              // x position of top-left corner
  int m_y;              // y position of top-left corner
  
  protected int m_mbH = 25;  // menu bar height
  protected int m_hgH;       // histogram height (= m_sNodeH - m_mbH - m_rsH - m_lbH)
  protected int m_rsH = 25;  // range selector height
  protected int m_lbH = 25;  // label bar height
  
  color m_mbBackgroundColor;
  color m_hgBackgroundColor;
  color m_rsBackgroundColor;
  color m_rsHandleColor;
  color m_rsHandlePressedColor;
  color m_rsSelectedRangeColor;
  color m_lbBackgroundColor;
  color m_lbForegroundColor;
  
  // Interaction
  boolean m_bNodeDragged;
  boolean m_bHasFocus;  
  boolean m_rsLeftHandlePressed;
  boolean m_rsRightHandlePressed;
  
  // References to data associated with this Node
  Model m_model; // reference to the associated Model
  int m_dataCol; // which column of data.. (1 based)
  
  // Histogram 
  int m_sMaxBins = 20;
  int m_hgNumBins;
  int[] m_hgBins;      // stores number of samples in each bin
  ArrayList<HistogramBar> m_hgBars;
  int m_hgMinInterBarGap = 8;
  
  // Range Selector
  int m_rsHandleW = 8;
  int m_rsLow = 0;   // the (0-based) index of the lowest selected histogram bar
  int m_rsHigh = 0;  // the (0-based) index of the highest selected histogram bar
  
  // Links to connected Nodes
  ArrayList<Node> m_parents; // TO DO: these will have to be populated after ALL Nodes have been constructed
  ArrayList<Node> m_children;  
  ArrayList<Integer> m_parentIDs;
  
  // Abstract classes to be specialised in subclasses
  abstract int getFullRange();
  abstract int getSelectedRange();
  abstract void initialiseHistogram();

  
  Node(Model model, int id, String name, int filecol, ArrayList<Integer> parentIDs) {
    m_model = model;
    m_id = id;
    m_name = name;
    m_dataCol = filecol;
    m_parentIDs = parentIDs;
    m_hgNumBins = 10;
    m_hgBars = new ArrayList<HistogramBar>(); 
    m_x = (int)random(0, width - m_sNodeW);
    m_y = (int)random(0, height - m_sNodeH);
    m_hgH = m_sNodeH - m_mbH - m_rsH - m_lbH;
    m_mbBackgroundColor    = #E0E0E0;
    m_hgBackgroundColor    = #FFFFFF;
    m_rsBackgroundColor    = #999999;
    m_rsHandleColor        = #BBDDDD;
    m_rsHandlePressedColor = #DDFFFF;
    m_rsSelectedRangeColor = #99BBBB;
    m_lbBackgroundColor    = #E0E0E0;
    m_lbForegroundColor    = #101010;
    m_bNodeDragged = false;
    m_rsLeftHandlePressed = false;
    m_rsRightHandlePressed = false;
  }
  
  void setPosition(int x, int y) {
    m_x = x;
    m_y = y;
  }
  
  //
  void initialiseHistogramCommon() {
    int barx = 0;
    for (int i=0; i<m_hgNumBins; i++) {
      HistogramBar bar = new HistogramBar(m_hgBins[i], barx, m_hgH);
      m_hgBars.add(bar);
      barx += (bar.numCols() * bar.m_sTileDim) + m_hgMinInterBarGap;
    }
    
    m_rsHigh = m_hgNumBins-1;    
  }
  //
  

  void draw(int globalZoom, int nodeZoom) {
    
    pushMatrix();
    
    //int midX = m_sNodeW/2;
    //int midY = m_sNodeH/2;
    
    scale(((float)globalZoom)/100.0);
    
    translate(m_x, m_y);
    
    drawMenuBar();
    drawHistogram();
    drawRangeSelector();
    drawLabelBar();
         
    popMatrix();
    
    
    /*
    int x = m_x + (m_dim/2);
    int y = m_y + (m_dim/2) + (1*(m_dim/10));

    if (m_bHasFocus) {
      strokeWeight(2);
      stroke(255);
    } else {
      noStroke();
    }
    fill(m_widgetBackgroundColor);
    rect(m_x, m_y, m_dim, m_dim + (2*(m_dim/10)));
    
    strokeWeight(1);
    stroke(150);
    noFill();
    ellipse(x, y, m_dim, m_dim);
 
    textFont(m_font, 16);
    fill(255);
    textAlign(CENTER);
    text(m_datafield.m_description, x, m_y + m_dim + (1.8*(m_dim/10)));
    */
  }
  
  void drawMenuBar() {
    pushMatrix();    
    //stroke(0);
    fill(m_mbBackgroundColor);
    rect(0, 0, m_sNodeW, m_mbH);
    popMatrix();
  }
  
  void drawHistogram() {
    pushMatrix();
    translate(0, m_mbH);
    //stroke(0);
    fill(m_hgBackgroundColor);
    rect(0, 0, m_sNodeW, m_hgH);
    
    /*
    if (m_hgBins != null) {
      int x=0;
      int dx = m_sNodeW / m_hgNumBins;
      //println(m_name+" "+m_hgNumBins+" "+dx+" "+m_hgBins[0]);
      for (int i=0; i < m_hgNumBins; i++) {
        fill(#880000);
        int h = (int)((float)m_hgBins[i]*0.5);
        rect(x, m_hgH-h, dx-1, h ); 
        x += dx;
      }
    }
    */
    
    if (m_hgBars != null) {
      for (HistogramBar bar : m_hgBars) {
        bar.draw();
      }
    }
    
    popMatrix();
  }
  
  void drawRangeSelector() {
    pushMatrix();
    translate(0, m_mbH+m_hgH);
    //stroke(0);
    fill(m_rsBackgroundColor);
    rect(0, 0, m_sNodeW, m_rsH);

    if (m_hgBars != null) {
      int lx = m_hgBars.get(m_rsLow).getLColLX();
      int rx = m_hgBars.get(m_rsHigh).getRColLX();
      fill(m_rsSelectedRangeColor);
      rect(lx, 0, rx-lx, m_rsH);
      fill(m_rsLeftHandlePressed ? m_rsHandlePressedColor : m_rsHandleColor);
      rect(lx, 0, m_rsHandleW, m_rsH);
      fill(m_rsRightHandlePressed ? m_rsHandlePressedColor : m_rsHandleColor);
      rect(rx, 0, m_rsHandleW, m_rsH);
    }
    
    popMatrix();
  }
  
  void drawLabelBar() {
    pushMatrix();
    translate(0, m_mbH+m_hgH+m_rsH);
    //stroke(0);
    fill(m_lbBackgroundColor);
    rect(0, 0, m_sNodeW, m_lbH);
    
    textFont(mediumFont, 16);
    fill(m_lbForegroundColor);
    //fill(255);
    textAlign(CENTER);
    text(m_name, m_sNodeW/2, m_lbH-8);
    
    //println(m_lbForegroundColor);
    
    popMatrix();
  }  
  
  void mousePressed() {
    if (mouseX >= m_x && mouseX < m_x + m_sNodeW && mouseY >= m_y && mouseY <= m_y + m_sNodeH) {
      // the mouse has been pressed within this node, so figure out what we need to do about it!
      
      if (mouseY >= m_y + m_mbH + m_hgH && mouseY <= m_y + m_mbH + m_hgH + m_rsH) {
        // mouse is in range selector area
        
        //println("Pressed range selector in "+m_name+" node!");
        int lx = m_hgBars.get(m_rsLow).getLColLX();
        int rx = m_hgBars.get(m_rsHigh).getRColLX();
        
        if (m_rsLow == m_rsHigh) {
          // first deal with special case where both range selectors are in the same position
          if (mouseX >= m_x + lx && mouseX <= m_x + lx + m_rsHandleW) {
            if (mouseY <= (m_y + m_mbH + m_hgH + (m_rsH/2))) {
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
          if (mouseX >= m_x + lx && mouseX <= m_x + lx + m_rsHandleW) {
            // left handle pressed
            m_rsLeftHandlePressed = true;
            //println("Pressed left handle!");
          }
          else if (mouseX >= m_x + rx && mouseX <= m_x + rx + m_rsHandleW) {
            // right handle pressed
            m_rsRightHandlePressed = true;
            //println("Pressed right handle!");
          }
        }
        
      }
      else if (mouseY >= m_y + m_mbH + m_hgH + m_rsH) {
        // mouse is in label bar area
        m_bNodeDragged = true;
      }
    }
  }


  void mouseReleased() {
    m_bNodeDragged = false;
    m_rsLeftHandlePressed = false;
    m_rsRightHandlePressed = false;
  }
  
  void mouseDragged() {
    
    if (m_bNodeDragged) {
      m_x += (mouseX - pmouseX);
      m_y += (mouseY - pmouseY);
      constrain(m_x, 0, width - m_sNodeW);
      constrain(m_y, 0, height - m_sNodeH);      
    }
    else if (m_rsLeftHandlePressed) {
      int lx = m_hgBars.get(m_rsLow).getLColLX();
      int rx = m_hgBars.get(m_rsLow).getRColRX();    
      if (mouseX < m_x) {
        m_rsLow = 0;
      }
      else if ((mouseX < m_x + lx) && (m_rsLow > 0)) {
        for (int i = m_rsLow-1; i >= 0; i--) {
          if (mouseX < m_x + m_hgBars.get(i).getRColRX()) {
            m_rsLow = i;
          }
          else {
            break;
          }
        } 
      }
      else if ((mouseX > m_x + rx) && (m_rsLow < m_rsHigh)) {
        for (int i = m_rsLow+1; i <= m_rsHigh; i++) {
          if (mouseX > m_x + m_hgBars.get(i).getLColLX()) {
            m_rsLow = i;
          }
          else {
            break;
          }
        } 
      }      
    }
    else if (m_rsRightHandlePressed) {
      int lx = m_hgBars.get(m_rsHigh).getLColLX();
      int rx = m_hgBars.get(m_rsHigh).getRColRX();    
      if (mouseX < m_x) {
        m_rsHigh = m_rsLow;
      }
      else if ((mouseX < m_x + lx) && (m_rsHigh > m_rsLow)) {
        for (int i = m_rsHigh-1; i >= m_rsLow; i--) {
          if (mouseX < m_x + m_hgBars.get(i).getRColRX()) {
            m_rsHigh = i;
          }
          else {
            break;
          }
        } 
      }
      else if ((mouseX > m_x + rx) && (m_rsHigh < m_hgNumBins-1)) {
        for (int i = m_rsHigh+1; i <= m_hgNumBins-1; i++) {
          if (mouseX > m_x + m_hgBars.get(i).getLColLX()) {
            m_rsHigh = i;
          }
          else {
            break;
          }
        } 
      }
    }
  }
  
  
  //////////// LEGACY STUFF //////////////////////////////
  
  //boolean m_bShowExtra;
  
  /*
  Dial() {
    setDefaults();
  }
  
  Dial(int x, int y, int d) {
    setDefaults();
    m_x = x;
    m_y = y;
    m_dim = d; 
  }
  
  Dial(int x, int y, int d, Data data, DataField datafield, ControlP5 c) {
    setDefaults();
    m_x = x;
    m_y = y;
    m_dim = d;
    m_data = data;
    m_datafield = datafield;

    m_range = c.addRange(m_datafield.m_description)
             // disable broadcasting since setRange and setRangeValues will trigger an event
             .setBroadcast(false) 
             .setPosition(m_x, m_y)
             .setSize(m_dim, m_dim/10)
             .setHandleSize(m_dim/15)
             //.setNumberOfTickMarks(8)
             //.showTickMarks(true)
             //.snapToTickMarks(true)
             .setRange(m_dialMin, m_dialMax)          // sets max range on dial
             .setRangeValues(m_dialLow, m_dialHigh)   // sets current range on dial
             .setCaptionLabel("")
             // after the initialization we turn broadcast back on again
             .setBroadcast(true)
             //.setColorForeground(color(255,40))
             //.setColorBackground(color(255,40))
             .setColorForeground(color(255,80))
             .setColorBackground(color(200,40)) 
             ;    
  }
  
  void setRange(float min, float max) {
    m_dialMin = (int)min;
    m_dialMax = (int)max;
    m_dialLow = m_dialMin;
    m_dialHigh = m_dialMax;
    m_range.setBroadcast(false);
    m_range.setRange(m_dialMin, m_dialMax);
    m_range.setRangeValues(m_dialLow, m_dialHigh);
    m_range.setBroadcast(true);
  }
  
  void initialiseTicks(int numTicks, boolean snapToTicks) {
    m_range.setBroadcast(false);
    m_range.setNumberOfTickMarks(numTicks);
    m_range.snapToTickMarks(snapToTicks);
    m_range.showTickMarks(numTicks <= 20);
    m_range.setDecimalPrecision(0);
    m_range.setBroadcast(true);
  }
  
  void setRangeAndTicksFromData() {
    if (m_datafield.isFloat()) {
      setRange(m_datafield.fMin(), m_datafield.fMax());
    }
    else if (m_datafield.isInt()) {
      setRange(m_datafield.iMin(), m_datafield.iMax());
      initialiseTicks(m_datafield.iRange(), true);
    }
  }
  
  void setDefaults() {
    m_x = 50;
    m_y = 50;
    m_dim = 200;
    m_dialMin = 0;
    m_dialMax = 100;
    m_dialLow = 0;
    m_dialHigh = 100;
    m_font = createFont("Arial",16,true);
    m_bDragged = false;
    m_bHasFocus = false;
    m_widgetBackgroundColor = 0xFF151515; //0x20151515;
    m_dialForegroundColor   = 0x65404040;
    m_connectedInputDials = new ArrayList<InputDial>();
    m_connectedOutputDials = new ArrayList<OutputDial>();
    m_bShowExtra = false;
  }
  
  void controlEvent(ControlEvent theControlEvent) {
    if(theControlEvent.isFrom(m_datafield.m_description)) {
      m_dialLow  = int(theControlEvent.getController().getArrayValue(0));
      m_dialHigh = int(theControlEvent.getController().getArrayValue(1));
    }
  }
  */

  
  /*
  boolean hasFocus() {
    return m_bHasFocus;
  }
  
  boolean isConnectedOutput(OutputDial odial) {
    for (OutputDial connection : m_connectedOutputDials) {
      if (connection == odial) {
        return true;
      }
    }
    return false;
  }
  
  boolean isConnectedInput(InputDial idial) {
    for (InputDial connection : m_connectedInputDials) {
      if (connection == idial) {
        return true;
      }
    }
    return false;
  }
  */
  
  
  /*
  boolean mousePressed(ArrayList<InputDial> allidials, ArrayList<OutputDial> allodials, boolean clearFocusIfNotTarget) {
    /*
    boolean dialPressed = false;
    /*
    int smx = (int)((float)mouseX / displayScale);
    int smy = (int)((float)mouseY / displayScale);
    if ((smx >= m_x) && 
        (smx < m_x + m_dim) && 
        (smy >= m_y + + (1*(m_dim/10))) &&
        (smy <= m_y + m_dim + (2*(m_dim/10)))) {
    * /
    if ((mouseX >= m_x) && 
        (mouseX < m_x + m_dim) && 
        (mouseY >= m_y + + (1*(m_dim/10))) &&
        (mouseY <= m_y + m_dim + (2*(m_dim/10)))) {    
      m_bDragged = true;
      m_bHasFocus = !m_bHasFocus;
      dialPressed = true;
    } else {
      m_bDragged = false;
      if (clearFocusIfNotTarget) {
        m_bHasFocus = false;
      }
    }
    return dialPressed;
    * /
  }
  */
  
}
