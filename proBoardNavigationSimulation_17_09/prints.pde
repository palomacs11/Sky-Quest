//**FIX THIS PART ALSO AND ADD MEASUREMENT UNITS**//
//--Function to print navigation angles. 
void printNavigationMonitor() {
  pushMatrix();
  textSize(16);
  translate(800, 50);
  textAlign(CENTER, CENTER);
  fill(yellow);
  text("motion", nmX, nmY - 10); 

  //--Accelerometer.
  text("accelerometer", nmX, nmY + 35);
  text("ax: ", nmX, nmY + 80);
  text(ax, nmX - 10, nmY + 125); 
  text("ay: ", nmX, nmY + 170);
  text(ax, nmX - 10, nmY + 215);
  text("az: ", nmX, nmY + 260);
  text(az, nmX - 10, nmY + 305);

  //--Gyroscope.
  text("gyroscope", nmX, nmY + 360);
  text("gx: ", nmX, nmY + 405);
  text(gx, nmX - 10, nmY + 450); 
  text("gy: ", nmX, nmY + 495);
  text(gx, nmX - 10, nmY + 540);
  text("gz: ", nmX, nmY + 585);
  text(gz, nmX - 10, nmY + 630);
  popMatrix();

  pushMatrix(); 
  translate(25, 50);
  //--3D motion simulator. 
  text("3D motion simulator", 370, 15);
  text("rotation angles", sX, sY);
  text("pitch: ", sX, sY + 45);
  text(pitch, sX + 60, sY + 45);
  text("yaw: ", sX, sY + 90);
  text(yaw, sX + 60, sY + 90);
  text("roll: ", sX, sY + 135); 
  text(roll, sX +60, sY + 135);
  popMatrix();
}

//****NEED TO PROVIDE AN EXPLANATION OF WHAT I'M DOING HERE**//
//--This function prints a weather monitor. 
void printWeatherMonitor() {
  pushMatrix();       //--Start object. 
  translate(950, 50);
  textAlign(CENTER, CENTER);
  textSize(16);
  fill(yellow);
  text("weather monitor", 265, 15);

  //-- IMU Temperature.
  text("IMU temperature: ", wmX, wmY);
  text(tempIMU, wmX + 200, wmY); 
  text(   "°C", wmX + 270, wmY);

  //--DHT11 Temperature. 
  text("DHT11 temperature: ", wmX + 10, wmY + 130);
  text(tempSens, wmX + 200, wmY + 130); 
  text("°C", wmX + 270, wmY + 130);

  //--DHT11 Humidity. 
  text(" humidity:", wmX - 30, wmY + 200);
  text(humidity, wmX - 40, wmY + 220);
  image(imgHum, wmX + 40, wmY + 185, imgHum.width/10, imgHum.height/10);

  //--DHT11 Heat index. 
  text("  heat index: ", wmX - 30, wmY + 280);
  text(heatIndex, wmX - 40, wmY + 300);
  text("°C", wmX + 10, wmY + 300);
  image(imgTem, wmX + 40, wmY + 290, imgTem.width/5, imgTem.height/5);

  //--UV Sensor. 
  text("UV reference level", wmX, wmY + 360); 
  text(refLevel, wmX - 10, wmY + 380);
  text("ML8511 UV level:", wmX - 10, wmY + 440);
  text(uvLevel, wmX - 10, wmY + 460);
  text("ML8511 output:", wmX - 20, wmY + 520);
  text(outputVoltage, wmX - 10, wmY + 540);
  text(" V", wmX + 30, wmY + 540);
  text("UV Intensity:", wmX - 25, wmY + 600);
  text(uvIntensity, wmX - 10, wmY + 620);
  text(" mW/cm^2", wmX + 60, wmY + 620);

  popMatrix();     //--End of the object.
}

void printTemperaturePanel(int x, int y, int w, int h, color color1, color color2) {
  pushMatrix();
  translate(950, 100); 

  //--Map values read from temperature sensor and map it to print temperature pointer.
  float posTriangle1 = map( tempIMU, -44, 85, x, x + w); 
  float posTriangle2 = map(tempSens, 0, 50, x, x + w);

  //--Draw triangle pointers (temperature indicators)
  fill(orange);
  stroke(yellow);
  triangle(posTriangle1 - 10, y - 25, posTriangle1, y - 5, posTriangle1 + 10, y - 25);
  fill(orange);
  stroke(yellow);
  triangle(posTriangle2 - 10, y + 85, posTriangle2, y + 65, posTriangle2 + 10, y + 85);

  //--Interpolate colors blue and red to create the panel. 
  for (int i = x; i <= x + w; i++) {
    float inter = map(i, x, x + w, 0, 1); 
    color colorInter = lerpColor(blue, red, inter);
    stroke(colorInter);
    line(i, y, i, y + h);
  }

  //--Print text. 
  fill(orange);
  textSize(16);
  text("-44°C", x - 50, y + 15);
  text("  0°C", x - 50, y + 55);
  text("85°C", x + w + 5, y + 15);
  text("50°C", x + w + 5, y + 55);

  popMatrix();
}