public class InputDial extends Dial {
  
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
    
    if (m_bShowExtra) {
      int[] databins = {};
      if (m_datafield.isInt()) {
        databins = new int[m_datafield.iRange()];
      }
      x = m_x + (int)(1.2 * (float)m_dim);
      y = m_y + (1*(m_dim/10));
      int w  = 400;
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
  
}

