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

ArrayList<Axis> axisList;
Boolean fiducialIn = false;
int fiducialId = 0;
float speed = 3;


HashMap<Integer, String> idToAttr;  //Maps from fiducial id to the attribute it represents
Vector tuioObjectList;
ArrayList<String> availableAttr; //Contains a list of attributes which can be assigned to new fiducials 

menu fieldsMenu; //The object of the menu class, used to show the list of attributes
int menuFiducial = 12; //The id of the fiducial which brings up the menu


void setup()
{
  //size(screen.width,screen.height);
  size(screenWidth, screenHeight);
  noStroke();
  fill(0);
  smooth();
  
  //font = loadFont("DroidSerif-Italic-48.vlw");

  loop();
  frameRate(30);
  //noLoop();
  axisList = new ArrayList<Axis>();
  font = createFont("Arial", 18);
  scale_factor = height/table_size;

  // we create an instance of the TuioProcessing client
  // since we add "this" class as an argument the TuioProcessing class expects
  // an implementation of the TUIO callback methods (see below)
  tuioClient  = new TuioProcessing(this);


  availableAttr = new ArrayList<String>();
  availableAttr.add("calories");
  availableAttr.add("proteins");
  availableAttr.add("fats");
  availableAttr.add("sodium");
  availableAttr.add("fiber");
  availableAttr.add("carbs");
  availableAttr.add("sugars");
  availableAttr.add("potassium");
  availableAttr.add("vitamins");

  idToAttr = new HashMap<Integer, String>();

  idToAttr.put(111, "calories"); 
  idToAttr.put(112, "proteins"); 
  idToAttr.put(113, "fats");



  cereals = new ReadCSV("data/cereals.csv"); //Read the cereals dataset csv
  columns = cereals.getTwoFields(4, 5); //Create a point for each entry in the dataset

  datapoints = cereals.getPoints();
  for (int i = 0; i < datapoints.length; i++) {
    datapoints[i].setloc("fats", "fiber", screenWidth/2);
    datapoints[i].fillNorm(cereals.min, cereals.range);
  }

  fieldsMenu = new menu(this, availableAttr); //pass the data-field names to the menu
  fieldsMenu.hide();                          //Keep the menu hidden initially
}

// within the draw method we retrieve a Vector (List) of TuioObject and TuioCursor (polling)
// from the TuioProcessing client and then loop over both lists to draw the graphical feedback.
void draw()
{
  background(220);
  textFont(font, 18*scale_factor);
  float obj_size = object_size*scale_factor; 
  float cur_size = cursor_size*scale_factor;

  text("No of points:"+datapoints.length, 10, 30);

  pushStyle();
  tuioObjectList = tuioClient.getTuioObjects();
  //println(tuioObjectList.size());

  for (int i=0;i<tuioObjectList.size();i++) {
    TuioObject tobj = (TuioObject)tuioObjectList.elementAt(i);
    int id = tobj.getSymbolID();   

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

  popStyle();

  pushStyle();
  Vector tuioCursorList = tuioClient.getTuioCursors();
  for (int i=0;i<tuioCursorList.size();i++) {

    TuioCursor tcur = (TuioCursor)tuioCursorList.elementAt(i);
    Vector pointList = tcur.getPath();

    if (pointList.size()>0) {
      stroke(0, 0, 255);
      TuioPoint start_point = (TuioPoint)pointList.firstElement();
      
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

  popStyle();

  //Loop to display each axis on screen
  for (Axis a: axisList) {
    a.draw();
  }  

  pushStyle();
  fill(0, 128, 255,80);                     //Blue, with a slight transparency
  stroke(0,200);
  //Loop to display each datapoint on screen
  for (int i = 0; i < datapoints.length; i++) {
    //  strokeWeight (10 - (i*10)/cereals.length);
    //  stroke(i*3,i*2,i);
    //  float x = (columns[i][0]*screenWidth)/200;
    //  float y = (columns[i][1]*screenHeight)/8;
    //    datapoints[i].move(speed);
    datapoints[i].updateAndMove(10);      
    datapoints[i].showpt();
  }

  //Show the scaled vector from each datapoint to the fiducial
//  if (fiducialIn) {
//    for (int i = 0; i < datapoints.length; i++) {
//      datapoints[i].showvec();
//    }
//  }
  popStyle();

  checkAssign();    //Check if it is possible to assign a value to the fiducial
}

// these callback methods are called whenever a TUIO event occurs

// called when an object is added to the scene
void addTuioObject(TuioObject tobj) {
  int id = tobj.getSymbolID();
  println("add object "+ id +" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle());
  pt fidPt = P(tobj.getX()*screenWidth, tobj.getY()*screenHeight);


  if (idToAttr.containsKey(id)) {
    //Calculate the vector from each datapoint to the fiducial
    for (int i = 0; i < datapoints.length; i++) {
      datapoints[i].setvec(fidPt, idToAttr.get(id));
    }

    //Set a flag indicating that a fiducial is present
    fiducialIn = true;
    fiducialId = tobj.getSymbolID();
  }
  else if (id < 119 && id > 110) {
    createAxisList();
    generateAxisPositions();
  }
  else if (id == menuFiducial) {
    fieldsMenu.show();
  }
}

//When an object is added or removed, we need to establish the current set of
//axes on the display.
void createAxisList() {
  axisList.clear();
  Vector tuioObjectList = tuioClient.getTuioObjects();
  for (int i=0;i<tuioObjectList.size();i++) {
    TuioObject tobj = (TuioObject)tuioObjectList.elementAt(i);
    int id = tobj.getSymbolID();
    if (id > 110 && id < 119) {
      TuioObject addedObject = null;
      for (Axis a: axisList) {
        addedObject = a.addTuioObject(tobj);
      }
      if (addedObject == null) {
        Axis axis = new Axis(tobj);
        axisList.add(axis);
      }
    }
  }
}

//Generate the coordinate positions for all dust particles and set them
void generateAxisPositions() {
  println("Generating axis positions outer loop");
  if (axisList.size() == 1) {
    println("Only one axis");
    Axis a = axisList.get(0);
    if (a.isFull()) 
      for (int i = 0; i < datapoints.length; i++) {
        datapoints[i].setDest(a.getDestinationAlongAxis(datapoints[i]));
      }
  }
  else
    for (int i = 0; i < axisList.size(); i++) {
      Axis a = axisList.get(i); 

      if (a.isFull()) {    
        pt a0 = P(a.start.getX()*screenWidth, a.start.getY()* screenHeight);
        pt a1 = P(a.end.getX()*screenWidth, a.end.getY()* screenHeight);
        pt aM = P(a0, a1);

        for (int j = i+1; j < axisList.size(); j++) {
          Axis b = axisList.get(j);    
          if (b.isFull()) {
            println("Generating axis positions");
            pt b0 = P(b.start.getX()*screenWidth, b.start.getY()* screenHeight);
            pt b1 = P(b.end.getX()*screenWidth, b.end.getY()* screenHeight);
            pt bM = P(b0, b1);
            float d = d(aM, bM);
            println("Distance " + d);
            vec U = U(a0, a1);
            vec V = U(b0, b1);
            float dp = dot(U, V);
            println("Testing right angle " + dp);
            //Determine if the two axes are close to a right angle. If so, they should create a scatterplot.
            if (d < 300 && abs(dp) < .2) {
              if (d(a0, b0) < d(a0, b1)) {
                pt temp = P(b0);
                b0 = P(b1);
                b1 = P(temp);                
                V = U(b0, b1);
                dp = dot(U, V);
              }
              else if (d(b0, a0) < d(b0, a1)) {
                pt temp = P(a0);
                a0 = P(a1);
                a1 = P(temp);                
                U = U(a0, a1);
                dp = dot(U, V);
              }
              println("right angle " + dp);

              //              pt v0 = P(a0.add(P(-1, a1)));
              //              pt v1 = P(b0.add(P(-1, b1)));
              //
              //              //Project the datapoint into the two dimensional space defined by the axes
              //              float[][] matrix = {
              //                {
              //                  v0.x, v1.x
              //                }
              //                , {
              //                  v0.y, v1.y
              //                }
              //              };

              for (int k = 0; k < datapoints.length; k++) {
                pt A = a.getDestinationAlongAxis(datapoints[k]);
                pt B = b.getDestinationAlongAxis(datapoints[k]);

                //                pt scoords = P(datapoints[k].getNormalizedValue(a.attribute), datapoints[k].getNormalizedValue(b.attribute));           
                //                pt projected = P(matrix[0][0]*scoords.x+matrix[0][1]*scoords.y, matrix[1][0]*scoords.x+matrix[1][1]*scoords.y);
                //                vec rV = R(V(projected), angle(V(P(a0,b0)))); 
                //                projected = P(rV.x, rV.y);
                //                projected = projected.add(P(a0,b0)); 
                datapoints[k].setDest(A.add(B).add(P(-1, b1)));
                //                datapoints[k].setDest(projected);
              }
            }      

            dp = dot(U, R(V));
            println("Testing parallel angle " + dp);
            //Otherwise, determine if the two axes are parallel. If so, they should create a parallel coordinate plot.
            if (abs(dp) < .2) {
              println("parallel " + dp);
            }

            //Need to compose bounding boxes for each plot and test for collisions.
          }
        }
      }
    }
}

// called when an object is removed from the scene
void removeTuioObject(TuioObject tobj) {
  println("remove object "+tobj.getSymbolID()+" ("+tobj.getSessionID()+")");
  fiducialIn = false;
  fiducialId = 0;

  int id = tobj.getSymbolID();
  if (id < 119 && id > 110) {
    createAxisList();
    generateAxisPositions();
  }
  else if (id == menuFiducial) {        //This is the id of the "Menu/Assignment fiducial" 
    fieldsMenu.hide();
  }
}




// called when an object is moved
void updateTuioObject (TuioObject tobj) {
  int id = tobj.getSymbolID();


  //    println("update object "+id+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" angle: "+tobj.getAngle()
  //      +" "+tobj.getMotionSpeed()+" "+tobj.getRotationSpeed()+" "+tobj.getMotionAccel()+" "+tobj.getRotationAccel());

  pt fidPt = P(tobj.getX()*screenWidth, tobj.getY()*screenHeight);

  if (idToAttr.containsKey(id)) {
    //Calculate the vector from each datapoint to the fiducial and move it
    for (int i = 0; i < datapoints.length; i++) {
      datapoints[i].setvec(fidPt, idToAttr.get(id));
      datapoints[i].move(speed);
    }
  }
  else if (id < 119 && id > 110) {
    generateAxisPositions();
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



public class Axis {
  TuioObject start, end;

  int symbolID;
  String attribute; 

  public Axis (TuioObject tobj) {
    symbolID = tobj.getSymbolID();
    start=tobj; 
    end = null;
    attribute = idToAttr.get(symbolID);
  }

  public Axis (TuioObject tobj0, TuioObject tobj1) {
    symbolID = tobj0.getSymbolID();
    start=tobj0; 
    end = tobj1;
    attribute = idToAttr.get(symbolID);
  }

  pt getDestinationAlongAxis(DataPoint point) {
    pt xy0 = P(start.getX()*screenWidth, start.getY()* screenHeight);
    pt xy1 = P(end.getX()*screenWidth, end.getY()* screenHeight);  
    return L(xy0, xy1, point.getNormalizedValue(attribute));
  }

  String print() {
    return attribute;
  }

  synchronized TuioObject addTuioObject(TuioObject tobj) {
    TuioObject addedObject = null;
    if (tobj.getSymbolID() == symbolID) {
      if (start == null && tobj.getAngle() - end.getAngle() < PI / 10) {
        start = tobj;
        addedObject = tobj;
      }
      else if (end == null && tobj.getAngle() - start.getAngle() < PI / 10) {
        end = tobj;
        addedObject = tobj;
      }
    }
    return addedObject;
  }

  synchronized void removeTuioObject(TuioObject tobj) {
    if (tobj.getSymbolID() == symbolID) {
      if (start == tobj) {
        start = null;
      }
      else if (end == tobj) {
        end = null;
      }
    }
  }

  void updateTuioObject(TuioObject tobj) {
  }

  boolean isEmpty() {
    boolean isEmpty = false;
    if (start == null && end == null)
      isEmpty = true;
    return isEmpty;
  }

  boolean isFull() {
    boolean isFull = true;
    if (start == null || end == null)
      isFull = false;
    return isFull;
  }

  synchronized void draw() {
    if (isFull()) {
      pt xy0 = P(start.getX()*screenWidth, start.getY()* screenHeight);
      pt xy1 = P(end.getX()*screenWidth, end.getY()* screenHeight);  
      //      println("Drawing axis" + xy0.x + " " + xy0.y + " " + xy1.x + " " + xy1.y);
      pushStyle();
      fill(100);
      stroke(0);
      line(xy0.x, xy0.y, xy1.x, xy1.y);
      fill(255, 0, 0);
      popStyle();
    }
  }
}



//Method to handle events from the menu and act on it
void controlEvent(ControlEvent theEvent) {
  // ListBox is if type ControlGroup.
  // 1 controlEvent will be executed, where the event
  // originates from a ControlGroup. therefore
  // you need to check the Event with
  // if (theEvent.isGroup())
  // to avoid an error message from controlP5.

  if (theEvent.isGroup()) {
    // an event from a group e.g. scrollList
    println(theEvent.group().value()+" from "+theEvent.group());
  }

  if (theEvent.isGroup() && theEvent.name().equals("myList")) {
    int test = (int)theEvent.group().value();
    println("test "+test);

    fieldsMenu.reDraw();
  }
}

void keyPressed() {
  if (key=='0') {

    fieldsMenu.l.setValue(5); // will activate the listbox item with value 5
  }
  else if (key == 'h') {
    fieldsMenu.hide();
  }
  else if (key == 's') {
    fieldsMenu.show();
  }
}

//Checks if exactly two fiducials are present, if yes, checks whether one is the menu fiducial and the other is unassigned
void checkAssign() {
  if (tuioObjectList.size() == 2 && availableAttr.size() > 0) {

    TuioObject tobj = (TuioObject)tuioObjectList.elementAt(0);
    int id1 = tobj.getSymbolID();
    tobj = (TuioObject)tuioObjectList.elementAt(1);
    int id2 = tobj.getSymbolID();
    if (id1 == menuFiducial && !idToAttr.containsKey(id2)) {
      idToAttr.put(id2, availableAttr.get(0));
      availableAttr.remove(0);
      fieldsMenu.reDraw(availableAttr);
    }
    else if (id2 == menuFiducial && !idToAttr.containsKey(id1)) {
      idToAttr.put(id1, availableAttr.get(0));
      availableAttr.remove(0);
      fieldsMenu.reDraw(availableAttr);
    }
  }
}

