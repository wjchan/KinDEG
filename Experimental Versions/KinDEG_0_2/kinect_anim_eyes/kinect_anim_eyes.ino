// Sweep
// by BARRAGAN <http://barraganstudio.com> 
// This example code is in the public domain.


#include <Servo.h> 

#define HEADER        '|'
#define MESSAGE         'M'
#define MESSAGE_BYTES  6  // the total bytes in a message

 
Servo myservo, myservo2, myservo3, myservo4;  // create servo object to control a servo 
                // a maximum of eight servo objects can be created 
int angle, prevAngle;
int val;
int pos = 0;    // variable to store the servo position 
int startTimer = millis();
 
 
void setup() 
{ 
  Serial.begin(9600);
  myservo.attach(9);  // attaches the servo on pin 9 to the servo object 
  //myservo.write(20); //default angle
  myservo2.attach(10);
  myservo3.attach(11);
  myservo4.attach(6);
  prevAngle = 20;
} 
 
 
void loop() 
{ 
  if (Serial.available()>=MESSAGE_BYTES){
    int valX, valY;
    if( Serial.read() == HEADER)
    {
      char tag = Serial.read();
      
      if(tag == MESSAGE)
      {
        valX = Serial.read()*256; // this was sent as a char
        valX = valX + Serial.read();
        valY = Serial.read() * 256;
        valY = valY + Serial.read();
        Serial.print("Received mouse msg, valueX = ");
        Serial.print(valX);
        Serial.print(", valueY  ");
        Serial.println(valY);
      }
      else{
         Serial.print("got message with unknown tag");
        Serial.println(tag); 
      }
      
      if (valX > 640){
        valX= prevAngle;
      }
      
        float angle = map(valX, 0, 640, 180, 0);
       if (valX > 640){
        angle= prevAngle;
      }
      float angle2 = map(valY, 0, 480,70 , 170);
    
      
        myservo.write(int(angle));
        myservo3.write(int(angle));
      
        myservo2.write(int(angle2));
        myservo4.write(int(angle2));
        //slowSweep(prevAngle, angle);
         prevAngle = angle;
         startTimer = millis();

    
    
    
    /*
    byte highByt = Serial.read();
    byte nexByte = Serial.read();
    //byte lowByt = Serial.read();
    //int rawAngle = word(highByt, lowByt);
    int rawAngle = highByt;
    int angle2 = nexByte;
    //byte rawAng = (highByt << 8)+lowByt;
   

      //angle = map(rawAngle, 0, 640, 20, 160); 
      //myservo.write(rawAngle);
      myservo2.write(angle2);
      
      //slowSweep(prevAngle, angle);
      */
      
      
     /* 
       for (int i = 0; i<161; i=i+10) //loop for range of angles (an attempt to avoid java from crashing)
    {
      if ((angle >= i) && (angle < i+10)) //if angle lies in this 10 degree range
      {
        //myservo.write(i);
        myservo.write(i); 
      }
    }
    */
      
      
      
      
      
      
      
      
  
      
     
    }
  }
  /*
  else{
    if ((millis()-startTimer)>10000){
      myservo.write(0);
        myservo3.write(180);
        myservo2.write(70);
        myservo4.write(70);
        startTimer=millis();
    }
    
  }
   */ 
    
     /*
   
    for (int i = 0; i<161; i=i+10) //loop for range of angles (an attempt to avoid java from crashing)
    {
      if ((angle >= i) && (angle < i+10)) //if angle lies in this 10 degree range
      {
        //myservo.write(i);
        slowSweep(prevAngle, angle);
      }
    }
    Serial.print("\nprev angle is ");
    Serial.print(prevAngle,DEC);
    Serial.print("\nangle is ");
    Serial.print(angle,DEC);
    prevAngle = angle;
    */
   
  

} 

void slowSweep(int curAngle, int tarAngle){
  if (curAngle > tarAngle)
  {
    for(int pos = curAngle; pos >= tarAngle; pos=pos-1)   
    {                                  
      myservo.write(pos);               
      //delay(5);                        
    } 
  }
  else
  {
    for(int pos = curAngle; pos <= tarAngle; pos=pos+1)   
    {                                  
      myservo.write(pos);               
      //delay(5);                        
    } 
  }
  
}
