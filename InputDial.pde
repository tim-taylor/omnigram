public class InputDial extends Dial {
  
  InputDial(int x, int y, int d, DataField datafield, ControlP5 c) {
      super(x,y,d,datafield,c);
      m_widgetBackgroundColor = 0xFF00B3B3; //0x8000B3B3;
  }
  
  void draw() {

    int x = m_x + (m_dim/2);
    int y = m_y + (m_dim/2) + (1*(m_dim/10));
    float dmin = ((float)m_min/100.0);
    float dmax = ((float)m_max/100.0);
    
    for (OutputDial odial : m_connectedOutputDials) {
      strokeWeight(2);
      //stroke(0x10808000);
      //stroke(255);
      stroke(255,200);
      line(x, y, odial.m_x + (m_dim/2), odial.m_y + (m_dim/2) + (1*(m_dim/10)));
      strokeWeight(1);
      //println("hello!");
    }
    
    super.draw();

    noStroke();
    fill(m_dialForegroundColor);
    arc(x, y, m_dim, m_dim, (dmin * TWO_PI - HALF_PI), (dmax * TWO_PI - HALF_PI), PIE);
    
    //arc(x, y, m_dim, m_dim, (-HALF_PI - (dmin * TWO_PI)), (-HALF_PI + ((1.0-dmax) * TWO_PI)), PIE);
    //arc(x, y, m_dim, m_dim, (dmax * TWO_PI - HALF_PI), (dmin * TWO_PI - HALF_PI), PIE); 
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

