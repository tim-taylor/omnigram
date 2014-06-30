public class InputDial extends Dial {
  
  InputDial(int x, int y, int d, DataField datafield, ControlP5 c) {
      super(x,y,d,datafield,c);
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
    
    /*
    x = m_x + (int)(1.5 * (float)m_dim);
    y = m_y + (1*(m_dim/10));
    int w  = 400;
    int h = m_dim;
    rect(x,y,w,h);
    int bw = w/m_numBins;
    int bx = x;
    int mag = 3;
    fill(100,0,0);
    for (int i=0; i<m_numBins; i++) {
      rect(bx, y+h, bw, -(m_dataBins[i]*h*mag/255));
      bx += bw;
    } 
    */   
  }
  
  void connect(OutputDial odial) {
    if (!isConnectedOutput(odial)) {
      m_connectedOutputDials.add(odial);
      odial.connect(this);
    }
    else {
      // do nothinig
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

