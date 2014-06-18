class Data {
  //int m_fields;
  DataField[] m_fields;
  ArrayList<ArrayList<Number>> m_data;
  
  Data() {
    setDefaults();
  }
  
  /*
  Data(int fields) {
    setDefaults();
    //m_fields = fields;
    m_data = new ArrayList<ArrayList<Number>>();
  }
  */
  
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
          if (m_fields[j].isInt()) 
            row.add(Integer.valueOf(data[j]));
          else if (m_fields[j].isFloat())
            row.add(Float.valueOf(data[j]));
          else {
            // not int or float... so do nothing?
          }
        }
        m_data.add(row);
      }
    }
    //println("hello! " + m_data.get(0).get(0));
  }
}

