/**
* ABM Interactive Visualization Prototype
*
* Tim Taylor
* Monash University
*
* version: 0.2
* date: 21 August 2014
*
*/

//PFont mediumFont;

String modelLoaderFile = "auto-mpg-loader.xml";  // N.B. loader doesn't seem to cope with filenames that are symbolic links!

int globalZoom = 100;
int nodeZoom = 100;

Model model;


void setup() {
  size((displayWidth*80)/100, (displayHeight*80)/100);
  
  //mediumFont = createFont("Arial", 16, true); // Arial, 16 point, anti-aliasing on
  
  if (frame != null) {
    frame.setResizable(true);
  }

  smooth();
  noStroke();
  
  model = new Model(modelLoaderFile);
  model.m_interactionMode = InteractionMode.SingleNodeBrushing;
  //model.m_interactionMode = InteractionMode.MultiNodeBrushing;

}


void draw() {

  //background(0x808080);
  
  model.draw(globalZoom, nodeZoom);

}


void mousePressed() {
  
  model.mousePressed();
 
}


void mouseReleased() {  
  
  model.mouseReleased();

}


void mouseDragged() {
  
  model.mouseDragged();

}


void keyPressed() {
  switch (key) {
    case '+':
      globalZoom++;
      redraw();
      break;
    case '-':
      globalZoom--;
      redraw();
      break;
    case '1':
      model.setInteractionMode(InteractionMode.SingleNodeBrushing);
      break;
    case '2':
      model.setInteractionMode(InteractionMode.MultiNodeBrushing);
      break;
    default:
      break;
  }
  
  /*
  if (key == '+') {
    globalZoom++;
    redraw();
  }
  else if (key == '-') {
    globalZoom--;
    redraw();
  }
  */
}


/*
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
  * /
}
*/
