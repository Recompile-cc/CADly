PFont openSans;
Workspace workArea;
ToolBox tb;

void setup(){
  size(1500, 900);
  
  if(!platformNames[platform].equals("linux")){
    surface.setResizable(true);
  }
  
  openSans = createFont("Open_Sans/OpenSans-Bold.ttf", 30);
  textFont(openSans);
  textSize(15);
  
  noSmooth();
  
  workArea = new Workspace();
  
  tb = new ToolBox(workArea);
  tb.setWidth(200);
  
  initializeLibrary();
  
  
  workArea.startUpdates();
}

void draw(){
  background(255);
  
  workArea.draw();
  tb.draw();
}

void mousePressed(){
  if(mouseX > tb.wide){
    workArea.mouseDown();
  } else {
    tb.mouseDown();
  }
}

void mouseReleased(){
  workArea.mouseUp();
}

void workAreaUpdate(){
  while(workArea.updating){
    workArea.update();
  }
}

void initializeLibrary(){
  Block blockBuilder = new Block();
  blockBuilder.setPosition(0, 0);
  blockBuilder.setConnections("b");
  blockBuilder.setLabel("Start");
  tb.addBlockToLibrary(blockBuilder);
  
  Block blockBuilder1 = new Block();
  blockBuilder1.updateSize();
  blockBuilder1.setPosition(0, 60);
  blockBuilder1.setConnections("tb");
  blockBuilder1.setLabel("Cube with side length %IF%");
  tb.addBlockToLibrary(blockBuilder1);
}