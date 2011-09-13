

/**
 * LoadFile 1
 * 
 * Loads a text file that contains two numbers separated by a tab ('\t').
 * A new pair of numbers is loaded each frame and used to draw a point on the screen.
 */

import processing.opengl.*;
String[] lines;
float[] cordX = new float[4760];
float[] cordY = new float[4760];
float[] cordZ = new float[4760];
int index = 0;

void setup() {
  size(700, 700, OPENGL);
  background(0);
  stroke(255);
  frameRate(25);
  lines = loadStrings("positions.txt");
  //if (index < lines.length) {
  for (int i = 0; i < lines.length; i++)  {
    String[] pieces = split(lines[i], ',');
    cordX[i] = float(pieces[0]);
    cordY[i] = float(pieces[1]);
    cordZ[i] = float(pieces[2]);       
    //println("index:" + index + ", x = " + cordX[index] + ", y = " + cordY[index] + ", z = " + cordZ[index]);
  }
}

void draw() {
  lights();
  background(0);
  
  // Change height of the camera with mouseY
  camera(2*mouseX, 2*mouseY, 220, // eyeX, eyeY, eyeZ
         0.0, 0.0, 0.0, // centerX, centerY, centerZ
         0.0, 1.0, 0.0); // upX, upY, upZ
  beginShape(POINTS);
  for (int i = 0; i < lines.length; i++)  {
    vertex(200*cordX[i]+ frameCount, 200*cordY[i], 200*cordZ[i]);
  }  
  
  endShape();

//println("ok");

}

