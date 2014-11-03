public class ContinuousNode extends Node {

  // Range selector info
  float m_rangeMin;      // min value selectable
  float m_rangeMax;      // max value selectable
  float m_rangeLow;      // current low point selected
  float m_rangeHigh;     // current high point selected
  
 
 
  ContinuousNode(Model model, int id, String name, int filecol, float min, float max, ArrayList<Integer> parentIDs) {
    super(model, id, name, filecol, parentIDs);
    m_rangeMin = m_rangeLow = min;
    m_rangeMax = m_rangeHigh = max;
  }  
  
  
  int getSelectedRange() {
    return (int)(m_rangeHigh - m_rangeLow);
  }


  int getFullRange() {
    return (int)(m_rangeMax - m_rangeMin);
  }
  
  
  void initialiseHistogram() {
    m_hgNumBins = m_sMaxBins;
    
    println("Histogram boundary values for "+m_name);
    for (int i=0; i<m_hgNumBins; i++) {
      println(getHistogramBinLowVal(i));
    }    
    
    initialiseHistogramCommon(); 
  }
  
  
  int getHistogramIndex(Number num) {
    // return the index in node.m_hgBins corresponding to the data value passed in (i.e. which
    // bin does that value belong to)
    float fNum = num.floatValue();
    int idx = (int)(((fNum - m_rangeMin) * m_hgNumBins) / (m_rangeMax - m_rangeMin));
    if (idx==m_hgNumBins) idx--; // not very elegant, but it works
    return idx;
  }
  
  
  Number getHistogramBinLowVal(int bin) {
    return new Float((((bin*(m_rangeMax - m_rangeMin))/m_hgNumBins) + m_rangeMin));
  }
  
  
  Number getHistogramBinHighVal(int bin) {
    Float high = new Float((Float)getHistogramBinLowVal(bin+1));
    return (high);
  }  
  
  
  /*

  final int m_numBins = 20;  // number of partitions of output dial display
  int[] m_dataBins;          // records color value for each partition (each bin entry in range 0-255)
  
  OutputDial(int x, int y, int d, Data data, DataField datafield, ControlP5 c) {
      super(x,y,d,data,datafield,c);
      m_widgetBackgroundColor = 0xFF56A5EC;
      m_dataBins = new int[m_numBins];
  }
  
  void draw() {
    super.draw();
    
    float ang = -HALF_PI;
    float arcang = TWO_PI / (float)m_numBins;
    int x = m_x + (m_dim/2);
    int y = m_y + (m_dim/2) + (1*(m_dim/10));
    for (int i=0; i<m_numBins; i++) {
      noStroke();
      fill(255 - m_dataBins[i]);
      arc(x,y,m_dim,m_dim,ang,ang+arcang);
      ang+=arcang;
    }
    
    x = m_x + (int)(1.2 * (float)m_dim);
    y = m_y + (1*(m_dim/10));
    int w  = 400;
    int h = m_dim;
    rect(x,y,w,h);
    int bw = w/m_numBins;
    int bx = x;
    int mag = 4;
    fill(100,0,0);
    for (int i=0; i<m_numBins; i++) {
      rect(bx, y+h, bw, -(m_dataBins[i]*h*mag/255));
      bx += bw;
    }
  }  
  
  void update(int[] bins, int numrows) {
    if (bins.length != m_numBins) {
      println("Bin length mismatch!");
      exit();
    }
    for (int i=0; i<m_numBins; i++) {
      m_dataBins[i] = (int)(255.0*((float)bins[i]/(float)numrows));
    }
  }
  
  void connect(InputDial idial) {
    if (!isConnectedInput(idial)) {
      m_connectedInputDials.add(idial);
      idial.connect(this);
    }
    else {
      // do nothing
    }
  }
  
  void disconnect(InputDial idial) {
    if (!isConnectedInput(idial)) {
      // do nothing
    }
    else {
      m_connectedInputDials.remove(idial);
      idial.disconnect(this);
    }
  }
  */
  
}

