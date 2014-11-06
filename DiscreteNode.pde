public class DiscreteNode extends Node {
  
  // Range selector info
  int m_rangeMin;      // min value selectable
  int m_rangeMax;      // max value selectable
  int m_rangeLow;      // current low point selected
  int m_rangeHigh;     // current high point selected  
  
  
  DiscreteNode(Model model, int id, String name, int filecol, int datacol, int min, int max, ArrayList<Integer> parentIDs) {
    super(model, id, name, filecol, datacol, parentIDs);
    m_rangeMin = m_rangeLow = min;
    m_rangeMax = m_rangeHigh = max;
  }

  
  int getSelectedRange() {
    return m_rangeHigh - m_rangeLow + 1;
  }


  int getFullRange() {
    return m_rangeMax - m_rangeMin + 1;
  }
  
  
  void initialiseHistogram() {
    int dataRange = getFullRange();
    m_hgNumBins = (dataRange > m_sMaxBins) ? m_sMaxBins : dataRange;
    
    println("Histogram boundary values for "+m_name);
    for (int i=0; i<m_hgNumBins; i++) {
      println(getHistogramBinLowVal(i));
    }
    
    initialiseHistogramCommon();
  }
  
  
  int getHistogramIndex(Number num) {
    // return the index in node.m_hgBins corresponding to the data value passed in (i.e. which
    // bin does that value belong to)
    int iNum = num.intValue();
    return (((iNum - m_rangeMin) * m_hgNumBins) / (m_rangeMax - m_rangeMin + 1));
  }
  
  
  Number getHistogramBinLowVal(int bin) {
    return new Integer((((bin*(m_rangeMax - m_rangeMin + 1))/m_hgNumBins) + m_rangeMin));
  }
  
  
  Number getHistogramBinHighVal(int bin) {
    Integer high = new Integer((Integer)getHistogramBinLowVal(bin+1));
    return (high - 1);
  }

  
  /*
  InputDial(int x, int y, int d, Data data, DataField datafield, ControlP5 c) {
      super(x,y,d,data,datafield,c);
      m_widgetBackgroundColor = 0xFF00B3B3;
  }
  
  void draw() {
    int x = m_x + (m_dim/2);
    int y = m_y + (m_dim/2) + (1*(m_dim/10));
    float dmin = ((float)(m_dialLow-m_dialMin)/(float)(m_dialMax-m_dialMin));
    float dmax = ((float)(m_dialHigh-m_dialMin)/(float)(m_dialMax-m_dialMin));
    
    for (OutputDial odial : m_connectedOutputDials) {
      strokeWeight(2);
      stroke(255,200);
      line(x, y, odial.m_x + (m_dim/2), odial.m_y + (m_dim/2) + (1*(m_dim/10)));
      strokeWeight(1);
    }
    
    super.draw();

    noStroke();
    fill(m_dialForegroundColor);
    arc(x, y, m_dim, m_dim, (dmin * TWO_PI - HALF_PI), (dmax * TWO_PI - HALF_PI), PIE);
    
    //println(m_datafield.toString());
    //println(m_dialLow + " " + m_dialHigh + " " + m_dialMin + " " + m_dialMax + " " + dmin + " " + dmax);
    
    // TEMPORARY PLACEMENT OF THIS CODE
    if (m_bShowExtra) {
      int numFloatBins = 20; // TODO this should be a member variable
      int[] databins = {};
      
      // TODO: should allocate these arrays once when datafield is ready, not at every call to draw()!
      if (m_datafield.isInt()) {
        databins = new int[m_datafield.iRange()];
      }
      else if (m_datafield.isFloat()) {
        databins = new int[numFloatBins];
      }
      
      x = m_x + (int)(1.2 * (float)m_dim);
      y = m_y + (1*(m_dim/10));
      int w  = m_dim * 2;
      int h = m_dim;
      fill(0xFFE0E0E0);
      rect(x,y,w,h);
      //ArrayList<Number> data = m_data.getRawData(m_datafield);
      fill(0x80800000);
      for (ArrayList<Number> row : m_data.m_data) {
      //for (Number datum : data) {
        Number datum  = row.get(m_datafield.m_dataIdx);
        boolean showPoint = false;
        int dx = 0;
        if (m_datafield.isInt()) {
          int val = datum.intValue();
          if (m_dialLow <= val && val <= m_dialHigh) {
            databins[val-m_datafield.iMin()]++;
          }
          //dx = (int)((float)w*((float)(datum.intValue()-m_datafield.iMin())/(float)(m_datafield.iRange())));
          //println(datum.intValue() + " " + m_datafield.iMin() + " " + m_datafield.iMax() + " " + m_datafield.iRange() + " " + dx);
        }
        else if (m_datafield.isFloat()) {
          dx = (int)((float)w*((datum.floatValue()-m_datafield.fMin())/(m_datafield.fRange())));
          float val = datum.floatValue();
          if ((float)m_dialLow <= val && val <= (float)m_dialHigh) {
            int idx = (int)(((val-m_datafield.fMin())*(float)numFloatBins)/m_datafield.fRange());
            databins[constrain(idx,0,numFloatBins-1)]++; // TODO check these calcs - shouldn't need to use constrain
          }          
        }
        int dy = (int)((float)(h/2) + random(-h/4,h/4));
        if (showPoint) {
          ellipse(x+dx,y+dy,10,10);
        }
      }
      if (m_datafield.isInt()) {
        int bw = w/m_datafield.iRange();
        int bx = x;
        int mag = 1;
        fill(100,0,0);
        for (int i=0; i<m_datafield.iRange(); i++) {
          rect(bx, y+h, bw, -(databins[i]*h*mag/255));
          bx += bw;
        }
      }
      else if (m_datafield.isFloat()) {
        int bw = w/numFloatBins;
        int bx = x;
        int mag = 1;
        fill(100,0,0);
        for (int i=0; i<numFloatBins; i++) {
          rect(bx, y+h, bw, -(databins[i]*h*mag/255));
          bx += bw;
        }        
      }
    }
  }
  
  void connect(OutputDial odial) {
    if (!isConnectedOutput(odial)) {
      m_connectedOutputDials.add(odial);
      odial.connect(this);
    }
    else {
      // do nothing
    }
  }
  
  void disconnect(OutputDial odial) {
    if (!isConnectedOutput(odial)) {
      // do nothing
    }
    else {
      m_connectedOutputDials.remove(odial);
      odial.disconnect(this);
    }
  }  
  
  boolean isConnected(OutputDial odial, InputDial idialAvoid) {
    return (isDirectlyConnected(odial) || isIndirectlyConnected(odial, idialAvoid));
  }
  
  boolean isDirectlyConnected(OutputDial odial) {
    return m_connectedOutputDials.contains(odial);
  }
  
  boolean isIndirectlyConnected(OutputDial odial, InputDial idialAvoid) {
    if (this == idialAvoid) {
      return false;
    }
    for (InputDial idial : m_connectedInputDials) {
      if (idial.isConnected(odial, this)) {
        return true;
      }
    }
    return false;
  }
  */
  
}

