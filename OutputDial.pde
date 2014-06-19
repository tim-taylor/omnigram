public class OutputDial extends Dial {
  
  OutputDial(int x, int y, int d, DataField datafield, ControlP5 c) {
      super(x,y,d,datafield,c);
      m_widgetBackgroundColor = 0x8056A5EC;
  }
  
  void draw() {
    super.draw();
    /* 
    noStroke();
    fill(m_dialForegroundColor);
    arc(x, y, m_dim, m_dim, (dmin * TWO_PI - HALF_PI), (dmax * TWO_PI - HALF_PI), PIE);
    */
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
  
  void connect(InputDial idial) {
    if (!isConnectedInput(idial)) {
      m_connectedInputDials.add(idial);
      idial.connect(this);
      println("Bingo!");
    }
    else {
      println("Yawn, already done!");
    }
  }  
  
}
