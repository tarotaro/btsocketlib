//
//  btsocketlib.cpp
//  btsocketlib
//
//  Created by 中村太郎 on 2018/10/11.
//  Copyright © 2018年 中村太郎. All rights reserved.
//

#include "btsocketlib.h"
#include "btsocketlibImp.h"


void _startServer(){
    [[btsocketlibImp sharedInstance] startServer];
}

void _searchDevice(){
    [[btsocketlibImp sharedInstance] searchDevice];
}

char * _getBluetoothIDList(){
    NSString *str =[[btsocketlibImp sharedInstance] getBluetoothIDList];
    const char *p = [str UTF8String];
    char* res = (char*)malloc(strlen(p) + 1);
    strcpy(res, p);
    return res;
}
void _connectById(const char * address){
    NSString *addr = [NSString stringWithUTF8String:address];
    [[btsocketlibImp sharedInstance] connectById:addr];
}
void _connectByListIndex(int index){
    [[btsocketlibImp sharedInstance] connectByListIndex:index];
}
void _send(Byte * data,int len){
    [[btsocketlibImp sharedInstance] send:data length:len];
}
BOOL _recv(Byte * data,int len){
    return [[btsocketlibImp sharedInstance] recv:data length:len];
}

long _getReadTime(){
    return [[btsocketlibImp sharedInstance] getReadTime];
}

long _getWriteTime(){
    return [[btsocketlibImp sharedInstance] getWriteTime];
}
int _getConnectState(){
    return [[btsocketlibImp sharedInstance] getConnectState];
}
void _disConnect(){
    [[btsocketlibImp sharedInstance] disConnect];
}
