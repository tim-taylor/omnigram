import controlP5.*;

class Dial {
  
  int m_dim;              // dimension of dial (width and height)
  int m_x;                // x position of dial
  int m_y;                // y position of dial
  int m_dialMin;          // min value selectable on dial  // TODO THESE SHOULD BE FLOATS!
  int m_dialMax;          // max value selectable on dial
  int m_dialLow;          // current low point selected on dial
  int m_dialHigh;         // current high point selected on dial
  Range m_range;
  PFont m_font;
  Data m_data;            // reference to the associated data
  DataField m_datafield;  // reference to associated data column info
  boolean m_bDragged;
  boolean m_bHasFocus;
  color m_widgetBackgroundColor;
  color m_dialForegroundColor;
  ArrayList<InputDial> m_connectedInputDials;
  ArrayList<OutputDial> m_connectedOutputDials;
  
  boolean m_bShowExtra;
  
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

  void draw() {
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
  }
  
  boolean mousePressed(ArrayList<InputDial> allidials, ArrayList<OutputDial> allodials, boolean clearFocusIfNotTarget) {
    boolean dialPressed = false;
    /*
    int smx = (int)((float)mouseX / displayScale);
    int smy = (int)((float)mouseY / displayScale);
    if ((smx >= m_x) && 
        (smx < m_x + m_dim) && 
        (smy >= m_y + + (1*(m_dim/10))) &&
        (smy <= m_y + m_dim + (2*(m_dim/10)))) {
    */
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
