KinDEG_v1.0 by Wei Jian Chan

The files in this directory are:
1. KinDEG_1_0Documentation.doc: Documentation of functions and classes in KinDEG_1_0.pde
2. KinDEG_1_0.pde: Main program file
3. KinDEG_classes_utils.pde: Supporting functions and classes file
4. README.txt

The folders in this directory are: 
1. kinect_anim_eyes:
	a) Contains AnimatronicEyes_CAD: holds all the design file associated with the animatronic eyes
	b) Contains ConnectionDiagram.doc: Shows the way to connect up the animatronic eyes to Arduino
	c) Contains Kinect_anim_eyes.ino: Arduino file to control servo motors
	d) Contains servo_connection_sweep_test folder which holds the ino file for checking the connection is correct. If connection is correct, all servo motors should do full 180 degree sweep
	e) Contains eyes_tracking.mp4: A video of the result from testing the animatronic eyes. For other eyes video with a subject (me) in it, please contact me.

2. timeGraph: Contains timeGraph.pde and Label.pde which are used as graph plotter



To run, the installation of the following is required:
Processing 1.5.1
OpenNI (get the latest version)
OpenCV 2.3.1

Processing Libraries:
JavaCVPro 0.4 Beta
Simple OpenNI v2.7

Viewing source code:
-KinDEG_1_0.pde is the main file. It is located in this directory. Edit with notepad++ or other text editer to view source code if Processing IDE is not installed
-timeGraph.pde is located within timeGraph folder in this directory
-kinect_anim_eyes.ino is located within kinect_anim_eyes folder in this directory
-Documentation of the functions in KinDEG main file can be found in this directory


KinDEG v1.0 features:
-gaze estimation algorithm based on SimpleOpenNI automatic calibration and JavaCVPro object detection
-More bug fixes from the 0.x versions
-Comes with Arduino code to run 4 servo motors which can be used to animate animatronic eyes
-ships with a graph plotter for your convenience


Basic instructions on running KinDEG main function:
1. Run KinDEG_1_0.pde
2. Click on any point on the screen to show the depth value (distance from Kinect) of the point 
3. Press 'e' to quit


To use Arduino to control a pair of animatronic eyes: 
1. Program kinect_anim_eyes.ino onto your Arduino  and ensure that all connections are good
2. Edit KinDEG_1_0.pde and set serialEnabled variable in KinDEG_1_0.pde to be true 
3. Run KinDEG_1_0.pde, let KinDEG calibrate you and enjoy!


To use the graph plotter:
1. Make sure the log file directories in timeGraph.pde in timeGraph.pde is correct. Edit them if not. The log file should appear in the same directory as KinDEG_1_0.pde.
2. Run timeGraph.pde to display the result either after a valid timeDataLog.txt file is generated or before running KinDEG_1_0.pde to obtain a dynamically updating graph
2. Press 'u' and 'v' to switch between graph of visitors count over time and graph of engaged visitors count over time


TimeDataLog format:

TotalVisits 		//total number of presence recorded = total number of gazes recorded = total ratio recorded
TotalGazeTime 		//total gaze time
AvgGazeTime 		//avg gaze time (total gaze time/ number of gazes recorded)
MaxGazeTime 		//max(gaze time)
TotalPresence 		//total presence time
AvgPresence 		//avg presence time (total presence/total number of presence recorded)
maxPresence 		//max (presence time)
maxRatioGazeP 		//maximum(list of ratio gaze)
RatioGazePres 		//ratio gaze to presence time (total ratio/total number of ratios recorded)
AvgRatioGazeP 		//avg ratio gaze to presence time (total gaze/total presence)
TotalRunTime 		//totalprogram run time
TotalPassers 		//total people walk pass (just detection)
maxUser1Time 		//maximum people recorded at a time (crowd)
totalRatio 		//sum of all ratios