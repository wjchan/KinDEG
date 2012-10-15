float plotX1, plotX2, plotY1, plotY2;
int leftMargin = 30;
int topMargin = 100;
int plotHeight = 250;
float timer = 0.0;
PFont comicSans;
char choice = 'c';
String logChoice = "C:/Users/Wei Jian/Desktop/EXPERIMENT2/NEWER/totalUserLog.txt";
String totalUserLog = "C:/Users/Wei Jian/Desktop/EXPERIMENT2/NEWER/totalUserLog.txt";
String engagedUsersLog = "C:/Users/Wei Jian/Desktop/EXPERIMENT2/NEWER/engagedVisitorsLog.txt";


void setup(){
  size(640, 480);
  smooth();
  comicSans = createFont("Comic Sans MS", 15);
  textFont(comicSans);
  
  // set plot size
  plotX1 = leftMargin;
  plotX2 = width - leftMargin;
  plotY1 = topMargin;
  plotY2 = height - topMargin;
}



void draw(){
  //data generator
  String log2lines[] = loadStrings(logChoice);
  //println("there are " + log2lines.length + " lines");
  ArrayList dateList=new ArrayList();
  ArrayList xaxis = new ArrayList();
  ArrayList yaxis = new ArrayList();
  ArrayList tokenArray = new ArrayList();
  
  //checked
  if (log2lines != null){
  for (int i =0 ; i < log2lines.length; i++) 
  {
      String[] Els = split(log2lines[i], '-');
      int y = parseInt(Els[0]);
      int mon = parseInt(Els[1]);
      int d =  parseInt(Els[2]);
      int h =  parseInt(Els[3]);
      int m =  parseInt(Els[4]);
      int sec =  parseInt(Els[5]);
      float parameter = parseFloat(Els[6]);
      timeEl date = new timeEl(y,mon,d,h,m,sec,parameter); 
      dateList.add(date); 
  }
  
  timeEl temp;
  float tempInt;
  //classify by year
  switch(choice){
    case 'y': //sort by year
      
      for (int i = 0; i<dateList.size(); i++){
        
        temp = (timeEl)dateList.get(i);
        if (isIn(xaxis,(temp.gety()))!=1){//if not in xaxis already
          //put it in
          
          xaxis.add(temp.y);
          yaxis.add(temp.parameter);
          
          
          
        }
        else{//if already in
          println("in else");
          //println(i);
          temp = (timeEl)dateList.get(i);
          int ind = findIndex(xaxis, temp.y);
          print(ind);
          tempInt = (Float)yaxis.get(ind);

          yaxis.set(ind,tempInt + temp.parameter);
         
        }  
      }
      break;
    
    case 'm': //sort by month
    
      for (int i = 0; i<dateList.size(); i++){
        temp = (timeEl)dateList.get(i);
        if (isIn(xaxis,temp.mon)==0){//if not in xaxis already
          //put it in
          xaxis.add(temp.mon);
         yaxis.add(temp.parameter);     
        }
        else{//if already in xaxis
          int ind = findIndex(xaxis, temp.mon); 
          tempInt = (Integer)yaxis.get(ind);
          yaxis.set(ind,tempInt + temp.parameter);
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
            yaxis.add(temp.parameter);   
            tokenArray.add(temp);
          }
          else{//if date has appeared
          //assuming chronological order, token is index

            
            
            tempInt = (Float)yaxis.get(token);
            yaxis.set(token,tempInt + temp.parameter);
          } 
        }
        break;
    
    
    
    
      
    
    case 'c': //sort by custom (works as long as within a day)
        for (int i = 0; i<dateList.size(); i++){
          temp = (timeEl)dateList.get(i);
          
          String hourPart;
          if (temp.h<10){
            hourPart = "0" + str(temp.h);
          }
          else{
            hourPart = str(temp.h);
          }
          
          String minPart;
           if (temp.m<10){
            minPart = "0" + str(temp.m);
          }
          else{
            minPart = str(temp.m);
          }
          
          String secPart;
          if (temp.sec<10){
            secPart = "0" + str(temp.sec);
          }
          else{
            secPart = str(temp.sec);
          }
          int temp2 = parseInt(hourPart + minPart+secPart);
          if (isIn(xaxis,temp2)==0){//if not in xaxis already
            //put it in
           xaxis.add(temp2);
           yaxis.add(temp.parameter);     
          }
 
        }
        break;
    default:
    break;
    
  }
  
  printIntArray(xaxis);
 // printIntArray(yaxis);
  
  int[] arrx = intArrayList2Array(xaxis);
  float[] arry = floatArrayList2Array(yaxis);

  
  
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
      
      float labelVal = arry[i];
      Label label = new Label("" + labelVal, x, y);
      if (choice == 'c'){
        String cLabelPart1 = str(arrx[i]).substring(0,2);
        
        String cLabelPart2 = str(arrx[i]).substring(2,4);
        String cLabelPart3 = str(arrx[i]).substring(4,6); 
        String cLabel = cLabelPart1 + ":" + cLabelPart2 + ":" + cLabelPart3;
        println("clabel is "+ cLabel);
        Label label2 = new Label(cLabel,x,y-30);
      }
      else if (choice != 'd'){
        Label label2 = new Label(str(arrx[i]),x,y-30);
      }
      else{
        timeEl tempTimeEl = (timeEl)tokenArray.get(i);
        Label label2 = new Label(tempTimeEl.printDate(),x,y-30);
      }
      

    }
  }
  fill(0, 123, 200);
  if (logChoice.equals(totalUserLog)){
   text("Number of Visitors", width/2-49, 30);
  }
  else if (logChoice.equals(engagedUsersLog)){
    text("Number of Engaged Visitors", width/2-49, 30); 
  }
  
  switch (choice){
    case 'y':
      text("By year", width/2-20, 50); 
      break;
    case 'm':
      text("By month", width/2-20, 50); 
      break;
    case 'd':
      text("By day", width/2-20, 50); 
      break;
    case 'h':
      text("By hour", width/2-20, 50); 
      break;
    case 'c':
      //text("custom",width/2-20, 50);
      break;
    default:
      text("By year", width/2-20, 50); 
      break;
  }
    
  }
  
  ///////////////////////////////////////////////////////////////////
  
}

void keyPressed(){
 if (key == 'u' ){
   logChoice = totalUserLog;
 } 
 else if (key=='v'){
   logChoice = engagedUsersLog;
 }
 else{
  //exit(); 
 }
  
  
  
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
 // println("START printing");
 // print("array size is "+intList.size()+"\n");
  
   for (int i=0; i<intList.size(); i++){
      int t = (Integer)intList.get(i);
      //println(t);
  }
 // println("END printing");
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

float[] floatArrayList2Array(ArrayList lis){
  float[] arr = new float[lis.size()];
  for (int i =0; i<lis.size(); i++){
    arr[i] = (Float)lis.get(i);
  }
  return arr;
}



