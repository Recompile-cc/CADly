class InputField{
  Block parentBlock;
  String userValue;
  
  InputField(){
  }
  
  void draw(float x, float y, float w, float h){
  }
  
  float getFloatVal(){
    return Float.parseFloat(userValue);
  }
}