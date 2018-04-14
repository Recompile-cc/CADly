Block bTest;

void setup(){
  size(800, 800);
  
  noSmooth();
  
  bTest = new Block();
  bTest.position = new PVector(100, 100);
  bTest.connectors = "tb";
  bTest.setLabel("Cube with side %IF%");s
}

void draw(){
  background(255);
  bTest.draw();
}