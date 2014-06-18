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

int myColorBackground = color(127,127,127);

ControlP5 cp5;
//Dial[] dials;
//int numDials = 7;

ArrayList<Dial> dials;

Data data;

void setup() {
  size(1250,750);
  smooth();
  noStroke();
  
  /*
  println("display: " + displayWidth + "x" + displayHeight);
  println("toolkit: " + java.awt.Toolkit.getDefaultToolkit().getScreenResolution() + " dpi");
  */
  
  cp5 = new ControlP5(this);
  
  /*
  String[] ddesc = {
    "mpg",
    "cylinders",
    "displacement",
    "horsepower",
    "weight",
    "acceleration",
    "model year",
    "origin",
    "car name"
  };
  */
  
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
  
  dials = new ArrayList<Dial>();
  
  int n=0;
  for (int i=0; i<datafields.length; i++) {
    if (datafields[i].isActiveInput()) {
      Dial dial = new Dial(20+n*175, 250, 140, datafields[i], cp5);
      dials.add(dial);
      n++;
    }
  }
  
  data = new Data(datafields);
  data.load("auto-mpg.data");
  
  /*
  dials = new Dial[numDials];
  for (int i=0; i<numDials; i++) {
    dials[i] = new Dial(20+i*175, 250, 140);
    dials[i].setup(cp5, ddesc[i+1]);
  }
  
  data = new Data(8);
  data.load("auto-mpg.data");
  */
}

void draw() {
  background(myColorBackground);
  /*
  for (int i=0; i<numDials; i++) {  
    dials[i].draw();
  }
  */
  
  for (Dial dial : dials) {
    dial.draw();
  }
}

void controlEvent(ControlEvent theControlEvent) {
  /*
  for (int i=0; i<numDials; i++) {
    dials[i].controlEvent(theControlEvent);
  }
  */
  for (Dial dial : dials) {
    dial.controlEvent(theControlEvent);
  }
}

void mousePressed() {
  for (Dial dial : dials) {
    dial.mousePressed();
  }  
}

void mouseReleased() {
  for (Dial dial : dials) {
    dial.mouseReleased();
  } 
}

void mouseDragged() {
  for (Dial dial : dials) {
    dial.mouseDragged();
  } 
}

