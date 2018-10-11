//
//  btsocketlib.hpp
//  btsocketlib
//
//  Created by 中村太郎 on 2018/10/11.
//  Copyright © 2018年 中村太郎. All rights reserved.
//

#ifndef _BTSOCKET_LIB_H_
#define _BTSOCKET_LIB_H_

extern "C" {
    void _startServer();
    void _searchDevice();
    
    NSString * _getBluetoothIDList();
    void _connectById(NSString * address);
    void _connectByListIndex(int index);
    void _send(Byte * data,int len);
    Byte* _recv(int len);
    long _getReadTime();
    int _getConnectState();
    void _disConnect();

}


#endif
