import controlP5.*;

class Dial {
  
  int m_dim;
  int m_x;
  int m_y;
  int m_min;
  int m_max;
  String m_id;
  Range m_range;
  PFont m_font;
  DataField m_datafield;
  boolean m_bDragged;
  boolean m_bHasFocus;
  color m_widgetBackgroundColor;
  color m_dialForegroundColor;
  ArrayList<InputDial> m_connectedInputDials;
  ArrayList<OutputDial> m_connectedOutputDials;
  
  Dial() {
    setDefaults();
  }
  
  Dial(int x, int y, int d) {
    setDefaults();
    m_x = x;
    m_y = y;
    m_dim = d; 
  }
  
  Dial(int x, int y, int d, DataField datafield, ControlP5 c) {
    setDefaults();
    m_x = x;
    m_y = y;
    m_dim = d;
    m_datafield = datafield;
    m_id = datafield.m_description; // don't need m_id anymore...
    m_range = c.addRange(m_id)
             // disable broadcasting since setRange and setRangeValues will trigger an event
             .setBroadcast(false) 
             .setPosition(m_x, m_y)
             .setSize(m_dim, m_dim/10)
             .setHandleSize(m_dim/15)
             .setRange(0,100)
             .setRangeValues(0,100)
             .setCaptionLabel("")
             // after the initialization we turn broadcast back on again
             .setBroadcast(true)
             .setColorForeground(color(255,40))
             .setColorBackground(color(255,40))  
             ;    
  }  
  
  void setDefaults() {
    m_x = 50;
    m_y = 50;
    m_dim = 200;
    m_min = 0;
    m_max = 100;
    m_font = createFont("Arial",16,true);
    m_bDragged = false;
    m_bHasFocus = false;
    m_widgetBackgroundColor = 0xFF151515; //0x20151515;
    m_dialForegroundColor   = 0x65404040;
    m_connectedInputDials = new ArrayList<InputDial>();
    m_connectedOutputDials = new ArrayList<OutputDial>();
  }
  
  void controlEvent(ControlEvent theControlEvent) {
    if(theControlEvent.isFrom(m_id)) {
      m_min = int(theControlEvent.getController().getArrayValue(0));
      m_max = int(theControlEvent.getController().getArrayValue(1));
    }
  }

  void draw() {
    int x = m_x + (m_dim/2);
    int y = m_y + (m_dim/2) + (1*(m_dim/10));
    float dmin = ((float)m_min/100.0);
    float dmax = ((float)m_max/100.0);

    if (m_bHasFocus) {
      strokeWeight(2);
      stroke(255);
    } else {
      noStroke();
    }
    fill(m_widgetBackgroundColor);
    //fill(20,20,20);
    //fill(0xFF151515);
    rect(m_x, m_y, m_dim, m_dim + (2*(m_dim/10)));
    
    strokeWeight(1);
    stroke(150);
    noFill();
    ellipse(x, y, m_dim, m_dim);
 
    textFont(m_font, 16);
    fill(255);
    textAlign(CENTER);
    text(m_id, x, m_y + m_dim + (1.8*(m_dim/10)));
  }
  
  void mousePressed(ArrayList<InputDial> allidials, ArrayList<OutputDial> allodials, boolean clearFocusIfNotTarget) {
    if ((mouseX >= m_x) && 
        (mouseX < m_x + m_dim) && 
        (mouseY >= m_y + + (1*(m_dim/10))) &&
        (mouseY <= m_y + m_dim + (2*(m_dim/10)))) { 
      m_bDragged = true;
      m_bHasFocus = !m_bHasFocus;
    } else {
      m_bDragged = false;
      if (clearFocusIfNotTarget) {
        m_bHasFocus = false;
      }
    }
  }

  void mouseReleased() {
    m_bDragged = false;
  }
  
  void mouseDragged() {
    if (m_bDragged) {
      m_x += (mouseX - pmouseX);
      m_y += (mouseY - pmouseY);
      constrain(m_x, 0, width - m_dim);
      constrain(m_y, 0, height - m_dim);
      m_range.setPosition(m_x, m_y);
    }
  }
  
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
}
