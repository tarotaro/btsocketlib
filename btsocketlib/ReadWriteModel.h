//
//  ReadWriteModel.h
//  btsocketlib
//
//  Created by 中村太郎 on 2018/10/14.
//  Copyright © 2018年 中村太郎. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "btsocketlibImp.h"

NS_ASSUME_NONNULL_BEGIN

@interface ReadWriteModel : NSObject

-(void)setConnectMode:(ConnectMode) _mode;
-(void)setConnectState:(ConnectState) _state;

@end

NS_ASSUME_NONNULL_END
