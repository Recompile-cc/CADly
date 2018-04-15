class Workspace{
  PVector eyePos;
  PVector relativeEye;
  boolean isHeld;
  ArrayList<Block> blocks;
  boolean updating = false;
  
  Workspace(){
    blocks = new ArrayList<Block>(0);
    eyePos = new PVector(0,0);
    relativeEye = new PVector();
    isHeld = false;
  }
  
  void addBlock(Block b){
    blocks.add(b);
  }
  
  void draw(){
    pushMatrix();
    translate(eyePos.x, eyePos.y);
    for(Block b : blocks){
      b.draw();
    }
    popMatrix();
  }
  
  void update(){
    while(updating){
      for(Block b : blocks){
        b.update();
      }
      if(isHeld){
        eyePos.set(mouseX - relativeEye.x, mouseY - relativeEye.y);
      }
    }
  }
  
  void startUpdates(){
    if(!updating){
      updating = true;
      thread("workAreaUpdate");
    }
  }
  
  void stopUpdates(){
    updating = false;
  }
  
  void mouseUp(){
    for(Block b : blocks){
      if(b.isHeld){
        b.isHeld = false;
      }
    }
    if(isHeld){
      isHeld = false;
    }
  }
  
  void mouseDown(){
    boolean searching = true;
    Block b = new Block();
    for(int i = blocks.size() - 1; i >= 0 && searching; i --){
      b = blocks.get(i);
      searching = !b.overlap(mouseX, mouseY);
    }
    if(!searching){
      b.isHeld = true;
    } else {
      relativeEye.set(mouseX - eyePos.x, mouseY - eyePos.y);;
      isHeld = true;
    }
  }
}