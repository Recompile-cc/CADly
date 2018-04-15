class InputField{
  Block parentBlock;
  String userValue;
  static final float marginWidth = 5;
  
  InputField(){
    userValue = "0.0";
  }
  
  void draw(float x, float y, float textHeight){
    float wide = this.getWidth();
    pushStyle();
    fill(255);
    noStroke();
    rect(x, y, wide, textHeight);
    fill(0);
    textAlign(CENTER, CENTER);
    text(userValue, x + wide/2, y + textHeight/2);
    
    popStyle();
  }
  
  float getFloatVal(){
    return Float.parseFloat(userValue);
  }
  
  float getWidth(){
    //Temporary
    return textWidth(userValue) + marginWidth*2;
  }
}