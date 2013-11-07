/*

 A client to recieve data from tangibles using the TUIO protocol,
 read dataset from CSV files and enable tangible interaction with
 multivariate data.
 
 A project by Sagar Raut <sagarraut@gatech.edu> and Alex Godwin <alex.godwin@gatech.edu>
 
 Based on the TUIO processing demo - part of the reacTIVision project
 by Martin Kaltenbrunner
 http://reactivision.sourceforge.net/
 
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

// we need to import the TUIO library
// and declare a TuioProcessing client variable
import TUIO.*;
import java.util.*;
TuioProcessing tuioClient;

// these are some helper variables which are used
// to create scalable graphical feedback
float cursor_size = 15;
float object_size = 60;
float table_size = 760;
float scale_factor = 1;
PFont font;
ReadCSV cereals;
int screenWidth = 1024, screenHeight = 768;
float[][] columns;
DataPoint[] datapoints;
Boolean fiducialIn = false;
int fiducialId = 0;
float speed = 0.3;

HashMap<Integer, String> idToAttr;

void setup()
{
  //size(screen.width,screen.height);
  size(screenWidth, screenHeight);
  noStroke();
  fill(0);

  loop();
  frameRate(30);
  //noLoop();

  hint(ENABLE_NATIVE_FONTS);
  font = createFont("Arial", 18);
  scale_factor = height/table_size;

  // we create an instance of the TuioProcessing client
  // since we add "this" class as an argument the TuioProcessing class expects
  // an implementation of the TUIO callback methods (see below)
  tuioClient  = new TuioProcessing(this);

  idToAttr = new HashMap<Integer, String>();
  idToAttr.put(1, "calories"); 
  idToAttr.put(2, "proteins"); 
  idToAttr.put(3, "fats"); 
  idToAttr.put(4, "sodium"); 
  idToAttr.put(5, "fiber"); 
  idToAttr.put(6, "carbs"); 
  idToAttr.put(7, "sugars"); 
  idToAttr.put(8, "potassium"); 
  idToAttr.put(9, "vitamins");

  //Read the cereals dataset csv
  cereals = new ReadCSV("data/cereals.csv");
  columns = cereals.getTwoFields(4, 5);
  //Create a point for each entry in the dataset
  datapoints = cereals.getPoints();
  for (int i = 0; i < datapoints.length; i++) {
    datapoints[i].setloc("fats", "fiber", screenWidth/2);
    datapoints[i].fillNorm(cereals.min, cereals.range);
  }
}

// within the draw method we retrieve a Vector (List) of TuioObject and TuioCursor (polling)
// from the TuioProcessing client and then loop over both lists to draw the graphical feedback.
void draw()
{
  background(255);
  textFont(font, 18*scale_factor);
  float obj_size = object_size*scale_factor; 
  float cur_size = cursor_size*scale_factor;


  fill(255, 0, 0);
  stroke(255, 0, 0);

  text("No of points:"+datapoints.length, 10, 30);

  //Loop to display each datapoint on screen
  for (int i = 0; i < datapoints.length; i++) {
    //  strokeWeight (10 - (i*10)/cereals.length);
    //  stroke(i*3,i*2,i);
    //  float x = (columns[i][0]*screenWidth)/200;
    //  float y = (columns[i][1]*screenHeight)/8;

    datapoints[i].showpt(screenWidth/2);
  }

  //Show the scaled vector from each datapoint to the fiducial
  if (fiducialIn) {
    for (int i = 0; i < datapoints.length; i++) {
      datapoints[i].showvec();
    }
  }


  Vector tuioObjectList = tuioClient.getTuioObjects();
  for (int i=0;i<tuioObjectList.size();i++) {
    TuioObject tobj = (TuioObject)tuioObjectList.elementAt(i);
    stroke(0);
    fill(0);
    pushMatrix();
    translate(tobj.getScreenX(width), tobj.getScreenY(height));
    rotate(tobj.getAngle());
    rect(-obj_size/2, -obj_size/2, obj_size, obj_size);
    popMatrix();
    fill(255);
    text(""+idToAttr.get(tobj.getSymbolID()), tobj.getScreenX(width)-obj_size/2, tobj.getScreenY(height));
  }

  Vector tuioCursorList = tuioClient.getTuioCursors();
  for (int i=0;i<tuioCursorList.size();i++) {
    TuioCursor tcur = (TuioCursor)tuioCursorList.elementAt(i);
    Vector pointList = tcur.getPath();

    if (pointList.size()>0) {
      stroke(0, 0, 255);
      TuioPoint start_point = (TuioPoint)pointList.firstElement();
      ;
      for (int j=0;j<pointList.size();j++) {
        TuioPoint end_point = (TuioPoint)pointList.elementAt(j);
        line(start_point.getScreenX(width), start_point.getScreenY(height), end_point.getScreenX(width), end_point.getScreenY(height));
        start_point = end_point;
      }

      stroke(192, 192, 192);
      fill(192, 192, 192);
      ellipse( tcur.getScreenX(width), tcur.getScreenY(height), cur_size, cur_size);
      fill(0);
      text(""+ tcur.getCursorID(), tcur.getScreenX(width)-5, tcur.getScreenY(height)+5);
    }
  }
}

// these callback methods are called whenever a TUIO event occurs

// called when an object is added to the scene
void addTuioObject(TuioObject tobj) {
  int id = tobj.getSymbolID();
  println("add object "+ id +" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle());
  pt fidPt = P(tobj.getX()*screenWidth, tobj.getY()*screenHeight);

  //Calculate the vector from each datapoint to the fiducial
  for (int i = 0; i < datapoints.length; i++) {
    datapoints[i].setvec(fidPt, idToAttr.get(id));
  }

  //Set a flag indicating that a fiducial is present
  fiducialIn = true;
  fiducialId = tobj.getSymbolID();
}

// called when an object is removed from the scene
void removeTuioObject(TuioObject tobj) {
  println("remove object "+tobj.getSymbolID()+" ("+tobj.getSessionID()+")");
  fiducialIn = false;
  fiducialId = 0;
}

// called when an object is moved
void updateTuioObject (TuioObject tobj) {
  int id = tobj.getSymbolID();

  println("update object "+id+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle()
    +" "+tobj.getMotionSpeed()+" "+tobj.getRotationSpeed()+" "+tobj.getMotionAccel()+" "+tobj.getRotationAccel());
  pt fidPt = P(tobj.getX()*screenWidth, tobj.getY()*screenHeight);

  //Calculate the vector from each datapoint to the fiducial and move it
  for (int i = 0; i < datapoints.length; i++) {
    datapoints[i].setvec(fidPt, idToAttr.get(id));
    datapoints[i].move(speed);
  }
}

// called when a cursor is added to the scene
void addTuioCursor(TuioCursor tcur) {
  println("add cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY());
}

// called when a cursor is moved
void updateTuioCursor (TuioCursor tcur) {
  println("update cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY()
    +" "+tcur.getMotionSpeed()+" "+tcur.getMotionAccel());
}

// called when a cursor is removed from the scene
void removeTuioCursor(TuioCursor tcur) {
  println("remove cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+")");
}

// called after each message bundle
// representing the end of an image frame
void refresh(TuioTime bundleTime) { 
  redraw();
}

