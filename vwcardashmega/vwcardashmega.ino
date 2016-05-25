//
// vwcardashmega
//
// Description of the project
// Developed with [embedXcode](http://embedXcode.weebly.com)
//
// Author 		Aykut Celik
// 				Aykut Celik
//
// Date			20/05/16 14:36
// Version		<#version#>
//
// Copyright	© Aykut Celik, 2016
// Licence		<#licence#>
//
// See

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
#elif defined(SPARK) || defined(PARTICLE) // Particle / Spark specific
#   include "Arduino.h"
#elif defined(TEENSYDUINO) // Teensy specific
#   include "Arduino.h"
#elif defined(REDBEARLAB) // RedBearLab specific
#   include "Arduino.h"
#elif defined(ESP8266) // ESP8266 specific
#   include "Arduino.h"
#elif defined(ARDUINO) // Arduino 1.0 and 1.5 specific
#   include "Arduino.h"
#else // error
#   error Platform not defined
#endif // end IDE


// Define variables and constants
#include "CSerialCom.h"
#include "GlobalFuncDefs.h"
#include "fmRadioHelper.h"
#include "CanBusReader.h"
// Add setup code
CanBusReader *canReader;
CSerialCom cserialCom;
fmRadioHelper *fmradio;
void setup()
{
    pinMode(46,OUTPUT);
    digitalWrite(46,LOW);
    Serial.begin(9600);
    fmradio=new fmRadioHelper();
    delay(1000);
    canReader=new CanBusReader();
    cserialCom.setCommand(seekUp, "seekup");
    cserialCom.setCommand(seekDown, "seekdn");
    cserialCom.setCommand(setFrequency, "setfr");
    cserialCom.setCommand(turnoff, "turnoff");
    cserialCom.setCommand(turnon, "turnon");
}

// Add loop code
boolean isIgnitionOnSent=false;
boolean isIgnitionOffSent=false;
void loop()
{
    cserialCom.listen();
    //canReader->readAll();
    canReader->listen();
    switch (canReader->getCurrentButtonState()) {
        case VolDown:
            cserialCom.send("voldwn");
            Serial.println("voldwn");
            break;
        case VolUp:
            cserialCom.send("volup");
            break;
        case Back:
            cserialCom.send("back");
            break;
        case Forward:
            cserialCom.send("forwrd");
            break;
        case Mute:
            cserialCom.send("mute");
            break;
        case Voice:
            cserialCom.send("voice");
            break;
        case Phone:
            cserialCom.send("phone");
            break;
        case OK:
            cserialCom.send("ok");
            break;
        case Up:
            cserialCom.send("up");
            break;
        case Down:
            cserialCom.send("down");
            break;
        case IgnitionOn:
            if(!isIgnitionOnSent)
            {
                turnoff("to");
                cserialCom.send("start");
                isIgnitionOnSent=true;
                isIgnitionOffSent=false;
            }
            break;
        case IgnitionOff:
            if(!isIgnitionOffSent)
            {
                turnon("to");
                cserialCom.send("shutdwn");
                isIgnitionOnSent=false;
                isIgnitionOffSent=true;
            }
            break;
        case Nothing:
            //Serial.println("nothing");
            break;
        default:
            break;
    }
    
}
void seekUp(char*)
{
    fmradio->seekUp();
    Serial.println("seeking up");
    sendCurrentFreq();
}
void seekDown(char*)
{
    fmradio->seekDown();
    Serial.println("seeking down");
    sendCurrentFreq();
}
void turnoff(char*)
{
    digitalWrite(46,HIGH);
}
void turnon(char*)
{
    digitalWrite(46,LOW);
}
void setFrequency(char* freq)
{
    Serial.println("frequency set");
    Serial.println(freq);
    fmradio->setFrequency(freq);
    sendCurrentFreq(freq);
}
void sendCurrentFreq()
{
    String freq =  String(fmradio->getCurrentFreq(), 1);
    cserialCom.send("freq;"+freq);
}
void sendCurrentFreq(String freq)
{
    cserialCom.send("freq;"+freq);
}





