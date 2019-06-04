//
//  btsocketlib.cpp
//  btsocketlib
//
//  Created by 中村太郎 on 2018/10/11.
//  Copyright © 2018年 中村太郎. All rights reserved.
//

#include "btsocketlib.h"
#include "btsocketlibImp.h"


void Bt_startServer(){
    [[btsocketlibImp sharedInstance] startServer];
}

void Bt_searchDevice(){
    [[btsocketlibImp sharedInstance] searchDevice];
}

char * Bt_getUuidForName(){
    NSString *str = [[btsocketlibImp sharedInstance] getUuidForName];
    const char *p = [str UTF8String];
    char* res = (char*)malloc(strlen(p)+1);
    strcpy(res,p);
    return res;
}

char * Bt_getBluetoothList(){
    NSString *str =[[btsocketlibImp sharedInstance] getBluetoothList];
    const char *p = [str UTF8String];
    char* res = (char*)malloc(strlen(p) + 1);
    strcpy(res, p);
    return res;
}
void Bt_connectByUuid(const char * uuid){
    NSString *_uuid = [NSString stringWithUTF8String:uuid];
    [[btsocketlibImp sharedInstance] connectByUuid:_uuid];
}
void Bt_connectByListIndex(int index){
    [[btsocketlibImp sharedInstance] connectByListIndex:index];
}
void Bt_send(Byte * data,int len){
    [[btsocketlibImp sharedInstance] send:data length:len];
}
BOOL Bt_recv(Byte * data,int len){
    return [[btsocketlibImp sharedInstance] recv:data length:len];
}

long Bt_getReadTime(){
    return [[btsocketlibImp sharedInstance] getReadTime];
}

long Bt_getWriteTime(){
    return [[btsocketlibImp sharedInstance] getWriteTime];
}
int Bt_getConnectState(){
    return [[btsocketlibImp sharedInstance] getConnectState];
}
void Bt_disConnect(){
    [[btsocketlibImp sharedInstance] disConnect];
}
