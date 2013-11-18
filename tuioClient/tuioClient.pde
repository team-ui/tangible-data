

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
ArrayList<DataPoint[]> pointSets;
Boolean fiducialIn = false;
int fiducialId = 0;
float speed = 3;
pt origin;
boolean drawing = false;

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
  axisList = new ArrayList<Axis>();

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
  idToAttr.put(111, "calories"); 
  idToAttr.put(112, "proteins"); 
  idToAttr.put(113, "fats");

  //Read the cereals dataset csv
  cereals = new ReadCSV("data/cereals.csv");
  columns = cereals.getTwoFields(4, 5);
  //Create a point for each entry in the dataset
  datapoints = cereals.getPoints();
  for (int i = 0; i < datapoints.length; i++) {
    datapoints[i].setloc("fats", "fiber", screenWidth/2);
    datapoints[i].fillNorm(cereals.min, cereals.range);
  }
  origin = P(100, 100);
  pointSets = new ArrayList<DataPoint[]>();
  pointSets.add(datapoints);
}

// within the draw method we retrieve a Vector (List) of TuioObject and TuioCursor (polling)
// from the TuioProcessing client and then loop over both lists to draw the graphical feedback.
void draw()
{
  background(255);
  drawing = true;
  textFont(font, 18*scale_factor);
  float obj_size = object_size*scale_factor; 
  float cur_size = cursor_size*scale_factor;

  text("No of points:"+datapoints.length, 10, 30);

  pushStyle();
  fill(0, 150, 0);
  ellipse(origin.x, origin.y, 10, 10);  
  popStyle();

  pushStyle();
  Vector tuioObjectList = tuioClient.getTuioObjects();
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
  popStyle();

  //Loop to display each axis on screen
  //Because of the way the axis list is constructed, there
  //is a risk of a concurrent modification exception here.
  for (Axis a: axisList) {
    a.draw();
  }  

  pushStyle();
  fill(255, 0, 0);
  stroke(255, 0, 0);

  for (DataPoint[] set : pointSets) {

    //Loop to display each datapoint on screen
    for (int i = 0; i < set.length; i++) {
      //  strokeWeight (10 - (i*10)/cereals.length);
      //  stroke(i*3,i*2,i);
      //  float x = (columns[i][0]*screenWidth)/200;
      //  float y = (columns[i][1]*screenHeight)/8;
      //    datapoints[i].move(speed);
      set[i].updateAndMove(10);      
      set[i].showpt(screenWidth/2);

      //Show the scaled vector from each datapoint to the fiducial
      if (fiducialIn) {
        datapoints[i].showvec();
      }
    }
  }
  popStyle();
  drawing = false;
}

// these callback methods are called whenever a TUIO event occurs

// called when an object is added to the scene
void addTuioObject(TuioObject tobj) {
  int id = tobj.getSymbolID();
  println("add object "+ id +" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle());
  pt fidPt = P(tobj.getX()*screenWidth, tobj.getY()*screenHeight);

  if (id < 9 && id > 0) {
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
            println("a: " + a0.x + "," + a0.y + " : " + a1.x + "," + a1.y);
            println("b: " + b0.x + "," + b0.y + " : " + b1.x + "," + b1.y);
            pt bM = P(b0, b1);
            float d = d(aM, bM);
            println("Distance " + d);
            vec U = U(a0, a1);
            vec V = U(b0, b1);
            float dp = dot(U, V);
            println("Testing right angle " + dp);
            //Determine if the two axes are close to a right angle. If so, they should create a scatterplot.
            if (d < 300 && abs(dp) < .2) {

              println("right angle " + dp);      

              //find the origin of the coordinate system defined by the scatterplot axes (line-line intersection)        
              origin  = linelineintersection(a0, a1, b0, b1);

              //Determine that the new origin does not lay on within either of the two line segments
              boolean isBetween = isBetween(a0, a1, origin) || isBetween(b0, b1, origin);

              println(origin.x + " " + origin.y + " " + isBetween);            

              //find length of each axis (distance from endpoints to the new origin
              pt aNear, aFar;
              pt bNear, bFar;

              if (d(a0, origin) > d(a1, origin)) {
                aFar = a0;
                aNear = a1;
              }
              else {
                aFar = a1;
                aNear = a0;
              }

              if (d(b0, origin) > d(b1, origin)) {
                bFar = b0;
                bNear = b1;
              }
              else {
                bFar = b1;
                bNear = b0;
              }

              float aScale = d(origin, aFar);
              float bScale = d(origin, bFar);              

              //find angle between axes 
              float angle = angle(V(aFar, origin), V(bFar, origin));

              //Should be able to determine direction based on angle...

              float shear = 1/tan(angle);

              float[][] sMatrix = {
                {
                  1, shear
                }
                , {
                  0, 1
                }
              };

              //find angle from new axes to origin
              pt ave = P(aFar, bFar);
              vec aveV = V(origin, ave);
              vec identity = U(V(1.0f, 1.0f));
              float rotate = angle(U(aveV), identity);              

              for (int k = 0; k < datapoints.length; k++) {
                pt plot;
                if (angle > 0)
                  plot = P(datapoints[k].getNormalizedValue(a.attribute), datapoints[k].getNormalizedValue(b.attribute));
                else
                  plot = P(datapoints[k].getNormalizedValue(b.attribute), datapoints[k].getNormalizedValue(a.attribute));
                plot.scale(aScale, bScale);

                //  plot = multMatrix(sMatrix, plot);

                plot.rotate(rotate);
                plot.add(origin);                                
                datapoints[k].setDest(plot);
                datapoints[k].line = false;
              }
            }

            dp = dot(U, R(V));
            println("Testing parallel angle " + dp);
            //Otherwise, determine if the two axes are parallel. If so, they should create a parallel coordinate plot.
            if (abs(dp) < .2) {
              println("parallel " + dp);
              for (int k = 0; k < datapoints.length; k++) {
                datapoints[k].line = true;
                datapoints[k].loc = a.getDestinationAlongAxis(datapoints[k]);
                datapoints[k].setDest(b.getDestinationAlongAxis(datapoints[k]));
              }
            }
            //Need to compose bounding boxes for each plot and test for collisions.
          }
        }
      }
    }
}

//Returns the point of intersection between two lines. 
//Returns null if the lines are parallel.
pt linelineintersection(pt a0, pt a1, pt b0, pt b1) {
  pt intersect = null;
  double x1 = a0.x, x2 = a1.x, x3 = b0.x, x4 = b1.x;
  double y1 = a0.y, y2 = a1.y, y3 = b0.y, y4 = b1.y;          
  double denom = det(x1-x2, y1-y2, x3-x4, y3-y4);

  //  println(xNum + " / " + denom + ", " + yNum + " / " + denom);              
  if (denom != 0) {
    double xNum = det(det(x1, y1, x2, y2), x1-x2, det(x3, y3, x4, y4), x3-x4);
    double yNum = det(det(x1, y1, x2, y2), y1-y2, det(x3, y3, x4, y4), y3-y4);
    double originX = xNum / denom;
    double originY = yNum / denom;

    intersect  = P((float)originX, (float)originY);
  }
  return intersect;
}

pt multMatrix(float[][] matrix, pt p) {
  pt result = P(matrix[0][0]*p.x + matrix [0][1]*p.y, matrix[1][0]*p.x+matrix[1][1]*p.y);
  return result;
}

//determine if a point exists on a line. the line is defined by two points.
boolean pointOnLine(pt l1, pt l2, pt a) {
  float m = (l2.y - l1.y) / (l2.x - l1.x);
  boolean pointOnLine = false;
  if (a.y == m*(a.x - l1.x) + l1.y)
    pointOnLine = true;
  return pointOnLine;
}

double det(pt a, pt b) {
  return det(a.x, b.x, a.y, b.y);
}

double det(double a, double b, double c, double d) {
  return a*d-b*c;
}

//determine if point C is aligned with and between points A & B
boolean isBetween(pt A, pt B, pt C) {
  double epsilon = 1E-14;
  boolean isBetween = true;
  double crossProduct = (C.y - A.y) * (B.x - A.x) - (C.x - A.x) * (B.y - A.y);
//  println(crossProduct + " " + epsilon);  
  if (crossProduct > epsilon)
    return false;
  double dotProduct = (C.x - A.x) * (B.x - A.x) + (C.y - A.y)*(B.y - A.y);
//  println(dotProduct + " " + epsilon);  
  if (dotProduct < 0 )
    return false;
  double squaredLengthBA = (B.x - A.x)*(B.x - A.x) + (B.y - A.y)*(B.y - A.y);
//  println(squaredLengthBA + " " + epsilon);  
  if (dotProduct > squaredLengthBA)
    return false;
  return isBetween;
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
}

//void multMatrix(vec 

// called when an object is moved
void updateTuioObject (TuioObject tobj) {
  int id = tobj.getSymbolID();

  //  println("update object "+id+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle()
  //    +" "+tobj.getMotionSpeed()+" "+tobj.getRotationSpeed()+" "+tobj.getMotionAccel()+" "+tobj.getRotationAccel());
  pt fidPt = P(tobj.getX()*screenWidth, tobj.getY()*screenHeight);
  //
  if (id<9 && id>0) {
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

public class ScatterPlot {
  Axis a, b;
  float shear, scaleX, scaleY, rotate;
  pt origin;
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
      stroke(200);

      for (float i = 0; i <= 1; i+=.1f) {
        pt m0 = L(xy0, xy1, i);
        pt m1 = L(xy0, xy1, i+.05);       
        pt r = P(m1);
        r.rotate(HALF_PI, m0); 
        line(m0.x, m0.y, r.x, r.y);
      }

      for (float i = 0; i <= 1; i+=.25f) {
        pt m0 = L(xy0, xy1, i);
        pt m1 = L(xy0, xy1, i+.1);       
        pt r = P(m1);
        r.rotate(HALF_PI, m0); 
        line(m0.x, m0.y, r.x, r.y);
      }

      for (float i = 0; i <= 1; i+=.05f) {
        pt m0 = L(xy0, xy1, i);
        pt m1 = L(xy0, xy1, i+.025);       
        pt r = P(m1);
        r.rotate(HALF_PI, m0); 
        line(m0.x, m0.y, r.x, r.y);
      }

      //Need text labels for the endpoints, perhaps the quarter increment labels.

      fill(255, 0, 0);
      popStyle();
    }
  }
}

