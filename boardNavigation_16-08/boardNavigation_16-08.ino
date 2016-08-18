//--This program uses Madgwick's algorithm to filter raw data from the IMU.
#include "CurieIMU.h"
#include "MadgwickAHRS.h"
Madgwick filter;

//--Accelerometer and Gyroscope variables.
int ax, ay, az, gx, gy, gz;
float AX, AY, AZ, GX, GY, GZ;

//--Navigation angles;
//  yaw (dirección) = vertical-axis rotation.
//  pitch (elevación) = side-to-side rotation.
//  roll (alabeo) = front-to-back rotation.
float yaw, pitch, roll;
int Y1, p1, r1, y2, p2, r2;

//--Sensitivity factor. We will divide the gyroscope values by this factor to
//  control sensitivity. For this program we can use a range factor of 5000-10000.
int sensFactor = 8000;

//--Zero Motion Detected variables.
String currentStatus = "";
String oldStatus = "";

//--Initialization.
void setup() {

  Serial.begin(9600);
  while (!Serial);
  CurieIMU.begin();

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

  //--Read all gyro/acc values from the IMU.
  CurieIMU.readMotionSensor(ax, ay, az, gx, gy, gz);

  //--Convert.
  AX = (ax * 2.0) / 32678.0;
  AY = (ay * 2.0) / 32678.0;
  AZ = (az * 2.0) / 32678.0;
  GX = (gx * 250.0) / 32678.0;
  GY = (gy * 250.0) / 32678.0;
  GZ = (gz * 250.0) / 32678.0;

  //--Use Madgwick filters to return the quaternions.
  filter.updateIMU(gx / sensFactor, gy / sensFactor, gz / sensFactor, ax, ay, az);

  //--Old values.
  Y1 = yaw * 100;
  p1 = pitch * 100;
  r1 = roll * 100;

  //--Get navigation angles.
  yaw = filter.getYaw();
  roll = filter.getRoll();
  pitch = filter.getPitch();

  //--New values.
  y2 = yaw * 100;
  p2 = pitch * 100;
  r2 = roll * 100;


  if (( Y1 == y2) && ( p1 == p2) && (r1 == r2)) {
    currentStatus = "No motion detected...";
  } else {
    currentStatus = "Motion detected..";
  }

  //if (Serial.available() > 0) {
  /*
    int val = Serial.read();
    if (val == 'r') {
    printAll();
    }
  */

  if (currentStatus != oldStatus) {
    Serial.println(currentStatus);
  }
  // }
  oldStatus = currentStatus;
}


void printAll() {
  //--Print Angle Navigation values.
  Serial.print(yaw);
  Serial.print(",");
  Serial.print(pitch);
  Serial.print(",");
  Serial.print(roll);
  Serial.print(",");

  //--Filtered accelerometer values.
  Serial.print(AX);
  Serial.print(",");
  Serial.print(AY);
  Serial.print(",");
  Serial.print(AZ);
  Serial.print(",");

  //--Filtered gyroscope values.
  Serial.print(GX);
  Serial.print(",");
  Serial.print(GY);
  Serial.print(",");
  Serial.print(GZ);
  Serial.print(",");

  Serial.print(currentStatus);
  Serial.print(",");
  Serial.println();
}


