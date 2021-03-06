class Workspace{
  PVector eyePos;
  PVector relativeEye;
  boolean isHeld;
  ArrayList<Block> blocks;
  boolean updating = false;
  
  static final float majorGridSize = 100;
  static final float minorGridSize = 20;
  
  Workspace(){
    blocks = new ArrayList<Block>(0);
    eyePos = new PVector(0,0);
    relativeEye = new PVector();
    isHeld = false;
  }
  
  void addBlock(Block b){
    b.setPosition(width / 2 - eyePos.x, height / 2 - eyePos.y);
    blocks.add(b);
  }
  
  void draw(){
    pushMatrix();
    translate(eyePos.x, eyePos.y);
    
    
    stroke(225);
    strokeWeight(2);
    float start = floor(-eyePos.x/minorGridSize)*minorGridSize;
    for(float i = start; i < width - eyePos.x; i += minorGridSize){
      line(i, -eyePos.y, i, height - eyePos.y);
    }
    strokeWeight(1);
    start = floor(-eyePos.y/minorGridSize)*minorGridSize;
    for(float i = start; i < height - eyePos.y; i += minorGridSize){
      line(-eyePos.x, i, width - eyePos.x, i);
    }
    
    stroke(180);
    strokeWeight(2);
    start = floor(-eyePos.x/majorGridSize)*majorGridSize;
    for(float i = start; i < width - eyePos.x; i += majorGridSize){
      line(i, -eyePos.y, i, height - eyePos.y);
    }
    strokeWeight(1);
    start = floor(-eyePos.y/majorGridSize)*majorGridSize;
    for(float i = start; i < height - eyePos.y; i += majorGridSize){
      line(-eyePos.x, i, width - eyePos.x, i);
    }
    
    for(Block b : blocks){
      b.draw();
    }
    popMatrix();
  }
  
  void update(){
    if(updating){
      boolean hasStart = false;
      try{
        for(int i = blocks.size() - 1; i >= 0; i --){
          blocks.get(i).update(this.eyePos);
          if(!hasStart){
            hasStart = blocks.get(i).isStart;
          }
        }
        
        if(!hasStart){
          Block start = new Block();
          start.setColor(100, 255, 100);
          start.setPosition(0, 0);
          start.setConnections("b");
          start.setLabel("Start");
          start.isStart = true;
          addBlock(start);
        }
      } catch(Exception e){}
     
      print();
      
      if(isHeld){
        eyePos.set(mouseX - relativeEye.x, mouseY - relativeEye.y);
      }
    }
  }
  
  void startUpdates(){
    while(!updating){
      updating = true;
      thread("workAreaUpdate");
    }
  }
  
  void stopUpdates(){
    updating = false;
  }
  
  void mouseUp(){
    if(mouseX > width-60 && mouseY > height -60){
      for(Block b : blocks){
        if(b.isHeld){
          b.queueDelete();
        }
      }
      
      for(int i = blocks.size() -1; i >= 0; i --){
        if(blocks.get(i).inDeleteQueue){
          blocks.remove(i);
        }
      }
    } else {
      for(int i = 0; i < blocks.size(); i ++){
        Block b = blocks.get(i);
        if(b.isHeld){
          b.isHeld = false;
          boolean s = true;
          for(int j = blocks.size() - 1; j >= 0 && s; j --){
            if(j != i){
              Block b1 = blocks.get(j);
              if(b.position.x > b1.position.x - 5 && b.position.x < b1.position.x + b1.size.x && b1.connectors.contains("b") && b.connectors.contains("t")){
                float totalHeight = 0;
                if(b1.isContainer){
                  totalHeight = b1.getTotalHeight();
                }
                if(b.position.y > b1.position.y + b1.size.y - 25 && b.position.y < b1.position.y + b1.size.y + 15){
                  b.setParentBlock(blocks.get(j));
                  s = false;
                } else  if(b1.isContainer && b.position.y > b1.position.y +  totalHeight -25 && b.position.y < b1.position.y + totalHeight +15){
                  b.setParentBlock(blocks.get(j), false);
                  s = false;
                }
              }
            }
          }
        }
      }
      if(isHeld){
        isHeld = false;
      }
    }
  }
  
  void mouseDown(){
    boolean searching = true;
    Block b = new Block();
    int i;
    for(Block b1 : blocks){
      b1.stopEdits();
    }
    for(i = blocks.size() - 1; i >= 0 && searching; i --){
      b = blocks.get(i);
      searching = !b.overlap(mouseX - eyePos.x, mouseY - eyePos.y, true);
    }
    if(!searching){
      b.isHeld = true;
      blocks.add(b);
      blocks.remove(i+1);
      if(b.hasParent){
        b.parentBlock.hasChild = false;
        b.hasParent = false;
      } else if(b.isBottomChild){
        b.parentBlock.hasBottomChild = false;
        b.isBottomChild = false;
      }
    } else {
      relativeEye.set(mouseX - eyePos.x, mouseY - eyePos.y);;
      isHeld = true;
    }
  }
}