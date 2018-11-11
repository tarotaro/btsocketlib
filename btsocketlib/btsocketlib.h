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
    void _startServer();
    void _searchDevice();
    char * _getId();
    
    char * _getBluetoothIDList();
    void _connectById(const char * uuid);
    void _connectByListIndex(int index);
    void _send(Byte * data,int len);
    BOOL _recv(Byte *data,int len);
    long _getReadTime();
    long _getWriteTime();
    int _getConnectState();
    void _disConnect();

}


#endif
