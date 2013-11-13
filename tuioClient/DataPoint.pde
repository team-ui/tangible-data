class DataPoint {
  pt loc;
  pt dest; 
  vec v;  
  HashMap<String, Float> dataval;
  HashMap<String, Float> normdata;

  // CREATE
  DataPoint() {
    loc = new pt();    
    dest = P(loc);
    v = U(loc, dest);
  }


  DataPoint(float cal, float pro, float fat, float sod, float fib, float car, float sug, float pot, float vit) {
    //normalizing values
    loc = new pt();     //initialize the location as the point
    dest = P(loc);
    v = U(loc, dest);
    dataval = new HashMap<String, Float>();

    dataval.put("calories", cal);

    dataval.put("proteins", pro);

    dataval.put("fats", fat); 

    dataval.put("sodium", sod); 

    dataval.put("fiber", fib); 

    dataval.put("carbs", car); 

    dataval.put("sugars", sug); 

    dataval.put("potassium", pot); 

    dataval.put("vitamins", vit);
  }


  //Normalize each data in a range from 0-10
  void fillNorm(float[] min, float[] range) {
    println("Filling normalized values");
    normdata = new HashMap<String, Float>();
    normdata.put("calories", ((dataval.get("calories")-min[0])*10)/range[0]);
    normdata.put("proteins", ((dataval.get("proteins")-min[1])*10)/range[1]);
    normdata.put("fats", ((dataval.get("fats")-min[2])*10)/range[2]);
    normdata.put("sodium", ((dataval.get("sodium")-min[3])*10)/range[3]);
    normdata.put("fiber", ((dataval.get("fiber")-min[4])*10)/range[4]);
    normdata.put("carbs", ((dataval.get("carbs")-min[5])*10)/range[5]);
    normdata.put("sugars", ((dataval.get("sugars")-min[6])*10)/range[6]);
    normdata.put("potassium", ((dataval.get("potassium")-min[7])*10)/range[7]);
    normdata.put("vitamins", ((dataval.get("vitamins")-min[8])*10)/range[8]);

    for (String key : normdata.keySet()) {
      println(normdata.get(key));
    }
  }
  
  //Get normalized value for a DataPoint
  float getNormalizedValue(String attr){
    return normdata.get(attr);
  }

  //Specify which data valued to use as a co-ordinate
  void setloc(String colX, String colY, float bias) {
    //println("Using " + colX + " & " + colY);
    loc = P(dataval.get(colX)+bias, dataval.get(colY)+bias);
  }


  //Explicitly set the location
  void setloc(float X, float Y) {
    println("Explicitly setting the location");
    loc = P(X, Y);
  }

  void showpt() {
    ellipse(loc.x, loc.y, 6, 6);
  }

  //move the points by a certain value
  void showpt(float bias) {
    ellipse(loc.x, loc.y, 6, 6);
  }

  //accepts the center of the fiducial, and sets a vector from  the current point to the fiducial
  void setvec(pt fidPt, String attr) {
    println("calculating vector");
    v = U(V(loc, fidPt));
    v.scaleBy(normdata.get(attr));
  }

  void showvec() {
    fill(0);

    show(loc, v);
  }
  
  //Update the destination to the newest
  void updateAndMove(float speed){
    v = U(loc, dest);
    loc = P(loc, mul(v, speed));      
  }
  
  //Move the datapoint in the direction of the fiducial
  void move(float speed) {
    loc = P(loc, mul(v, speed));
  }
  
}

