PFont openSans;
Workspace workArea;
ToolBox tb;

IntList keyBuffer;

void setup(){
  size(1500, 900);
  keyBuffer = new IntList(0);
  
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
  
  drawDelete();
  drawCodeRender();
}

void drawDelete(){
  pushStyle();
  stroke(255, 20, 20);
  strokeWeight(10);
  line(width-5, height-5, width -60, height -60);
  line(width-60, height -5, width-5, height - 60);
  popStyle();
}

void drawCodeRender(){
  pushStyle();
  ellipseMode(CORNER);
  fill(100, 255, 100);
  ellipse(width - 40, 0, 40, 40);
  popStyle();
}

void pull(int val){
  try{
    for(int i = keyBuffer.size() - 1; i >= 0; i --){
      if(keyBuffer.get(i) == key){
        keyBuffer.remove(i);
      }
    }
  }catch(Exception e){}
}

void keyPressed(){
  keyBuffer.append(key);
}

void keyReleased(){
  pull(key);
}

void mousePressed(){
  if(mouseX > width - 40 && mouseY < 40){
    for(Block b : workArea.blocks){
      if(b.isStart){
        saveStrings("out.scad", new String[]{b.renderCodeString()});
        println("Done");
      }
    }
  } else if(mouseX > tb.wide){
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
  color shapeGenerateColor = color(100, 100, 255);
  color transformColor = color(255, 255, 100);
  
  Block cube = new Block();
  cube.setContainer(false);
  cube.setColor(shapeGenerateColor);
  cube.setPosition(0, 0);
  cube.setConnections("tb");
  cube.setLabel("Cube %IF%");
  cube.setCodeFormatter("cube(%F%);\n");
  tb.addBlockToLibrary(cube);
  
  Block rotate = new Block();
  rotate.setContainer(true);
  rotate.setColor(transformColor);
  rotate.setPosition(0, cube.position.y + cube.size.y + 10);
  rotate.setConnections("tb");
  rotate.setLabel("Rotate X:%IF% Y:%IF% Z:%IF%");
  rotate.setCodeFormatter("rotate([%F%,%F%,%F%]){\n%BLOCKS%}\n");
  tb.addBlockToLibrary(rotate);
}