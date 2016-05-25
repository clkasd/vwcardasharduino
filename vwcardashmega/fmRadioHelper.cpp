//
// fmRadioHelper.cpp
// Library C++ code
// ----------------------------------
// Developed with embedXcode+
// http://embedXcode.weebly.com
//
// Project 		vwCarDash
//
// Created by 	Aykut Celik, 06/05/16 16:21
// 				Aykut Celik
//
// Copyright 	(c) Aykut Celik, 2016
// Licence		<#license#>
//
// See 			fmRadioHelper.h and ReadMe.txt for references
//


// Library header
#include "fmRadioHelper.h"
#include "Wire.h"
#define DEBUG 1
fmRadioHelper::fmRadioHelper()
{
    Wire.begin();
    radio.init();
    radio.set_frequency(105.4);
    Serial.println("radio init");
    updateStatus();
}
double fmRadioHelper::getCurrentFreq()
{
    return currentFreq;
}
void fmRadioHelper::setCurrentFreq(double freq)
{
    currentFreq;
}
int fmRadioHelper::getSignalLevel()
{
    return signalLevel;
}
void fmRadioHelper::seekUp()
{
    boolean stationFound=false;
    radio.search_up(buf);
    delay(300);
    radio.read_status(buf);
    while(!stationFound)
    {
        if (radio.process_search (buf, TEA5767_SEARCH_DIR_UP) == 1) {
            stationFound = true;
        }
        updateStatus();
    }
}
void fmRadioHelper::setFrequency(char *frq)
{
    radio.set_frequency(atof(frq));
}
void fmRadioHelper::seekDown()
{
    
    boolean stationFound=false;
    radio.search_down(buf);
    delay(300);
    radio.read_status(buf);
    while(!stationFound)
    {
        if (radio.process_search (buf, TEA5767_SEARCH_DIR_DOWN) == 1) {
            stationFound = true;
        }
        updateStatus();
    }
}
boolean fmRadioHelper::getIsStereo()
{
    return isStereo;
}
void fmRadioHelper::updateStatus()
{
    if(radio.read_status(buf)==1)
    {
        currentFreq =  floor (radio.frequency_available (buf) / 100000 + .5) / 10;
        isStereo = radio.stereo(buf);
        signalLevel = radio.signal_level(buf);
        if(DEBUG)
        {
            Serial.print("Freq : ");
            Serial.print(currentFreq);
            Serial.print(" - isStereo :");
            Serial.print(isStereo);
            Serial.print(" - signalLevel :");
            Serial.print(signalLevel);
            Serial.println();
        }
    }
}
// Code
