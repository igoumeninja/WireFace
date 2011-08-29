//:Rotate circle
OF.int("rotateY",230);

//:Rotate circle
~delay = (1/24);
~angleScale = 1;
{
	inf.do { |i|
		NetAddr("localhost", 12345).sendMsg("int","rotateY", i*~angleScale);
		~delay.wait;
	}
}.fork;

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