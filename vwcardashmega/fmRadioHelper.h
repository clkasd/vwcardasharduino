///
/// @file		fmRadioHelper.h
/// @brief		Library header
/// @details	<#details#>
/// @n	
/// @n @b		Project vwCarDash
/// @n @a		Developed with [embedXcode+](http://embedXcode.weebly.com)
/// 
/// @author		Aykut Celik
/// @author		Aykut Celik
///
/// @date		06/05/16 16:21
/// @version	<#version#>
/// 
/// @copyright	(c) Aykut Celik, 2016
/// @copyright	<#license#>
///
/// @see		ReadMe.txt for references
///


// Core library for code-sense - IDE-based
#if defined(WIRING) // Wiring specific
#   include "Wiring.h"
#elif defined(MAPLE_IDE) // Maple specific
#   include "WProgram.h"
#elif defined(ROBOTIS) // Robotis specific
#   include "libpandora_types.h"
#   include "pandora.h"
#elif defined(MPIDE) // chipKIT specific
#   include "WProgram.h"
#elif defined(DIGISPARK) // Digispark specific
#   include "Arduino.h"
#elif defined(ENERGIA) // LaunchPad specific
#   include "Energia.h"
#elif defined(LITTLEROBOTFRIENDS) // LittleRobotFriends specific
#   include "LRF.h"
#elif defined(MICRODUINO) // Microduino specific
#   include "Arduino.h"
#elif defined(TEENSYDUINO) // Teensy specific
#   include "Arduino.h"
#elif defined(REDBEARLAB) // RedBearLab specific
#   include "Arduino.h"
#elif defined(RFDUINO) // RFduino specific
#   include "Arduino.h"
#elif defined(SPARK) // Spark specific
#   include "application.h"
#elif defined(ARDUINO) // Arduino 1.0 and 1.5 specific
#   include "Arduino.h"
#else // error
#   error Platform not defined
#endif // end IDE

#ifndef fmRadioHelper_cpp
#define fmRadioHelper_cpp
#include "TEA5767.h"

class fmRadioHelper
{
public:
    fmRadioHelper();
    void seekUp();
    void seekDown();
    void setFrequency(char* frq);
    int getSignalLevel();
    double getCurrentFreq();
    boolean getIsStereo();
    void setCurrentFreq(double freq);
private:
    int signalLevel;
    double currentFreq;
    boolean isStereo;
    void updateStatus();
    unsigned char buf[5];
    TEA5767 radio;
};

#endif
