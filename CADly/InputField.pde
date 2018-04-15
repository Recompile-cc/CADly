class InputField{
  Block parentBlock;
  String userValue;
  static final float marginWidth = 5;
  boolean editing = false;
  
  InputField(Block pB){
    userValue = "0.0";
    parentBlock = pB;
  }
  
  void startEdit(){
    editing = true;
    userValue = "";
  }
  
  void stopEdit(){
    editing = false;
    if(userValue.equals("")){
      userValue = "0.0";
    }
  }
  
  void update(){
    if(editing){
      if(keyBuffer.get(0) == 8){
        if(userValue.length() > 0){
          userValue = userValue.substring(0, userValue.length() - 1);
        }
      } else if((char)keyBuffer.get(0) == '\n'){
      } else {
        userValue = userValue + (char)keyBuffer.get(0);
      }
      keyBuffer.remove(0);
    }
  }
  
  void draw(float x, float y, float textHeight){
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
  
  float getFloatVal(){
    return Float.parseFloat(userValue);
  }
  
  float getWidth(){
    //Temporary
    return textWidth(userValue) + marginWidth*2;
  }
}