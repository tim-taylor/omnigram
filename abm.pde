/**
* ABM Interactive Visualization Prototype
*
* Tim Taylor
* Monash University
*
* version: 0.1
* date: 16 June 2014
*
*/

import controlP5.*;

color windowBackgroundColor = 0xFF909090;

ControlP5 cp5;
Data data;
ArrayList<InputDial> idials;  // Dials for inputs
ArrayList<OutputDial> odials; // Dials for outputs

void setup() {
  size(1250,750);
  smooth();
  noStroke();
  
  /*
  println("display: " + displayWidth + "x" + displayHeight);
  println("toolkit: " + java.awt.Toolkit.getDefaultToolkit().getScreenResolution() + " dpi");
  */
  
  cp5 = new ControlP5(this);
  
  DataField[] datafields = {
    new DataField("mpg", 'F', true),
    new DataField("cylinders", 'I'),
    new DataField("displacement", 'F'),
    new DataField("horsepower", 'F'),
    new DataField("weight", 'F'),
    new DataField("acceleration", 'F'),
    new DataField("model year", 'I'),
    new DataField("origin", 'I'),
    new DataField("car name", 'S', false, true)
  };
  
  idials = new ArrayList<InputDial>();
  odials = new ArrayList<OutputDial>();
  
  int inputs=0, outputs=0;
  for (int i=0; i<datafields.length; i++) {
    if (datafields[i].isActiveInput()) {
      InputDial dial = new InputDial(20+inputs*175, 250, 140, datafields[i], cp5);
      idials.add(dial);
      inputs++;
    }
    else if (datafields[i].isTarget()) {
      OutputDial dial = new OutputDial(100+outputs*175, 50, 140, datafields[i], cp5);
      odials.add(dial);
      outputs++;
    }
  }
  
  data = new Data(datafields);
  data.load("auto-mpg.data");
  
  data.normalise();
}

void draw() {
  background(windowBackgroundColor);
  for (Dial dial : idials) {
    dial.draw();
  }
  for (Dial dial : odials) {
    dial.draw();
  }
  updateOutputDials();
}

void updateOutputDials() {
  // this method considers all current input dials and constraints between them,
  // and calculates the corresponding state of all output dials
  
  OutputDial od1 = odials.get(0);  // TODO... just looking at first output for now
  int od1dIdx = od1.m_datafield.m_dataIdx;
  int c=0;
  int numOBins = 20;
  int[] obins = new int[numOBins];
  
  ArrayList<InputDial> od1connectedids = new ArrayList<InputDial>();
  for (InputDial idial : idials) {
    if (idial.isConnected(od1, idial)) {
      od1connectedids.add(idial);
    }
  }
  
  // Go through each row of data, and check if connected idial values lie in current range.
  // If so, out output value to relevant obin
  for (ArrayList<Number> row : data.m_data) {
    boolean allInRange = false;
    
    for (InputDial cidial : od1connectedids) {
      boolean inRange = false;
      
      int idIdx = cidial.m_datafield.m_dataIdx;
      
      if (cidial.m_datafield.isInt()) {
        int val = row.get(idIdx).intValue();
        //println(id1.m_datafield.m_iMin + " " + val + " " + id1.m_datafield.m_iMax);
        float dnorm = 100.0 * ((float)(val - cidial.m_datafield.m_iMin) / (float)(cidial.m_datafield.m_iMax - cidial.m_datafield.m_iMin));
        if (cidial.m_min <= dnorm && dnorm <= cidial.m_max) {
          inRange = true;
        }
      }
      else if (cidial.m_datafield.isFloat()) {
        float val = row.get(idIdx).floatValue();
        float dnorm = 100.0 * ((float)(val - cidial.m_datafield.m_fMin) / (float)(cidial.m_datafield.m_fMax - cidial.m_datafield.m_fMin));
        if (cidial.m_min <= dnorm && dnorm <= cidial.m_max) {
          inRange = true;
        }        
      }
      
      if (inRange) {
        allInRange = true;
      }
      else {
        allInRange = false;
        break;
      }
    }
    
    if (allInRange) {
      c++;
      float oVal = row.get(od1dIdx).floatValue(); // TODO: assuming float o/p value for now (CAREFUL! use m_fMin not m_iMin...)
      int obin = (int)((float)numOBins * ((float)(oVal - od1.m_datafield.m_fMin) / (float)(od1.m_datafield.m_fMax - od1.m_datafield.m_fMin)));
      obin = constrain(obin, 0, numOBins-1);
      obins[obin]++;
      //println(od1.m_datafield.m_fMin + " - " + oVal + " - " + od1.m_datafield.m_fMax + " => " + obin);
    }
  }
  
  // update output dial with new bins
  od1.update(obins, data.m_data.size());
}

void controlEvent(ControlEvent theControlEvent) {
  for (Dial dial : idials) {
    dial.controlEvent(theControlEvent);
  }
  for (Dial dial : odials) {
    dial.controlEvent(theControlEvent);
  }  
}

void mousePressed() {
  for (Dial dial : idials) {
    dial.mousePressed(idials, odials, true);
  }
  for (Dial dial : odials) {
    dial.mousePressed(idials, odials, false);
  }  
}

void mouseReleased() {
  for (Dial dial : idials) {
    dial.mouseReleased();
  }
  for (Dial dial : odials) {
    dial.mouseReleased();
  }
}

void mouseDragged() {
  for (Dial dial : idials) {
    dial.mouseDragged();
  }
  for (Dial dial : odials) {
    dial.mouseDragged();
  }  
}

void keyPressed() {
  if (key == 'c') {
    connectFocalDials();
  }
}

void connectFocalDials() {
  ArrayList<InputDial> focalinputs = new ArrayList<InputDial>();
  ArrayList<OutputDial> focaloutputs = new ArrayList<OutputDial>();
  for (InputDial idial : idials) {
    if (idial.hasFocus()) {
      focalinputs.add(idial);
    }
  }
  for (OutputDial odial : odials) {
    if (odial.hasFocus()) {
      focaloutputs.add(odial);
    }
  }
  if (focalinputs.size() > 0 && focaloutputs.size() > 0) {
    // TODO...
    // for the time being, we are only connecting the first focal input with the first focal output 
    if (focalinputs.get(0).isDirectlyConnected(focaloutputs.get(0))) {
      focalinputs.get(0).disconnect(focaloutputs.get(0));
    }
    else {
      focalinputs.get(0).connect(focaloutputs.get(0));
    }
    //println("We're in business!");
  }
  /*
  else {
    println("Close, but no cigar!");
  }
  */
}
