//
//  CList.h
//  PiribotPilotArduino
//
//  Created by Aykut Celik on 27/08/15.
//  Copyright (c) 2015 Aykut Celik. All rights reserved.
//


#include <stdio.h>
#include "Arduino.h"
template <class T>
class CList
{
public:
    CList()
    {
        size=0;
    }
    ~CList()
    {
        delete listBuffer;
    }
    void add(T data)
    {
        T *tempBuffer=new T[size+1];
        for (int i=0; i<size; i++) {
            tempBuffer[i]=listBuffer[i];
        }
        delete listBuffer;
        listBuffer=tempBuffer;
        listBuffer[size]=data;
        size++;
    }
    
    void remove(int index)
    {
        int removeIndex=0;
        T *tempBuffer=new T[size-1];
        for (int i=0; i<size; i++) {
            if(i!=index)
            {
                tempBuffer[removeIndex]=listBuffer[i];
                removeIndex++;
            }
        }
        delete listBuffer;
        listBuffer=tempBuffer;
        size--;
    }
    int find(T data)
    {
        for (int i=0;i<size;i++) {
            if(listBuffer[i]==data)
                return i;
        }
    }
    T get(int index)
    {
        return listBuffer[index];
    }
    int getSize()
    {
        return size;
    }
    void clear()
    {
        T *tempBuffer;
        delete listBuffer;
        listBuffer=tempBuffer;
        size=0;
    }
    T* getAll()
    {
        return listBuffer;
    }
    //replaces all elements in list
    void replace(T dataToReplace,T dataToBeReplaced)
    {
        for (int i=0;i<size;i++) {
            if(listBuffer[i]==dataToBeReplaced)
                listBuffer[i]=dataToReplace;
        }
    }
private:
    T *listBuffer;
    int index;
    int size;
};
