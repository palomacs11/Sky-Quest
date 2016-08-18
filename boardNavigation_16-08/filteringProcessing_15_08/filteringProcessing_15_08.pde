//--This program will show a 3D projection of the position and angular movements of a Genuino 101. 

//--Class for sending and receiving data from the arduino. 
import processing.serial.*;

//--Serial port the arduino is using. 
Serial myPort;

//--New line character in ASCII.
int newLine = 13; 

//--Navigation angles. 
float yaw, pitch, roll;
float ax, ay, az;
float gx, gy, gz;

//--Message display and format. 
String message;
String [] ypr_axyz_gxyz = new String [9];
PFont font;

//--Initialization. 
void setup() {

  //--Screen size and set it to 3D. 
  size(800, 800, P3D);

  //--Port initialization. The baud rate should be the same as arduino's. 
  //  The port should be the same as the arduino. 
  myPort = new Serial(this, "COM4", 9600);            

  //--Text settings.
  //--To print the list of fonts that processing manages. 
  //  String[] fontList = PFont.list();
  //  printArray(fontList);
  textSize(16);    //Set text size
  textMode(SHAPE); //Set text mode to shape. 
  font = createFont("Consolas Bold", 16, true);
}

//--Main program. 
void draw() {

  //--To read the incoming message. 
  serialEvent();                 

  //--Background color. 
  background(255);               
  textFont(font, 16);
  fill(0);

  //--Print on screen.
  printYPR();
  printAG();

  //--Set the position of the object to the center. 
  translate(width/2, height/2);  

  //--The object.
  //  The pushMatrix function saves the current coordinate system to the stack and the
  //  popMatrix function restores the prior coordinate system. 
  pushMatrix();      

  //--Rotate the arduino board given the angle received form the arduino. 
  rotateX(pitch); 
  rotateY(-yaw);                 
  rotateZ(-roll);                

  //--This function draws and Arduino board. 
  drawArduino();                 

  //--End of object. 
  popMatrix();                  

  //--Print values to console.
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
  println("\t");


  //--Write an s to receive data from the arduino. 
  myPort.write("r");
} 

//--Function reads form port. 
void serialEvent() {
  message = myPort.readStringUntil(newLine); 
  if (message != null) {
    ypr_axyz_gxyz   = split(message, ","); 

    //--Navigation Angle variables.
    yaw   = float(ypr_axyz_gxyz[0]);
    pitch = float(ypr_axyz_gxyz[1]);      
    roll  = float(ypr_axyz_gxyz[2]);

    //--Accelerometer values. 
    ax    = float(ypr_axyz_gxyz[3]);
    ay    = float(ypr_axyz_gxyz[4]);
    az    = float(ypr_axyz_gxyz[5]);

    //--Gyroscope values. 
    gx    = float(ypr_axyz_gxyz[6]);
    gy    = float(ypr_axyz_gxyz[7]);
    gz    = float(ypr_axyz_gxyz[8]);
  }
}

void drawArduino() {

  //--Set outline colour to darker teal
  stroke(0, 90, 90);            
  //--Set fill colour to lighter teal.
  fill(0, 130, 130);            
  //--Draw Arduino board base shape.
  box(300, 10, 200);            

  //--Set outline colour to black.
  stroke(0);
  //--Set fill colour to dark grey.
  fill(80);                     

  //--Set position to edge of Arduino box.
  translate(60, -10, 90);       
  //--Draw pin header as box.
  box(170, 20, 10);             

  //--Set position to other edge of Arduino box.
  translate(-20, 0, -180);      
  //--Draw other pin header as box.
  box(210, 20, 10);
}

//--Function to print navigation angles. 
void printYPR() {
  textAlign(LEFT, TOP);
  text("rotation angles", 10, 10);
  text("pitch: ", 10, 30);
  text(pitch, 60, 30);
  text(" ", 110, 30);
  text("yaw: ", 160, 30);
  text(yaw, 195, 30);
  text(" ", 260, 30);
  text("roll: ", 310, 30); 
  text(roll, 355, 30);
}


//--Function to print acc-gyro values. 
void printAG() {
  textAlign(LEFT, TOP);
  //--Accelerometer.
  text("accelerometer", 10, 70);
  text("ax: ", 10, 90);
  text(ax, 40, 90); 
  text("ay: ", 130, 90);
  text(ax, 160, 90);
  text("az: ", 250, 90);
  text(az, 280, 90);

  //--Gyroscope.
  text("gyroscope", 10, 130);
  text("gx: ", 10, 150);
  text(gx, 40, 150); 
  text("gy: ", 130, 150);
  text(gx, 160, 150);
  text("gz: ", 250, 150);
  text(gz, 280, 150);
}