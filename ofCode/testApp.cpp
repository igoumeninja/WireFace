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
		
		sender.setup( "localhost", SC_PORT );

		current_msg_string = 0;

		//glutSetCursor(GLUT_CURSOR_CYCLE);  // change cursor icon (http://pyopengl.sourceforge.net/documentation/manual/glutSetCursor.3GLUT.html)
				
		ofSetWindowTitle("WireFace: AudioVisual Performance ®reWorks");
		ofSetFrameRate(24); // if vertical sync is off, we can go a bit fast... this caps the framerate at 60fps.
		ofSetVerticalSync(false);
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
		bThreshWithOpenCV = false;

		bRecord = false;
		bPlayback = false;

		// zero the tilt on startup
		angle = 0;
		kinect.setCameraTiltAngle(angle);
		
		// start from the front
		pointCloudRotationY = 180;
		bDrawPointCloud = true;
	}	//	kinect
	
	{
		iv["rBack"] = iv["gBack"] = iv["bBack"] = iv["aBack"] = 255;
		iv["rFace"] = iv["gFace"] = iv["bFace"] = 0;
		iv["rotateY"] = 180;
	}	// Initial Values
}

//--------------------------------------------------------------
void testApp::update() {
	ofBackground(0,0,0);
	
	kinectSource->update();
	
	// there is a new frame and we are connected
	if(kinectSource->isFrameNew()) {
	
		// load grayscale depth image from the kinect source
		grayImage.setFromPixels(kinectSource->getDepthPixels(), kinect.width, kinect.height);
 	
		// we do two thresholds - one for the far plane and one for the near plane
		// we then do a cvAnd to get the pixels which are a union of the two thresholds 
		if(bThreshWithOpenCV) {
			grayThreshNear = grayImage;
			grayThreshFar = grayImage;	
			grayThreshNear.threshold(nearThreshold, true);
			grayThreshFar.threshold(farThreshold);
			cvAnd(grayThreshNear.getCvImage(), grayThreshFar.getCvImage(), grayImage.getCvImage(), NULL);
		} else {
		
			// or we do it ourselves - show people how they can work with the pixels
			unsigned char * pix = grayImage.getPixels();

			int numPixels = grayImage.getWidth() * grayImage.getHeight();
			for(int i = 0; i < numPixels; i++) {
				if(pix[i] < nearThreshold && pix[i] > farThreshold) {
					pix[i] = 255;
				} else {
					pix[i] = 0;
				}
			}
		}

		// update the cv images
		grayImage.flagImageChanged();
	
		// find contours which are between the size of 20 pixels and 1/3 the w*h pixels.
    	// also, find holes is set to true so we will get interior contours as well....
    	contourFinder.findContours(grayImage, 1, (kinect.width*kinect.height)/2, 20, false);
		
		ofxOscMessage m;
		m.setAddress( "nBlobs" );
		m.addIntArg( contourFinder.nBlobs );
		sender.sendMessage( m );
		
		cout << contourFinder.nBlobs << endl;
		
	}

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
			else if ( m.getAddress() == "int" )	{
				iv[m.getArgAsString(0)] = m.getArgAsInt32(1);	
				//printf("value = %d\n", m.getArgAsInt32(1));		
			}
			else if ( m.getAddress() == "float" )	{
				fv[m.getArgAsString(0)] = m.getArgAsFloat(1);			
			}
			// check for mouse button message
			else if ( m.getAddress() == "sakis" )
			{

			}
			else
			{}
		}
	}	//	OSC 
	
}

//--------------------------------------------------------------
void testApp::draw() {
	ofSetColor(iv["rBack"], iv["gBack"], iv["bBack"], iv["aBack"]);
	ofRect(0,0,ofGetWidth(), ofGetHeight());

	ofSetColor(255, 255, 255);
	
	if(bDrawPointCloud) {
		ofPushMatrix();
		ofTranslate(420, 320);
		ofScale(600, 600, 600);
		// we need a proper camera class
		drawPointCloud();
		ofPopMatrix();
	}
}

void testApp::drawPointCloud() {
	
	//ofScale(2*1200, 2*1200, 2*1200);	
//	int w = 1280;
//	int h = 960;
	int w = 640;
	int h = 480;
//	int w = 320;
//	int h = 240;

	ofRotateY(iv["rotateY"]);
	ofRotateX(iv["rotateX"]);
//	ofScale(1200, 1200, 1200);
	
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
			glColor3ub(0,0,0);
			//glColor3ub(iv["rFace"], iv["gFace"], iv["bFace"]);	
//			printf("%f\n",cur.z);		
			if (cur.z < 1.5)		{
				glVertex3f(cur.x, cur.y, cur.z);
			}
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
	//pointCloudRotationY = x;
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
