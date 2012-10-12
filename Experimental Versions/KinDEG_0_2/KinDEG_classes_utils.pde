//statistic stuff
//onexituser: ratio, duration


class user{
    //details from log
   int id;
   int gazeTime;
   int startGaze;
   boolean inRect;
   int enterTime;
   
   user(){
     id = 0;
     gazeTime = 0;
     startGaze = millis();
     
     inRect = false;
     enterTime = millis();
   }
   
   user(int a1){
     id=a1;
     gazeTime = 0;
     startGaze = millis();
     enterTime = millis();
   
     inRect = false;
   }
   
   float getRatio(){
     int tempInt = millis()-enterTime;
     float tempF = gazeTime;
     tempF = tempF/tempInt;
     return tempF;
   }
   int getDuration(){
     return (millis() - enterTime);
   }
}


void drawSkeleton(int userId)
{
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);

  //noStroke();
  
   fill(255,0,0);
  drawJoint(userId, SimpleOpenNI.SKEL_HEAD);
  drawJoint(userId, SimpleOpenNI.SKEL_NECK);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_ELBOW);
  //drawJoint(userId, SimpleOpenNI.SKEL_NECK);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  drawJoint(userId, SimpleOpenNI.SKEL_TORSO);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HIP);  
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_KNEE);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_HIP);  
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_FOOT);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_KNEE);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HIP);  
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_FOOT);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_HAND);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HAND);
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



//  SimpleOpenNI EVENTS  #################################################

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
  
  //user gaze time and normal duration stuff
  if (userMap.containsKey(userId)) //unnecessary stuff (safety net)
  {  //old user
  }
  else //new user
  {
     user tempUser = new user(userId);
     userMap.put(userId, tempUser);
     
  }



  
  
  //user duration stuff
  if (!(userDurationMap.containsKey(userId)))
  {
      userDurationMap.put(userId, millis());
  }
}

void onLostUser(int userId)
{
  println("onLostUser - userId: " + userId);
   user target = (user)userMap.get(userId);
   println(target.gazeTime);
   println(target.getRatio());
   println(target.getDuration());
   //threshold gazetime stuff
  if (target.gazeTime > timeThresh)
  {
    threshNumPpl++;
    gazeTimeAr.add(target.gazeTime);
    presenceAr.add(target.getDuration());
    ratioAr.add(target.getRatio());
    
  }
  userMap.remove(userId);
  
  //user duration stuff
  userDurationMap.remove(userId);
}

void onExitUser(int userId)
{
  println("onExitUser - userId: " + userId);
  user target = (user)userMap.get(userId);
  if (target.gazeTime > timeThresh)
  {
    threshNumPpl++;
    
    //add some user duration stuff here too

  }
  userMap.remove(userId);
  
  //user duration stuff
  userDurationMap.remove(userId);
}

void onReEnterUser(int userId) //not used yet
{
  println("onReEnterUser - userId: " + userId);
}

void onStartCalibration(int userId) //not used since autocalib is used
{
  println("onStartCalibration - userId: " + userId);
}

void onEndCalibration(int userId, boolean successfull) //not used
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


void mousePressed()
{
  int[] depthValues = kinect.depthMap();
  int clickPosition = mouseX+(mouseY*640);
  int millimeters = depthValues[clickPosition];
  float inches = millimeters/25.4;
  println("mm: " + millimeters + " in: "+inches);
}


//custom function
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
          //println("LOOKING AT YA"); //can add saveframe to take pic
          return true;
        }
    }
  }
  return false;
    
}


float sumFloatAL(ArrayList lis) //sum up all elements of float arrayList
{ 
  float sum = 0;
  for (int i=0; i<lis.size(); i++)
  {
    float y = (Float)lis.get(i);
    sum = sum + y;
  }
  return sum;
}

float maxFloatAL(ArrayList lis) //sum up all elements of float arrayList
{ 
  float maxNum = 0;
  for (int i=0; i<lis.size(); i++)
  {
    float y = (Float)lis.get(i);
    if (y>maxNum){
      maxNum = y;
    }
  }
  return maxNum;
}

int sumIntAL(ArrayList lis) //sum up all elements of float arrayList
{ 
  int sum = 0;
  for (int i=0; i<lis.size(); i++)
  {
    int y = (Integer)lis.get(i);
    sum = sum + y;
  }
  return sum;
}

float maxIntAL(ArrayList lis) //sum up all elements of float arrayList
{ 
  int maxNum = 0;
  for (int i=0; i<lis.size(); i++)
  {
    int y = (Integer)lis.get(i);
    if (y>maxNum){
      maxNum = y;
    }
  }
  return maxNum;
}


