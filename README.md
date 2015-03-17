# FlightHue
The flight instrument has been used in an UAVGS project , which can be customized and free to use or modify.

you can use this hue easily by the following 3 steps:
step 1:
copy the "BLMInstrumentViewController.h" "BLMInstrumentViewController.m" and "InstrumentImg" to your project

step 2:
add the import in the controller, where you wan't to use the hue
  
  #import "BLMInstrumentViewController.h"

setp 3:
add the following code in the controller, where you wan't to use the hue

    BLMInstrumentViewController* hueController = [BLMInstrumentViewController shared];
    [hueController.instrumentView setCenter:self.view.center];
    [self.view addSubview:hueController.instrumentView];
    [hueController setHeight:4.5];
    [hueController setSpeed:3];
    [hueController setYawAngle:150];
    
the display effect in a UAVGS project:
![image](https://github.com/weconquered/FlightHue/blob/master/effect_0.PNG)
