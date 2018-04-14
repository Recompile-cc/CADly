class Block{
  PVector position;
  String nameFormat;
  Block parentBlock;
  Block child;
  color displayColor;
  boolean isHeld;
  float depth;
  String codeFormatter;
  InputField[] fields;
  
  Block(){
    child = null;
  }
  
  void draw(){
  }
  
  String renderString(){
    String output = "";
    if(child == null){
      
    }
    return child.renderString();
  }
  
  void update(){
  }
}