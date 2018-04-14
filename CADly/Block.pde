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
  
  boolean isContainer;
  String connectors;
  
  Block(){
    child = null;
    connectors = "";
  }
  
  void draw(){
    pushMatrix();
    translate(position.x, position.y);
    
    int wide = 90;
    int tall = 35;
    
    fill(100, 100, 200);
    strokeWeight(2);
    stroke(0);
    beginShape();
    vertex(0, 0);
    if(connectors.contains("t")){
      vertex(10, 0);
      vertex(15, 5);
      vertex(20, 0);
    }
    vertex(wide, 0);
    vertex(wide, tall);
    
    if(connectors.contains("b")){
      vertex(20, tall);
      vertex(15, tall + 5);
      vertex(10, tall);
    }
    vertex(0, tall);
    vertex(0, 0);
    endShape();
    
    popMatrix();
  }
  
  void update(){
  }
}