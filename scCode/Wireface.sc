Wireface	{
	
	*audio	{
		
	}
		
	*visuals	{
		~angle = 0;
		~rotDur = 0.1;
		~angleStep = 5;
		
		~rotDurValue = 0.9;
		~rotDur = PatternProxy(Pseq([~rotDurValue],inf));		
		
		~pat = Pdef(\rotDurPat, 
		Posc(
		\dur, ~rotDur,
		 	\dest,  [NetAddr.localAddr, NetAddr("localhost", 57120)],
		\msg, Pseq([['rotY', Pseq([1], 10)]], inf)
		);
		);	
	}
	
	*responders	{
	
	}
	
	}