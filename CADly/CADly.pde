Block bTest;

void setup(){
  size(800, 800);
  
  bTest = new Block();
  bTest.position = new PVector(100, 100);
  bTest.connectors = "tb";
}

void draw(){
  background(255);
  bTest.draw();
}