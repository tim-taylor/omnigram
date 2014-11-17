import java.util.Arrays;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Collections;

public class Model {

  ArrayList<ArrayList<Number>> m_data; // holds the model's data, indexed by m_data.get(sampleID).get(node.m_dataArrayCol)
  ArrayList<String> m_dataLabels;
  
  // general data about the model
  String  m_modelName;
  boolean m_modelHasData;
  boolean m_modelHasDataLabels;
  int     m_modelDataLabelFileCol;  // column in data file corresponding to sample label (1-based)
  String  m_modelDataFilename;
  boolean m_modelLiveRun;
  
  // information about individual nodes
  ArrayList<Node> m_rnodes; // Root nodes
  ArrayList<Node> m_inodes; // Intermediate nodes
  ArrayList<Node> m_lnodes; // Leaf nodes

  ArrayList<Node> m_allNodes;     // contains ALL nodes (the union of rnodes, inodes and lnodes)
  boolean m_allNodesSafe = false; // can we use allNodes or do we have to rebuild it?
  
  // a list of all currently-selected samples
  HashSet<Integer> m_allSelectedSamples; // sample IDs (index of m_data) of all samples currently selected in focal nodes
  
  // information about brush links between nodes
  ArrayList<BrushLink> m_brushLinks;
  boolean m_bNewBrushLinkUnderConstruction;
  Node m_newBrushLinkNode1;
  
  // current mode of interaction
  InteractionMode m_interactionMode = InteractionMode.Unassigned;
  
  // information needed in ShowSamples interaction mode
  boolean m_ssAutoUpdate = true;           // flags whether samples are automatically or manually updated
  int m_ssTimer = 0;                       // a timer to determine when a new sample should be shown
  int m_ssTimerReset = 30;                 // timer value at which a new sample is shown and timer reset occurs
  int m_ssMaxSamplesToDisplay = 5;         // maximum allowed length of m_ssSamplesToDisplay 
  ArrayList<Integer> m_ssSamplesToDisplay; // list of currently displayed SampleIDs, last in list is the most recent
  int m_ssDisplayIdx = 0;                  // index of first current displayed sample in m_ssSamplesToDisplay
  ArrayList<Integer> m_ssSampleHues;       // list of color hues used for displaying samples

  
  // mode of visualisation
  VisualisationMode m_visualisationMode = VisualisationMode.FullAutoHeightAdjust;
  boolean m_visTiled = true; // tiled or continuous?
  
  // global information about appearance
  int   m_globalZoom = 100;
  int   m_nodeDefaultHeight  = 200;
  int   m_nodeDefaultWidth   = 330;
  float m_nodeBinScaleFactor = 5.0; // used to determine the default scale of histogram bins in nodes
  int   m_minInternodeGap = 20;
  int   m_numRootCols = 1;
  int   m_numInterCols = 1;
  int   m_numLeafCols = 1;
  
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
    
    m_modelDataLabelFileCol = general.getInt("label-filecol");
    
    String sLiveRun = general.getString("live");
    m_modelLiveRun = (sLiveRun != null) && (sLiveRun.equals("true"));
    
    XML modelLabel = general.getChild("label");
    if (modelLabel != null) {
      m_modelName = modelLabel.getContent();
    }
    
    XML appearance = xml.getChild("appearance");
    if (appearance != null) {
      m_nodeDefaultHeight = appearance.getInt("node-default-height", m_nodeDefaultHeight);
      m_nodeDefaultWidth = appearance.getInt("node-default-width", m_nodeDefaultWidth);
      m_nodeBinScaleFactor = appearance.getFloat("node-bin-scale-factor", m_nodeBinScaleFactor);
      m_minInternodeGap = appearance.getInt("min-internode-gap", m_minInternodeGap);
      m_numRootCols = appearance.getInt("num-root-cols", m_numRootCols);
      m_numInterCols = appearance.getInt("num-inter-cols", m_numInterCols);
      m_numLeafCols = appearance.getInt("num-leaf-cols", m_numLeafCols);
    }
    
    
    // Now go through each of the nodes specified in the XML file, and create a new Node object of
    // the appropriate subclass (discrete, continuous) for each one
    
    XML nodelist = xml.getChild("nodes"); 
    XML[] nodes = nodelist.getChildren("node");
    
    int rYpos = 20;
    int iYpos = 20;
    int lYpos = 20;   
   
    int nextFreeDataCol = 0; 
    
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
        newnode = new DiscreteNode(this,id,name,filecol,nextFreeDataCol++,imin,imax,parentIDs);
      }
      else if (datatype.equals("continuous")) {
        fmin = xnode.getFloat("min");
        fmax = xnode.getFloat("max");
        newnode = new ContinuousNode(this,id,name,filecol,nextFreeDataCol++,fmin,fmax,parentIDs);
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
    
    // We have now created all of the nodes, now we lay them out on the screen according to any
    // layout specifications given in the XML file (note that later on we tweek the positions
    // once we have loaded in the data, in case any node has had to be resized)
    tileNodes(); 
    
    // Having read all of the model specification file, load in the data if a
    // data file has been specified
    if (m_modelHasData) {
      
      // load data
      load(m_modelDataFilename);
      
      // first pass of initialisation of nodes based upon the data associated with each one
      checkAllNodesSafe();      
      int numNodes = m_allNodes.size(); 
      int[] nodeHeights = new int[numNodes]; 
      int n = 0;
      for (Node node : m_allNodes) {
        node.initialiseHistogram();
        nodeHeights[n++] = node.getH();
      }
      
      // having initialised nodes, rescale them according to the distribution of heights of all nodes
      Arrays.sort(nodeHeights);
      /*
      println("Sorted node heights:");
      for (int i = 0; i < numNodes; i++) {
        println(nodeHeights[i]);
      }
      println("*****");
      */
      int defaultH = m_allNodes.get(0).getDefaultH();
      int refH = nodeHeights[(numNodes*3)/4];
      if (defaultH != refH) {
        float sf = (float)refH / (float)defaultH;
        for (Node node : m_allNodes) {
          node.setH((int)(((float)node.getH())*sf), true);
        }
      }
      
      // The node heights might have been adjusted now that we have added the data, so retile all 
      // nodes to ensure that they are still evenly spaced
      tileNodes();
      
    }
  }
  
  
  void setDefaults() {
    m_data       = new ArrayList<ArrayList<Number>>();
    m_dataLabels = new ArrayList<String>();
    m_rnodes     = new ArrayList<Node>();
    m_inodes     = new ArrayList<Node>();
    m_lnodes     = new ArrayList<Node>();
    m_allNodes   = new ArrayList<Node>();
    m_allNodesSafe = false;
    m_brushLinks = new ArrayList<BrushLink>();
    m_bNewBrushLinkUnderConstruction = false;
    m_allSelectedSamples = new HashSet<Integer>();
    m_ssSamplesToDisplay = new ArrayList<Integer>();
    m_ssSampleHues = new ArrayList<Integer>();
    m_modelDataLabelFileCol = 0;
    m_smallFont  = createFont("Arial", 11, true);
    m_mediumFont = createFont("Arial", 16, true);
    resetSampleHueList();
  }


  void load(String filename) {
    // Having set up the Node objects, read in data from the specified data file (in CSV format) and store it 
    // in the m_data variable
    
    String lines[] = loadStrings(filename);
    
    checkAllNodesSafe();
    int numNodes = m_allNodes.size();
    
    // cycle through each line of data in the date file
    for (int i = 0 ; i < lines.length; i++) {

      boolean dataAdded = false;
      boolean exception = false;
      String label = "";
      
      String[] data = splitTokens(lines[i],",");
      ArrayList<Number> row = new ArrayList<Number>(numNodes);
      for (int n=0; n<numNodes; n++) {
        // just fill the array with 0s for now. We'll replace these with the real data in due course
        row.add(0); 
      }
        
      // read each column of data in this row
      for (int j=0; j < data.length; j++) {
      
        int thisFileCol = j+1;
        
        // work out where to store this data
        for (Node node : m_allNodes) {

          if (node.m_dataFileCol == thisFileCol) {
            
            if (m_modelDataLabelFileCol == thisFileCol) {
              label = data[j];
            }
            else if (node instanceof DiscreteNode) {
              try {
                Integer val = Integer.valueOf(data[j]);
                row.set(node.m_dataArrayCol, val);
                dataAdded = true;
              }
              catch (Exception e) {
                exception = true;
              }
            }  
            else if (node instanceof ContinuousNode) {
              try {
                Float val = Float.valueOf(data[j]);
                row.set(node.m_dataArrayCol, val);
                dataAdded = true;
              }
              catch (Exception e) {
                exception = true;
              }
            }
            else {
              // Don't know what to do with this column of data, so ignore it
            }
          }
        }
      }
      
      // if we successfully read all of the data in the row, then store it!
      if (exception) {
        println("Problem encountered in line "+(i+1)+" of data file. Ignoring data in this line.");
      }
      else if (dataAdded) {  
        m_data.add(row);
        m_dataLabels.add(label);
      }
      
    }

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
  
  
  void tileNodes() {
    // Arrange all nodes to have regular spacing, according to the node heights and the
    // model variables m_numRootCols, m_numInterCols, m_numLeafCols, m_minInternodeGap
    
    int currentColXpos = m_minInternodeGap;
    
    if (!m_rnodes.isEmpty()) {
      currentColXpos = layoutNodeColumns(m_rnodes, m_numRootCols, currentColXpos);   
      currentColXpos += m_minInternodeGap;
    }
    
    if (!m_inodes.isEmpty()) {
      currentColXpos = layoutNodeColumns(m_inodes, m_numInterCols, currentColXpos);   
      currentColXpos += m_minInternodeGap;
    }
    
    if (!m_lnodes.isEmpty()) {
      currentColXpos = layoutNodeColumns(m_lnodes, m_numLeafCols, currentColXpos);   
    }
  }
  
  
  int layoutNodeColumns(ArrayList<Node> nodes, int numCols, int firstColXpos) {
    // Helper method for tileNodes
    // Lay out the nodes passed in into the specified number of columns, beginning the
    // first column at x position firstColXpos. 
    // The method returns the x position to the right of the final column laid out
    // plus a small extra spacing gap.
  
    int currentColXpos = firstColXpos;
    int currentColYpos = m_minInternodeGap;  
    int nodesPerCol = ceil((float)nodes.size() / (float)numCols);
    int nIdx = 0;
    
    for (int c = 0; c < numCols; c++) {
      int maxW = 0; // track the maximum width of a node in the current column
      for (int n = 0; n < nodesPerCol && nIdx < nodes.size(); n++, nIdx++) {
        Node node = nodes.get(nIdx);
        node.setPosition(currentColXpos, currentColYpos);
        currentColYpos += (node.getH() + m_minInternodeGap);
        maxW = max(maxW, node.getW());
      }
      currentColXpos += (maxW + m_minInternodeGap);
      currentColYpos = m_minInternodeGap;
    }
    
    return currentColXpos;
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
      case ShowSamples: {
        m_interactionMode = InteractionMode.ShowSamples;
        resetAllBrushing();
        brushAllNodesOnMultiSelection();
        m_ssTimer = 0;
        m_ssSamplesToDisplay.clear();
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
  
  
  void draw(int globalZoom, int nodeZoom) {
    
    background(m_windowBackgroundColor);
    
    m_globalZoom = globalZoom;
    
    // draw brush links
    for (BrushLink link : m_brushLinks) {
      link.draw();
    }    
    
    // draw nodes
    checkAllNodesSafe();
    for (Node node : m_allNodes) {
      node.draw(nodeZoom);
    }
    
    // calculate menu visibility based upon position of mouse pointer
    if (mouseY < m_menuH) {
      if (mouseY < pmouseY) {
        m_menuVisible = true;
      }
    }
    else {
      m_menuVisible = false;
    }
    
    // update ShowSamples data if required
    if (m_interactionMode == InteractionMode.ShowSamples) {
      updateShowSamples();
    }
    
    // draw menu if required
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
        case ShowSamples:
          mode = "Show Samples";
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
  
  
  void updateShowSamples() {
    // In ShowSample interaction mode, we need to update a timer at each frame, and, at regular intervals,
    // chose a new sample from the currently selected samples to add to the display list. We also need
    // to remove old samples from the end of the list.
    
    if (m_ssAutoUpdate) {
      m_ssTimer++;
      if (m_ssTimer >= m_ssTimerReset) {
        m_ssTimer = 0;  
        if (!m_ssSamplesToDisplay.isEmpty()) {
          m_ssDisplayIdx = (m_ssDisplayIdx+1) % m_ssSamplesToDisplay.size();
        }  
      }
    }
  }

  
  void updateSelectedSampleList() {
    // Update m_allSelectedSamples to contain a list of all Samples currently selected by the range selectors
    // of all focal nodes
    
    m_allSelectedSamples.clear();
    boolean firstNode = true;
    
    checkAllNodesSafe();
    for (Node node : m_allNodes) {
      if (node.hasFocus()) {
        if (firstNode) {
          m_allSelectedSamples.addAll(node.getSamplesInRange());
        }
        else {
          m_allSelectedSamples.retainAll(node.getSamplesInRange()); // keep the intersection of this and previous sets
        }
      }
      firstNode = false;
    }

    // Reset m_ssSamplesToDisplay to be an ArrayList corresponding to the new m_allSelectedSamples HashSet
    m_ssSamplesToDisplay = new ArrayList<Integer>(m_allSelectedSamples);
    Collections.shuffle(m_ssSamplesToDisplay);
    m_ssDisplayIdx = 0;
    
  }
  
  
  void showSamplesAutoSpeedUp() {
    // Decrease the time between displaying new samples in ShowSamples mode when under automatic control
    m_ssAutoUpdate = true;
    if (m_ssTimerReset > 1) {
      m_ssTimerReset--;
    }
  }
  
  
  void showSamplesAutoSlowDown() {
    // Increase the time between displaying new samples in ShowSamples mode when under automatic control
    m_ssAutoUpdate = true;
    if (m_ssTimerReset < 100) {
      m_ssTimerReset++;
    }
  }
  
  
  void showSamplesStepBackward() {
    // Reverse to previous sample in ShowSamples mode when under manual user control
    m_ssAutoUpdate = false;
    m_ssDisplayIdx = (m_ssDisplayIdx <= 0) ? (m_ssSamplesToDisplay.size() - 1) : (m_ssDisplayIdx - 1);
  }

  
  void showSamplesStepForward() {
    // Step forward to the next sample in ShowSamples mode when under manual user control
    m_ssAutoUpdate = false;
    m_ssDisplayIdx = (m_ssDisplayIdx+1) % m_ssSamplesToDisplay.size();
  }
  
  
  void showSamplesDecrementNumSamples() {
    // Decrease the number of samples to be displayed in ShowSamples mode
    if (m_ssMaxSamplesToDisplay > 1) {
      m_ssMaxSamplesToDisplay--;
      resetSampleHueList();
    }
  }
  
  
  void showSamplesIncrementNumSamples() {
    // Increase the number of samples to be displayed in ShowSamples mode
    if ((m_ssMaxSamplesToDisplay < 100) && (m_ssMaxSamplesToDisplay < m_allSelectedSamples.size())) {
      m_ssMaxSamplesToDisplay++;
      resetSampleHueList();
    }
  }
  
  
  int getSampleHue(int sampleDisplayIdx) {
    // returns a Hue value between 0 and 255 to be used for displaying a specific sample in ShowSamples mode,
    // from the current palatte defined in m_ssSampleHues according to the index number passed in
    
    assert(sampleDisplayIdx < m_ssSampleHues.size());
    
    return m_ssSampleHues.get(sampleDisplayIdx);
  }
  
  
  void resetSampleHueList() {
    // Repopulate the m_ssSampleHues list with a palette of hues equally spaced between 0 and 255 according
    // to the number of samples specified in m_ssMaxSamplesToDisplay. Then randomly shuffle the order of
    // the palatte to remove any correlation between sameple order and color
    
    m_ssSampleHues.clear();
    for (int i = 0; i < m_ssMaxSamplesToDisplay; i++) {
      m_ssSampleHues.add((i*255)/m_ssMaxSamplesToDisplay);
    }
    Collections.shuffle(m_ssSampleHues);
  }

  
  void mousePressed() {
    checkAllNodesSafe();
    for (Node node : m_allNodes) {
      node.mousePressed();
    }
    for (BrushLink link : m_brushLinks) {
      link.mousePressed();
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
  
  
  void linkRequest() {
    // The user has pressed 'L' to create a new brush link or to delete an existing link
    // We first look at the case of deleting an existing link, by checking if the mousr pointer is
    // currently over a link's control handle. If so, we delete that link.
    // Otherwise, we check if the mouse pointer is currently over a node, and whether we have already
    // initiated a new brush link creation process (in which case this is the second node of the link
    // rather than the first).
    
    // First check for deletion of an existing link
    for (BrushLink link : m_brushLinks) {
      if (link.mouseOver()) {
        m_brushLinks.remove(link);
        return;
      }
    }    
    
    // Failing that, look for creation of a new link
    checkAllNodesSafe();
    for (Node node : m_allNodes) {
      if (node.mouseOver()) {
        // mouse is over this node, so let's investigate further...
        if (m_bNewBrushLinkUnderConstruction) {
          if (checkProposedBrushLinkValid(node)) {
            BrushLink link = new BrushLink(this, m_newBrushLinkNode1, node, 1.0);
            m_brushLinks.add(link); 
          }
          else {
            // tried to create a link, but it is not valid. Indicate this to the user
            // TO DO...
          }
          m_newBrushLinkNode1.setBrushLinkUnderConstruction(false);
          m_bNewBrushLinkUnderConstruction = false;
        }
        else {
          // this is the first node specified for a new link
          m_bNewBrushLinkUnderConstruction = true;
          m_newBrushLinkNode1 = node;
          node.setBrushLinkUnderConstruction(true);
        }
        break;
      }
    }

  }
  
  
  boolean checkProposedBrushLinkValid(Node node) {   
    // Perform the following checks on whether the proposed creation of a new
    // brush link between m_newBrushLinkNode1 and node is valid:
    // 1. Check that we're not trying to link a node to itself
    // 2. Check that both nodes currently have focus
    // 3. Check that the link doesn't already exist
    // 4. Check that the creation of the link does not create any circular links between nodes
    
    assert(m_bNewBrushLinkUnderConstruction);
        
    boolean valid = true;
    
    // Check 1
    if (node == m_newBrushLinkNode1) {
      return false;
    }
    
    // Check 2
    if (!(node.m_bHasFocus && m_newBrushLinkNode1.m_bHasFocus)) {
      return false;
    }

    // Check 3
    for (BrushLink link : m_brushLinks) {
      if ((link.m_node1 == node && link.m_node2 == m_newBrushLinkNode1) ||
          (link.m_node2 == node && link.m_node1 == m_newBrushLinkNode1)) {
        return false;
      }
    }
    
    // Check 4
    // Actually, we can get away without this at the moment, as we don't propagate linked
    // brushing in any case, so circular links do not cause a problem
    // TO DO... at some point in the future, if and when we implement propagation of linked brushing
    
    return valid;
  }
  
  
  void adjustBrushLinkedNodes(Node node) {
    // This method is called when node's range selector bar has been dragged.
    // Look for any other nodes that are linked to node in m_brushLinks. If any are found, adjust
    // their range selector bars according to the nature of the link.
    
    for (BrushLink link : m_brushLinks) {
      if (link.m_node1 == node) {
        link.m_node2.adjustRangeSelector(node, link.m_strength);
      }
      else if (link.m_node2 == node) {
        link.m_node1.adjustRangeSelector(node, link.m_strength);
      }
    }
  }


}

