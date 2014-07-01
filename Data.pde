class Data {
  DataField[] m_fields;
  ArrayList<ArrayList<Number>> m_data;
  
  Data() {
    setDefaults();
  }
  
  Data(DataField[] fields) {
    setDefaults();
    m_fields = fields;
    m_data = new ArrayList<ArrayList<Number>>();
  }
  
  void setDefaults() {
    // m_fields = 0;
    m_data = new ArrayList<ArrayList<Number>>();
  }

  /*
  void insert(Number... data) {
    ArrayList<Number> row = new ArrayList<Number>();
    // TODO: check against m_fields? throw exception if not the same??
    for (Number num : data) {
      row.add(num);
    }
    m_data.add(row);
  }
  */
  
  void load(String filename) {
    String lines[] = loadStrings(filename);
    //println("there are " + lines.length + " lines");  
    for (int i = 0 ; i < lines.length; i++) {
      String[] data = splitTokens(lines[i],",");
      //println("data: " + lines[i] + " -> " + data.length + " | " + m_fields);
      if (data.length >= m_fields.length) {
        ArrayList<Number> row = new ArrayList<Number>();
        
        for (int j=0; j < m_fields.length; j++) {
          
          boolean dataAdded = false;
          
          if (m_fields[j].isInt()) {
            Integer val = Integer.valueOf(data[j]);
            row.add(val);
            dataAdded = true;
            if (val < m_fields[j].m_iMin) {
              m_fields[j].m_iMin = val;
            }
            if (val > m_fields[j].m_iMax) {
              m_fields[j].m_iMax = val;
            }
          }
          else if (m_fields[j].isFloat()) {
            Float val = Float.valueOf(data[j]);
            row.add(val);
            dataAdded = true;
            if (val < m_fields[j].m_fMin) {
              m_fields[j].m_fMin = val;
            }
            if (val > m_fields[j].m_fMax) {
              m_fields[j].m_fMax = val;
            }
          }
          else if (m_fields[j].isString()) {
            // ignore string fields for now
          }
          else {
            println("Warning! Unrecognised field type " + m_fields[j].m_type);
          }
          if ((i==0) && dataAdded) { // do this once at start of file
            m_fields[j].m_dataIdx = row.size()-1; // record column index of newly added data
          }
        }
        m_data.add(row);
      }
    }
  }
  
  /*
  int[] getColMinMax(int col) {
    int[] minmax = new int[2];
    
    if (col < 0 || col > m_fields.length) {
      println("Something is very wrong in getColMinMax!");
      return minmax;
    }
    if (m_fields[col]... //is col column in original data or in m_data? need to check if is int
    

    minmax[0] =  2147483647; // min
    minmax[1] = -2147483648; // max
    for (ArrayList<Number> row : m_data) {
      if (row.get(col).toInt() < minmax[0]) {
        minmax[0] = row.get(col);
      }
      else if (row.get(col) > minmax[1]) {
        minmax[1] = row.get(col);
      }
    }
    if (minmax[0] > minmax[1]) {
      // this would only happen if no data was processed
      minmax[0] = minmax[1];
    }
    return minmax;
  }
  */
  
  void normalise() {
    for (int i=0; i<m_fields.length; i++) {
      println(m_fields[i].toString());
    }
  }
  
  ArrayList<Number> getRawData(DataField field) {
    return m_data.get(field.m_dataIdx);
  }
  
  
 
}

