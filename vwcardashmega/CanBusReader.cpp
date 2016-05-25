//
// CanBusReader.cpp 
// Library C++ code
// ----------------------------------
// Developed with embedXcode+ 
// http://embedXcode.weebly.com
//
// Project 		vwCarDash
//
// Created by 	Aykut Celik, 18/05/16 18:20
// 				Aykut Celik
//
// Copyright 	(c) Aykut Celik, 2016
// Licence		<#license#>
//
// See 			CanBusReader.h and ReadMe.txt for references
//


// Library header
#include "CanBusReader.h"
const int SPI_CS_PIN = 9;
const int LED=8;
boolean ledON=1;
MCP_CAN CAN(SPI_CS_PIN);


CanBusReader::CanBusReader()
{
    pinMode(LED,OUTPUT);
    
    while (CAN_OK != CAN.begin(CAN_500KBPS))              // init can bus : baudrate = 500k
    {
        Serial.println("CAN BUS Shield init fail");
        Serial.println(" Init CAN BUS Shield again");
        delay(100);
    }
    Serial.println("CAN BUS Shield init ok!");
}
void CanBusReader::readAll()
{
    unsigned char len = 0;
    unsigned char buf[8];
    if(CAN_MSGAVAIL == CAN.checkReceive())            // check if data coming
    {
        CAN.readMsgBuf(&len, buf);    // read data,  len: data length, buf: data buf
        
        unsigned char canId = CAN.getCanId();
        if(canId==0x1b)//(true)
        {
            Serial.print(canId);
            Serial.print(" ");
            for(int i = 0; i<len; i++)    // print the data
            {
                Serial.print(buf[i]);
                Serial.print("\t");
            }
            Serial.println();
        }
    }

}
void CanBusReader::listen()
{
    buttonState=Nothing;
    unsigned char len = 0;
    unsigned char buf[8];
    if(CAN_MSGAVAIL == CAN.checkReceive())            // check if data coming
    {
        CAN.readMsgBuf(&len, buf);    // read data,  len: data length, buf: data buf
        
        unsigned char canId = CAN.getCanId();
        //Serial.println(canId);
        if(canId==0xbf)
        {
            
            switch (buf[0]) {
                case 16:
                    buttonState=VolUp;
                    break;
                case 17:
                    buttonState=VolDown;
                    break;
                case 22:
                    buttonState=Back;
                    break;
                case 21:
                    buttonState=Forward;
                    break;
                case 32:
                    buttonState=Mute;
                    break;
                case 25:
                    buttonState=Voice;
                    break;
                case 28:
                    buttonState=Phone;
                    break;
                case 7:
                    buttonState=OK;
                    break;
                case 4:
                    buttonState=Up;
                case 5:
                    buttonState=Down;
                    break;
                    break;
                default:
                    buttonState=Nothing;
                    break;
            }
        }
        else if(canId==0x1b)
        {
            if(buf[4]==0)
            {
                buttonState=IgnitionOn;
            }
            else if(buf[4]==1)
            {
                buttonState=IgnitionOff;
            }
        }
    }
}
ButtonState CanBusReader::getCurrentButtonState()
{
    return buttonState;
}

// Code
