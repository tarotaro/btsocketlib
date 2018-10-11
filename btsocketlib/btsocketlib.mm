//
//  btsocketlib.cpp
//  btsocketlib
//
//  Created by 中村太郎 on 2018/10/11.
//  Copyright © 2018年 中村太郎. All rights reserved.
//

#include "btsocketlib.h"
#include "btsocketlibImp.h"

NSString * _getBluetoothIDList(){
    return [[btsocketlibImp sharedInstance] getBluetoothIDList];
}
void _connectById(NSString * address){
    [[btsocketlibImp sharedInstance] connectById:address];
}
void _connectByListIndex(int index){
    [[btsocketlibImp sharedInstance] connectByListIndex:index];
}
void _send(Byte * data,int len){
    [[btsocketlibImp sharedInstance] send:data length:len];
}
Byte* _recv(int len){
    return [[btsocketlibImp sharedInstance] recv:len];
}

long _getReadTime(){
    return [[btsocketlibImp sharedInstance] getReadTime];
}
int _getConnectState(){
    return [[btsocketlibImp sharedInstance] getConnectState];
}
void _disConnect(){
    [[btsocketlibImp sharedInstance] disConnect];
}
