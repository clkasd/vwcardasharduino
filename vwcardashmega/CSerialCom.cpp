//
//  CSerialCom.cpp
//  PiribotPilotArduino
//
//  Created by Aykut Celik on 28/08/15.
//  Copyright (c) 2015 Aykut Celik. All rights reserved.
//

#include "CSerialCom.h"

CSerialCom::CSerialCom()
{
    Serial3.begin(9600);
}
CSerialCom::~CSerialCom()
{
    commandList.clear();
}
String incomingData;

void CSerialCom::listen()
{
    incomingData="";
    while(Serial3.available())
    {
        incomingData=Serial3.readString();
    }
    parseData(incomingData);
}
void CSerialCom::parseData(String data)
{
    if(data!="" || data!=NULL)
    {
        char dataCharArray[data.length()+1];
        data.toCharArray(dataCharArray, data.length()+1);
        if(strstr(dataCharArray, ";")!=NULL)
        {
            Serial.println("; found");
            char* command=strtok(dataCharArray, ";");
            char* parameter=strtok(NULL, ";");//unnecessary
            Serial.println(command);
            Serial.println(parameter);
            for (int i=0; i<commandList.getSize(); i++) {
                if(commandList.get(i).command==command)
                {
                    Serial.print("Matched command : ");
                    Serial.println(command);
                    commandList.get(i).function(parameter);
                }
            }
        }
        else
        {
            Serial.println(data);
            for (int i=0; i<commandList.getSize(); i++) {
                if(commandList.get(i).command==data)
                {
                    Serial.print("Matched command : ");
                    Serial.println(data);
                    commandList.get(i).function("");
                }
            }
        }
    }
}
void CSerialCom::send(String str)
{
    Serial3.println(str);
}
void CSerialCom::setCommand(void (*function)(char*),String id)
{
    
    CommandStruct comStrct;
    comStrct.function=function;
    comStrct.command=id;
    commandList.add(comStrct);
    Serial.println("Added command");
}









