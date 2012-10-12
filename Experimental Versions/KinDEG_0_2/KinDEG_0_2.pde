/* --------------------------------------------------------------------------
 * KinDEG v0.2
  Author: Wei Jian Chan
 */


//half implemented - timeDataLog (average value for each param)
//starting implementing maxppl - maxUserList (ie max number of user at a time)

import SimpleOpenNI.*;
import monclubelec.javacvPro.*;
import java.awt.*; 
import processing.serial.*;
public static final char HEADER = '|';
public static final char MOUSE  = 'M';


Rectangle[] faceRect;
OpenCV opencv;
SimpleOpenNI  kinect;
boolean autoCalib=true;
int UID;
float headx, heady, neckx, necky;
String logName = "log.txt";
int msElapsed = 0;
int counter;
HashMap userMap = new HashMap();
int timeThresh = 2000; //2000ms = 2s
int threshNumPpl=0; //number of people counted using threshold method
int timeAverage, timeAverageNumPpl, timeAverageTotalTime;
String timeDataLog = "timeDataLog.txt";
int maxUserNum = 0;
HashMap userDurationMap = new HashMap(); //dynamically updating
ArrayList gazeTimeAr =  new ArrayList(); //update = growing only
ArrayList presenceAr = new ArrayList();
ArrayList ratioAr = new ArrayList();
Serial myPort;
int timerStart=millis();

void setup()
{
  kinect = new SimpleOpenNI(this);
  counter = 0;
  String portName = Serial.list()[0];
  //println(portName);
  myPort = new Serial(this, portName, 9600);
   
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
  
  image(kinect.depthImage(),0,0);
  
  // draw the skeleton if it's available
  int[] userList = kinect.getUsers();
  
  if ((userList.length)>maxUserNum)
  {
    maxUserNum = userList.length;
  }
  
  faceRect = opencv.detect(1,false); //can modify coefficients, so far 2 is best with kinect
  opencv.drawRectDetect(false);
  
  for(int i=0;i<userList.length;i++)
  {
    if(kinect.isTrackingSkeleton(userList[i]))
    {
      
      drawSkeleton(userList[i]);
      float[] coord = getHeadCoord(userList[i]);
      
      if (i==0){//first person
      sendMessage(MOUSE, int(coord[0]), int(coord[1]));
      }
      
      if (coord[2]>0.5) //if confidence > 0.5
      {     
        if (isHeadInRect(coord[0], coord[1], faceRect))//if looking at display
        {  
           
           //assuming fps is 30
           if (userMap.containsKey(userList[i])) //unnecessary stuff (safety net)
           {  //update value
             user target = (user)userMap.get(userList[i]);
             if (target.inRect)
             {
               target.gazeTime = target.gazeTime + (millis() - target.startGaze);
               target.startGaze = millis();
             }
             else
             {//if frontal face was not detected before this
               target.inRect = true;
               target.startGaze = millis();
             }
           }
           else //unnecessary stuff (safety net)
           {
             user tempUser = new user(userList[i]);
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
  //println(coord[0]);
  //println(coord[1]);
  return coord;
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
        gazeTimeAr.add(target.gazeTime);
        presenceAr.add(target.getDuration());
        ratioAr.add(target.getRatio());
      }
      userMap.remove(userList[i]);
    }
  }
  
  
  
  //LOG STUFF
  //declare variables
  int totalRunTime = millis();
  int totalVisits = threshNumPpl;
  int totalPassers = counter;
  int maxUser1Time = maxUserNum;
  
  
  
  int totalGazeTime;
  float avgGazeTime;
  int maxGazeTime;  
  int totalPresence;
  float avgPresence;
  int maxPresence;
  float maxRatioGazeP;
  float ratioGazePres;
  float avgRatioGazeP;
  float totalRatio;
  
  
  if (totalVisits != 0)
  {
    
  //declare variables
    totalGazeTime = int(sumIntAL(gazeTimeAr));
    
    //just to get division correct
    avgGazeTime = totalGazeTime;
    avgGazeTime = avgGazeTime/totalVisits;
    
    maxGazeTime = int(maxIntAL(gazeTimeAr));  
    totalPresence = int(sumIntAL(presenceAr));

    avgPresence = totalPresence/1.0;
    avgPresence = avgPresence/totalVisits;
    maxPresence = int(maxIntAL(presenceAr));
    maxRatioGazeP = maxFloatAL(ratioAr);
    ratioGazePres = sumFloatAL(ratioAr)/totalVisits;
    avgRatioGazeP = totalGazeTime/totalVisits;
    totalRatio = sumFloatAL(ratioAr);

  }
  else{
    totalGazeTime = 0;
    avgGazeTime = 0;
    maxGazeTime =0;
    totalPresence =0;
    avgPresence =0;
    maxPresence=0;
    maxRatioGazeP = 0;
    ratioGazePres =0;
    avgRatioGazeP =0;
    totalRatio = 0;
  }
  
  //extract stuff
  
    String timeData[] = loadStrings(timeDataLog);
  
    String[] Els = split(timeData[0], '\t');
    int totalVisitsToDate = parseInt(Els[1]); //get total visits
    
    Els = split(timeData[1], '\t');
    int totalGazeTimeToDate = parseInt(Els[1]);//get total gaze time
    
    Els = split(timeData[2], '\t');
    int avgGazeTimeToDate = parseInt(Els[1]);  //get average time
    
    Els = split(timeData[3], '\t');
    int maxGazeTimeToDate = parseInt(Els[1]);  //get average time
    
    Els = split(timeData[4], '\t');
    int totalPresenceToDate = parseInt(Els[1]);  //get average time
    
    Els = split(timeData[5], '\t');
    int avgPresenceToDate = parseInt(Els[1]);  //get average time
    
    Els = split(timeData[6], '\t');
    int maxPresenceToDate = parseInt(Els[1]);  //get average time
    
    Els = split(timeData[7], '\t');
    float maxRatioGazePToDate = parseFloat(Els[1]);  //get average time
    
    Els = split(timeData[8], '\t');
    float ratioGazePresToDate = parseFloat(Els[1]);  //get average time
    
    Els = split(timeData[9], '\t');
    float avgRatioGazePToDate = parseFloat(Els[1]);  //get average time
    
    Els = split(timeData[10], '\t');
    int totalRunTimeToDate = parseInt(Els[1]);  //get average time
    
    Els = split(timeData[11], '\t');
    int totalPassersToDate = parseInt(Els[1]);  //get average time
    
    Els = split(timeData[12], '\t');
    int maxUser1TimeToDate = parseInt(Els[1]);  //get average time
    
    Els = split(timeData[12], '\t');
    float totalRatioToDate = parseFloat(Els[1]);  //get average time
  
  //
    totalRunTime = totalRunTime + totalRunTimeToDate;
    totalVisits = totalVisits + totalVisitsToDate;
    totalPassers = totalPassers + totalPassersToDate;    
    maxUser1Time = max(maxUser1Time, maxUser1TimeToDate);
    totalGazeTime = totalGazeTime + totalGazeTimeToDate;
    avgGazeTime = totalGazeTime/totalVisits;
    maxGazeTime = max(maxGazeTime, maxGazeTimeToDate);
    totalPresence = totalPresence + totalPresenceToDate;
    avgPresence = totalPresence/totalVisits;
    maxPresence = max(maxPresence, maxPresenceToDate);
    maxRatioGazeP = max(maxRatioGazeP, maxRatioGazePToDate);
    
    avgRatioGazeP = totalGazeTime;
    avgRatioGazeP = avgRatioGazeP/totalPresence;
    
    totalRatio = totalRatio + totalRatioToDate;
    ratioGazePres = totalRatio;
    ratioGazePres = ratioGazePres/totalVisits;
    
  
  //
  
  //turn everything to string
  String[] statData = new String[14];
  String a1 = "TotalVisits\t" + str(totalVisits);
  statData[0] = a1;
  a1 = "TotalGazeTime\t"+str(totalGazeTime);
  statData[1] = a1;
  a1 = "AvgGazeTime\t"+str(avgGazeTime);
  statData[2] = a1;
  a1 = "MaxGazeTime\t"+str(maxGazeTime);
  statData[3] = a1;
  a1 = "TotalPresence\t"+str(totalPresence);
  statData[4] = a1;
  a1 = "AvgPresence\t"+str(avgPresence);
  statData[5] = a1;
  a1 = "MaxPresence\t"+str(maxPresence);
  statData[6] = a1;
  a1 = "MaxRatioGazeP\t"+str(maxRatioGazeP);
  statData[7] = a1;
    a1 = "RatioGazePres\t"+str(ratioGazePres);
  statData[8] = a1;
    a1 = "AvgRatioGazeP\t"+str(avgRatioGazeP);
  statData[9] = a1;
    a1 = "TotalRunTime\t"+str(totalRunTime);
  statData[10] = a1;
      a1 = "TotalPassers\t"+str(totalPassers);
  statData[11] = a1;
    a1 = "maxUser1Time\t"+str(maxUser1Time);
  statData[12] = a1;
    a1 = "totalRatio\t"+str(totalRatio);
  statData[13] = a1;
  
  saveStrings(timeDataLog, statData);
  
  
  
  
  
  ///////////////////////////////////////////////
  if (userMap.isEmpty() == false)
  {
    println("not all user deleted, something is not right here");
  }
  userMap.clear();
  timeStamp();
  println("threshNumPpl is " + str(threshNumPpl));
  println("QUIT? NOOOOOOO :(");
  exit();
}


































void readTimeDate(){
  //int timeAverage, timeAverageNumPpl, timeAverageTotalTime;
  String timeData[] = loadStrings(timeDataLog);
  
  String[] Els = split(timeData[0], '\t');
  int totalVisitsToDate = parseInt(Els[1]); //get total visits
  
  Els = split(timeData[1], '\t');
  int totalGazeTimeToDate = parseInt(Els[1]);//get total gaze time
  
  Els = split(timeData[2], '\t');
  int avgGazeTimeToDate = parseInt(Els[1]);  //get average time
  
  Els = split(timeData[3], '\t');
  int maxGazeTimeToDate = parseInt(Els[1]);  //get average time
  
  Els = split(timeData[4], '\t');
  int totalPresenceToDate = parseInt(Els[1]);  //get average time
  
  Els = split(timeData[5], '\t');
  int avgPresenceToDate = parseInt(Els[1]);  //get average time
  
  Els = split(timeData[6], '\t');
  int maxPresenceToDate = parseInt(Els[1]);  //get average time
  
  Els = split(timeData[7], '\t');
  int maxRatioGazePToDate = parseInt(Els[1]);  //get average time
  
  Els = split(timeData[8], '\t');
  int ratioGazePresToDate = parseInt(Els[1]);  //get average time
  
  Els = split(timeData[9], '\t');
  int avgRatioGazePToDate = parseInt(Els[1]);  //get average time
  
  Els = split(timeData[10], '\t');
  int totalRunTimeToDate = parseInt(Els[1]);  //get average time
  
  Els = split(timeData[11], '\t');
  int totalPassersToDate = parseInt(Els[1]);  //get average time
  
  Els = split(timeData[12], '\t');
  int maxUser1TimeToDate = parseInt(Els[1]);  //get average time
  
  
  //sadsdf
  
  
}

void timeDataInc(int userGazeTime){
  
  
}


void recordGaze(user target)
{
  
}


void serialEvent(Serial p){
  //handle incoming data
  String inString = myPort.readStringUntil('\n');
  if (inString != null){
    println(inString); //echo text string from Arduino
  }
}

void sendMessage(char tag, int valueX, int valueY){
  if (millis() - timerStart > 10){
  myPort.write(HEADER);
  myPort.write(tag);

  char c = (char)(valueX / 256); // msb
  myPort.write(c);
  c = (char)(valueX & 0xff);  // lsb
  myPort.write(c);
  
  
  char d = (char)(valueY / 256); // msb
  myPort.write(d);
  d = (char)(valueY & 0xff);  // lsb
  myPort.write(d);
  timerStart = millis();
  }
  
  
  
}
