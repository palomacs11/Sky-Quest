//--What are we working with?
//  Madgwick's algorithm to filter raw data from the IMU.
//  CurieIMU to get data from the built-in accelerometer and gyroscope.
//  DHT humidity-tempIMUerature sensor library, obviously, to get temperature and humidity.
#include "DHT.h"
#include "CurieIMU.h"
#include "MadgwickAHRS.h"

//--temperature sensor definition (pin and type) and initialization.
#define DHTPIN 2
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);

//--Accelerometer and Gyroscope variables (raw and filtered).
int   ax, ay, az, gx, gy, gz;
float agXYZ[6];

//--Navigation angles' filter.
Madgwick filter;

//--Navigation angles;
float yaw;   //--yaw (dirección)   - vertical-axis rotation.
float pitch; //--pitch (elevación) - side-to-side rotation.
float roll;  //--roll (alabeo)     - front-to-back rotation.

int sensFactor = 18000; //--Sensitivity factor. //**NEED TO KNOW HOW TO HANDLE THIS FACTOR**//

//--Temperature sensor variables.
float tempIMU;      //--Built-in Genuino's IMU.
float tempSens = 0; //--DHT11 sensor. 
float humidity;     //--DHT11 sensor. 
float heatIndex;    //--DHT11 sensor.

//--UV sensor variables.
int UV = A0;             //--Sensor output based on the reference. 
int ref = A1;            //--3.3 V. 
int refLevel = 0;        //-- 
int uvLevel = 0;         //--
float outputVoltage = 0; //-- 
float uvIntensity = 0;   //--Intensity. 

//--Initialization.
void setup() {

  Serial.begin(57600); //--Speed of data transmission. 
  while (!Serial);     //--  
  CurieIMU.begin();    //--Initialize CurieIMU. 
  dht.begin();         //--Initialize DHT. 

  //--Set accelerometer and gyroscope ranges.
  CurieIMU.setAccelerometerRange(2);
  CurieIMU.setGyroRange(250);

  //--Calibrate accelerometer and gyroscope offset values.
  //--The IMU should be resting horizontally for the calibration
  //  procedure to work correctly.
  //--The target for z == 1 represents the vertical force of gravity (1G).
  //--Optional:
  //          Print internal sensor offsets before and after calibration.
  //          Calibrate both gyro and acc manually.
  CurieIMU.autoCalibrateGyroOffset();
  CurieIMU.autoCalibrateAccelerometerOffset(X_AXIS, 0);
  CurieIMU.autoCalibrateAccelerometerOffset(Y_AXIS, 0);
  CurieIMU.autoCalibrateAccelerometerOffset(Z_AXIS, 1);

  //--Set UV sensor input variables. 
  pinMode(UV,  INPUT);
  pinMode(ref, INPUT);
}

//--Main program.
void loop() {

  //--Read temperature and convert raw value.
  tempIMU = CurieIMU.readTemperature();
  tempIMU = (tempIMU / 32768.0) + 23;
  tempSens = dht.readTemperature();
  humidity = dht.readHumidity();

  //--Compute heat index as celsius.
  heatIndex = dht.computeHeatIndex(tempSens, humidity, false);

  //--Check if any read failed to try sense temperature again.
  if (isnan(tempSens)) {
    Serial.println("Cannot read sensor");
    return;
  }

  //--Read UV sensor and use the reference to get an accurate output value. 
  uvLevel = averageRead(UV);
  refLevel = averageRead(ref);
  outputVoltage = 3.3 / refLevel * uvLevel; 
  uvIntensity = mapFloat(outputVoltage, 0.99, 2.8, 0.0, 15);
  
  //--Read all gyro/acc values from the IMU.
  CurieIMU.readMotionSensor(ax, ay, az, gx, gy, gz);

  //--Convert raw values into mg
  agXYZ[0] = (ax / 32768.0) * CurieIMU.getAccelerometerRange();
  agXYZ[1] = (ay / 32768.0) * CurieIMU.getAccelerometerRange();
  agXYZ[2] = (az / 32768.0) * CurieIMU.getAccelerometerRange();
  agXYZ[3] = (gx * 250.0) / 32678.0;
  agXYZ[4] = (gy * 250.0) / 32678.0;
  agXYZ[5] = (gz * 250.0) / 32678.0;

  //--Use Madgwick filters to return the quaternions.
  filter.updateIMU(gx / sensFactor, gy / sensFactor, gz / sensFactor, ax, ay, az);

  //--Get navigation angles.
  yaw =   filter.getYaw();
  roll =  filter.getRoll();
  pitch = filter.getPitch();

  if (Serial.available() > 0) {
    int val = Serial.read();
    if (val == 'r') {
      printAll();
    }
  }
}

void printAll() {
  //--Print Angle Navigation values.
  Serial.print(yaw);          //--Yaw.
  Serial.print(",");          
  Serial.print(pitch);        //--Pitch.
  Serial.print(",");
  Serial.print(roll);         //--Roll. 
  Serial.print(",");

  //--Filtered accelerometer values.
  Serial.print(agXYZ[0]);      //--AX.
  Serial.print(",");
  Serial.print(agXYZ[1]);      //--AY.
  Serial.print(",");
  Serial.print(agXYZ[2]);      //--AZ.
  Serial.print(",");

  //--Filtered gyroscope values.
  Serial.print(agXYZ[3]);      //--GX.
  Serial.print(",");
  Serial.print(agXYZ[4]);      //--GY.
  Serial.print(",");
  Serial.print(agXYZ[5]);      //--GZ.
  Serial.print(",");

  //--Temperature, humidity, heat index.
  Serial.print(tempIMU);       //--IMU temperature. 
  Serial.print(","); 
  Serial.print(tempSens);      //--DHT11 temperature. 
  Serial.print(",");
  Serial.print(humidity);      //--DHT11 humidity. 
  Serial.print(",");
  Serial.print(heatIndex);     //--DHT11 heat index. 
  Serial.print(",");

  //--UV sensor data. 
  Serial.print(refLevel);       //--Output.
  Serial.print(",");
  Serial.print(uvLevel);        //--M8511 output. 
  Serial.print(",");
  Serial.print(outputVoltage);  //--ML8511 voltage
  Serial.print(",");
  Serial.println(uvIntensity);    //--UV intensity mW/cm^2
}

//--This function gets an average of readings on a pin, 
int averageRead(int pin) {
  byte numberOfReadings = 8;
  unsigned int runningValue = 0; 
  for (int x = 0; x < numberOfReadings; x++) {
    runningValue += analogRead(pin);
  }
  runningValue /= numberOfReadings; 
  return(runningValue);
}

//--This function maps floats. 
float mapFloat(float x, float inMin, float inMax, float outMin, float outMax) {
  return (x - inMin) * (outMax - outMin) / (inMax - inMin) + outMin; 
}

