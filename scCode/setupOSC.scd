//:Rotate circle
{
	inf.do { |i|
		NetAddr("localhost", 12345).sendMsg("rotateY", i);
		(1/24).wait;
	}
}.fork;

//:---

Function