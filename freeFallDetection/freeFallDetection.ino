//--This program detects free fall. 

//--Led state. 
bool ledState = false; 

//--Time since the loop started.  
unsigned long programTime = 0; 

//--Free fall detected (ffd) time. 
unsigned long ffdTime = 0;  

//--Initialization. 
void setup () {
  Serial.begin(9600); 
  
  //--Wait for the serial port to open. 
  while(!Serial); 
  
  //--Initialize the IMU.
  CurieIMU.begin(); 

  //--Attach an interrupt function. 
  CurieIMU.attachInterrupt(callBack);

  //--Enable free fall detection. 
  
  //--Set a treshold: CURIE_IMU_FREEFALL --> 3.91 to 1995.46 mg
  CurieIMU.setDetectionThreshold(CURIE_IMU_FREEFALL, 1000);

  //--Set Detection time: CURIE_IMU_FREEFALL --> 2.5 to 637.5 ms
  CurieIMU.setDetectionDuration(CURIE_IMU_FREEFALL, 50); 

  //--Set an interrupt. 
  CurieIMU.interrupts(CURIE_IMU_FREEFALL);

  //--Initialization complete. 
}

//--Main program. 
void loop() {
 
  //--We should indicate if freefall is detected within 1000ms by turning the LED on. 
  programTime = millis(); 
  
  if (abs(programTime - ffdTime) < 1000) { ledState = true; }
  else { ledState = false; }
  
  digitalWrite(13, ledState); 
}

static void callBack () {
  if (CurieIMU.getInterruptStatus(CURIE_IMU_FREEFALL)) {
    Serial.println("Free Fall!!!!!!"); 
    ffdTime = millis(); 
  }
}

