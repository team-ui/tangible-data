// LecturesInGraphics: utilities
// Author: Jarek ROSSIGNAC, last edited on August 1, 2013

// ************************************************************************ COLORS 
color black=#000000, white=#FFFFFF, // set more colors using Menu >  Tools > Color Selector
   red=#FF0000, grey=#818181, green=#00FF01, blue=#0300FF, yellow=#FEFF00, cyan=#00FDFF, magenta=#FF00FB;

// ************************************************************************ GRAPHICS 
void pen(color c, float w) {stroke(c); strokeWeight(w);}
void showDisk(float x, float y, float r) {ellipse(x,y,r*2,r*2);}

// ************************************************************************ IMAGES & VIDEO 
int pictureCounter=0;
PImage myFace; // picture of author's face, should be: data/pic.jpg in sketch folder
void snapPicture() {saveFrame("PICTURES/P"+nf(pictureCounter++,3)+".jpg"); }


// ************************************************************************ TEXT 
Boolean scribeText=true; // toggle for displaying of help text
void scribe(String S, float x, float y) {fill(0); text(S,x,y); noFill();} // writes on screen at (x,y) with current fill color
void scribeHeader(String S, int i) {fill(0); text(S,10,20+i*20); noFill();} // writes black at line i
void scribeHeaderRight(String S) {fill(0); text(S,width-7.5*S.length(),20); noFill();} // writes black on screen top, right-aligned
void scribeFooter(String S, int i) {fill(0); text(S,10,height-10-i*20); noFill();} // writes black on screen at line i from bottom
void scribeAtMouse(String S) {fill(0); text(S,mouseX,mouseY); noFill();} // writes on screen near mouse
void scribeMouseCoordinates() {fill(black); text("("+mouseX+","+mouseY+")",mouseX+7,mouseY+25); noFill();}



// ************************************************************************ GENERIC TEXT FOR TITLE 
String subtitle = "for Jarek Rossignac's CS3451 class in the Fall 2013";
//************************ capturing frames for a movie ************************
boolean filming=false;  // when true frames are captured in FRAMES for a movie
int frameCounter=0;     // count of frames captured (used for naming the image files)
boolean change=false;   // true when the user has presed a key or moved the mouse
boolean animating=false; // must be set by application during animations to force frame capture

// ************************************************************************ IO FILES
String fileName="data/points";

void fileSelected(File selection) {
  if (selection == null) println("Window was closed or the user hit cancel.");
  else {
    fileName = selection.getAbsolutePath();
    println("User selected " + fileName);
    }
  }



