public class Model {

  ArrayList<ArrayList<Number>> m_data;
  ArrayList<String> m_dataLabels;
  
  // general data about the model
  String  m_modelName;
  boolean m_modelHasData;
  boolean m_modelHasDataLabels;
  int     m_modelDataLabelCol;
  String  m_modelDataFilename;
  boolean m_modelLiveRun;
  
  // information about individual nodes
  ArrayList<Node> m_rnodes; // Root nodes
  ArrayList<Node> m_inodes; // Intermediate nodes
  ArrayList<Node> m_lnodes; // Leaf nodes

  ArrayList<Node> m_allNodes;     // contains ALL nodes (the union of rnodes, inodes and lnodes)
  boolean m_allNodesSafe = false; // can we use allNodes or do we have to rebuild it?
  
  // current mode of interaction
  InteractionMode m_interactionMode = InteractionMode.Unassigned;
  
  //////////// METHODS //////////////////
  
  Model(String configXMLfilename) {
    
    setDefaults();
     
    XML xml = loadXML(configXMLfilename);    
 
    XML general = xml.getChild("general");
    
    m_modelDataFilename = general.getString("data");
    m_modelHasData = (m_modelDataFilename != null);

    String sDataHasLabels = general.getString("has-labels");
    m_modelHasDataLabels = (sDataHasLabels != null) && (sDataHasLabels.equals("true"));
    
    m_modelDataLabelCol = general.getInt("label-filecol");
    
    String sLiveRun = general.getString("live");
    m_modelLiveRun = (sLiveRun != null) && (sLiveRun.equals("true"));
    
    XML modelLabel = general.getChild("label");
    if (modelLabel != null) {
      m_modelName = modelLabel.getContent();
    }
    
    XML nodelist = xml.getChild("nodes"); 
    XML[] nodes = nodelist.getChildren("node");
    
    int rYpos = 20;
    int iYpos = 20;
    int lYpos = 20;    
    
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
        newnode = new DiscreteNode(this,id,name,filecol,imin,imax,parentIDs);
      }
      else if (datatype.equals("continuous")) {
        fmin = xnode.getFloat("min");
        fmax = xnode.getFloat("max");
        newnode = new ContinuousNode(this,id,name,filecol,fmin,fmax,parentIDs);
      }
      else {
        println("Oops! Found a node of unknown type '" + datatype + "' in file " + configXMLfilename);
        exit();
      }
           
      if (role.equals("root")) {
        m_rnodes.add(newnode);
        newnode.setPosition(100, rYpos);
        rYpos += 230;
        println("Adding new rnode " + newnode.m_name);
      }
      else if (role.equals("inter")) {
        m_inodes.add(newnode);
        newnode.setPosition(500, iYpos);
        iYpos += 230;
        println("Adding new inode " + newnode.m_name);
      }
      else if (role.equals("leaf")) {
        m_lnodes.add(newnode);
        newnode.setPosition(900, lYpos);
        lYpos += 230;
        println("Adding new lnode " + newnode.m_name);
      }
      else {
        println("Oops! Found a node with unknown role '" + role + "' in file " + configXMLfilename);
        exit();
      }
    }
    
    // Having read all of the model specification file, load in the data if a
    // data file has been specified
    if (m_modelHasData) {
      load(m_modelDataFilename);
      checkAllNodesSafe();
      for (Node node : m_allNodes) {
        node.initialiseHistogram();
      }
    }
  }
  
  
  void setDefaults() {
    // m_fields = 0;
    m_data = new ArrayList<ArrayList<Number>>();
    m_dataLabels = new ArrayList<String>();
    m_rnodes   = new ArrayList<Node>();
    m_inodes   = new ArrayList<Node>();
    m_lnodes   = new ArrayList<Node>();
    m_allNodes = new ArrayList<Node>();
    m_allNodesSafe = false;
    m_modelDataLabelCol = 0;      
  }


  void load(String filename) {
    String lines[] = loadStrings(filename);
    
    checkAllNodesSafe();
    int numNodes = m_allNodes.size();
    boolean[] colDiscrete = new boolean[numNodes];
    for (Node node : m_allNodes) {
      assert(node.m_dataCol <= numNodes); // TODO: for now, assuming all cols have associated nodes, and cols labeled from 1 up
      colDiscrete[node.m_dataCol-1] = (node instanceof DiscreteNode);
    }
    
    for (int i = 0 ; i < lines.length; i++) {
      String[] data = splitTokens(lines[i],",");
      ArrayList<Number> row = new ArrayList<Number>();
        
      for (int j=0; j < data.length /*m_fields.length*/; j++) {
        boolean dataAdded = false;
         
        if (j == m_modelDataLabelCol-1) {
          m_dataLabels.add(data[j]); // TO DO: we are assuming here that every row has a label, so data and labels remain in sync
        }
        else if (colDiscrete[j]) {
          Integer val = Integer.valueOf(data[j]);
          row.add(val);
          dataAdded = true;
        }
        else /*if (m_fields[j].isFloat())*/ {
          Float val = Float.valueOf(data[j]);
          row.add(val);
          dataAdded = true;
        }
      }
      m_data.add(row);
    }
    
    /*
    for (int i=0; i<m_data.size(); i++) {
      println(m_data.get(i).get(1));
    }
    */
  }

  
  void checkAllNodesSafe() {
    if (!m_allNodesSafe) {
      m_allNodes.clear();
      m_allNodes.addAll(m_rnodes);
      m_allNodes.addAll(m_inodes);
      m_allNodes.addAll(m_lnodes);
      m_allNodesSafe = true;
    }
  }
  
  
  void setSingleFocus(int nodeIdx) {
    checkAllNodesSafe();
    for (Node node : m_allNodes) {
      if (node.m_id == nodeIdx) {
        node.m_bHasFocus = true;
      }
      else {
        node.m_bHasFocus = false;
        node.setFullRange();
      }
    }
  }
  
  
  void setInteractionMode(InteractionMode mode) {
    switch (mode) {
      case SingleNodeBrushing: {
        m_interactionMode = InteractionMode.SingleNodeBrushing;
        resetAllBrushing();
        break;  
      }
      case Unassigned:
      default: {
        // TO DO...
      }
    }
  }
  
  
  void brushAllNodesOnOneSelection(Node focalNode) {
    // first gather a list of selected samples
    ArrayList<Integer> selectedSampleIDs = focalNode.getSelectedSampleIDs();
    for (Node node : m_allNodes) {
      if (node != focalNode) {
        node.brushSamples(selectedSampleIDs);
      }
    }
  }
  
  
  void resetAllBrushing() {
    for (Node node : m_allNodes) {
      node.resetBrushing();
    }    
  }
  
  
  void draw(int globalZoom, int nodeZoom) {
    checkAllNodesSafe();
    for (Node node : m_allNodes) {
      node.draw(globalZoom, nodeZoom);
    }
  }
  
  
  void mousePressed() {
    checkAllNodesSafe();
    for (Node node : m_allNodes) {
      node.mousePressed();
    }      
  }
 
 
  void mouseReleased() {
    checkAllNodesSafe();
    for (Node node : m_allNodes) {
      node.mouseReleased();
    }      
  }
  
  
  void mouseDragged() {
    checkAllNodesSafe();
    for (Node node : m_allNodes) {
      node.mouseDragged();
    }     
  }
  
  
  // OLD STUFF.....

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
  
  /*
  void normalise() {
    for (int i=0; i<m_fields.length; i++) {
      println(m_fields[i].toString());
    }
  }
  */
    
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
  
  /*
  ArrayList<Number> getRawData(DataField field) {
    return m_data.get(field.m_dataIdx);
  }
  */  
}

