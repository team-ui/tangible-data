/* Part of the TUIO client*/


class ReadCSV {
  String filePath;
  int length;
  String[] lines;

  ReadCSV(String path) {
    filePath = path;
    lines = loadStrings(filePath);
    length = lines.length-1;
  }

  String getEntry(int line, int column) {

    String[] tokens = split(lines[line], ",");
    return tokens[column - 1];
  }

  float[][] getTwoFields(int col1, int col2) {


    float[][] columns = new float[length][2];

    for (int i = 0; i<length; i++) {
      String[] tokens = split(lines[i+1], ",");

      columns[i][0] = Float.parseFloat(tokens[col1-1]);
      columns[i][1] = Float.parseFloat(tokens[col2-1]);
    }


    return columns;
  }

  DataPoint[] getPoints() {

    DataPoint[] points = new DataPoint[length];

    println("Loading points..");
    for (int i = 0; i<length; i++) {

      String[] tokens = split(lines[i+1], ",");

      float cal = Float.parseFloat(tokens[3]);
      float pro = Float.parseFloat(tokens[4]);
      float fat = Float.parseFloat(tokens[5]);
      float sod = Float.parseFloat(tokens[6]);
      float fib = Float.parseFloat(tokens[7]);
      float car = Float.parseFloat(tokens[8]);
      float sug = Float.parseFloat(tokens[9]);
      float pot = Float.parseFloat(tokens[10]);
      float vit = Float.parseFloat(tokens[11]);


      points[i] = new DataPoint(cal, pro, fat, sod, fib, car, sug, pot, vit);
    }
    println(length + " Points loaded");

    return points;
  }
}

