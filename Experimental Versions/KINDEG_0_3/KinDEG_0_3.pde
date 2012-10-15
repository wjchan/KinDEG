/* --------------------------------------------------------------------------
 * KinDEG v0.2
  Author: Wei Jian Chan
 */

import SimpleOpenNI.*;
import monclubelec.javacvPro.*;
import java.awt.*; 
import processing.serial.*;
public static final char HEADER = '|';
public static final char MESSAGE  = 'M';


Rectangle[] faceRect;
OpenCV opencv;
SimpleOpenNI  kinect;
boolean autoCalib=true;


int counter;
HashMap userMap = new HashMap();
int timeThresh = 2000; //2000ms = 2s
int threshNumPpl=0; //number of people counted using threshold method
int maxUserNum = 0;
HashMap userDurationMap = new HashMap(); //dynamically updating
ArrayList gazeTimeAr =  new ArrayList(); //update = growing only
ArrayList presenceAr = new ArrayList();
ArrayList ratioAr = new ArrayList();
Serial myPort;
boolean serialEnabled=false;
int picCount=0;

//log names
String timeDataLog = "timeDataLog.txt";
String logTxt = "log.txt";


//timers
timer timerSerialSend = new timer(10); //10 ms stopwatch
//timer timerLog = new timer(60000); //1 minute stopwatch
timer timerLog = new timer(5000); 


void setup()
{
  counter = 0;
  
 //serial stuff 
  if (serialEnabled)
  {
    String portName = Serial.list()[0];
    myPort = new Serial(this, portName, 9600);
  }
  
  //kinect stuff
  kinect = new SimpleOpenNI(this);
  if(kinect.enableDepth() == false)
  {
     println("Can't open the depthMap, maybe the camera is not connected!");
     
     exit();
     return;
  }
  kinect.enableRGB();
  kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
  kinect.alternativeViewPointDepthToImage(); 
  background(200,0,0);
  stroke(0,0,255);
  strokeWeight(3);
  smooth();
  size(kinect.depthWidth(), kinect.depthHeight()); 

  
   //opencv stuff
  opencv = new OpenCV(this);
  opencv.allocate(kinect.depthWidth(),kinect.depthHeight());
  opencv.cascade("C:/opencv/data/haarcascades/","haarcascade_frontalface_alt.xml"); //select descriptor
  //opencv.cascade("C:/opencv/data/lpbcascades/","lbpcascade_frontalface.xml"); //select descriptor



}

void draw()
{
  // update the cam
 
  kinect.update();
   opencv.copy(kinect.rgbImage());
  
  image(kinect.rgbImage(),0,0);
  
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
      
      
      if (coord[2]>0.5) //if confidence > 0.5
      { 
        if (serialEnabled)
        {
         
          sendMessage(MESSAGE, int(coord[0]), int(coord[1]));
        }    
        if (isHeadInRect(coord[0], coord[1], faceRect))//if looking at display
        {  
           takePic();
           
           if (userMap.containsKey(userList[i])) //unnecessary stuff (safety net)
           {  
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
  if (timerLog.timesUp()){
  logIt(false);
  timerLog.restart();
  }
  //end
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
  return coord;
}


void keyPressed(){
  
  if (key == 'e'){ //exit
    logIt(true);
    println("QUIT? NOOOOOOO :(");
    exit();
  } 

}


void logIt(boolean last){ //put into log files
  int[] userList = kinect.getUsers();
  int activeUser=0;
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
        activeUser++;
        if (target.counted == false)
        {
          threshNumPpl++;
          target.counted = true;
        }

        if (target.gazeTimeArIndex == -1){
          gazeTimeAr.add(target.gazeTime);
          target.gazeTimeArIndex = gazeTimeAr.size()-1;
        }
        else{
          gazeTimeAr.set(target.gazeTimeArIndex, target.gazeTime);
        }
        if (target.presenceArIndex == -1){
          presenceAr.add(target.getDuration());
          target.presenceArIndex = presenceAr.size()-1;
        }
        else{
         presenceAr.set(target.presenceArIndex, target.getDuration()); 
        }
        if (target.ratioArIndex == -1){
          ratioAr.add(target.getRatio());
          target.ratioArIndex = ratioAr.size()-1;
        }
        else{
          ratioAr.set(target.ratioArIndex, target.getRatio());
        }
      }
      if (last){
      userMap.remove(userList[i]);
      }
    }
  }
  println("activeuser is " +str(activeUser));
  
  
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
    totalRatio = sumFloatAL(ratioAr);
    
    ratioGazePres= totalRatio;
    ratioGazePres = ratioGazePres/totalVisits;
    avgRatioGazeP = totalGazeTime;
    //println("avgratiogazep is " + str(avgRatioGazeP));
    avgRatioGazeP = avgRatioGazeP/totalPresence;
    //println("divided by totalVisits which is " + str(totalPresence));
    //println("now avgratiogazep is " + str(avgRatioGazeP));
    
    

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
  
    timeStampIntParam("totalVisitsLog.txt", totalVisits);
    timeStampIntParam("totalGazeTimeLog.txt", totalGazeTime);
    timeStampIntParam("totalPresenceLog.txt", totalPresence);
    timeStampFloatParam("avgPresenceLog.txt", avgPresence);
    timeStampFloatParam("avgRatioGazePLog.txt", avgRatioGazeP);
    timeStampFloatParam("ratioGazePresLog.txt", ratioGazePres);
    timeStampIntParam("totalUserLog.txt", userList.length);
    timeStampIntParam("engagedVisitorsLog.txt", activeUser);
  
  
  //extract stuff
  if (last){
  
    String timeData[] = loadStrings(timeDataLog);
    
    //declare variables
     int totalVisitsToDate;
     int totalGazeTimeToDate;
     float avgGazeTimeToDate;
     int maxGazeTimeToDate;
     int totalPresenceToDate;
     float avgPresenceToDate;
     int maxPresenceToDate;
     float maxRatioGazePToDate;
     float ratioGazePresToDate;
     float avgRatioGazePToDate;
     int totalRunTimeToDate;
     int totalPassersToDate;
     int maxUser1TimeToDate;
     float totalRatioToDate;
    
    if (timeData != null)
    {
  
    String[] Els = split(timeData[0], '\t');
    totalVisitsToDate = parseInt(Els[1]); //get total visits
    
    Els = split(timeData[1], '\t');
    totalGazeTimeToDate = parseInt(Els[1]);//get total gaze time
    
    Els = split(timeData[2], '\t');
    avgGazeTimeToDate = parseFloat(Els[1]);  //get average time
    
    Els = split(timeData[3], '\t');
    maxGazeTimeToDate = parseInt(Els[1]);  //get average time
    
    Els = split(timeData[4], '\t');
    totalPresenceToDate = parseInt(Els[1]);  //get average time
    
    Els = split(timeData[5], '\t');
    avgPresenceToDate = parseFloat(Els[1]);  //get average time
    
    Els = split(timeData[6], '\t');
    maxPresenceToDate = parseInt(Els[1]);  //get average time
    
    Els = split(timeData[7], '\t');
    maxRatioGazePToDate = parseFloat(Els[1]);  //get average time
    
    Els = split(timeData[8], '\t');
    ratioGazePresToDate = parseFloat(Els[1]);  //get average time
    
    Els = split(timeData[9], '\t');
    avgRatioGazePToDate = parseFloat(Els[1]);  //get average time
    
    Els = split(timeData[10], '\t');
    totalRunTimeToDate = parseInt(Els[1]);  //get average time
    
    Els = split(timeData[11], '\t');
    totalPassersToDate = parseInt(Els[1]);  //get average time
    
    Els = split(timeData[12], '\t');
    maxUser1TimeToDate = parseInt(Els[1]);  //get average time
    
    Els = split(timeData[12], '\t');
    totalRatioToDate = parseFloat(Els[1]);  //get average time
    }
    else
    {
         totalVisitsToDate=0;
         totalGazeTimeToDate=0;
         avgGazeTimeToDate=0;
         maxGazeTimeToDate =0;
         totalPresenceToDate = 0;
         avgPresenceToDate =0;
         maxPresenceToDate = 0;
         maxRatioGazePToDate=0;
         ratioGazePresToDate=0;
         avgRatioGazePToDate=0;
         totalRunTimeToDate=0;
         totalPassersToDate =0;
         maxUser1TimeToDate=0;
         totalRatioToDate=0;
    }
  
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
  if (userMap.isEmpty() == false)
  {
    println("not all user deleted, something is not right here");
  }
  userMap.clear();

  }

  ///////////////////////////////////////////////
  
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

/*
void serialEvent(Serial p){
  //handle incoming data
  String inString = myPort.readStringUntil('\n');
  if (inString != null){
    println(inString); //echo text string from Arduino
  }
}
*/

void sendMessage(char tag, int valueX, int valueY){
  if (timerSerialSend.timesUp()){
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
  timerSerialSend.restart();
  }
  
  
  
}
