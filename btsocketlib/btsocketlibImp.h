//
//  btsocketlib.h
//  btsocketlib
//
//  Created by 中村太郎 on 2018/10/10.
//  Copyright © 2018年 中村太郎. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString *const kServiceUuidYouCanChange = @"0000CA0C-0000-1000-8000-00805f9b34fb";
NSString *const kCharWriteUuidYouCanChange = @"0000F9EF-0000-1000-8000-00805f9b34fb";
NSString *const kCharReadUuidYouCanChange = @"0000F9EE-0000-1000-8000-00805f9b34fb";
NSString *const kServicesUuid = @"CA0C";
NSString *const kCharWritesUuid = @"F9EF";
NSString *const kCharReadsUuid = @"F9EE";
int const kConnectionInterval = 20;
int const kMaxQueueSize = 4096;
int const MaxSize = 185;

typedef NS_ENUM(NSInteger, ConnectState){
    DisConnect = 0,
    Connected = 1,
    Connecting = 2,
    Failed = 3
};

typedef NS_ENUM(NSInteger, ConnectMode)  {
    ServerMode,
    ClientMode
};

@interface btsocketlibImp : NSObject
+ (btsocketlibImp*)sharedInstance;
-(void)startServer;
-(NSString *)getId;
-(void)searchDevice;
-(NSString *)getBluetoothIDList;
-(void)connectById:(NSString *)address;
-(void)connectByListIndex:(int)index;
-(void)send:(Byte *) data length:(int) len;
-(BOOL)recv:(Byte *) data length:(int)len;
-(long) getReadTime;
-(long) getWriteTime;
-(int)getConnectState;
-(void)disConnect;


@end
