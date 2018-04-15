PFont openSans;
Workspace workArea;

void setup(){
  size(800, 800);
  
  openSans = createFont("Open_Sans/OpenSans-Bold.ttf", 30);
  textFont(openSans);
  textSize(15);
  
  noSmooth();
  
  workArea = new Workspace();
  Block feedBlock = new Block(workArea);
  feedBlock.position.set(100, 100);
  feedBlock.connectors = "tb";
  feedBlock.setLabel("Cube with side length %IF%");
  
  workArea.addBlock(feedBlock.clone());
  
  workArea.startUpdates();
}

void draw(){
  background(255);
  
  workArea.draw();
}

void mousePressed(){
  workArea.mouseDown();
}

void mouseReleased(){
  workArea.mouseUp();
}

void workAreaUpdate(){
  while(workArea.updating){
    workArea.update();
  }
}