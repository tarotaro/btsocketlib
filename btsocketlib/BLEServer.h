//
//  BLEServer.h
//  btsocketlib
//
//  Created by 中村太郎 on 2018/10/19.
//  Copyright © 2018年 中村太郎. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Queue.h"

NS_ASSUME_NONNULL_BEGIN

@interface BLEServer : NSObject

- (void)startAdvertizing;
- (void)stopAdvertizing;
-(Queue *)getReadQueue;
-(NSString *)getDeviceID;
-(void)addWriteQueue:(Queue *) queue;

@end

NS_ASSUME_NONNULL_END
