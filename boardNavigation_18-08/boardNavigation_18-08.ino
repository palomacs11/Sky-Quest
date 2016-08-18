//--This program uses Madgwick's algorithm to filter raw data from the IMU.
#include "CurieIMU.h"
#include "MadgwickAHRS.h"
Madgwick filter;

//--Accelerometer and Gyroscope variables.
int ax, ay, az, gx, gy, gz;
float agXYZ[6];

//--Navigation angles;
//  yaw (dirección) = vertical-axis rotation.
//  pitch (elevación) = side-to-side rotation.
//  roll (alabeo) = front-to-back rotation.
float yaw, pitch, roll;

//--Sensitivity factor. We will divide the gyroscope values by this factor to
//  control sensitivity. For this program we can use a range factor of 5000-10000.
int sensFactor = 12000;

//--Zero Motion Detected variables.
int currentStatus = 1;
String statusString = "";
bool state = 0;
unsigned long loopTime = 0;
unsigned long interruptTime = 0;

const int calibration = 100;

//--Initialization.
void setup() {

  Serial.begin(12000);
  while (!Serial);
  CurieIMU.begin();

  //--Set interrupt.
  CurieIMU.attachInterrupt(interrupt);
  CurieIMU.setDetectionThreshold(CURIE_IMU_ZERO_MOTION, 1500);
  CurieIMU.setDetectionDuration(CURIE_IMU_ZERO_MOTION, 25);
  CurieIMU.interrupts(CURIE_IMU_ZERO_MOTION);

  //--Set accelerometer and gyroscope ranges.
  CurieIMU.setAccelerometerRange(2);
  CurieIMU.setGyroRange(250);

  //--Calibrate accelerometer and gyroscope offset values.
  //--The IMU should be resting in a horizontal position for the calibration
  //  procedure to work correctly.
  //--The target for z == 1 represents the vertical force of gravity (1G).
  //--Optional, print internal sensor offsets before and after calibration.
  CurieIMU.autoCalibrateGyroOffset();
  CurieIMU.autoCalibrateAccelerometerOffset(X_AXIS, 0);
  CurieIMU.autoCalibrateAccelerometerOffset(Y_AXIS, 0);
  CurieIMU.autoCalibrateAccelerometerOffset(Z_AXIS, 1);
}

//--Main program.
void loop() {

  loopTime = millis();
  if (abs(loopTime - interruptTime) < 1500) {
    currentStatus = 1;
    statusString = "Steady";
  } else {
    currentStatus = 0;
    statusString ="Not steady";
  }

  //--Read all gyro/acc values from the IMU.
  CurieIMU.readMotionSensor(ax, ay, az, gx, gy, gz);

  //--Convert.
  agXYZ[0] = (ax * 2.0) / 32678.0;
  agXYZ[1] = (ay * 2.0) / 32678.0;
  agXYZ[2] = (az * 2.0) / 32678.0;
  agXYZ[3] = (gx * 250.0) / 32678.0;
  agXYZ[4] = (gy * 250.0) / 32678.0;
  agXYZ[5] = (gz * 250.0) / 32678.0;

  //--Use Madgwick filters to return the quaternions.
  filter.updateIMU(gx / sensFactor, gy / sensFactor, gz / sensFactor, ax, ay, az);

  //--Get navigation angles.
  yaw = filter.getYaw();
  roll = filter.getRoll();
  pitch = filter.getPitch();

  // if (Serial.available() > 0) {
  // int val = Serial.read();
  //if (val == 'r') {
  printAll();
  //}
  // }
}

void printAll() {
 
  //--Print Angle Navigation values.
  Serial.print(yaw);
  Serial.print(", ");
  Serial.print(pitch);
  Serial.print(", ");
  Serial.print(roll);
  Serial.print(", ");

  //--Filtered accelerometer values.
  Serial.print(agXYZ[0]);
  Serial.print(", ");
  Serial.print(agXYZ[1]);
  Serial.print(", ");
  Serial.print(agXYZ[2]);
  Serial.print(", ");

  //--Filtered gyroscope values.
  Serial.print(agXYZ[3]);
  Serial.print(", ");
  Serial.print(agXYZ[4]);
  Serial.print(", ");
  Serial.print(agXYZ[5]);
  Serial.print(", ");

  //--Board Status.
  Serial.print(statusString);
  Serial.print(", ");
  Serial.println();
}

static void interrupt() {
  if (CurieIMU.getInterruptStatus(CURIE_IMU_ZERO_MOTION)) {
    interruptTime = millis();
  }
}

