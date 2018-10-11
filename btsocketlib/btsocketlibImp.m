//
//  btsocketlib.m
//  btsocketlib
//
//  Created by 中村太郎 on 2018/10/10.
//  Copyright © 2018年 中村太郎. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "btsocketlibImp.h"

@implementation btsocketlibImp

static btsocketlibImp *singleton  = nil;

+ (btsocketlibImp*) sharedInstance{
    static dispatch_once_t once;
    dispatch_once( &once, ^{
       singleton =  [[btsocketlibImp alloc] init];
    });
    
    return singleton;
}

-(void)startServer{
    
}

-(void)searchDevice{
    
}

-(NSString *)getBluetoothIDList{
    NSString *str=@"";
    return str;
}

-(void)connectById:(NSString *)address{
    
}

-(void)connectByListIndex:(int)index{
    
}

-(void)send:(Byte *) data length:(int) len{
    
}

-(Byte*)recv:(int)len{
    return nil;
}

-(long) getReadTime{
    return 0;
}

-(int)getConnectState{
    return 0;
}

-(void)disConnect{
    
}

@end


