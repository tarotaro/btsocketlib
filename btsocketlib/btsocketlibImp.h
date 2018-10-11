//
//  btsocketlib.h
//  btsocketlib
//
//  Created by 中村太郎 on 2018/10/10.
//  Copyright © 2018年 中村太郎. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface btsocketlibImp : NSObject

+ (btsocketlibImp*)sharedInstance;
-(void)startServer;
-(void)searchDevice;
-(NSString *)getBluetoothIDList;
-(void)connectById:(NSString *)address;
-(void)connectByListIndex:(int)index;
-(void)send:(Byte *) data length:(int) len;
-(Byte*)recv:(int)len;
-(long) getReadTime;
-(int)getConnectState;
-(void)disConnect;


@end
