//--This code is for shock detection.
#include "CurieIMU.h"

bool ledState = false;

//--Initialization.
void setup() {
  Serial.begin(9600);
  CurieIMU.attachInterrupt(callBack);
  //--Set a 1.5g threshold.
  CurieIMU.setDetectionThreshold(CURIE_IMU_SHOCK, 1500);
  //--Set a detection duration of 50ms.
  CurieIMU.setDetectionDuration(CURIE_IMU_SHOCK, 50);
  CurieIMU.interrupts(CURIE_IMU_SHOCK);
}

//--Main program.
void loop() {
  //--This is to indicate there's activity going on.
  digitalWrite(13, ledState);
  ledState = !ledState;
  delay(1000);
}

//--Callback funciton.
static void callBack(void) {
  if (CurieIMU.getInterruptStatus(CURIE_IMU_SHOCK)) {
    if (CurieIMU.shockDetected(X_AXIS, POSITIVE))
      Serial.println("Negative shock detected on X-axis");
    if (CurieIMU.shockDetected(X_AXIS, NEGATIVE))
      Serial.println("Positive shock detected on X-axis");
    if (CurieIMU.shockDetected(Y_AXIS, POSITIVE))
      Serial.println("Negative shock detected on Y-axis");
    if (CurieIMU.shockDetected(Y_AXIS, NEGATIVE))
      Serial.println("Positive shock detected on Y-axis");
    if (CurieIMU.shockDetected(Z_AXIS, POSITIVE))
      Serial.println("Negative shock detected on Z-axis");
    if (CurieIMU.shockDetected(Z_AXIS, NEGATIVE))
      Serial.println("Positive shock detected on Z-axis");
  }
}

