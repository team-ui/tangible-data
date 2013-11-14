/* Part of the TUIO client*/


class ReadCSV {
  String filePath;
  int length;
  String[] lines;
  float[] max = new float[9];
  float[] min = new float[9];
  float[] range = new float[9];
  ReadCSV(String path) {
    filePath = path;
    lines = loadStrings(filePath);
    length = lines.length-1;
    max = new float[9];
    min = new float[9];
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
    String[] tokens1 = split(lines[1], ",");
    for (int k = 0; k < 9; k++) {
      max[k] = 0;
      min[k] = Float.parseFloat(tokens1[k+3]);
    }

    println("Loading points..");

    for (int i = 0; i<length; i++) {

      String[] tokens = split(lines[i+1], ",");
      float[] values = new float[9];

      for (int k = 0, j = 3; k < 9; k++, j++) { 
        values[k] = Float.parseFloat(tokens[j]);

        if (values[k] > max[k]) {
          max[k] = values[k];
        }
        if (values[k] < min[k]) {
          min[k] = values[k];
        }
      }



      points[i] = new DataPoint(values[0], values[1], values[2], values[3], values[4], values[5], values[6], values[7], values[8]);
    }

    for (int k = 0; k < 9; k++) {
      range[k] = max[k] - min[k];
//      print("max: "+ max[k]);
//      println("min: "+ min[k]);
    }

    println(length + " Points loaded");

    return points;
  }
}

