class Block implements Cloneable{
  PVector position;
  PVector size;
  String[] label;
  Block parentBlock;
  Block child;
  color displayColor;
  boolean isHeld;
  PVector relativeMouse;
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
    displayColor = 0xFF8080FF;
    position = new PVector(0,0);
    size = new PVector(0, 0);
    relativeMouse = new PVector(0, 0);
    
    
    setLabel("");
  }
  
  Block clone(){
    try{
      return (Block)super.clone();
    }catch(Exception e){
      println("NO CLONE");
    }
    return new Block();
  }
  
  void update(){
    if(isHeld){
      float x = mouseX - relativeMouse.x;
      float y = mouseY - relativeMouse.y;
      
      position.set(x, y);
    }
  }
  
  void setLabel(String labelFormat){
    label = split(labelFormat, "%IF%");
    fields = new InputField[label.length - 1];
    for(int i = 0; i < fields.length; i ++){
      fields[i] = new InputField(this);
    }
    
    updateSize();
  }
  
  void updateSize(){
    float wide = marginWidth;
    for(int i = 0; i < label.length; i ++){
      wide += textWidth(label[i]);
    }
    for(int i = 0; i < fields.length; i ++){
      wide += fields[i].getWidth();
    }
    wide += marginWidth;
    
    float tall = doveTailHeight * 3 + (textAscent() + textDescent());
    
    size.set(wide, tall);
  }
  
  void draw(){
    pushMatrix();
    translate(position.x, position.y);
    
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
    vertex(size.x, 0);
    vertex(size.x, size.y);
    
    if(connectors.contains("b")){
      vertex(20, size.y);
      vertex(15, size.y + doveTailHeight);
      vertex(10, size.y);
    }
    vertex(0, size.y);
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
  
  boolean overlap(float x, float y){
    if( (x > position.x && x < position.x + size.x) && (y > position.y && y < position.y + size.y) ){
      relativeMouse.set(x - position.x, y - position.y);
      return true;
    }
    return false;
  }
}