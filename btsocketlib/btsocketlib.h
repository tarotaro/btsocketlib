//
//  btsocketlib.hpp
//  btsocketlib
//
//  Created by 中村太郎 on 2018/10/11.
//  Copyright © 2018年 中村太郎. All rights reserved.
//

#ifndef _BTSOCKET_LIB_H_
#define _BTSOCKET_LIB_H_
#import <Foundation/Foundation.h>


extern "C" {
    void startServer();
    void searchDevice();
    char * getUuidForName();
    
    char * getBluetoothList();
    void connectByUuid(const char * uuid);
    void connectByListIndex(int index);
    void send(Byte * data,int len);
    BOOL recv(Byte *data,int len);
    long getReadTime();
    long getWriteTime();
    int getConnectState();
    void disConnect();

}


#endif
