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
    void Bt_startServer();
    void Bt_searchDevice();
    char * Bt_getUuidForName();
    char * Bt_getBluetoothList();
    void Bt_connectByUuid(const char * uuid);
    void Bt_connectByListIndex(int index);
    void Bt_send(Byte * data,int len);
    BOOL Bt_recv(Byte *data,int len);
    long Bt_getReadTime();
    long Bt_getWriteTime();
    int Bt_getConnectState();
    void Bt_disConnect();

}


#endif
