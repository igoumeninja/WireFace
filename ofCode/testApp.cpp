#include "testApp.h"


//--------------------------------------------------------------
void testApp::setup() {
	{
		ofSetCircleResolution(200);
		//texScreen.allocate(ofGetWidth(), ofGetHeight(),GL_RGB);// GL_RGBA); 
		ofSetBackgroundAuto(false);
		ofEnableSmoothing();
		ofEnableAlphaBlending(); 
		cout << "listening for osc messages on port " << PORT << "\n";
		receiver.setup( PORT );

		current_msg_string = 0;

		//glutSetCursor(GLUT_CURSOR_CYCLE);  // change cursor icon (http://pyopengl.sourceforge.net/documentation/manual/glutSetCursor.3GLUT.html)
				
		ofSetWindowTitle("WireFace: AudioVisual Performance ®reWorks");
		ofSetFrameRate(24); // if vertical sync is off, we can go a bit fast... this caps the framerate at 60fps.
	}	//	setup
	{
		kinect.init();
		//kinect.init(true);  // shows infrared instead of RGB video image
		//kinect.init(false, false);  // disable infrared/rgb video iamge (faster fps)
		kinect.setVerbose(true);
		kinect.open();
		
		// start with the live kinect source
		kinectSource = &kinect;

		colorImg.allocate(kinect.width, kinect.height);
		grayImage.allocate(kinect.width, kinect.height);
		grayThreshNear.allocate(kinect.width, kinect.height);
		grayThreshFar.allocate(kinect.width, kinect.height);

//		nearThreshold = 230;
//		farThreshold  = 70;
		nearThreshold = 230;		
		farThreshold  = 70;
		bThreshWithOpenCV = true;

		bRecord = false;
		bPlayback = false;

		// zero the tilt on startup
		angle = 0;
		kinect.setCameraTiltAngle(angle);
		
		// start from the front
		pointCloudRotationY = 180;
		bDrawPointCloud = true;
	}	//	kinect
}

//--------------------------------------------------------------
void testApp::update() {
	{
		for ( int i=0; i<NUM_MSG_STRINGS; i++ )
		{
			if ( timers[i] < ofGetElapsedTimef() )
				msg_strings[i] = "";
		}

		// check for waiting messages
		while( receiver.hasWaitingMessages() )
		{
			// get the next message
			ofxOscMessage m;
			receiver.getNextMessage( &m );

			// check for mouse moved message
			if ( m.getAddress() == "rotateY" )
			{
				pointCloudRotationY = m.getArgAsInt32( 0 );
				cout << m.getArgAsInt32( 0 ) << endl;
			}
			// check for mouse button message
			else if ( m.getAddress() == "sakis" )
			{

			}
			else
			{
				// unrecognized message: display on the bottom of the screen
				string msg_string;
				msg_string = m.getAddress();
				msg_string += ": ";
				for ( int i=0; i<m.getNumArgs(); i++ )
				{
					// get the argument type
					msg_string += m.getArgTypeName( i );
					msg_string += ":";
					// display the argument - make sure we get the right type
					if( m.getArgType( i ) == OFXOSC_TYPE_INT32 )
						msg_string += ofToString( m.getArgAsInt32( i ) );
					else if( m.getArgType( i ) == OFXOSC_TYPE_FLOAT )
						msg_string += ofToString( m.getArgAsFloat( i ) );
					else if( m.getArgType( i ) == OFXOSC_TYPE_STRING )
						msg_string += m.getArgAsString( i );
					else
						msg_string += "unknown";
				}
				// add to the list of strings to display
				msg_strings[current_msg_string] = msg_string;
				timers[current_msg_string] = ofGetElapsedTimef() + 5.0f;
				current_msg_string = ( current_msg_string + 1 ) % NUM_MSG_STRINGS;
				// clear the next line
				msg_strings[current_msg_string] = "";
			}

		}
	
	}	//	OSC 

	ofBackground(0,0,0);
	
	kinectSource->update();
}

//--------------------------------------------------------------
void testApp::draw() {

	ofSetColor(255, 255, 255);
	
	if(bDrawPointCloud) {
		ofPushMatrix();
		ofTranslate(420, 320);
		ofScale(600, 600, 600);
		// we need a proper camera class
		drawPointCloud();
		ofPopMatrix();
	} else {
		if(!bPlayback) {
			// draw from the live kinect
			kinect.drawDepth(10, 10, 400, 300);
			kinect.draw(420, 10, 400, 300);
		} else {
			// draw from the player
			kinectPlayer.drawDepth(10, 10, 400, 300);
			kinectPlayer.draw(420, 10, 400, 300);
		}

		grayImage.draw(10, 320, 400, 300);
		contourFinder.draw(10, 320, 400, 300);
	}
	
	// draw recording/playback indicators
	ofPushMatrix();
	ofTranslate(25, 25);
	ofFill();
	if(bRecord) {
		ofSetColor(255, 0, 0);
		ofCircle(0, 0, 10);
	}
	if(bPlayback) {
		ofSetColor(0, 255, 0);
		ofTriangle(-10, -10, -10, 10, 10, 0);
	}
	ofPopMatrix();
	
}

void testApp::drawPointCloud() {
	
	//ofScale(2*1200, 2*1200, 2*1200);	
//	int w = 1280;
//	int h = 960;
	int w = 640;
	int h = 480;
//	int w = 320;
//	int h = 240;

	ofRotateY(pointCloudRotationY);
	
	//ofRotateY(373);
	float* distancePixels = kinect.getDistancePixels();
	//glBegin(GL_POINTS);
	glBegin(GL_POINTS);

	int step = 3;
	for(int y = 0; y < h; y += step) {
		for(int x = 0; x < w; x += step) {
			ofPoint cur = kinect.getWorldCoordinateFor(x, y);
			ofColor color = kinect.getCalibratedColorAt(x,y);
			//glColor3ub((unsigned char)color.r,(unsigned char)color.g,(unsigned char)color.b);
			//glColor3ub(255-(unsigned char)color.r,255-(unsigned char)color.g,255-(unsigned char)color.b);			
			//glColor3ub(250*(unsigned char)color.r,250*(unsigned char)color.r,250*(unsigned char)color.r);			
			glColor3ub(255,255,255);
//			if (cur.z > 1)		{
//				cout << "+1" << endl;					
//			}	else	{
//				cout << "-1" << endl;					
//			}			
			glVertex3f(cur.x, cur.y, cur.z);
		}
	}
	glEnd();
}

//--------------------------------------------------------------
void testApp::exit() {
	//kinect.setCameraTiltAngle(0); // zero the tilt on exit
	kinect.close();
	kinectPlayer.close();
	kinectRecorder.close();
}

//--------------------------------------------------------------
void testApp::keyPressed (int key) {
	switch (key) {
		case ' ':
			bThreshWithOpenCV = !bThreshWithOpenCV;
		break;
		
		case'p':
			bDrawPointCloud = !bDrawPointCloud;
			break;
	
		case '>':
		case '.':
			farThreshold ++;
			if (farThreshold > 255) farThreshold = 255;
			break;
			
		case '<':		
		case ',':		
			farThreshold --;
			if (farThreshold < 0) farThreshold = 0;
			break;
			
		case '+':
		case '=':
			nearThreshold ++;
			if (nearThreshold > 255) nearThreshold = 255;
			break;
			
		case '-':		
			nearThreshold --;
			if (nearThreshold < 0) nearThreshold = 0;
			break;
			
		case 'w':
			kinect.enableDepthNearValueWhite(!kinect.isDepthNearValueWhite());
			break;
			
		case 'o':
			kinect.setCameraTiltAngle(angle);	// go back to prev tilt
			kinect.open();
			break;
			
		case 'c':
			kinect.setCameraTiltAngle(0);		// zero the tilt
			kinect.close();
			break;
			
		case 'r':
			bRecord = !bRecord;
			if(bRecord) {
				startRecording();
			} else {
				stopRecording();
			}
			break;
			
		case 'q':
			bPlayback = !bPlayback;
			if(bPlayback) {
				startPlayback();
			} else {
				stopPlayback();
			}
			break;

		case OF_KEY_UP:
			angle++;
			if(angle>30) angle=30;
			kinect.setCameraTiltAngle(angle);
			break;

		case OF_KEY_DOWN:
			angle--;
			if(angle<-30) angle=-30;
			kinect.setCameraTiltAngle(angle);
			break;
	}
}

//--------------------------------------------------------------
void testApp::mouseMoved(int x, int y) {
	pointCloudRotationY = x;
}

//--------------------------------------------------------------
void testApp::mouseDragged(int x, int y, int button)
{}

//--------------------------------------------------------------
void testApp::mousePressed(int x, int y, int button)
{}

//--------------------------------------------------------------
void testApp::mouseReleased(int x, int y, int button)
{}

//--------------------------------------------------------------
void testApp::windowResized(int w, int h)
{}

//--------------------------------------------------------------
void testApp::startRecording() {
	
	// stop playback if running
	stopPlayback();
	
	kinectRecorder.init(ofToDataPath("recording.dat"));
	bRecord = true;
}

//--------------------------------------------------------------
void testApp::stopRecording() {
	kinectRecorder.close();
	bRecord = false;
}

//--------------------------------------------------------------
void testApp::startPlayback() {
	
	stopRecording();
	kinect.close();

	// set record file and source
	kinectPlayer.setup(ofToDataPath("recording.dat"), true);
	kinectPlayer.loop();
	kinectSource = &kinectPlayer;
	bPlayback = true;
}

//--------------------------------------------------------------
void testApp::stopPlayback() {
	kinectPlayer.close();
	kinect.open();
	kinectSource = &kinect;
	bPlayback = false;
}
