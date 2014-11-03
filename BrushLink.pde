public class BrushLink {
  
  Model m_model;
  Node  m_node1;
  Node  m_node2;
  float m_strength;
  
  PVector m_chPos; // position of the link's control handle
  int m_chSize;    // size of the control handle
  
  color m_strokeCol;
  color m_chHighlightCol;
  color m_chBackgroundCol;

  
  BrushLink(Model model, Node n1, Node n2, float strength) {
    m_model = model;
    m_node1 = n1;
    m_node2 = n2;
    m_strength = strength;
    m_chPos = new PVector();
    m_chSize = 20;
    m_strokeCol = #000000;
    m_chHighlightCol = #FF0000;
    m_chBackgroundCol = #FFFFFF;
  }
  
  
  void draw() {
    
    pushMatrix();
    pushStyle();
    
    int n1x = m_node1.getCentreX();
    int n1y = m_node1.getCentreY();
    int n2x = m_node2.getCentreX();
    int n2y = m_node2.getCentreY();
    
    PVector v1 = new PVector(n1x, n1y);
    PVector v2 = new PVector(n2x, n2y);
    PVector v1v2 = PVector.sub(v2, v1);
    m_chPos = PVector.add(v1, PVector.mult(v1v2, 0.5));    
    
    scale(((float)m_model.m_globalZoom)/100.0);    
    
    // draw line
    stroke(m_strokeCol);
    strokeWeight(2);
    line(v1.x, v1.y, v2.x, v2.y);
    
    // draw control handle
    rectMode(CENTER);
    
    strokeWeight(1);
    fill(m_chBackgroundCol);
    rect(m_chPos.x, m_chPos.y, m_chSize, m_chSize);
    
    //stroke(m_strokeCol);
    noStroke();
    fill(m_strokeCol);
    rect(m_chPos.x, m_chPos.y - (int)(((m_strength * (float)m_chSize) / 4.0)), 
         m_chSize, (int)((m_strength * (float)m_chSize) / 2.0));
    
    noFill();
    strokeWeight(2);
    stroke( mouseOver() ? m_chHighlightCol : m_strokeCol );
    rect(m_chPos.x, m_chPos.y, m_chSize, m_chSize);    
    
    popStyle();
    popMatrix();
  }
  
  
  boolean mouseOver() {
    // is the mouse pointer currently over this link's control handle
    int r = m_chSize / 2;
    int mx = m_node1.scaledMouseX();
    int my = m_node1.scaledMouseY();
    return (mx >= (m_chPos.x - r) &&
            mx <  (m_chPos.x + r) &&
            my >= (m_chPos.y - r) &&
            my <  (m_chPos.y + r));    
  }
  
  
  void mousePressed() {
    if (mouseOver()) {
      if (m_node1.scaledMouseY() <= m_chPos.y) {
        m_strength += 0.2;
      }
      else {
        m_strength -= 0.2;
      }
      m_strength = constrain(m_strength, -1.0, 1.0);
    }
  }
  
}
