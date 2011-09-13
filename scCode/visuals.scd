//:VISUALS
//:-------


//:PatternProxy
~angle = 0;
~rotDur = 0.1;
~angleStep = 5;

~rotDurValue = 0.9;
~rotDur = PatternProxy(Pseq([~rotDurValue],inf));		

~pat = Pdef(\rotDurPat, 
	Posc(
		\dur, ~rotDur,
	 	\dest,  [NetAddr.localAddr, NetAddr("localhost", 57120)],
		\msg, Pseq([['rotY']], inf)
	);
);	

//:Precieve
Preceive(
	'rotY' -> {
		~angle = ~angle + ~angleStep;
		OF.rotY(~angle);
		}
).play;


//:---------
//:Play ~pat
~pat.play;
//:Stop ~pat
~pat.stop;


//:Pattern Rotate circle

// Pdef
Pdef(\rotate, Posc(
		\msg, Pseq([['rotY', Pseq([1, 2, 3], 10)]], inf),
		\dur, ~rotDur,
		\dest,  [NetAddr.localAddr, NetAddr("localhost", 57120)]
		)
	);



//:Play
Pdef(\rotate).play;	
//:Stop
Pdef(\rotate).stop

//:------------------





//:Rotate circle
OF.int("rotateY",230);

//:Rotate circle
~delay = (1/24);
~angleScale = 2;
{
	360.do { |i|
		NetAddr("localhost", 12345).sendMsg("rotY", i*~angleScale);
		~delay.wait;
	}
}.fork;




//:Other Pdef
Pdef(\rotate, Posc(
		\msg, Pseq([['rotY', Pseq([1, 2, 3], 10)]], inf),
		\dur, rotDur,
		\dest,  [NetAddr.localAddr, NetAddr("localhost", 57120)]
		)
	);

//:Precieve
~angle = 0;
Preceive(
	'rotY' -> {
		"Precieve is working".postln;
		~angle = ~angle + ~angleStep;
		~angle.postln;
		OF.rotY(~angle);
		},

	'2' -> {
		~klk = Synth("over", [
			\atk, 0.5,
			\sus, 1,
			\rel, 4,
			\pan, 1.0.rand2,
			\freqs,  {6000.0.linrand+80}.dup(12),
			\rings, {0.1.rrand(3)}.dup(12)
		]);
		}
).play;



//:erase back
OF.int("aBack",50);
OF.int("rBack",255);
OF.int("gBack",255);
OF.int("bBack",255);
//:erase back
OF.int("aBack",250);
OF.int("rBack",0);
OF.int("gBack",0);
OF.int("bBack",0);
OF.int("rFace",255);
OF.int("gFace",255);
OF.int("bFace",255);