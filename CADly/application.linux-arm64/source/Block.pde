class Block implements Cloneable{
  PVector position;
  PVector size;
  String[] label;
  String formatLabel;
  InputField[] fields;
  
  color displayColor;
  boolean isHeld;
  PVector relativeMouse;
  
  String codeFormatter; //%F% for a float, reads from the inputFields. %BLOCKS% reads from encapsulated blocks 
  
  String connectors; //'b' for bottom, 't' for top
  
  boolean isBottomChild = false;
  
  boolean hasParent = false;
  boolean hasChild = false;
  boolean hasBottomChild = false;
  Block parentBlock;
  Block childBlock;
  Block bottomChildBlock;
  
  boolean editing = false;
  
  boolean isStart = false;
  
  boolean isContainer = false;
  
  boolean inDeleteQueue = false;
  
  static final float marginWidth = 10;
  static final float doveTailHeight = 5;
  
  Block(){
    connectors = "";
    displayColor = 0xFF8080FF;
    position = new PVector(0,0);
    size = new PVector(0, 0);
    relativeMouse = new PVector(0, 0);
    codeFormatter = "";
    
    editing = false;
    
    setLabel("");
  }
  
  void setCodeFormatter(String format){
    codeFormatter = format;
  }
  
  void setContainer(boolean c){
    isContainer = c;
  }
  
  void setColor(int r, int g, int b){
    displayColor = color(r, g, b);
  }
  
  void setColor(int argb){
    displayColor = argb;
  }
  
  void setParentBlock(Block pb){
    hasParent = true;
    parentBlock = pb;
    pb.registerChild(this);
    setPosition(pb.position.x, pb.position.y + pb.size.y);
  }
  
  void setParentBlock(Block pb, boolean insideContainer){
    if(!pb.isContainer || insideContainer){
      setParentBlock(pb);
      return;
    }
    
    isBottomChild = true;
    parentBlock = pb;
    pb.registerBottomChild(this);
    setPosition(pb.position.x, pb.position.y + pb.getTotalHeight() + 15);
  }
  
  void registerChild(Block c){
    hasChild = true;
    childBlock = c;
  }
  
  void registerBottomChild(Block c){
    hasBottomChild = true;
    bottomChildBlock = c;
  }
  
  
  void setPosition(float x, float y){
    position.set(x, y);
    try{
      if(hasChild && childBlock.hasParent){
        childBlock.setPosition(x, y + size.y);
      }
      if(hasBottomChild && bottomChildBlock.isBottomChild){
        bottomChildBlock.setPosition(x, y + getTotalHeight() + 15);
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
  
  String renderCodeString(){
    /*
    String theCode = "";
    Block head = this;
    int depth = 0;
    boolean ascending = false;
    while(head.hasChild || depth > 0){
      String headCode = head.codeFormatter;
      String[] headCodeTokens = split(headCode, "%F%");
      for(int i = 0; i < headCodeTokens.length - 1; i ++){
        theCode += headCodeTokens[i];
        if(i < fields.length){
          fields[i].getFloatVal();
        }
      }
      
      
    }*/
    String code = "";
    String[] frags = split(codeFormatter, "%F%");
    for(int i = 0; i < frags.length; i ++){
      code += frags[i];
      if(i < fields.length){
        code += fields[i].getFloatVal();
      }
    }
    
    if(isContainer){
      frags = split(code, "%BLOCKS%");
      code = "";
      
      code += frags[0];
      if(hasChild){
        code += childBlock.renderCodeString();
      }
      code += frags[1];
      
      if(hasBottomChild){
        return code += bottomChildBlock .renderCodeString();
      }
    }else if(hasChild){
      return code + childBlock.renderCodeString();
    }
    
    return code;
  }
  
  void update(PVector eyePos){
    if(editing){
      updateSize();
      for(InputField f : fields){
        if(f.editing){
          f.update();
        }
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
      if(hTree.isContainer){
        tHeight += 15;
      }
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
      vertex(size.x, totalHeight + 15);
      
      vertex(20, totalHeight + 15);
      vertex(15, doveTailHeight + totalHeight + 15);
      vertex(10, totalHeight + 15);
      
      vertex(-10, totalHeight + 15);
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
  
  boolean overlap(float x, float y, boolean editable){
    if( (x > position.x && x < position.x + size.x) && (y > position.y && y < position.y + size.y) ){
      if(editable){
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
      }
      
      
      relativeMouse.set(x - position.x, y - position.y);
      return true;
    }
    return false;
  }
  
  void queueDelete(){
    inDeleteQueue = true;
    try{
      childBlock.queueDelete();
    }catch(Exception e){}
  }
  
  Block copy(){
    Block b = new Block();
    b.setLabel(formatLabel);
    b.setConnections(connectors);
    b.setContainer(isContainer);
    b.setColor(displayColor);
    b.setCodeFormatter(codeFormatter);
    return b;
  }
}
