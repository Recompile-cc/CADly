class Block implements Cloneable{
  PVector position;
  PVector size;
  String[] label;
  String formatLabel;
  InputField[] fields;
  
  color displayColor;
  boolean isHeld;
  PVector relativeMouse;
  String codeFormatter;
  
  String connectors; //'b' for bottom, 't' for top
  
  boolean hasParent = false;
  boolean hasChild = false;
  Block parentBlock;
  Block childBlock;
  
  boolean editing = false;
  
  boolean isContainer = false;
  
  static final float marginWidth = 10;
  static final float doveTailHeight = 5;
  
  Block(){
    connectors = "";
    displayColor = 0xFF8080FF;
    position = new PVector(0,0);
    size = new PVector(0, 0);
    relativeMouse = new PVector(0, 0);
    
    
    setLabel("");
  }
  
  void setContainer(boolean c){
    isContainer = c;
  }
  
  void setParentBlock(Block pb){
    hasParent = true;
    parentBlock = pb;
    pb.registerChild(this);
    setPosition(pb.position.x, pb.position.y + pb.size.y);
  }
  
  void registerChild(Block c){
    hasChild = true;
    childBlock = c;
  }
  
  void setPosition(float x, float y){
    position.set(x, y);
    try{
      if(childBlock.hasParent && hasChild){
        childBlock.setPosition(x, y + size.y);
      }
    }catch (Exception e){}
  }
  
  void setConnections(String conns){
    connectors = conns;
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
  
  void update(PVector eyePos){
    if(editing){
      updateSize();
      for(InputField f : fields){
        f.update();
      }
    }
    if(isHeld){
      
      float x = mouseX - relativeMouse.x - eyePos.x;
      float y = mouseY - relativeMouse.y - eyePos.y;
      
      setPosition(x, y);
      //position.set(x, y);
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
  
  float getTotalHeight(){
    float tHeight = 0;
    Block hTree = this;
    while(hTree.hasChild){
      tHeight += hTree.size.y;
      hTree = hTree.childBlock;
    }
    tHeight += hTree.size.y;
    return tHeight;
  }
  
  void draw(){
    pushMatrix();
    translate(position.x, position.y);
    
    fill(displayColor);
    strokeWeight(2);
    stroke(0);
    beginShape();
    if(connectors.contains("c")){
      vertex(-10, 0);
    }
    vertex(0, 0);
    if(connectors.contains("t")){
      vertex(10, 0);
      vertex(15, doveTailHeight);
      vertex(20, 0);
    }
    vertex(size.x, 0);
    vertex(size.x, size.y);
    
    if(connectors.contains("b") || isContainer){
      vertex(20, size.y);
      vertex(15, size.y + doveTailHeight);
      vertex(10, size.y);
    }
    vertex(0, size.y);
    if(isContainer){
      float totalHeight = getTotalHeight();
      vertex(0, totalHeight);
      vertex(size.x, totalHeight);
      vertex(size.x, totalHeight + 10);
      vertex(-10, totalHeight + 10);
      vertex(-10, 0);
    }
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
  
  void stopEdits(){
    editing = false;
    for(InputField f : fields){
      f.stopEdit();
    }
    updateSize();
  }
  
  boolean overlap(float x, float y){
    if( (x > position.x && x < position.x + size.x) && (y > position.y && y < position.y + size.y) ){
      float target = marginWidth;
      for(int i = 0; i < label.length; i ++){
        target += textWidth(label[i]);
        if(i < fields.length){
          if(x > position.x + target && x < position.x + target + fields[i].getWidth()){
            fields[i].startEdit();
            this.editing = true;
            return false;
          }
          target += fields[i].getWidth();
        }
      }
      
      
      relativeMouse.set(x - position.x, y - position.y);
      return true;
    }
    return false;
  }
  
  Block copy(){
    Block b = new Block();
    b.setLabel(formatLabel);
    b.setConnections(connectors);
    b.setContainer(isContainer);
    return b;
  }
}