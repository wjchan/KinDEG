/* --------------------------------------------------------------------------
 * KinDEG v0.2
  Author: Wei Jian Chan
 */

import SimpleOpenNI.*;
import monclubelec.javacvPro.*;
import java.awt.*; 


Rectangle[] faceRect;
OpenCV opencv;
SimpleOpenNI  kinect;
boolean       autoCalib=true;
int UID;
float headx, heady, neckx, necky;
String logName = "log.txt";
int msElapsed = 0;
int counter;
HashMap userMap = new HashMap();
int timeThresh = 2000; //2000ms = 2s
int threshNumPpl=0; //number of people counted using threshold method

void setup()
{
  kinect = new SimpleOpenNI(this);
  counter = 0;
   
  // enable depthMap generation 
  
  if(kinect.enableDepth() == false)
  {
     println("Can't open the depthMap, maybe the camera is not connected!"); 
     exit();
     return;
  }
  //kinect.enableRGB(640,480, 1);
   kinect.enableRGB();
  // enable skeleton generation for all joints
  kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
 // kinect.alternativeViewPointDepthToImage(); 
 
  background(200,0,0);

  stroke(0,0,255);
  strokeWeight(3);
  smooth();
  
  size(kinect.depthWidth(), kinect.depthHeight()); 
  kinect.alternativeViewPointDepthToImage();
  
   //opencv stuff
  opencv = new OpenCV(this);
  opencv.allocate(kinect.depthWidth(),kinect.depthHeight());
  opencv.cascade("C:/opencv/data/haarcascades/","haarcascade_frontalface_alt.xml"); //select descriptor
  // frameRate(100);
}

void draw()
{
  // update the cam
 
  kinect.update();
   opencv.copy(kinect.rgbImage());
  
  image(kinect.rgbImage(),0,0);
  
  // draw the skeleton if it's available
  int[] userList = kinect.getUsers();
  
    faceRect = opencv.detect(2,true); //can modify coefficients, so far 2 is best with kinect
  opencv.drawRectDetect(true);
  
  for(int i=0;i<userList.length;i++)
  {
    if(kinect.isTrackingSkeleton(userList[i]))
    {
      drawSkeleton(userList[i]);
      float[] coord = getHeadCoord(userList[i]);
      
      if (coord[2]>0.5) //if confidence > 0.5
      {
        
        
        
        if (isHeadInRect(coord[0], coord[1], faceRect))//if looking at display
        {  
          println("true");
           //assuming fps is 30
           if (userMap.containsKey(userList[i]))
           {  //update value
             user target = (user)userMap.get(userList[i]);
             if (target.inRect)
             {
               target.gazeTime = target.gazeTime + (millis() - target.startGaze);
               target.startGaze = millis();
               
             }
             else
             {
               target.inRect = true;
               target.startGaze = millis();
             }
           }
           else //new user
           {
             user tempUser = new user(userList[i]);
             tempUser.startGaze = millis();
             userMap.put(userList[i], tempUser);
             
           }
        }
        else //if head not in
        {
          if (userMap.containsKey(userList[i]))
          {  
             user target = (user)userMap.get(userList[i]);
             if (target.inRect)
             {
               target.gazeTime = target.gazeTime + (millis() - target.startGaze);
               
             }
             target.inRect =  false;
          }
        }
        
        
      }
      
     
    }
  }    
}

// draw the skeleton with the selected joints


// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(int userId)
{
  println("onNewUser - userId: " + userId);
  println("  start pose detection");
  
  if(autoCalib)
  {
    kinect.requestCalibrationSkeleton(userId,true);
  }
  else 
  {  
    kinect.startPoseDetection("Psi",userId);
  }
    
  println("tracking");
  counter++;
  println("counter is currently ");
  println(counter);  
  
}

float[] getHeadCoord(int userId)
{//return x and y of head
  PVector joint = new PVector();
  float confidence = kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_HEAD, joint);
  PVector convertedJoint = new PVector();
  kinect.convertRealWorldToProjective(joint, convertedJoint);
  float[] coord = new float[3];
  coord[0] = convertedJoint.x;
  coord[1] = convertedJoint.y;
  coord[2] = confidence;
  println(coord[0]);
  println(coord[1]);
  return coord;
  


}





void drawJoint(int userId, int jointID) {
  PVector joint = new PVector();
  float confidence = kinect.getJointPositionSkeleton(userId, jointID, joint);
  if(confidence < 0.5){
    return;
  }
  PVector convertedJoint = new PVector();
  kinect.convertRealWorldToProjective(joint, convertedJoint);
  ellipse(convertedJoint.x, convertedJoint.y, 5, 5);
  
  if (jointID == SimpleOpenNI.SKEL_HEAD){
    //println("HEAD: x is " + str(convertedJoint.x)); 
    //println("HEAD: y is " + str(convertedJoint.y)); 
    
    headx = convertedJoint.x;
    heady = convertedJoint.y;
  }
  if (jointID == SimpleOpenNI.SKEL_NECK){
    // println("NECK: x is " + str(convertedJoint.x)); 
   // println("NECK: y is " + str(convertedJoint.y)); 
     neckx = convertedJoint.x;
    necky = convertedJoint.y;
    //put here because drawjoint(neck) is called after head
   // println("MID: x is " + str(0.5*(neckx+headx)));
    // println("MID: y is " + str(0.5*(necky+heady)));
    
  }
  

  
 
}

void onLostUser(int userId)
{
  println("onLostUser - userId: " + userId);
   user target = (user)userMap.get(userId);
  if (target.gazeTime > timeThresh)
  {
    threshNumPpl++;
  }
  userMap.remove(userId);
}

void onExitUser(int userId)
{
  println("onExitUser - userId: " + userId);
  user target = (user)userMap.get(userId);
  if (target.gazeTime > timeThresh)
  {
    threshNumPpl++;
  }
  userMap.remove(userId);
}

void onReEnterUser(int userId)
{
  println("onReEnterUser - userId: " + userId);
}

void onStartCalibration(int userId)
{
  println("onStartCalibration - userId: " + userId);
}

void onEndCalibration(int userId, boolean successfull)
{
  println("onEndCalibration - userId: " + userId + ", successfull: " + successfull);
  
  if (successfull) 
  { 
    println("  User calibrated !!!");
    kinect.startTrackingSkeleton(userId); 
  } 
  else 
  { 
    println("  Failed to calibrate user !!!");
    println("  Start pose detection");
    kinect.startPoseDetection("Psi",userId);
  }
}

void onStartPose(String pose,int userId)
{
  println("onStartPose - userId: " + userId + ", pose: " + pose);
  println(" stop pose detection");
  
  kinect.stopPoseDetection(userId); 
  kinect.requestCalibrationSkeleton(userId, true);
 
}

void onEndPose(String pose,int userId)
{
  println("onEndPose - userId: " + userId + ", pose: " + pose);
}


void keyPressed(){
  int[] userList = kinect.getUsers();
  for (int i = 0; i<userList.length; i++)
  {
    user target = (user)userMap.get(userList[i]);
    if (target != null)
    {
      print("gazetime is ");
      print(target.gazeTime);
      print("\n");
      if (target.gazeTime > timeThresh)
      {  
        threshNumPpl++;
      }
      userMap.remove(userList[i]);
    }
  }
  if (userMap.isEmpty() == false)
  {
    println("not all user deleted, something is not right here");
  }
  userMap.clear();
  timeStamp();
  println(threshNumPpl);
  println("QUIT? NOOOOOOO :(");
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
  toSave = toSave + str(threshNumPpl);
  lis[newIndex-1] = toSave;
  
  println(toSave);
  saveStrings(logName, lis);
}

boolean isHeadInRect(float x, float y, Rectangle[] fRect){
  
  for (int i=0; i<fRect.length; i++)
  {
    if ((x < (fRect[i]).x + fRect[i].width) && (x>fRect[i].x))
    {
        if ((y < fRect[i].y + fRect[i].height) && (x>fRect[i].y))
        {//it's in box
          println("LOOKING AT YA");
          return true;
        }
    }
  }
  return false;
    
}
