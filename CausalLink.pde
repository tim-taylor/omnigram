public class CausalLink {
  
  Model m_model;
  Node  m_nodeFrom;
  Node  m_nodeTo;
  
  int     m_chSizeBy2;  // defines the size of the control handle
  PVector m_chPos;      // current position of the link's control handle
  float   m_chAngle;    // current angle of the link's control handle
  
  color m_strokeCol;
  color m_chHighlightCol;
  color m_chBackgroundCol;

  
  CausalLink(Model model, Node nodeFrom, Node nodeTo) {
    m_model = model;
    m_nodeFrom = nodeFrom;
    m_nodeTo = nodeTo;
    m_chPos = new PVector();
    m_chSizeBy2 = 10;
    m_chAngle = 0;
    m_strokeCol = #000000;
    m_chHighlightCol = #FF0000;
    m_chBackgroundCol = #FFFFFF;
  }
  
  
  void draw() {
    
    pushMatrix();
    pushStyle();
    
    int nFx = m_nodeFrom.getCentreX();
    int nFy = m_nodeFrom.getCentreY();
    int nTx = m_nodeTo.getCentreX();
    int nTy = m_nodeTo.getCentreY();
    
    PVector vF = new PVector(nFx, nFy);
    PVector vT = new PVector(nTx, nTy);
    PVector vFvT = PVector.sub(vT, vF);
    m_chPos = PVector.add(vF, PVector.mult(vFvT, 0.5));    
    
    scale(((float)m_model.m_globalZoom)/100.0);    
    
    // draw line
    stroke(m_strokeCol);
    strokeWeight(2);
    line(vF.x, vF.y, vT.x, vT.y);
       
    // draw control handle (an arrow pointing from nodeFrom to nodeTo)
    m_chAngle = atan2(vFvT.x, vFvT.y);
    translate(m_chPos.x, m_chPos.y);
    rotate(PI-m_chAngle);
    fill(m_chBackgroundCol);
    triangle(0,-m_chSizeBy2, m_chSizeBy2,m_chSizeBy2, -m_chSizeBy2,m_chSizeBy2);
    // draw outline of handle according to whether mouse is over it
    noFill();
    strokeWeight(2);
    stroke( mouseOver() ? m_chHighlightCol : m_strokeCol );
    triangle(0,-m_chSizeBy2, m_chSizeBy2,m_chSizeBy2, -m_chSizeBy2,m_chSizeBy2);    
    
    popStyle();
    popMatrix();
  }
  
  
  boolean mouseOver() {
    // is the mouse pointer currently over this link's control handle
    int mx = m_nodeFrom.scaledMouseX();
    int my = m_nodeFrom.scaledMouseY();
    return (dist(mx,my, m_chPos.x,m_chPos.y) <= m_chSizeBy2);   
  }
  
  
  void toggleDirection() {
    // reverse the direction of the to/from nodes 
    Node tmp = m_nodeFrom;
    m_nodeFrom = m_nodeTo;
    m_nodeTo = tmp;
  }
  
}
