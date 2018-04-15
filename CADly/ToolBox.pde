class ToolBox extends BlockBox{
  float wide;
  Block[] library;
  Workspace ws;
  
  ToolBox(Workspace ws){
    this.ws = ws;
    library = new Block[0];
    eyePos = new PVector(10, 10);
  }
  
  void setWidth(float w){
    wide = w;
  }
  
  void addBlockToLibrary(Block toAdd){
    library = (Block[])append(library, toAdd);
  }
  
  void mouseDown(){
    boolean searching = true;
    int i;
    for(i = 0; i < library.length && searching; i ++){
      searching = !library[i].overlap(mouseX - eyePos.x, mouseY - eyePos.y);
    }
    if(!searching){
      ws.addBlock(library[i-1].copy());
    }
  }
  
  void draw(){
    pushStyle();
    fill(225);
    stroke(0);
    strokeWeight(1);
    rect(0, 0, wide, height);
    
    pushMatrix();
    translate(eyePos.x, eyePos.y);
    
    for(Block b : library){
      b.draw();
    }
    popMatrix();
    popStyle();
  }
}