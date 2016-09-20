//--This program will show a 3D projection of the position and angular movements of a Genuino 101. 
//  It will also take measurements of temperature, humidity and heat index. 

//--Class for sending and receiving data from the arduino. 
import processing.serial.*;
import org.firmata.*;
import cc.arduino.*;

Serial ardPort;      //--Serial port the arduino is using. 
int newLine = 13;    //--New line character in ASCII.

//--Navigation angle variables.  
float yaw, pitch, roll;
float ax, ay, az;
float gx, gy, gz;

//--Weather variables. 
float tempIMU; 
float tempSens; 
float humidity;
float heatIndex; 
float[] tempLog1 = new float[200];
float[] tempLog2 = new float[200];
int refLevel; 
int uvLevel; 
float outputVoltage; 
float uvIntensity; 

//--Weather monitor translation constants. 
int wmX = 90;
int wmY = 60;

//--Temperature panel translation constants. 
int l = 60; 
int w = 45; 
int tpY = 55;
int tpX = 30; 

//--Navigation monitor translation constants. 
int nmX = 60; 
int nmY = 25;
int sX = 100; 
int sY = 500; 

//--Colors. 
color orange = color(255, 110, 26);
color yellow = color(255, 213, 0);
color gray = color(30, 30, 30);
color red = color(250, 10, 10);
color blue = color(10, 16, 252);

//--Message display, formatting and dimension variables.
String message; 
String [] ardMsg = new String [17];
PFont font;

//--Image variables. 
PImage imgHum; 
PImage imgTem;

//--Flight simulator. 
float spanAngle = 120;
int majorDiv, minorDiv; 

//--Initialization. 
void setup() {

  size(1500, 800, P3D); //--Screen size and set to 3D. 
  frameRate(200);

  for (int i = 0; i < 200; i++) {   //--Fill temperature logs with zeroes. 
    tempLog1[i] = 0;
    tempLog2[i] = 0;
  }

  //--Port initialization. The baud rate and port should be the same set on the Arduino IDE.
  ardPort = new Serial(this, "COM7", 57600);            

  //--Text settings (uncomment code lines to list fonts and choose a different one. 
  //  String[] fontList = PFont.list();
  //  printArray(fontList);  
  textSize(16);    //Set text size
  textMode(SHAPE); //Set text mode to shape. 
  font = createFont("Consolas Bold", 16, true);

  //--Load images (they must be in the folder of the current sketch). 
  imgHum = loadImage("humidity.png");
  imgTem = loadImage("temp.png");
}

//--Main program. 
void draw() {

  ardSerial();        //--Read the incoming message.            
  background(gray);   //--Set gray background. 
  textFont(font, 16); //--Use the font set on the setup. 

  //****REQUIRE CALIBRATION ASAP****// 
  drawTables();        //--Draw tables using lines.
  printNavigationMonitor(); //--Print Navigation Monitor variables. 
  printFlightSimulator();   //--Print flight simulator.
  printTemperaturePanel(60, 45, 410, 60, blue, red); //--Print the temperature panel. 
  printWeatherMonitor();    //--Print the weather monitor variables.  
  graphTemperature();       //--Print temperature graphs. 
  arduino();                //--Draw and display arduino board. 

  //--Print values to console. For debugging purposes. DO NOT COMMENT. 
  print(pitch);         
  print("\t");
  print(roll);          
  print("\t");
  print(-yaw);          
  print("\t");
  print(ax);            
  print("\t");
  print(ay);            
  print("\t");
  print(az);            
  print("\t");
  print(gx);            
  print("\t");
  print(gy);            
  print("\t");
  print(gz);            
  print("\t");
  print(refLevel);      
  print("\t");
  print(uvLevel);       
  print("\t");
  print(outputVoltage); 
  print("\t");
  println(uvIntensity);     


  ardPort.write("r");  //--Write an r to receive data from the arduino. **SEE ARDUINO CODE**
} 

void drawTables() {
  stroke(yellow);              //--Yellow lines. 
  noFill();                    //--Do not fill the rectangle. **NOT SURE IF THIS LINE'S NEEDED. **
  rect(25, 50, 1455, 700);     //--Full screen rectangle.
  line(950, 50, 950, 750);     //--Vetical - separates weather monitor from navigation variables.
  line(1150, 260, 1150, 750);  //--Vertical - separates graphs from weather variables. 
  line(775, 50, 775, 750);     //--Verical - separates navigation variables from 3D simulators. 
  line(950, 85, 1480, 85);     //--Horizontal - separates weather title. 
  line(950, 260, 1480, 260);   //--Horizontal - separates temperature panel from other weather variables. 
  line(775, 85, 950, 85);      //--Horizontal - separates title from navigation variables.
  line(25, 85, 950, 85);       //--Horixontal - separates title from simulators.
}



//****NEED TO PROVIDE AN EXPLANATION OF WHAT I'M DOING HERE**//
void graphTemperature() {
  pushMatrix();    //--Start object. 
  //--Graph temperature. 
  // Y1 is for IMU temperature sensor, Y2 is for DHT sensor. 
  translate(1170, 290); //(220+950), (210+100)
  float posY1 = map( tempIMU, -44, 85, wmY + 160, wmY - 40);
  float posY2 = map(tempSens, 0, 50, wmY + 385, wmY + 185);
  stroke(0);
  fill(255, 255, 255);
  rect(wmX - 25, wmY - 40, 200, 200);
  rect(wmX - 25, wmY + 185, 200, 200);
  for (int i = 0; i < 200; i++) {
    if (i == 199) {
      tempLog1[i] = posY1; 
      tempLog2[i] = posY2;
    } else {
      tempLog1[i] = tempLog1[i + 1];
      tempLog2[i] = tempLog2[i + 1];
      //--Graph points. 
      stroke(blue);
      point(wmX - 30 + i, tempLog1[i]);       //***FIX THIS***// 
      stroke(orange);
      point(wmX - 30 + i, 200 + tempLog2[i]); //***FIX THIS***//
    }
  }

  //--Graph text
  textAlign(CENTER); 
  fill(yellow);
  text("Temperature vs Time", wmX + 60, 0);
  text("IMU(T)", wmX - 55, wmY - 40);
  text("t(s)", wmX + 200, wmY + 160); 
  text("DHT(T)", wmX - 55, wmY + 190);
  text("t(s)", wmX + 200, wmY + 390);
  popMatrix();
}

//--This function displays the circle horizon with scale divisions. 
void horizon() { 
  pushMatrix();
  stroke(4); 
  fill(0, 180, 255);
  ellipse(0, 0, 300, 300);
  fill(95, 55, 40);
  arc(0, 0, 300, 300, 0, PI);
  spanAngle = 360; 
  minorDiv = 12; 
  majorDiv = 24;
  circularScale();
  popMatrix();
}

//--This function draws the division scales on the map. 
void circularScale() { 
  pushMatrix();
  float circleAmplitude = 350;  
  float angle; 
  float xDivCloser; 
  float xDivFar; 
  float yDivCloser; 
  float yDivFar; 
  float divCloseLength = circleAmplitude / 2 - circleAmplitude / 10;
  float divFarLength   = circleAmplitude / 2 - circleAmplitude / 7.4;
  stroke(255);
  for (int div = 0; div < majorDiv + 1; div++) { 
    angle = spanAngle / 2 + div * spanAngle / majorDiv;  
    xDivCloser = divCloseLength * cos(radians(angle)); 
    xDivFar = divFarLength * cos(radians(angle)); 
    yDivCloser = divCloseLength * sin(radians(angle)); 
    yDivFar = divFarLength * sin(radians(angle)); 
    if (div == majorDiv / 4 || div == 3*majorDiv/4 || div == majorDiv || div == majorDiv/2  ) { 
      strokeWeight(15); 
      stroke(0); 
      line(xDivCloser, yDivCloser, xDivFar, yDivFar); 
      strokeWeight(4); 
      stroke(100, 255, 100); 
      line(xDivCloser, yDivCloser, xDivFar, yDivFar);
    } else { 
      strokeWeight(2); 
      stroke(255); 
      line(xDivCloser, yDivCloser, xDivFar, yDivFar);
    }
  }
  popMatrix();
}

//--Function to print axis. 
void axis() {
  pushMatrix();
  stroke(255, 0, 0); 
  strokeWeight(2); 
  line(  0, 115, 0, -115); 
  fill(100, 255, 100); 
  stroke(0); 
  triangle(0, -130, -10, -115, 10, -115); 
  triangle(0, 130, -10, 115, 10, 115);
  popMatrix();
}

//--Function to draw a board. 
void board() { 
  pushMatrix();
  fill(red); 
  stroke(0);
  strokeWeight(2);
  triangle(-20, -10, 20, -10, 0, 25);
  rect( 15, -10, 80, 10); 
  rect(-95, -10, 80, 10);
  popMatrix();
}

//--Draw a pitch scale. 
void pitchScale() {  
  pushMatrix();
  stroke(255); 
  fill(255); 
  strokeWeight(0.5); 
  textSize(8); 
  textAlign(CENTER); 
  for (int i=-4; i<5; i++) {  
    if ((i==0)==false) { 
      line(55, 25*i, -55, 25*i);
    }  
    text(""+i*5, 50, 25*i, 25, 15); 
    text(""+i*5, -90, 25*i, 65, 15);
  } 
  textAlign(CENTER); 
  strokeWeight(1); 
  for (int i=-9; i<10; i++) { 
    if ((i==0)==false) {    
      line(12.5, 12.5*i, -12.5, 12.5*i);
    }
  }
  popMatrix();
}

void printFlightSimulator() {
  pushMatrix();
  translate(600, 550);
  rotate(-pitch);
  horizon();
  rotate(-roll);
  pitchScale();
  board();
  rotate(-roll);
  axis();
  popMatrix();
}