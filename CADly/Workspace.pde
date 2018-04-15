class Workspace{
  ArrayList<Block> blocks;
  boolean updating = false;
  
  Workspace(){
    blocks = new ArrayList<Block>(0);
  }
  
  void addBlock(Block b){
    blocks.add(b);
  }
  
  void draw(){
    for(Block b : blocks){
      b.draw();
    }
  }
  
  void update(){
    while(updating){
      for(Block b : blocks){
        b.update();
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
  
  void mouseDown(){
    boolean searching = true;
    Block b = new Block();
    for(int i = blocks.size() - 1; i >= 0 && searching; i --){
      b = blocks.get(i);
      searching = !b.overlap(mouseX, mouseY);
    }
    if(!searching){
      b.isHeld = true;
    }
  }
}