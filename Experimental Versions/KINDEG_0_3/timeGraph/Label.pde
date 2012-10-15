class Label {
  
  Label(String txt, float x, float y) {
    
    // get text width
    float labelW = textWidth(txt);
    
    // check if label would go beyond screen dims
    if (x + labelW + 20 > width) {
      x -= (labelW + 20);
    }
    
    // draw bg
    fill(0);
    noStroke();
    rectMode(CORNER); // note: this is the default mode. confusing b/c similar to CORNERS (plural)
    rect(x+10, y-30, labelW+10, 22); 
    
    // draw text
    fill(255);
    text(txt, x+15, y-15);

  }
}



class timeEl{
    //details from log
   int y;
   int mon;
   int d;
   int h;
   int m;
   int sec;
   float parameter;
   
   //index in axis
   int index;
   
   timeEl(){
     y=0;
     mon=0;
     d=0;
     h=0;
     m=0;
     sec=0;
     parameter=0;
   }
   
   timeEl(int a1, int a2, int a3, int a4, int a5, int a6, float a7){
     y=a1;
     mon=a2;
     d=a3;
     h=a4;
     m=a5;
     sec=a6;
     parameter=a7;
   }
   
   int isEqual(timeEl t1){
     if (y == t1.y){
       if (mon == t1.mon){
         if (d == t1.d){
           return 1;
         }
       }
     }
     return 0;      
   }
   
   String printDate(){
     println((str(d) + "/" + str(mon) + "/" + str(y)));
     return (str(d) + "/" + str(mon) + "/" + str(y));    
   }
   
   int gety(){
     return y;
   }
   float getparameter(){
     return parameter;
   }
}
