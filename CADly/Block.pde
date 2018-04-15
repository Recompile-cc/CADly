class Block{
  PVector position;
  String[] label;
  Block parentBlock;
  Block child;
  color displayColor;
  boolean isHeld;
  float depth;
  String codeFormatter;
  InputField[] fields;
  
  boolean isContainer;
  String connectors;
  
  static final float marginWidth = 10;
  static final float doveTailHeight = 5;
  
  Block(){
    child = null;
    connectors = "";
    setLabel("");
    displayColor = 0xFF8080FF;
  }
  
  void setLabel(String labelFormat){
    label = split(labelFormat, "%IF%");
    fields = new InputField[label.length - 1];
    for(int i = 0; i < fields.length; i ++){
      fields[i] = new InputField();
    }
  }
  
  void draw(){
    pushMatrix();
    translate(position.x, position.y);
    
    
    float wide = marginWidth;
    for(int i = 0; i < label.length; i ++){
      wide += textWidth(label[i]);
    }
    for(int i = 0; i < fields.length; i ++){
      wide += fields[i].getWidth();
    }
    wide += marginWidth;
    
    float tall = doveTailHeight * 3 + (textAscent() + textDescent());
    
    fill(displayColor);
    strokeWeight(2);
    stroke(0);
    beginShape();
    vertex(0, 0);
    if(connectors.contains("t")){
      vertex(10, 0);
      vertex(15, doveTailHeight);
      vertex(20, 0);
    }
    vertex(wide, 0);
    vertex(wide, tall);
    
    if(connectors.contains("b")){
      vertex(20, tall);
      vertex(15, tall + doveTailHeight);
      vertex(10, tall);
    }
    vertex(0, tall);
    vertex(0, 0);
    endShape();
    
    textAlign(LEFT, TOP);
    
    fill(0);
    float where = marginWidth;
    for(int i = 0; i < label.length; i ++){
      text(label[i], where, doveTailHeight*1.5);
      where += textWidth(label[i]);
      if(i < fields.length){
        fields[i].draw(where, doveTailHeight*1.5, textAscent() + textDescent());
        where += fields[i].getWidth();
      }
    }
    
    popMatrix();
  }
  
  void update(){
  }
}