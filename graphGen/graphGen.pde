float plotX1, plotX2, plotY1, plotY2;
int leftMargin = 30;
int topMargin = 100;
int plotHeight = 250;
float timer = 0.0;
PFont helvetica;

void setup(){
  size(1280, 480);
  smooth();
  helvetica = createFont("Helvetica-Bold", 14);
  textFont(helvetica);
  
  // set plot size
  plotX1 = leftMargin;
  plotX2 = width - leftMargin;
  plotY1 = topMargin;
  plotY2 = height - topMargin;
}

class timeEl{
    //details from log
   int y;
   int mon;
   int d;
   int h;
   int m;
   int sec;
   int pplNum;
   
   //index in axis
   int index;
   
   timeEl(){
     y=0;
     mon=0;
     d=0;
     h=0;
     m=0;
     sec=0;
     pplNum=0;
   }
   
   timeEl(int a1, int a2, int a3, int a4, int a5, int a6, int a7){
     y=a1;
     mon=a2;
     d=a3;
     h=a4;
     m=a5;
     sec=a6;
     pplNum=a7;
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
   
   int gety(){
     return y;
   }
   int getPplNum(){
     return pplNum;
   }
}

void draw(){
  //data generator
  String log2lines[] = loadStrings("log2.txt");
  println("there are " + log2lines.length + " lines");
  ArrayList dateList=new ArrayList();
  ArrayList xaxis = new ArrayList();
  ArrayList yaxis = new ArrayList();
  char choice = 'y';

  //checked
  for (int i =0 ; i < log2lines.length; i++) 
  {
      String[] Els = split(log2lines[i], '-');
      int y = parseInt(Els[0]);
      int mon = parseInt(Els[1]);
      int d =  parseInt(Els[2]);
      int h =  parseInt(Els[3]);
      int m =  parseInt(Els[4]);
      int sec =  parseInt(Els[5]);
      int pplNum = parseInt(Els[6]);
      timeEl date = new timeEl(y,mon,d,h,m,sec,pplNum); 
      dateList.add(date); 
  }
  
  timeEl temp;
  int tempInt;
  //classify by year
  switch(choice){
    case 'y': //sort by year
      
      for (int i = 0; i<dateList.size(); i++){
        
        temp = (timeEl)dateList.get(i);
        if (isIn(xaxis,(temp.gety()))!=1){//if not in xaxis already
          //put it in
          
          xaxis.add(temp.y);
          yaxis.add(temp.pplNum);
          
          
          
        }
        else{//if already in
          println("in else");
          println(i);
          temp = (timeEl)dateList.get(i);
          int ind = findIndex(xaxis, temp.y);
          print(ind);
          tempInt = (Integer)yaxis.get(ind);

          yaxis.set(ind,tempInt + temp.pplNum);
         
        }  
      }
      break;
    
    case 'm': //sort by month
    
      for (int i = 0; i<dateList.size(); i++){
        temp = (timeEl)dateList.get(i);
        if (isIn(xaxis,temp.mon)==0){//if not in xaxis already
          //put it in
          xaxis.add(temp.mon);
         yaxis.add(temp.pplNum);     
        }
        else{//if already in xaxis
          int ind = findIndex(xaxis, temp.mon); 
          tempInt = (Integer)yaxis.get(ind);
          yaxis.set(ind,tempInt + temp.pplNum);
        }  
      }
      break;
    
    case 'd': //sort by day/date
        println("im lost");
        int token = -1;
        ArrayList dates=new ArrayList();//match with index, just for keeping track purpose
        for (int i = 0; i<dateList.size(); i++){
          temp = (timeEl)dateList.get(i);
          if (isDateIn(dates,temp)==0){//if date has not appeared
            //put it in
            token++;
            dates.add(temp);
            xaxis.add(token);
            yaxis.add(temp.pplNum);   
          }
          else{//if date has appeared
          //assuming chronological order, token is index

            
            
            tempInt = (Integer)yaxis.get(token);
            yaxis.set(token,tempInt + temp.pplNum);
          } 
        }
        break;
    
    
    
    
      
    
    case 'h': //sort by hour
        for (int i = 0; i<dateList.size(); i++){
          temp = (timeEl)dateList.get(i);
          if (isIn(xaxis,temp.h)==0){//if not in xaxis already
            //put it in
            xaxis.add(temp.h);
           yaxis.add(temp.pplNum);     
          }
          else{//if already in
            int ind = findIndex(xaxis, temp.h);
 
            
            tempInt = (Integer)yaxis.get(ind);
          yaxis.set(ind,tempInt + temp.pplNum);
          }  
        }
        break;
    
    
    default:
    break;
    
  }
  
  printIntArray(xaxis);
  printIntArray(yaxis);
  
  int[] arrx = intArrayList2Array(xaxis);
  int[] arry = intArrayList2Array(yaxis);

  
  
  ////////////////////////////////////////////////////////////////////////////
  //real draw
   background(0);
  
  // draw plot background
  fill(255);
  noStroke();
  rectMode(CORNERS);
  rect(plotX1, plotY1, plotX2, plotY2);
  
  //line(plotX1, height - topMargin, plotX2, height - topMargin);
  //line(plotX1, height - topMargin, plotX1, height - topMargin - plotHeight);
  
  noFill();
  stroke(0);
  strokeWeight(2);  
  beginShape();
  
  float x, y;
  
  /*
  // double curve vertext points
  x = map(0, 0, values.length-1, plotX1, plotX2);
  y = map(values[0], 0, 200, height - topMargin, height - topMargin - plotHeight);
  curveVertex(x, y);
  */
  
  for (int i = 0; i < arry.length; i++) {
    x = map(i, 0, arry.length-1, plotX1, plotX2);
    y = map(arry[i], 0, max(arry), height - topMargin, height - topMargin - plotHeight);
    vertex(x, y);
  }
  
  /*
  // double curve vertext points
  x = map(values.length-1, 0, values.length-1, plotX1, plotX2);
  y = map(values[values.length-1], 0, 200, height - topMargin, height - topMargin - plotHeight);
  curveVertex(x, y); 
  */
  
  endShape();
  
  // draw points on mouse over
  for (int i = 0; i < arry.length; i++) {
    x = map(i, 0, arry.length-1, plotX1, plotX2);
    y = map(arry[i], 0, max(arry), height - topMargin, height - topMargin - plotHeight);
       
    // check mouse pos
    // float delta = dist(mouseX, mouseY, x, y);
    float delta = abs(mouseX - x);
    if ((delta < 2) && (y > plotY1) && (y < plotY2)) {
      stroke(255);
      fill(0);
      ellipse(x, y, 8, 8);
      
      int labelVal = round(arry[i]);
      Label label = new Label("" + labelVal, x, y);
      //Label label2 = new Label("haha",x-10,y-10);
    }
  }
  
  
  ///////////////////////////////////////////////////////////////////
  
}
    
int isIn(ArrayList intList, int x){
  for (int i=0; i<intList.size(); i++){
    if (x==(Integer)intList.get(i)){
      return 1;
    }
  }
  
  return 0;  
  
} 



int findIndex(ArrayList intList, int x){
  //intList should be checked to be populated beforehand
  for (int i=0; i<intList.size(); i++){
    if (x==(Integer)intList.get(i)){
      return i;
    }
  }
  return 0; //shouldn't need to come here if intList was populated
  
}
    
    
void printIntArray(ArrayList intList){
  println("START printing");
  print("array size is "+intList.size()+"\n");
  
   for (int i=0; i<intList.size(); i++){
      int t = (Integer)intList.get(i);
      println(t);
  }
  println("END printing");
}  


int isDateIn(ArrayList dateList, timeEl x){
  timeEl tempDate;
  for (int i=0; i<dateList.size(); i++){
    tempDate = (timeEl)dateList.get(i);
    if (tempDate.isEqual(x)==1){
      return 1;
    }
  }
  return 0;
}
 
 //convert arraylist to array (int)   
int[] intArrayList2Array(ArrayList lis){
  int[] arr = new int[lis.size()];
  for (int i =0; i<lis.size(); i++){
    arr[i] = (Integer)lis.get(i);
  }
  return arr;
}

