//
//  Queue.m
//  btsocketlib
//
//  Created by 中村太郎 on 2018/10/14.
//  Copyright © 2018年 中村太郎. All rights reserved.
//

#import "Queue.h"

@implementation Queue

- (id)initWithSize:(int)aMaxSize{
    self = [super init];
    if (self != nil) {
        queue = [[NSMutableArray alloc] init];
        maxSize = aMaxSize;
    }
    return self;
}

- (id)dequeue {
    id headObject;
    @synchronized(queue){
        if ([queue count] == 0) return nil;
        headObject = [queue objectAtIndex:0];
        if (headObject != nil) {
            [queue removeObjectAtIndex:0];
        }
    }
    return headObject;
}

- (void)enqueue:(id)anObject {
    @synchronized(queue){
        if (anObject == nil) {
            return;
        }
        if ([queue count] >= maxSize) {
            [queue removeObjectAtIndex:0];
        }
        [queue addObject:anObject];
    }
}

- (int)count {
    int c = 0;
    @synchronized(queue) {
        c = [queue count];
    }
    return c;
}

- (void)add:(Byte[])array length:(int)length{
    for(int i = 0;i<length;i++){
        NSNumber *num = [NSNumber numberWithUnsignedChar:array[i]];
        [self enqueue:num];
    }
}

- (Byte)remove {
   NSNumber *num = [self dequeue];
    return [num charValue];
}


@end
