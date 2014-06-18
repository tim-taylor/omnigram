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
  updateOutputDials();
  for (Dial dial : odials) {
    dial.draw();
  }  
}

void updateOutputDials() {
  // this method considers all current input dials and constraints between them,
  // and calculates the corresponding state of all output dials
  
  InputDial id1 = idials.get(0);
  OutputDial od1 = odials.get(0);
  int id1dIdx = id1.m_datafield.m_dataIdx;
  int od1dIdx = od1.m_datafield.m_dataIdx;
  int c=0;
  int numOBins = 20;
  int[] obins = new int[numOBins];
  //println(id1dIdx + " " + od1dIdx);
  for (ArrayList<Number> row : data.m_data) {
    //println(row.get(id1dIdx) + " " + row.get(od1dIdx));
    if (id1.m_datafield.isInt()) {
      int val = row.get(id1dIdx).intValue();
      println(id1.m_datafield.m_iMin + " " + val + " " + id1.m_datafield.m_iMax);
      float dnorm = 100.0 * ((float)(val - id1.m_datafield.m_iMin) / (float)(id1.m_datafield.m_iMax - id1.m_datafield.m_iMin));
      if (id1.m_min <= dnorm && dnorm <= id1.m_max) {
        c++;
        float oVal = row.get(od1dIdx).floatValue(); // assuming float for now
        int obin = (int)((float)numOBins * ((float)(val - id1.m_datafield.m_iMin) / (float)(id1.m_datafield.m_iMax - id1.m_datafield.m_iMin)));
        obin = constrain(obin, 0, numOBins-1);
        obins[obin]++;
      }
      //println(id1.m_min + " " + dnorm + " " + id1.m_max);
    }
  }
  //println(c);
  //println(obins);
  //println(data.m_data.size());
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
    dial.mousePressed();
  }
  for (Dial dial : odials) {
    dial.mousePressed();
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

