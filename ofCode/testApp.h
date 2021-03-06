#pragma once

#include "ofMain.h"
#include "ofxOpenCv.h"
#include "ofxKinect.h"
#include "ofxOsc.h"

// listen on port 12345
#define PORT 12345
#define SC_PORT 57120

#define NUM_MSG_STRINGS 20

class testApp : public ofBaseApp {
	public:

		void setup();
		void update();
		void draw();
		void exit();
	
		void drawPointCloud();

		void keyPressed  (int key);
		void mouseMoved(int x, int y );
		void mouseDragged(int x, int y, int button);
		void mousePressed(int x, int y, int button);
		void mouseReleased(int x, int y, int button);
		void windowResized(int w, int h);
		
		/// start/stop recording and playback,
		/// make sure you don't record and playback simultaneously 
		/// using the same file!!!
		void startRecording();
		void stopRecording();
		void startPlayback();
		void stopPlayback();

		ofxKinect 			kinect;
		ofxKinectRecorder 	kinectRecorder;
		ofxKinectPlayer 	kinectPlayer;
		
		/// used to switch between the live kinect and the recording player
		ofxBase3DVideo* 	kinectSource;

		ofxCvColorImage		colorImg;

		ofxCvGrayscaleImage grayImage;			// grayscale depth image
		ofxCvGrayscaleImage grayThreshNear;		// the near thresholded image
		ofxCvGrayscaleImage grayThreshFar;		// the far thresholded image

		ofxCvContourFinder 	contourFinder;
		
		
		ofxOscReceiver	receiver;
		ofxOscSender	sender;
		int				current_msg_string;
		string		msg_strings[NUM_MSG_STRINGS];
		float			timers[NUM_MSG_STRINGS];
		
		float camDepth, rBack,gBack,bBack,aBack,rFace,gFace,bFace,aFace, rotX,rotY, scale, randomness;
		int step, glBeginCase, bufferBlob, colorMode;
		bool full;
		map<string, int> iv;
		map<string, float> fv;		

		
		bool				bThreshWithOpenCV;
		bool				bDrawPointCloud;

		int 				nearThreshold;
		int					farThreshold;

		int					camAngle;
		
		int 				pointCloudRotationY;
		
		bool 				bRecord;
		bool 				bPlayback;
		
};
