//
//  ReadWriteModel.m
//  btsocketlib
//
//  Created by 中村太郎 on 2018/10/14.
//  Copyright © 2018年 中村太郎. All rights reserved.
//

#import "ReadWriteModel.h"


@interface ReadWriteModel()

@property (nonatomic) ConnectState state;
@property (nonatomic) ConnectMode mode;

@end


@implementation ReadWriteModel

-(void)setConnectMode:(ConnectMode) _mode{
    self.mode = _mode;
}

-(void)setConnectState:(ConnectState) _state{
    self.state = _state;
}

@end
