public class OutputDial extends Dial {
  
  OutputDial(int x, int y, int d, DataField datafield, ControlP5 c) {
      super(x,y,d,datafield,c);
      m_widgetBackgroundColor = 0x8056A5EC;
  }
  
  void draw() {
    //super.draw();
    
    int x = m_x + (m_dim/2);
    int y = m_y + (m_dim/2) + (1*(m_dim/10));
    float dmin = ((float)m_min/100.0);
    float dmax = ((float)m_max/100.0);

    fill(m_widgetBackgroundColor);
    rect(m_x, m_y, m_dim, m_dim + (2*(m_dim/10)));
    
    stroke(150);
    noFill();
    ellipse(x, y, m_dim, m_dim);
   
    noStroke();
    fill(m_dialForegroundColor);
    arc(x, y, m_dim, m_dim, (dmin * TWO_PI - HALF_PI), (dmax * TWO_PI - HALF_PI), PIE);
    
    //arc(x, y, m_dim, m_dim, (-HALF_PI - (dmin * TWO_PI)), (-HALF_PI + ((1.0-dmax) * TWO_PI)), PIE);
    //arc(x, y, m_dim, m_dim, (dmax * TWO_PI - HALF_PI), (dmin * TWO_PI - HALF_PI), PIE);     
 
    textFont(m_font, 16);
    fill(255);
    textAlign(CENTER);
    text(m_id, x, m_y + m_dim + (1.8*(m_dim/10)));
  }  
  
  void update(int[] bins, int numrows) {
    int n = bins.length;
    float ang = -HALF_PI;
    float arcang = TWO_PI / (float)n;
    int x = m_x + (m_dim/2);
    int y = m_y + (m_dim/2) + (1*(m_dim/10));
    for (int i=0; i<n; i++) {
      noStroke();
      fill(255-(int)(255.0*((float)bins[i]/(float)numrows)));
      arc(x,y,m_dim,m_dim,ang,ang+arcang);
      ang+=arcang;
    }
  }
  
}
