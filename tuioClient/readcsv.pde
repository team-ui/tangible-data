/* Part of the TUIO client*/


class ReadCSV{
  String filePath;
  
  ReadCSV(String path){
    filePath = path;
  }
  
  String getEntry(int line, int column){
    String[] lines = loadStrings(filePath);
    String[] tokens = split(lines[line],",");
    return tokens[column - 1];
    
    
  }
}
