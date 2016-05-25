//
// File			GlobalFuncDefs.h
// Header
//
// Details		<#details#>
//
// Project		 vwCarDash
// Developed with [embedXcode](http://embedXcode.weebly.com)
//
// Author		Aykut Celik
// 				Aykut Celik
//
// Date			06/05/16 15:48
// Version		<#version#>
//
// Copyright	© Aykut Celik, 2016
// Licence    <#license#>
//
// See			ReadMe.txt for references
//


// Core library for code-sense - IDE-based
#if defined(WIRING) // Wiring specific
#   include "Wiring.h"
#elif defined(MAPLE_IDE) // Maple specific
#   include "WProgram.h"
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
#elif defined(SPARK) // Spark specific
#   include "application.h"
#elif defined(ARDUINO) // Arduino 1.0 and 1.5 specific
#   include "Arduino.h"
#else // error
#   error Platform not defined
#endif // end IDE


#ifndef GlobalFuncDefs_
#define GlobalFuncDefs_

void setFreq(int freq);
void seekUp(char*);
void seekDown(char*);
void setFrequency(char* freq);
void sendCurrentFreq();
enum ButtonState{VolUp,VolDown,Back,Forward,Mute,Voice,Phone,OK,Up,Down,IgnitionOn,IgnitionOff,Nothing};
void turnoff(char*);
void turnon(char*);
void sendCurrentFreq(String freq);
#endif
