class Block implements Cloneable{
  BlockBox ws;
  PVector position;
  PVector size;
  String[] label;
  String formatLabel;
  InputField[] fields;
  
  color displayColor;
  boolean isHeld;
  PVector relativeMouse;
  String codeFormatter;
  
  String connectors;
  
  static final float marginWidth = 10;
  static final float doveTailHeight = 5;
  
  Block(BlockBox ws){
    this.ws = ws;
    connectors = "";
    displayColor = 0xFF8080FF;
    position = new PVector(0,0);
    size = new PVector(0, 0);
    relativeMouse = new PVector(0, 0);
    
    
    setLabel("");
  }
  
  void setPosition(float x, float y){
    position.set(x, y);
  }
  
  void setConnections(String conns){
    connectors = conns;
  }
  
  void setBox(BlockBox bb){
    ws = bb;
  }
  
  void setLabel(String labelFormat){
    formatLabel = labelFormat;
    label = split(labelFormat, "%IF%");
    fields = new InputField[label.length - 1];
    for(int i = 0; i < fields.length; i ++){
      fields[i] = new InputField(this);
    }
    
    updateSize();
  }
  
  void update(){
    if(isHeld){
      
      float x = mouseX - relativeMouse.x - ws.eyePos.x;
      float y = mouseY - relativeMouse.y - ws.eyePos.y;
      
      position.set(x, y);
    }
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
  
  Block copy(BlockBox bb){
    Block b = new Block(bb);
    b.setLabel(formatLabel);
    b.setConnections(connectors);
    return b;
  }
}