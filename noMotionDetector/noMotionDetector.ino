//--This program detects when the board is not moving. 

#include "CurieIMU.h"

unsigned long zmdTime = 0;  //--Time when zero motion is detected. 

//--Main program. 
void setup() {
  Serial.begin(9600);
  while (!Serial);
  CurieIMU.begin();
  CurieIMU.attachInterrupt(callBack); 
  CurieIMU.setDetectionThreshold(CURIE_IMU_ZERO_MOTION, 1500); 
  CurieIMU.setDetectionDuration(CURIE_IMU_ZERO_MOTION, 25);
  CurieIMU.interrupts(CURIE_IMU_ZERO_MOTION);
}

//--Main program. 
void loop() {
  
}

//--Callback function. 
static void callBack(void) {
  if (CurieIMU.getInterruptStatus(CURIE_IMU_ZERO_MOTION)) {
    Serial.println("No motion detected...");
  } 
}

