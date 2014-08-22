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
  
  Data(String configXMLfilename, ArrayList<Node> rnodes, ArrayList<Node> inodes, ArrayList<Node> lnodes) {
  
    XML xml = loadXML(configXMLfilename);    
 
    XML general = xml.getChild("general");
    
    String dataFilename = general.getString("data");
    boolean hasData = (dataFilename != null);

    String sDataHasLabels = general.getString("has-labels");
    boolean dataHasLabels = (sDataHasLabels != null) && (sDataHasLabels.equals("true"));
    
    String sLiveRun = general.getString("live");
    boolean liveRun = (sLiveRun != null) && (sLiveRun.equals("true"));
    
    XML modelLabel = general.getChild("label");
    String modelName;
    if (modelLabel != null) {
      modelName = modelLabel.getContent();
    }
    
    //println(general.toString());  
    
    XML nodelist = xml.getChild("nodes"); 
    XML[] nodes = nodelist.getChildren("node");
    
    for (int i=0; i < nodes.length; i++) {
      int imin, imax;
      float fmin, fmax;
      ArrayList<Integer> parentIDs = new ArrayList<Integer>();
      Node newnode = null;
      
      XML xnode = nodes[i];
      
      int id = xnode.getInt("id");
      int filecol = xnode.getInt("filecol");
      String role = xnode.getString("role"); // this determines whether node is placed into rnodes, inodes or lnodes

      XML label = xnode.getChild("label");
      String name = label.getContent();

      XML parentlist = xnode.getChild("parents");
      if (parentlist != null) {
        XML[] parents = parentlist.getChildren("parent");
        for (int j=0; j < parents.length; j++) {
          int pid = parents[j].getInt("id");
          parentIDs.add(pid);
        }
      }
      
      String datatype = xnode.getString("datatype");
      if (datatype.equals("discrete")) {
        imin = xnode.getInt("min");
        imax = xnode.getInt("max");
        newnode = new DiscreteNode(id,name,filecol,imin,imax,parentIDs);
      }
      else if (datatype.equals("continuous")) {
        fmin = xnode.getFloat("min");
        fmax = xnode.getFloat("max");
        newnode = new ContinuousNode(id,name,filecol,fmin,fmax,parentIDs);
      }
      else {
        println("Oops! Found a node of unknown type '" + datatype + "' in file " + configXMLfilename);
        exit();
      }
      
      if (role.equals("root")) {
        rnodes.add(newnode);
      }
      else if (role.equals("inter")) {
        inodes.add(newnode);
      }
      else if (role.equals("leaf")) {
        lnodes.add(newnode);
      }
      else {
        println("Oops! Found a node with unknown role '" + role + "' in file " + configXMLfilename);
        exit();
      }

    }
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

