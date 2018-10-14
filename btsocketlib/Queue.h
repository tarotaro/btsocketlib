//
//  Queue.h
//  btsocketlib
//
//  Created by 中村太郎 on 2018/10/14.
//  Copyright © 2018年 中村太郎. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Queue : NSObject {
    NSMutableArray *queue;
    int maxSize;
}
- (id)initWithSize:(int)maxSize;
- (id)dequeue;
- (void)enqueue:(id)anObject ;
- (void)add:(Byte[])array length:(int)length;
- (Byte)remove;
- (Byte)peek;
- (int)count;
@end

NS_ASSUME_NONNULL_END
