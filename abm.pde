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
//float displayScale = 1.2;
int dialSize = 130; //160;

ControlP5 cp5;
Data data;
ArrayList<InputDial> idials;  // Dials for inputs
ArrayList<OutputDial> odials; // Dials for outputs

void setup() {
  //size(1250,750);
  size((displayWidth*90)/100, (displayHeight*90)/100);
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
  
  
  data = new Data(datafields);
  data.load("auto-mpg.data");
  
  data.normalise();

  idials = new ArrayList<InputDial>();
  odials = new ArrayList<OutputDial>();
  
  int inputs=0, outputs=0;
  for (int i=0; i<datafields.length; i++) {
    if (datafields[i].isActiveInput()) {
      InputDial dial = new InputDial(20+inputs*200, 170+(80*i), dialSize, data, datafields[i], cp5);
      dial.setRangeAndTicksFromData();
      if (true /*inputs==0*/) {
        dial.m_bShowExtra = true;
      }
      idials.add(dial);
      inputs++;
    }
    else if (datafields[i].isTarget()) {
      OutputDial dial = new OutputDial(400+outputs*175, 30, dialSize, data, datafields[i], cp5);
      dial.setRangeAndTicksFromData();
      odials.add(dial);
      outputs++;
    }
  }
}

void draw() {
  //scale(displayScale);
  background(windowBackgroundColor);
  for (Dial dial : idials) {
    dial.draw();
  }
  updateOutputDials();
  for (Dial dial : odials) {
    dial.draw();
  }
  //updateOutputDials();
  //rect(10,10,50,50);
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
        //float dnorm = 100.0 * ((float)(val - cidial.m_datafield.iMin()) / (float)(cidial.m_datafield.iRange()));
        if (cidial.m_dialLow <= val && val <= cidial.m_dialHigh) {
        //if (cidial.m_dialLow <= dnorm && dnorm <= cidial.m_dialHigh) {
          inRange = true;
        }
      }
      else if (cidial.m_datafield.isFloat()) {
        float val = row.get(idIdx).floatValue();
        //float dnorm = 100.0 * (val - cidial.m_datafield.fMin()) / cidial.m_datafield.fRange();
        if (cidial.m_dialLow <= val && val <= cidial.m_dialHigh) {
        //if (cidial.m_dialLow <= dnorm && dnorm <= cidial.m_dialHigh) {
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
  boolean outputDialPressed = false;
  for (Dial dial : odials) {
    boolean pressed = dial.mousePressed(idials, odials, false);
    if (pressed) {
      outputDialPressed = true;
    }
  }  
  for (Dial dial : idials) {
    dial.mousePressed(idials, odials, !outputDialPressed);
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
