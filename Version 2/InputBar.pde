class InputBar{
  boolean show;
  String input;
  String promptText;
  int flashing;
  
  InputBar(){
    show = true;
    input = "";
    promptText = "X: ";
    flashing = 0;
  }
  
  void display(){
    if(show){
      stroke(0);
      strokeWeight(3);
      fill(255);
      rect(50, 50, 700, 50, 25);
      fill(0);
      textSize(30);
      text(promptText+input, 70, 85);
      float cursorPosition = textWidth(promptText+input);
      if(flashing>=70){
        flashing = 0;
      }else if(flashing>=35){
        stroke(255);
      }else{
        stroke(0);
      }
      line(cursorPosition+70, 60, cursorPosition+70, 90);
      flashing++;
    }
  }
}