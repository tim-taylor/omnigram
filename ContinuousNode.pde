public class ContinuousNode extends Node {

  // Range selector info
  float m_rangeMin;      // min value selectable
  float m_rangeMax;      // max value selectable
  float m_rangeLow;      // current low point selected
  float m_rangeHigh;     // current high point selected
  
 
 
  ContinuousNode(Model model, int id, String name, int filecol, int datacol, float min, float max, int role, ArrayList<Integer> parentIDs) {
    super(model, id, name, filecol, datacol, role, parentIDs);
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
    
    /*
    println("Histogram boundary values for "+m_name);
    for (int i=0; i<m_hgNumBins; i++) {
      println(getHistogramBinLowVal(i));
    }
    */   
    
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

}

