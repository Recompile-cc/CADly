import static javax.swing.JOptionPane.*;

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
      selectOutput("Save SCAD file", "saveFile");  
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

void saveFile(File selection){
  if (selection == null){
    showMessageDialog(null, "No Save selected.", "Alert", ERROR_MESSAGE);
  }else{
    for(Block b : workArea.blocks){
      if(b.isStart){
        saveStrings(selection.getAbsolutePath() + ".scad" , new String[]{b.renderCodeString()});
        println("Saved to: " + selection.getAbsolutePath() + ".scad");
      }
    }
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
  cube.setCodeFormatter("cube(%F%, center = true);\n");
  tb.addBlockToLibrary(cube);
  
  Block rotate = new Block();
  rotate.setContainer(true);
  rotate.setColor(transformColor);
  rotate.setPosition(0, cube.position.y + cube.size.y + 10);
  rotate.setConnections("tb");
  rotate.setLabel("Rotate X:%IF% Y:%IF% Z:%IF%");
  rotate.setCodeFormatter("rotate([%F%,%F%,%F%]){\n%BLOCKS%}\n");
  tb.addBlockToLibrary(rotate);
  
  Block cylinder = new Block();
  cylinder.setContainer(false);
  cylinder.setColor(shapeGenerateColor);
  cylinder.setPosition(0, rotate.position.y + rotate.size.y + 25);
  cylinder.setConnections("tb");
  cylinder.setLabel("Cylinder H:%IF% R:%IF%");
  cylinder.setCodeFormatter("cylinder( h = %F%, r = %F%, center = true);\n");
  tb.addBlockToLibrary(cylinder);

  Block move = new Block();
  move.setContainer(true);
  move.setColor(transformColor);
  move.setPosition(0, cylinder.position.y + cylinder.size.y + 10);
  move.setConnections("tb");
  move.setLabel("Move X:%IF% Y:%IF% Z:%IF%");
  move.setCodeFormatter("translate([%F%,%F%,%F%){\n%BLOCKS%\n}\n");
  tb.addBlockToLibrary(move);
}
