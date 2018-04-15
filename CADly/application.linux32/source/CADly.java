import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import static javax.swing.JOptionPane.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class CADly extends PApplet {



PFont openSans;
Workspace workArea;
ToolBox tb;

IntList keyBuffer;

public void setup(){
  
  keyBuffer = new IntList(0);
  
  if(!platformNames[platform].equals("linux")){
    surface.setResizable(true);
  }
  PImage icon = loadImage("icon.png");
  surface.setIcon(icon);
  openSans = createFont("Open_Sans/OpenSans-Bold.ttf", 30);
  textFont(openSans);
  textSize(15);
  
  
  
  workArea = new Workspace();
  
  tb = new ToolBox(workArea);
  tb.setWidth(200);
  
  initializeLibrary();
  
  
  workArea.startUpdates();
}

public void draw(){
  background(255);
  
  workArea.draw();
  tb.draw();
  
  drawDelete();
  drawCodeRender();
}

public void drawDelete(){
  pushStyle();
  stroke(255, 20, 20);
  strokeWeight(10);
  line(width-5, height-5, width -60, height -60);
  line(width-60, height -5, width-5, height - 60);
  popStyle();
}

public void drawCodeRender(){
  pushStyle();
  ellipseMode(CORNER);
  fill(100, 255, 100);
  ellipse(width - 40, 0, 40, 40);
  popStyle();
}

public void pull(int val){
  try{
    for(int i = keyBuffer.size() - 1; i >= 0; i --){
      if(keyBuffer.get(i) == key){
        keyBuffer.remove(i);
      }
    }
  }catch(Exception e){}
}

public void keyPressed(){
  keyBuffer.append(key);
}

public void keyReleased(){
  pull(key);
}

public void mousePressed(){
  if(mouseX > width - 40 && mouseY < 40){
      selectOutput("Save SCAD file", "saveFile");  
  } else if(mouseX > tb.wide){
    workArea.mouseDown();
  } else {
    tb.mouseDown();
  }
}

public void mouseReleased(){
  workArea.mouseUp();
}

public void workAreaUpdate(){
  while(workArea.updating){
    workArea.update();
  }
}

public void saveFile(File selection){
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

public void initializeLibrary(){
  int shapeGenerateColor = color(100, 100, 255);
  int transformColor = color(255, 255, 100);
  
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
  move.setCodeFormatter("translate([%F%,%F%,%F%){\n%BLOCKS%}\n");
  tb.addBlockToLibrary(move);
  
  Block difference = new Block();
  difference.setContainer(true);
  difference.setColor(transformColor);
  difference.setPosition(0, move.position.y + move.size.y + 25);
  difference.setConnections("tb");
  difference.setLabel("Cut");
  difference.setCodeFormatter("difference(){\n%BLOCKS%}\n");
  tb.addBlockToLibrary(difference);
  
  Block sphere = new Block();
  sphere.setContainer(false);
  sphere.setColor(shapeGenerateColor);
  sphere.setPosition(0, difference.position.y + difference.size.y + 25);
  sphere.setConnections("tb");
  sphere.setLabel("Ball r:%IF%");
  sphere.setCodeFormatter("sphere(%F%);\n");
  tb.addBlockToLibrary(sphere);
}
class Block implements Cloneable{
  PVector position;
  PVector size;
  String[] label;
  String formatLabel;
  InputField[] fields;
  
  int displayColor;
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
  
  public void setCodeFormatter(String format){
    codeFormatter = format;
  }
  
  public void setContainer(boolean c){
    isContainer = c;
  }
  
  public void setColor(int r, int g, int b){
    displayColor = color(r, g, b);
  }
  
  public void setColor(int argb){
    displayColor = argb;
  }
  
  public void setParentBlock(Block pb){
    hasParent = true;
    parentBlock = pb;
    pb.registerChild(this);
    setPosition(pb.position.x, pb.position.y + pb.size.y);
  }
  
  public void setParentBlock(Block pb, boolean insideContainer){
    if(!pb.isContainer || insideContainer){
      setParentBlock(pb);
      return;
    }
    
    isBottomChild = true;
    parentBlock = pb;
    pb.registerBottomChild(this);
    setPosition(pb.position.x, pb.position.y + pb.getTotalHeight() + 15);
  }
  
  public void registerChild(Block c){
    hasChild = true;
    childBlock = c;
  }
  
  public void registerBottomChild(Block c){
    hasBottomChild = true;
    bottomChildBlock = c;
  }
  
  
  public void setPosition(float x, float y){
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
  
  public void setConnections(String conns){
    connectors = conns;
  }
  
  public void setLabel(String labelFormat){
    formatLabel = labelFormat;
    label = split(labelFormat, "%IF%");
    fields = new InputField[label.length - 1];
    for(int i = 0; i < fields.length; i ++){
      fields[i] = new InputField(this);
    }
    
    updateSize();
  }
  
  public String renderCodeString(){
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
  
  public void update(PVector eyePos){
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
  
  public void updateSize(){
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
  
  public float getTotalHeight(){
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
  
  public void draw(){
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
      text(label[i], where, doveTailHeight*1.5f);
      where += textWidth(label[i]);
      if(i < fields.length){
        fields[i].draw(where, doveTailHeight*1.5f, textAscent() + textDescent());
        where += fields[i].getWidth();
      }
    }
    
    popMatrix();
  }
  
  public void stopEdits(){
    editing = false;
    for(InputField f : fields){
      f.stopEdit();
    }
    updateSize();
  }
  
  public boolean overlap(float x, float y, boolean editable){
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
  
  public void queueDelete(){
    inDeleteQueue = true;
    try{
      childBlock.queueDelete();
    }catch(Exception e){}
  }
  
  public Block copy(){
    Block b = new Block();
    b.setLabel(formatLabel);
    b.setConnections(connectors);
    b.setContainer(isContainer);
    b.setColor(displayColor);
    b.setCodeFormatter(codeFormatter);
    return b;
  }
}
class InputField{
  Block parentBlock;
  String userValue;
  static final float marginWidth = 5;
  boolean editing = false;
  
  InputField(Block pB){
    userValue = "0.0";
    parentBlock = pB;
  }
  
  public void startEdit(){
    editing = true;
    userValue = "";
  }
  
  public void stopEdit(){
    editing = false;
    if(userValue.equals("")){
      userValue = "0.0";
    }
  }
  
  public void update(){
    if(editing){
      if(keyBuffer.get(0) == 8){
        if(userValue.length() > 0){
          userValue = userValue.substring(0, userValue.length() - 1);
        }
      } else if((char)keyBuffer.get(0) == '\n'){
      } else {
        if(Character.isDigit((char)keyBuffer.get(0)) || (char)keyBuffer.get(0) == '.'){
          userValue = userValue + (char)keyBuffer.get(0);
        }
      }
      keyBuffer.remove(0);
    }
  }
  
  public void draw(float x, float y, float textHeight){
    float wide = this.getWidth();
    pushStyle();
    if(editing){
      fill(220, 220, 225);
    } else {
      fill(255);
    }
    noStroke();
    rect(x, y, wide, textHeight);
    fill(0);
    textAlign(CENTER, CENTER);
    text(userValue, x + wide/2, y + textHeight/2);
    
    popStyle();
  }
  
  public float getFloatVal(){
    return Float.parseFloat(userValue);
  }
  
  public float getWidth(){
    float v = textWidth(userValue) + marginWidth*2;
    if(v != 32.0f){ 
    }
    return v;
  }
}
class ToolBox{
  PVector eyePos;
  float wide;
  Block[] library;
  Workspace ws;
  
  ToolBox(Workspace ws){
    this.ws = ws;
    library = new Block[0];
    eyePos = new PVector(10, 10);
  }
  
  public void setWidth(float w){
    wide = w;
  }
  
  public void addBlockToLibrary(Block toAdd){
    library = (Block[])append(library, toAdd);
    if(toAdd.size.x > wide){
      wide = toAdd.size.x + 20;
    }
  }
  
  public void mouseDown(){
    boolean searching = true;
    int i;
    for(i = 0; i < library.length && searching; i ++){
      searching = !library[i].overlap(mouseX - eyePos.x, mouseY - eyePos.y, false);
    }
    if(!searching){
      ws.addBlock(library[i-1].copy());
    }
  }
  
  public void draw(){
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
  
  public void addBlock(Block b){
    b.setPosition(width / 2 - eyePos.x, height / 2 - eyePos.y);
    blocks.add(b);
  }
  
  public void draw(){
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
  
  public void update(){
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
  
  public void startUpdates(){
    while(!updating){
      updating = true;
      thread("workAreaUpdate");
    }
  }
  
  public void stopUpdates(){
    updating = false;
  }
  
  public void mouseUp(){
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
  
  public void mouseDown(){
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
  public void settings() {  size(1500, 900);  noSmooth(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "CADly" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
