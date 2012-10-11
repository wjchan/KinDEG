/* --------------------------------------------------------------------------
 * KinDEG v0.2
  Author: Wei Jian Chan
 */


//half implemented - timeDataLog (average value for each param)
//starting implementing maxppl - maxUserList (ie max number of user at a time)

import SimpleOpenNI.*;
import monclubelec.javacvPro.*;
import java.awt.*; 


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
  int totalVisits = threshNumPpl;
  //int totalGazeTime = //go through array to sum all gaze time
  //int avgGazeTime = totalGazeTime/totalVisits;
  //int maxGazeTime = //go through array to find max
  //int totalPresence = //go through array to sum all presence time
  //int avgPresence = totalPresence/totalVisits;
  //int maxPresence = //go through array to find max
  //float maxRatioGazeP = //go through array to find max
  //float ratioGazePres = //sum all ratio then divide by totalVisits
  //float avgRatioGazeP = totalGazeTime/totalVisits;
  int totalRunTime = millis();
  int totalPassers = counter;
  int maxUser1Time = maxUserNum;
  
  
  
  
  

  
  
  
  
  
  
  
  
  
  
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
  int averageToDate = parseInt(Els[1]);  //get average time
  
  //sadsdf
  
  
}

void timeDataInc(int userGazeTime){
  
  
}


void recordGaze(user target)
{
  
}
