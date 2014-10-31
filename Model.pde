public class Model {

  ArrayList<ArrayList<Number>> m_data; // holds the model's data, indexed by m_data.get(sampleID).get(node.m_dataArrayCol)
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
  
  // mode of visualisation
  VisualisationMode m_visualisationMode = VisualisationMode.FullAutoHeightAdjust;
  boolean m_visTiled = true; // tiled or continuous?
  
  // global information about appearance
  int m_globalZoom = 100;
  
  // global UI items
  int     m_menuH = 50;
  boolean m_menuVisible = false;
  color   m_menuBackgroundColor = 0xFF000000;
  color   m_menuTextColor = 0xFFEEEE30;
  color   m_windowBackgroundColor = 0xFF808080;
  PFont   m_smallFont;
  PFont   m_mediumFont;
  int     m_defaultInterNodeGapV = 20;

  
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
      tileNodesV();
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
    m_smallFont = createFont("Arial", 11, true);
    m_mediumFont = createFont("Arial", 16, true);
  }


  void load(String filename) {
    String lines[] = loadStrings(filename);
    
    checkAllNodesSafe();
    int numNodes = m_allNodes.size();
    boolean[] colDiscrete = new boolean[numNodes];
    for (Node node : m_allNodes) {
      assert(node.m_dataArrayCol < numNodes); // TODO: for now, assuming all cols have associated nodes, and cols labeled from 1 up
      colDiscrete[node.m_dataArrayCol] = (node instanceof DiscreteNode);
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
    // in SingleNodeBrushing mode, set the indicated node to be the focus node, and
    // remove focus from all other nodes
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
  
  
  void toggleMultiFocus(int nodeIdx) {
    // in MultiNodeBrushing mode, toggle the focus flag of the indicated node
    checkAllNodesSafe();
    for (Node node : m_allNodes) {
      if (node.m_id == nodeIdx) {
        node.m_bHasFocus = !node.m_bHasFocus;
        if (!node.m_bHasFocus) {
          node.setFullRange();
        }
        break;
      }
    }
  }  
  
  
  void setInteractionMode(InteractionMode mode) {
    switch (mode) {
      case SingleNodeBrushing: {
        m_interactionMode = InteractionMode.SingleNodeBrushing;
        resetAllBrushing();
        checkAllNodesSafe();
        // now ensure that at most one Node has the focus
        for (Node node : m_allNodes) {
          if (node.m_bHasFocus) {
            setSingleFocus(node.m_id);
            brushAllNodesOnOneSelection(node);
            redraw();
            break;
          }
        }
        break;  
      }
      case MultiNodeBrushing: {
        m_interactionMode = InteractionMode.MultiNodeBrushing;
        resetAllBrushing();
        brushAllNodesOnMultiSelection();
        redraw();
        break;
      }
      case Unassigned:
      default: {
        println("Unexpected Interaction Mode in Model.setInteractionMode!");
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
  
  
  void brushAllNodesOnMultiSelection() {
    
    // First build up a list of all nodes that currently have focus, and a list of all other nodes
    
    ArrayList<Node> focalNodes = new ArrayList<Node>();
    ArrayList<Node> otherNodes = new ArrayList<Node>();
    
    for (Node node : m_allNodes) {
      if (node.m_bHasFocus) {
        focalNodes.add(node);
      }
      else {
        otherNodes.add(node);
      }
    }
    
    for (Node onode : otherNodes) {
      onode.resetBrushing();
    }

    // Now go through every sample in the data and check whether it lies within the selected range of values
    // for each of the focal nodes (and if not, how many focal nodes it misses). Then brush the sample
    // in all the other nodes according to the number of misses.

    int numBrushes = m_allNodes.get(0).m_hgNumBrushes;
    int numSamplesAll = m_data.size();
    
    for (int i=0; i<numSamplesAll; i++) {
      int numMisses = 0;
      
      for (Node fnode : focalNodes) {
        if (!(fnode.sampleSelected(i))) {
          numMisses++;
        }
      }
      
      if (numMisses < numBrushes) {
        for (Node onode : otherNodes) {
          onode.brushSampleAdd(i, numMisses);
        }
      }
    }
    
  }  
  
  
  void resetAllBrushing() {
    for (Node node : m_allNodes) {
      node.resetBrushing();
    }    
  }
  
  
  void tileNodesV() {
    // rearrange all nodes to have a constant vertical spacing between nodes
    tileNodesV(m_rnodes);
    tileNodesV(m_inodes);
    tileNodesV(m_lnodes);
  }
  
  
  void tileNodesV(ArrayList<Node> nodes) {
    // rearrange the given nodes to have a constant vertical spacing between nodes
    int[] startpos = new int[nodes.size()];
    for (int i=0; i<nodes.size(); i++) {
      startpos[i] = nodes.get(i).m_y;
    }
    startpos = sort(startpos);
    int curY = m_defaultInterNodeGapV;
    int deltaY = m_defaultInterNodeGapV;
    for (int i=0; i<nodes.size(); i++) {
      Node node = getNodeFromY(nodes, startpos[i]);
      node.setY(curY);
      curY += (node.getH() + deltaY);
    }
  }
  
  
  Node getNodeFromY(ArrayList<Node> nodes, int y) {
    // Look for the node which has a Y position of y from the list of nodes passed in.
    // If found, return that node, else return the first node in the list
    assert(!nodes.isEmpty());
    for (Node node : nodes) {
      if (node.m_y == y) {
        return node;
      }
    }
    return nodes.get(0);
  }
  
  
  
  void draw(int globalZoom, int nodeZoom) {
    
    background(m_windowBackgroundColor);
    
    m_globalZoom = globalZoom;
    
    checkAllNodesSafe();
    for (Node node : m_allNodes) {
      node.draw(nodeZoom);
    }
    
    if (mouseY < m_menuH) {
      if (mouseY < pmouseY) {
        m_menuVisible = true;
      }
    }
    else {
      m_menuVisible = false;
    }
    
    if (m_menuVisible) {
      fill(m_menuBackgroundColor);
      rect(0, 0, width, m_menuH);
      String mode;
      switch (m_interactionMode) {
        case SingleNodeBrushing:
          mode = "Single Node";
          break;
        case MultiNodeBrushing:
          mode = "Multi Node";
          break;
        default:
          mode = "(no mode set)";
      }
      textFont(m_mediumFont, 16);
      textAlign(LEFT);
      fill(m_menuTextColor);
      text(mode, 30, 30);
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

