Block bTest;
PFont openSans;

void setup(){
  size(800, 800);
  
  openSans = createFont("Open_Sans/OpenSans-Bold.ttf", 30);
  textFont(openSans);
  textSize(15);
  
  noSmooth();
  
  bTest = new Block();
  bTest.position = new PVector(100, 100);
  bTest.connectors = "tb";
  bTest.setLabel("Cube with side %IF%");
}

void draw(){
  background(255);
  bTest.draw();
}