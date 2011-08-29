ReadBuffer
//:--
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

//:OSC Responders
p = NetAddr("127.0.0.1", 57120);  // send to SuperCollider Server (just for debugging)
OSCresponder(nil, "ice", { x.set(\trigger, 1, \bufnum, 0);}).add; //Create a Responder
p.sendMsg(\ice); //test message
2