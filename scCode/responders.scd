//:RESPONDERS
//:----------

//:Visuals

// colorMode
OSCresponderNode(n, '/colorMode', { |t,r,msg| 
	if( msg[1] == 1,{
		OF.colorMode(1);
	},{
		OF.colorMode(0);
	});
}).add;



// Scale
~scaleSpec = ControlSpec(1, 10, \lin);
OSCresponderNode(n, '/scale', { |t,r,msg| 
	OF.scale(~scaleSpec.map(msg[1]));
}).add;

// Randomness
~randomnessSpec = ControlSpec(0,0.1, \lin);
OSCresponderNode(n, '/randomness', { |t,r,msg| 
	OF.randomness(~randomnessSpec.map(msg[1]));
}).add;


// Rotation
~rotYSpec = ControlSpec(360.0, 0.0, \lin);
~rotXSpec = ControlSpec(-180.0, 180.0, \lin);
OSCresponderNode(n, '/rotate', { |t,r,msg| 
	y.set(\freqShift, ~rotXSpec.map(msg[1]));	
	OF.rotY(~rotYSpec.map(msg[2]));
	OF.rotX(~rotXSpec.map(msg[1]));
}).add;

// Rotation angle
~rotAngleSpec = ControlSpec(1,15, \lin);
OSCresponderNode(n, '/rotAngle', { |t,r,msg| 
	~angleStep = ~rotAngleSpec.map(msg[1]);
}).add;

// Rotate circle
OSCresponderNode(n, '/loopRotate', { |t,r,msg| 
	if( msg[1] == 1,{
		OF.background(0);
		OF.aBack(0);
		~pat.play;
		y.set(\bufnum, rrand(0,5).asInteger);		
	},{
		~pat.stop;
		y.set(\bufnum, rrand(0,5).asInteger);		
	});
}).add;

// Speed Rotation
~speedRotSpec = ControlSpec(0.01,2, \lin);
OSCresponderNode(n, '/speedRot', { |t,r,msg| 
	~rotDurValue = ~speedRotSpec.map(msg[1]);
	~rotDur = PatternProxy(Pseq([~rotDurValue],inf));		~pat = Pdef(\rotDurPat, 
		Posc(
			\dur, ~rotDur,
		 	\dest,  [NetAddr.localAddr, NetAddr("localhost", 57120)],
			\msg, Pseq([['rotY', Pseq([1, 2, 3], 10)]], inf)
		);
	);	
}).add;

// Camera
~camDepthSpec = ControlSpec(0,10, \lin);
OSCresponderNode(n, '/camDepth', { |t,r,msg| 
	OF.camDepth(~camDepthSpec.map(msg[1]));
}).add;

~camAngleSpec = ControlSpec(-30,30, \lin);
OSCresponderNode(n, '/camAngle', { |t,r,msg| 
	OF.camAngle(~camAngleSpec.map(msg[1]).asInteger);
}).add;

// Background Colors
~rBackSpec = ControlSpec(0,255, \lin);
OSCresponderNode(n, '/rBack', { |t,r,msg| 
	OF.rBack(~rBackSpec.map(msg[1]));
}).add;
~gBackSpec = ControlSpec(0,255, \lin);
OSCresponderNode(n, '/gBack', { |t,r,msg| 
	OF.gBack(~gBackSpec.map(msg[1]));
}).add;
~bBackSpec = ControlSpec(0,255, \lin);
OSCresponderNode(n, '/bBack', { |t,r,msg| 
	OF.bBack(~bBackSpec.map(msg[1]));
}).add;
~aBackSpec = ControlSpec(0,55, \lin);
OSCresponderNode(n, '/aBack', { |t,r,msg| 
	OF.aBack(~aBackSpec.map(msg[1]));
}).add;

// WireFace Colors
~rFaceSpec = ControlSpec(0,255, \lin);
OSCresponderNode(n, '/rFace', { |t,r,msg| 
	OF.rFace(~rFaceSpec.map(msg[1]));
}).add;
~gFaceSpec = ControlSpec(0,255, \lin);
OSCresponderNode(n, '/gFace', { |t,r,msg| 
	OF.gFace(~gFaceSpec.map(msg[1]));
}).add;
~bFaceSpec = ControlSpec(0,255, \lin);
OSCresponderNode(n, '/bFace', { |t,r,msg| 
	OF.bFace(~bFaceSpec.map(msg[1]));
}).add;
~aFaceSpec = ControlSpec(0,255, \lin);
OSCresponderNode(n, '/aFace', { |t,r,msg| 
	OF.aFace(~aFaceSpec.map(msg[1]));
}).add;

// Step
OF.step(2);	OF.glBeginCase(0);

// glBegin
OSCresponderNode(n, '/glBeginCase', { |t,r,msg| 
	OF.glBeginCase(msg[1].asInt);
}).add;

//:Sound
// Batuhan
~ampButSpec = ControlSpec(0.001, 6, \lin);
OSCresponderNode(n, '/ampBut', { |t,r,msg| 
	x.set(\amp, ~ampButSpec.map(msg[1]));
	~ampButSpec.map(msg[1]).postln;
}).add;

~tempoButSpec = ControlSpec(0.001, 5, \lin);
OSCresponderNode(n, '\butTempo', { |t,r,msg| 
	msg.postln;
	x.set(\tempo, ~tempoButSpec.map(msg[1]));
	~tempoButSpec.map(msg[1]).postln;
}).add;	


// Buffers
OSCresponderNode(n, '/bufNum/1/1', { |t,r,msg| 
	msg.postln;
	y.set(\bufnum, 0);
}).add;	

OSCresponderNode(n, '/bufNum/1/2', { |t,r,msg| 
	msg.postln;
	y.set(\bufnum, 1);
}).add;	

OSCresponderNode(n, '/bufNum/1/3', { |t,r,msg| 
	msg.postln;
	y.set(\bufnum, 2);
}).add;	

OSCresponderNode(n, '/bufNum/1/4', { |t,r,msg| 
	msg.postln;
	y.set(\bufnum, 3);
}).add;	

OSCresponderNode(n, '/bufNum/1/5', { |t,r,msg| 
	msg.postln;
	y.set(\bufnum, 4);
}).add;	

~bufRateSpec = ControlSpec(-5, 5, \lin);
OSCresponderNode(n, '/bufRate', { |t,r,msg| 
	y.set(\rate, ~bufRateSpec.map(msg[1]));
	~bufRateSpec.map(msg[1]).postln;
}).add;

~ampBufSpec = ControlSpec(0, 5, \lin);
OSCresponderNode(n, '/ampBuf', { |t,r,msg| 
	y.set(\level, ~ampBufSpec.map(msg[1]));
}).add;

~freqShiftSpec = ControlSpec(-2000, 2000, \lin);
OSCresponderNode(n, '/freqShift', { |t,r,msg| 
	y.set(\freqShift, ~freqShiftSpec.map(msg[1]));
}).add;


// Crotale
OSCresponderNode(n, '/crataleNote/1/1', { |t,r,msg| 
	if( msg[1] == 1,{
		Synth("PMCrotale", ["midi", 60, "tone", 3]);
		OF.rFace(255);
		OF.gFace(0);
		OF.bFace(255);
	},{
		Synth("PMCrotale", ["midi", 72, "tone", 1]);
		OF.rFace(255);
		OF.gFace(255);
		OF.bFace(255);
	});

}).add;	
OSCresponderNode(n, '/crataleNote/2/1', { |t,r,msg| 
	if( msg[1] == 1,{
		Synth("PMCrotale", ["midi", 62, "tone", 3]);
		OF.rFace(255);
		OF.gFace(255);
		OF.bFace(0);
	},{
		Synth("PMCrotale", ["midi", 74, "tone", 3]);	
		OF.rFace(255);
		OF.gFace(255);
		OF.bFace(255);
	});

}).add;	
OSCresponderNode(n, '/crataleNote/3/1', { |t,r,msg| 
	if( msg[1] == 1,{
		Synth("PMCrotale", ["midi", 64, "tone", 3]);
		OF.rFace(255);
		OF.gFace(0);
		OF.bFace(0);
	},{
		Synth("PMCrotale", ["midi", 76, "tone", 2]);
		OF.rFace(255);
		OF.gFace(255);
		OF.bFace(255);
	});

}).add;	
OSCresponderNode(n, '/crataleNote/4/1', { |t,r,msg| 
	if( msg[1] == 1,{
		Synth("PMCrotale", ["midi", 67, "tone", 3]);
		OF.rFace(0);
		OF.gFace(255);
		OF.bFace(0);
	},{
		Synth("PMCrotale", ["midi", 79, "tone", 3]);
		OF.rFace(255);
		OF.gFace(255);
		OF.bFace(255);
	});

}).add;	
OSCresponderNode(n, '/crataleNote/5/1', { |t,r,msg| 
	if( msg[1] == 1,{
		Synth("PMCrotale", ["midi", 71, "tone", 3]);
		OF.rFace(0);
		OF.gFace(0);
		OF.bFace(255);
	},{
		Synth("PMCrotale", ["midi", 83, "tone", 4]);	
		OF.rFace(255);
		OF.gFace(255);
		OF.bFace(255);
	});

}).add;	

// Padovani

~ampPadSpec = ControlSpec(0, 5, \lin);
OSCresponderNode(n, '/ampPad', { |t,r,msg| 
	z.set(\level, ~ampPadSpec.map(msg[1]));
}).add;

~trigDurSpec = ControlSpec(0.001, 10, \lin);
OSCresponderNode(n, '/trigDur', {|t,r,msg| 
	 z.set(\trigDur, ~trigDurSpec.map(msg[1])) ;
	 ~trigDurSpec.map(msg[1]).postln;
	 }).add;
~trigFreqSpec = ControlSpec(0.001, 100, \lin);
OSCresponderNode(n, '/trigFreq', {|t,r,msg| 
	 z.set(\trigFreq, ~trigFreqSpec.map(msg[1]));
	 ~trigFreqSpec.map(msg[1]).postln;
	 }).add;
~sawFreqSpec = ControlSpec(0.001, 100, \lin);
OSCresponderNode(n, '/sawFreq', {|t,r,msg| 
	z.set(\sawFreq, ~sawFreqSpec.map(msg[1])) ;
	 ~sawFreqSpec.map(msg[1]).postln;
	 }).add;
~sizeGrainSpec = ControlSpec(2, 0.001, \lin);
OSCresponderNode(n, '/sizeGrain', {|t,r,msg| 
	 z.set(\sizeGrain, ~sizeGrainSpec.map(msg[1])) ;
	 ~sizeGrainSpec.map(msg[1]).postln;
	 }).add;
~roomSizeSpec = ControlSpec(0.001, 0.32, \lin);
OSCresponderNode(n, '/roomSize', {|t,r,msg| 
	  z.set(\roomSize, ~roomSizeSpec.map(msg[1])) ;
	 ~roomSizeSpec.map(msg[1]).postln;
	 }).add;
~signalOutputSpec = ControlSpec(10, 1, \lin);
OSCresponderNode(n, '/signalOutput', {|t,r,msg| 
	  z.set(\signalOutput, ~signalOutputSpec.map(msg[1])) ;
	 ~signalOutputSpec.map(msg[1]).postln;
	 }).add;


// Recieve from oF CV
OSCresponder(nil, "mute", { | t, r, msg | 
			{	
				y.set(\level, (0));
			}.fork;
	}
).add;
OSCresponder(nil, "intro", { | t, r, msg | 
			{	
				y.set(\level, 1);
			}.fork;
	}
).add;


// Centroid
~centroidXSpec = ControlSpec(-5, 5, \lin);
OSCresponder(nil, "centroid", { | t, r, msg | 
			{	
				y.set(\rate, ~centroidXSpec.map(msg[1]));
				x.set(\tempo, ~tempoButSpec.map(msg[2]));
			}.fork;
	}
).add;

//:Control Padovani
~trigDurSpec = ControlSpec(0.001, 10, \lin);
OSCresponderNode(n, '/trigDur', { |t,r,msg| 
	p.set(\trigDur, ~trigDurSpec.map(msg[1])*0.1);
	~trigDurSpec.map(msg[1]).postln;
}).add;


//:Testing 
NetAddr("127.0.0.1", 57120).sendMsg("\tempo", 0.1);

//:---
z.set(\trigDur, 0.1) ;