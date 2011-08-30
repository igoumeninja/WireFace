//:Stagones by Batuhan
SynthDef( "stagones",
			{ arg freq = 40, tempo = 1.5, out = 0, pan =0, amp=1, 
			mulDelay = 2, roundStart = 2e-3, roundEnd = 4e-3;
	 			var source;
				source = AllpassC.ar( SinOsc.ar(freq).tanh,  //AllpassC.ar(in, ...)
							0.4, // maxdelaytime,
							TExpRand.ar(2e-4, 0.4, 
								Impulse.ar(tempo)).round([roundStart, roundEnd]), //delaytime,
							mulDelay,
							0.1); // mul,
				Out.ar( out, Pan2.ar(source, 0, amp));
				
	}).send(s);
//:--
x = Synth(\stagones).play;
//:Padovani
SynthDef('padovani', {	|sawFreq = 1, trigDur = 0.05, trigFreq = 10, roomSize = 2, sizeGrain = 1, signalOutput = 10|
	var in, singal;
	p= Trig.ar(Saw.ar(sawFreq),trigDur);
	y= SinOsc.ar(p*trigFreq);
	z= SinOsc.ar(p);
	in = GrainIn.ar(
			2, 			//channelNum
			y, 			//trigger
			y/sizeGrain,	//duration-the size of the grain
			z,			//input to granulate
			p*z			//pan
			-1			//buf num 
		);
	singal = GVerb.ar(in, roomSize )/signalOutput;
	Out.ar(0, singal);
}).send(s);
//:Play Padovani
p = Synth(\padovani).play;
//:Control Padovani
~trigDurSpec = ControlSpec(0.001, 10, \lin);
OSCresponderNode(n, '/trigDur', {|t,r,msg| 
	 { | i | format("mySynths%", i).asSymbol.set(\trigDur, ~trigDurSpec.map(msg[1])*0.1*i ) } ! 5;
	 ~trigDurSpec.map(msg[1]).postln;
	 }).add;
//:Test padovani
NetAddr("127.0.0.1", 57120).sendMsg('/trigDur', 10)
//:foubuf v.002
SynthDef(\foubuf_002, {| out = 0, bufnum = 0, rate = 1, trigger = 1, loop = 1, pos = 0, level = 1 |
	Out.ar(out,
		Pan2.ar( 
			PlayBuf.ar(1, 
				bufnum, 
				rate, 
				trigger, 
				0, 
				loop
			),
			pos,
			level
		)
	)
}).send(s);
//:--
y = Synth(\foubuf_002).play
//:Control foubuf
y.set(\bufnum, 2)
y.set(\loop, 1)
y.set(\level, 1)
y.set(\rate, 0.3)

//:Buffer OSC Responders
p = NetAddr("127.0.0.1", 57120);  // send to SuperCollider Server (just for debugging)
OSCresponder(nil, "ice", { x.set(\trigger, 1, \bufnum, 0);}).add; //Create a Responder
p.sendMsg(\ice); //test message

//:Blod detection Responder
o = OSCresponder(nil, "nBlobs", { | t, r, msg | 
		//msg.postln;
		if( msg[1]>0,{
		msg[1].postln;
	},{
		"no Blobs".postln;
	})
		//n.sendMsg("/blobFound",msg[1].round.asInteger, msg[2].round.asInteger, msg[3].round.asInteger );
	}
).add;

//:remove OSCresponder
o.remove;
  

