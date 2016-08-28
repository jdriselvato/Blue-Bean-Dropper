# Blue-Bean-Dropper

This iOS application is a proof of concept to better my understanding of BLE communication with CoreBluetooth.

This app communicates with Lightblue Bean so that when the Bean is dropped the app uploads the drop count value to a personal Freeboard (https://freeboard.io/board/1jPodr). In addition, the app will sync the drop count when the app is in the background. 

Still working on seeing if it's possible to sync the drop count when the app is completely closed (user closes it in the processing tray).

# LightBlue Bean Code
````
/* 
  This sketch shows you how to monitor if your Bean is in free fall. 
  
  The Bean will track how many times it's been dropped print it in Arduino's Serial Monitor.
  
  To use the Serial Monitor, set Arduino's serial port to "/tmp/tty.LightBlue-Bean"
  and the Bean as "Virtual Serial" in the OS X Bean Loader.
      
  This example code is in the public domain.
*/

// When acceleration is below this threshold, we consider it free fall.
#define THRESHOLD 65    

int fallDuration = 0;
int fallCount = 0;
int hasDropped = 0;

void setup() {
  // Bean Serial is at a fixed baud rate. Changing the value in Serial.begin() has no effect.
  Serial.begin(); 
}

void loop() {
  // Take 60 readings in three seconds and check for free fall
  for(int i = 0; i < 60; i++){
    // Get the current acceleration with a conversion of 3.91×10-3 g/unit.
    AccelerationReading currentAccel = Bean.getAcceleration();   
    uint32_t magnitude = abs(currentAccel.xAxis) + abs(currentAccel.yAxis) + abs(currentAccel.zAxis);
    
    // Is the Bean in free fall?                                            
    if(magnitude < THRESHOLD){
      fallDuration++; 
      // Check if the Bean has been in free fall for at least 150ms.
      if(fallDuration == 3){
        fallCount++;
        hasDropped = 1;
      } 
    }else{
      fallDuration = 0;
    }
    // Sleep for a bit before checking for free falling again
    Bean.sleep(50);
  }
  
  // Print the drop count
  if (hasDropped == 1) {
    Serial.print("I've been dropped ");
    Serial.print(fallCount);
    Serial.println(" time(s)!");
    Bean.setScratchNumber(1, fallCount);
    hasDropped = 0;
  }
}
````
