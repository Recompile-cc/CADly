class Workspace extends BlockBox{
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
      for(int i = blocks.size() - 1; i >= 0; i --){
        blocks.get(i).update(this.eyePos);
      }
      println("Do updates");
      
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
      searching = !b.overlap(mouseX - eyePos.x, mouseY - eyePos.y);
    }
    if(!searching){
      b.isHeld = true;
    } else {
      relativeEye.set(mouseX - eyePos.x, mouseY - eyePos.y);;
      isHeld = true;
    }
  }
}