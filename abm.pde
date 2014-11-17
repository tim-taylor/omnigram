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

// N.B. When specifying the loader file, loader doesn't seem to cope with filenames that are symbolic links!
String modelLoaderFile = "auto-mpg-loader.xml";
//String modelLoaderFile = "breast-cancer-wisconsin-loader.xml";
//String modelLoaderFile = "pertussis-data-reduced-n-1000-seed-1-clean-loader.xml";
//String modelLoaderFile = "influenza-data-31-20-n-1000-clean-loader.xml";

int globalZoom = 100;
int nodeZoom = 100;

Model model;


void setup() {
  size((displayWidth*80)/100, (displayHeight*80)/100);
  
  if (frame != null) {
    frame.setResizable(true);
  }

  smooth();
  noStroke();
  
  model = new Model(modelLoaderFile);
  model.m_interactionMode = InteractionMode.SingleNodeBrushing;
}


void draw() {
  
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
      case 'L':
      case 'l':
        model.linkRequest();
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

