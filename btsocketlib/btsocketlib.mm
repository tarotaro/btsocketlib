//
//  btsocketlib.cpp
//  btsocketlib
//
//  Created by 中村太郎 on 2018/10/11.
//  Copyright © 2018年 中村太郎. All rights reserved.
//

#include "btsocketlib.h"
#include "btsocketlibImp.h"


void startServer(){
    [[btsocketlibImp sharedInstance] startServer];
}

void searchDevice(){
    [[btsocketlibImp sharedInstance] searchDevice];
}

char * getUuidForName(){
    NSString *str = [[btsocketlibImp sharedInstance] getUuidForName];
    const char *p = [str UTF8String];
    char* res = (char*)malloc(strlen(p)+1);
    strcpy(res,p);
    return res;
}

char * getBluetoothList(){
    NSString *str =[[btsocketlibImp sharedInstance] getBluetoothList];
    const char *p = [str UTF8String];
    char* res = (char*)malloc(strlen(p) + 1);
    strcpy(res, p);
    return res;
}
void connectByUuid(const char * uuid){
    NSString *_uuid = [NSString stringWithUTF8String:uuid];
    [[btsocketlibImp sharedInstance] connectByUuid:_uuid];
}
void connectByListIndex(int index){
    [[btsocketlibImp sharedInstance] connectByListIndex:index];
}
void send(Byte * data,int len){
    [[btsocketlibImp sharedInstance] send:data length:len];
}
BOOL recv(Byte * data,int len){
    return [[btsocketlibImp sharedInstance] recv:data length:len];
}

long getReadTime(){
    return [[btsocketlibImp sharedInstance] getReadTime];
}

long getWriteTime(){
    return [[btsocketlibImp sharedInstance] getWriteTime];
}
int getConnectState(){
    return [[btsocketlibImp sharedInstance] getConnectState];
}
void disConnect(){
    [[btsocketlibImp sharedInstance] disConnect];
}
