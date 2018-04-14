class InputField{
  Block parentBlock;
  String userValue;
  
  InputField(){
    userValue = "";
  }
  
  void draw(float x, float y){
  }
  
  float getFloatVal(){
    return Float.parseFloat(userValue);
  }
  
  float getWidth(){
    //Temporary
    return textWidth(userValue);
  }
}