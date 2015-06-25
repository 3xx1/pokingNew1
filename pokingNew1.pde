import processing.serial.*;
import oscP5.*;
import netP5.*;

Serial myPort_thz;
Serial myPort_r;
OscP5 oscP5;

float angleX, angleY; 
int z  = 60;
int th = 100;
float radratio = 90.0/15.0;
int stretch = 5;
int[][][] points = new int[z][th][3]; 
float[] radians = new float[th*z];

int val;
int r = 10;

int count_r, count_th, count_z;
boolean rF, thF, zF;

void setup() 
{
  size(1280, 720, P3D);
  colorMode(RGB, 256);
  myPort_thz = new Serial(this, "/dev/tty.usbmodem1411", 9600);
  myPort_r   = new Serial(this, "/dev/tty.usbmodem1451", 9600);
  
  for(int j=0; j<z; j++){
    for(int i=0; i<th; i++){
      radians[j*th+i] = 90.0;
      points[j][i][0] = int(radians[j*th+i]*cos(radians((360.0/th)*i))); 
      points[j][i][1] = int(radians[j*th+i]*sin(radians((360.0/th)*i))); 
      points[j][i][2] = j*stretch; 
    }
  }
  
  frameRate(60);
  count_r  = 0;
  count_th = 0;
  count_z  = 0;
  rF  = false;
  thF = false;
  zF  = false;
  
  oscP5 = new OscP5(this,12001);
 
}


void draw() 
{
  background(0);
  angleX += .001;
  angleY += .003;    
  
  for(int j=0; j<z; j++){
    for(int i=0; i<th; i++){
      points[j][i][0] = int(radians[j*th+i]*cos(radians((360.0/th)*i))); 
      points[j][i][1] = int(radians[j*th+i]*sin(radians((360.0/th)*i))); 
    }
  }
  
  translate(width/2, 3*height/4, stretch*z/2);
  rotateX(radians(90));
  rotateZ(radians(mouseX));
  stroke(255, 150);
  for(int j=0; j<z-1; j++){
    for(int i=0; i<th-1; i++){
      line(points[j][i][0], points[j][i][1], points[j][i][2], points[j][i+1][0], points[j][i+1][1], points[j][i+1][2]);
      line(points[j][i][0], points[j][i][1], points[j][i][2], points[j+1][i][0], points[j+1][i][1], points[j+1][i][2]);
    }
    line(points[j][th-1][0], points[j][th-1][1], points[j][th-1][2], points[j][0][0], points[j][0][1], points[j][0][2]);
  }
  line(points[z-1][th-1][0], points[z-1][th-1][1], points[z-1][th-1][2], points[0][th-1][0], points[0][th-1][1], points[0][th-1][2]);
  
 
  
  if(frameCount%20 == 5 && rF)  myPort_r.write(mouseX/8);
  if(frameCount%20 == 15 && rF)  myPort_r.write(0);
  if(frameCount%20 == 19 && rF)  count_r++;
  if(count_r==(15-r)){
    rF = false;
    count_r = 0;
    if(count_th<th)
    {
      myPort_thz.write(1);
      count_th++;
    }else
    {
      myPort_thz.write(2);
      count_th = 0;
    }
  }
  
  if(myPort_thz.available()>0){
    myPort_thz.read();
    rF = true;
  }
  
}

void keyPressed()
{
  if (key == 't') myPort_thz.write(1);
  if (key == 'z') myPort_thz.write(2);
  if (key == 'b') myPort_thz.write(3);
}

void mousePressed()
{
  rF = true;
}

void oscEvent(OscMessage theOscMessage) 
{
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());
  println(theOscMessage.get(0).intValue());
  for(int i=0; i<20; i++)
  {
    int step = theOscMessage.get(0).intValue();
    radians[step*20+i] = theOscMessage.get(i+1).floatValue() * 6.0;
  }
}

