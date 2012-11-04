//kinect_anim_eyes.ino
//author: Wei Jian Chan
//supplementary program to KinDEG_1_0.pde

#include <Servo.h> 
#define HEADER        '|'
#define MESSAGE         'M'
#define MESSAGE_BYTES  6  // the total bytes in a message
Servo myservo, myservo2, myservo3, myservo4;  //create servo objects 
int angle, prevAngle;
int val;
int pos = 0;    // variable to store the servo position 
int startTimer = millis();
boolean serialOutEnabled = false;
 
void setup() 
{ 
  Serial.begin(9600);
   //attach servos to pin 9, 10, 11, 6
  myservo.attach(9); 
  myservo2.attach(10);
  myservo3.attach(11);
  myservo4.attach(6);
  prevAngle = 20;
} 
 
 
void loop() 
{ 
  if (Serial.available()>=MESSAGE_BYTES) //if received data from computer
  {
    int valX, valY;
    if( Serial.read() == HEADER) //check if it's coming from KinDEG
    {
      char tag = Serial.read();
      if(tag == MESSAGE)
      {
        valX = Serial.read()*256; // this was sent as a char
        valX = valX + Serial.read(); //get x-coordinate
        valY = Serial.read() * 256;
        valY = valY + Serial.read(); //get y-coordinate
        if (serialOutEnabled) //send debug message to computer
        {
          Serial.print("Received message, valueX = ");
          Serial.print(valX);
          Serial.print(", valueY  ");
          Serial.println(valY); 
        }
      }
      else
      {
        if (serialOutEnabled) //received weird stuff
        {
          Serial.print("received message with unknown tag");
          Serial.println(tag); 
        }
      }
      if (valX > 640)
      {
        valX= prevAngle;
      }        
      float angle = map(valX, 0, 640, 180, 0); //left/right angle
      if (valX > 640)
      {
        angle= prevAngle;
      }
      float angle2 = map(valY, 0, 480,0 , 180); //up/down angle
      myservo.write(int(angle));
      myservo3.write(int(angle));
      myservo2.write(int(angle2));
      myservo4.write(int(angle2));
      prevAngle = angle;
      startTimer = millis();   
    }
  }
} 

void slowSweep(int curAngle, int tarAngle)
{ //to approach target slowly, not used currently
  if (curAngle > tarAngle)
  {
    for(int pos = curAngle; pos >= tarAngle; pos=pos-1)   
    {                                  
      myservo.write(pos);                                       
    } 
  }
  else
  {
    for(int pos = curAngle; pos <= tarAngle; pos=pos+1)   
    {                                  
      myservo.write(pos);                                      
    } 
  }
}
