import processing.core.*; 
import processing.xml.*; 

import processing.opengl.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class loadFile extends PApplet {



/**
 * LoadFile 1
 * 
 * Loads a text file that contains two numbers separated by a tab ('\t').
 * A new pair of numbers is loaded each frame and used to draw a point on the screen.
 */


String[] lines;
float[] cordX = new float[4760];
float[] cordY = new float[4760];
float[] cordZ = new float[4760];
int index = 0;

public void setup() {
  size(700, 700, OPENGL);
  background(0);
  stroke(255);
  frameRate(25);
  lines = loadStrings("positions.txt");
  //if (index < lines.length) {
  for (int i = 0; i < lines.length; i++)  {
    String[] pieces = split(lines[i], ',');
    cordX[i] = PApplet.parseFloat(pieces[0]);
    cordY[i] = PApplet.parseFloat(pieces[1]);
    cordZ[i] = PApplet.parseFloat(pieces[2]);       
    //println("index:" + index + ", x = " + cordX[index] + ", y = " + cordY[index] + ", z = " + cordZ[index]);
  }
}

public void draw() {
  beginShape(POINTS);
  for (int i = 0; i < lines.length; i++)  {
    vertex(200*cordX[i], 200*cordY[i], 200*cordZ[i]);
  }  
  
  endShape();

//println("ok");

}

  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#FFFFFF", "loadFile" });
  }
}
