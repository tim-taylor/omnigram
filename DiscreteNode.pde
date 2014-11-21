public class DiscreteNode extends Node {
  
  // Range selector info
  int m_rangeMin;      // min value selectable
  int m_rangeMax;      // max value selectable
  int m_rangeLow;      // current low point selected
  int m_rangeHigh;     // current high point selected  
  
  
  DiscreteNode(Model model, int id, String name, int filecol, int datacol, int min, int max, int role, ArrayList<Integer> parentIDs) {
    super(model, id, name, filecol, datacol, role, parentIDs);
    m_rangeMin = m_rangeLow = min;
    m_rangeMax = m_rangeHigh = max;
  }

  
  int getSelectedRange() {
    return m_rangeHigh - m_rangeLow + 1;
  }


  int getFullRange() {
    return m_rangeMax - m_rangeMin + 1;
  }
  
  
  void initialiseHistogram() {
    int dataRange = getFullRange();
    m_hgNumBins = (dataRange > m_sMaxBins) ? m_sMaxBins : dataRange;
    
    println("Histogram boundary values for "+m_name);
    for (int i=0; i<m_hgNumBins; i++) {
      println(getHistogramBinLowVal(i));
    }
    
    initialiseHistogramCommon();
  }
  
  
  int getHistogramIndex(Number num) {
    // return the index in node.m_hgBins corresponding to the data value passed in (i.e. which
    // bin does that value belong to)
    int iNum = num.intValue();
    return (((iNum - m_rangeMin) * m_hgNumBins) / (m_rangeMax - m_rangeMin + 1));
  }
  
  
  Number getHistogramBinLowVal(int bin) {
    return new Integer((((bin*(m_rangeMax - m_rangeMin + 1))/m_hgNumBins) + m_rangeMin));
  }
  
  
  Number getHistogramBinHighVal(int bin) {
    Integer high = new Integer((Integer)getHistogramBinLowVal(bin+1));
    return (high - 1);
  }

}

