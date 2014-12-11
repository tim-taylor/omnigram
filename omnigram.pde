/**
* Omnigram Explorer
* An Interactive Data Exploration Tool
*
* Tim Taylor
* Monash University
* tim@tim-taylor.com
*
* version: 1.0
* date: 26 November 2014
*
* Notes on exporting to platform-specific binaries:
* - Export to Linux works best NOT as a full screen mode app [and with size less than full screen in setup()]
* - Export to Windows works best as a full screen mode app [and with size = full screen in setup()]
* - Export to MacOS: for current version of Processing (2.2.1), only works when exporting from a Mac
*
*/

String modelLoaderFile = "";
int globalZoom = 100;
int nodeZoom = 100;
Model model;


void setup() {
  size((displayWidth*80)/100, (displayHeight*80)/100); // best for Linux
  //size(displayWidth, displayHeight); // best for Windows
  if (frame != null) {
    frame.setResizable(true);
  }
  smooth();
  noStroke();
  noLoop();
  selectInput("Select a model definition XML file", "modelFileSelected");
}


void modelFileSelected(File file) {
  // Callback function for the file selection dialog
  if (file == null) {
    exit();
  } else {
    modelLoaderFile = file.getAbsolutePath();
    model = new Model(modelLoaderFile);
    model.m_interactionMode = InteractionMode.SingleNodeBrushing;
    loop();
  }
}


void draw() {
  if (model != null) {
    model.draw(globalZoom, nodeZoom);
  }
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
  if (key == CODED) {
    switch (keyCode) {
      case UP:
        model.showSamplesAutoSpeedUp();
        break;
      case DOWN:
        model.showSamplesAutoSlowDown();
        break;
      case LEFT:
        model.showSamplesStepBackward();
        break;
      case RIGHT:
        model.showSamplesStepForward();
        break;
      default:
        break;
    }
  }
  else {
    switch (key) {
      case '+': {
        if (globalZoom < 1000) { 
          globalZoom++;
          redraw();
        }
        break;
      }
      case '-': {
        if (globalZoom > 1) {
          globalZoom--;
          redraw();
        }
        break;
      }
      case '1':
        model.setInteractionMode(InteractionMode.SingleNodeBrushing);
        break;
      case '2':
        model.setInteractionMode(InteractionMode.MultiNodeBrushing);
        break;
      case '3':
        model.setInteractionMode(InteractionMode.ShowSamples);
        break;
      case 'B':
      case 'b':
        model.requestBrushLinkDelete();
        break;
      case 'C':
      case 'c':
        model.requestCausalLinkDelete();
        break;
      case 'D':
      case 'd':
        model.requestToggleCausalLinkDir();
        break;
      case 'H':
      case 'h':  
        model.toggleHelpScreen();
        break;
      case 'L':
      case 'l':
        model.requestBrushLinkCreate();
        break;
      case 'M':
      case 'm':
        model.toggleMeanMedian();
        break;
      case 'R':
      case 'r':
        model.initialiseCausalLinks();
      case 'S':
      case 's':
        model.toggleSSDisplayMode();
        break;
      case 'Z':
      case 'z':
        model.showSamplesDecrementNumSamples();
        break;
      case 'X':
      case 'x':
        model.showSamplesIncrementNumSamples();
        break;
      default:
        break;
    }
  }
}
  

