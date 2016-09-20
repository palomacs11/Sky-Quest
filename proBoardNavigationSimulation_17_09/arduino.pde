//--Function reads form port. 
void ardSerial() {
  message = ardPort.readStringUntil(newLine); //--Receive arduino incomming message as a string. 
  if (message != null) {
    ardMsg   = split(message, ",");           //--Split message whenever you see a comma. **SEE ARDUINO CODE**

    //--Navigation Angle variables.
    yaw   = float(ardMsg[0]);
    pitch = float(ardMsg[1]);      
    roll  = float(ardMsg[2]);

    //--Accelerometer values. 
    ax = float(ardMsg[3]);
    ay = float(ardMsg[4]);
    az = float(ardMsg[5]);

    //--Gyroscope values. 
    gx = float(ardMsg[6]);
    gy = float(ardMsg[7]);
    gz = float(ardMsg[8]);

    //--Temperature, humidity and heat index values. 
    tempIMU   = float(ardMsg[9]);
    tempSens  = float(ardMsg[10]);
    humidity  = float(ardMsg[11]);
    heatIndex = float(ardMsg[12]);

    //--UV sensor values. 
    refLevel = int(ardMsg[13]);
    uvLevel  = int(ardMsg[14]);
    outputVoltage = float(ardMsg[15]);
    uvIntensity = float(ardMsg[16]);
  }
}

void arduino() {
  //--Printing the arduino board simulator. 
  //****NOTES: the push matrix function saves the current coordinate system to the stack, this is very useful to handle translations
  //           and you don't have to do a lot of calculations to guess where you should place a specific shape. Then, the pop matrix 
  //          function restores the coordinate system. 
  pushMatrix();  //--Start object. 
  translate(300, 250); 

  //--Rotate the arduino board given the angle received from the arduino. 
  rotateX(pitch); 
  rotateY(-yaw);                 
  rotateZ(-roll);                

  //--Configuration needed to draw the arduino.  
  stroke(0, 90, 90);        //--Set outline colour to darker teal
  fill(0, 130, 130);        //--Set fill colour to lighter teal.
  box(300, 10, 200);        //--Draw Arduino board base shape.   
  stroke(0);                //--Set outline colour to black.
  fill(80);                 //--Set fill colour to dark grey.      
  translate(60, -10, 90);   //--Set position to edge of Arduino box.
  box(170, 20, 10);         //--Draw pin header as box.    
  translate(-20, 0, -180);  //--Set position to other edge of Arduino box.
  box(210, 20, 10);         //--Draw other pin header as box.
  popMatrix();              //--End of the object.
}