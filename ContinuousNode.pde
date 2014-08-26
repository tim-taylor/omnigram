public class ContinuousNode extends Node {
  
  
  // Range selector info
  float m_rangeMin;      // min value selectable on dial
  float m_rangeMax;      // max value selectable on dial
  float m_rangeLow;      // current low point selected on dial
  float m_rangeHigh;     // current high point selected on dial
  
 
 
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
    m_hgBins = new int[m_hgNumBins];
    for (ArrayList<Number> row : m_model.m_data) {
      Number data = row.get(m_dataCol-1);
      int idx = getHistogramIndex(data);
      //println("data="+data+", idx="+idx+", numBins="+m_hgNumBins);
      if (idx==m_hgNumBins) idx--; // TO DO... a temporary hack...
      m_hgBins[idx]++;
    }
    
    initialiseHistogramCommon();
    
    /*
    int barx = 0;
    for (int i=0; i<m_hgNumBins; i++) {
      HistogramBar bar = new HistogramBar(m_hgBins[i], barx, m_hgH);
      m_hgBars.add(bar);
      barx += (bar.numCols() * bar.m_sTileDim) + m_hgMinInterBarGap;
    }
    */   
  }
  
  int getHistogramIndex(Number num) {
    float fNum = num.floatValue();
    //int range = getFullRange();
    //println(iNum+" "+range);
    return (int)(((fNum - m_rangeMin) * m_hgNumBins) / (m_rangeMax - m_rangeMin));
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

