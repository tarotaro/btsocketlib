//
//  btsocketlib.m
//  btsocketlib
//
//  Created by 中村太郎 on 2018/10/10.
//  Copyright © 2018年 中村太郎. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "btsocketlibImp.h"
#import "LGBluetooth.h"
#import "CBUUID+StringExtraction.h"


@interface btsocketlibImp()

@property (nonatomic, strong) NSArray * searchedPeripherals;
@property (nonatomic, strong) LGPeripheral *connectedPeripheral;
@property (nonatomic) ConnectState state;
@property (nonatomic) ConnectMode mode;

@end

@implementation btsocketlibImp


static btsocketlibImp *singleton  = nil;

+ (btsocketlibImp*) sharedInstance{
    static dispatch_once_t once;
    dispatch_once( &once, ^{
       singleton =  [[btsocketlibImp alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(peripheralDidDisconnect:)
                                                     name:kLGPeripheralDidDisconnect
                                                   object:nil];
        singleton.mode = ServerMode;
    });
    
    singleton.state = DisConnect;
    return singleton;
}

-(void)startServer{
    
}

-(void)searchDevice{
    NSArray *services = @[[CBUUID UUIDWithString:kServiceUuidYouCanChange]];
    [[LGCentralManager sharedInstance] scanForPeripheralsByInterval:5 services:services options:nil completion:^(NSArray *peripherals) {
        if(peripherals.count > 0){
            self.searchedPeripherals = peripherals;
        }
    }];
}

-(NSString *)getBluetoothIDList{
    if(self.searchedPeripherals == nil){
        return nil;
    }
    
    NSMutableArray *bluetoothlist = [NSMutableArray array];
    for(int i = 0;i < self.searchedPeripherals.count;i++){
        LGPeripheral *ph= self.searchedPeripherals[i];
        NSString *name = ph.name == nil ? @"NoName" : ph.name;
        NSDictionary *dic = @{@"device":name,@"address":ph.UUIDString};
        [bluetoothlist addObject:dic];
    }
    NSDictionary *devices = @{@"devices":bluetoothlist};
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:devices options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonStr = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonStr;
}

-(void)connectById:(NSString *)address{
    LGPeripheral *select = nil;
    for(int i = 0 ;i< self.searchedPeripherals.count ;i++){
        if([[self.searchedPeripherals[i] UUIDString] isEqualToString:address]){
            select = self.searchedPeripherals[i];
            break;
        }
    }
    self.state = Connecting;
    [select connectWithCompletion:^(NSError *error) {
        if(error != nil){
            self.state = Failed;
            self.mode = ServerMode;
        }else{
            self.connectedPeripheral = select;
            self.state = Connected;
            self.mode = ClientMode;
        }
    }];
    
}

-(void)connectByListIndex:(int)index{
    if(index > self.searchedPeripherals.count || index < 0){
        self.state = Failed;
    }
    LGPeripheral *select = self.searchedPeripherals[index];
    [select connectWithCompletion:^(NSError *error) {
        if(error != nil){
            self.state = Failed;
            self.mode = ServerMode;
        }else{
            self.connectedPeripheral = select;
            self.state = Connected;
            self.mode = ClientMode;
        }
    }];
}

-(void)send:(Byte *) data length:(int) len{
    
}

-(Byte*)recv:(int)len{
    return nil;
}

-(long) getReadTime{
    return 0;
}

-(long) getWriteTime{
    return 0;
}

-(int)getConnectState{
    return self.state;
}

-(void)disConnect{
    if(self.connectedPeripheral != nil){
        [self.connectedPeripheral disconnectWithCompletion:^(NSError *error) {
            if(error != nil){
                
            }else{
                self.state = DisConnect;
                self.mode = ServerMode;
            }
        }];
    }
}

- (void)peripheralDidDisconnect:(NSNotification *)notification {
    self.state = DisConnect;
    self.mode = ServerMode;
}

@end


