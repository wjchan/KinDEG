import SimpleOpenNI.*;
import monclubelec.javacvPro.*; // importe la librairie javacvPro
import java.awt.*; // pour classes Point , Rectangle..

SimpleOpenNI kinect;
Rectangle[] faceRect;
PImage img;
OpenCV opencv;

int userID;
int counter; //counter to keep track of number of people
int kinWid = 640; //kinect frame width
int kinHei = 480; //kinect frame height
int cirSize = 15; //size of circle displaying centre of mass
int msElapsed = 0;
String logName = "log.txt";

void setup() {
  size( 2 * kinWid , kinHei);
  
  //kinect stuff
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_NONE); 
  kinect.enableRGB();
  kinect.alternativeViewPointDepthToImage(); 
  
  //opencv stuff
  opencv = new OpenCV(this);
  opencv.allocate(kinWid, kinHei);
  opencv.cascade("C:/opencv/data/haarcascades/","haarcascade_frontalface_alt.xml"); //select descriptor

}

void draw() {
  kinect.update();
  msElapsed = millis();
  opencv.copy(kinect.rgbImage());
  
  image(kinect.rgbImage(),0 ,0);
  image(kinect.depthImage(), kinWid, 0);

  IntVector userList = new IntVector();
  kinect.getUsers(userList);
  
  faceRect = opencv.detect(1,true); //can modify coefficients, so far 2 is best with kinect
  opencv.drawRectDetect(true);
  println("Number of faces detected = " + faceRect.length);
  println("OpenCV image processing time=" + (millis()-msElapsed)+" ms ");

  for (int i=0; i<userList.size(); i++) { 
    int userId = userList.get(i);
    PVector position = new PVector();
    kinect.getCoM(userId, position); 

    kinect.convertRealWorldToProjective(position, position);
    fill(255, 0,255); //purple circle
    ellipse(position.x, position.y, cirSize, cirSize);
    
    fill(255, 255,0); //yellow circle
    ellipse(position.x + kinWid, position.y, cirSize, cirSize);
  }
}

void onNewUser(int uID) {
  userID = uID;
  println("tracking");
  counter++;
  println("counter is currently ");
  println(counter);
}

void keyPressed(){
  timeStamp();
  println("NOOOOOOO");
  exit();
}


void timeStamp(){
  int y = year();
  int mon = month();
  int d = day();
  int h = hour();
  int m = minute();
  int sec = second();

  //declaration without initialization
  String toSave;
  String[] lis;
  int newIndex;
  
  
  //rewrite what is already there
  String liness[] = loadStrings(logName);
  
  
  if (liness != null){
    newIndex = liness.length + 1;
    lis = new String[newIndex];
    
    for (int i =0 ; i < liness.length; i++) {
      lis[i] = liness[i];
    }
  }
  else{
    newIndex = 1;
    lis = new String[newIndex];
  }
  
  toSave = (y + "-" + mon + "-" + d + "-" + h + "-" + m + "-" + sec) + "-";
  toSave = toSave + str(counter);
  lis[newIndex-1] = toSave;
  
  println(toSave);
  saveStrings("log.txt", lis);
}
