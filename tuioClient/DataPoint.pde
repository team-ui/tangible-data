class DataPoint {
  pt loc;
  vec v;  
  HashMap<String, Float> dataval;

  // CREATE
  DataPoint() {
    loc = new pt();
  }

  DataPoint(float cal, float pro, float fat, float sod, float fib, float car, float sug, float pot, float vit) {
    loc = new pt();     //initialize the location as the point
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
    v.scaleBy(dataval.get(attr));
  }

  void showvec() {
    fill(0);

    show(loc, v);
  }

  void move(float speed) {
    loc = P(loc, mul(v, speed));
  }
}
