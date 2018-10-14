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
#import "Queue.h"


@interface btsocketlibImp()

@property (nonatomic, strong) NSArray * searchedPeripherals;
@property (nonatomic, strong) LGPeripheral *connectedPeripheral;
@property (nonatomic) ConnectState state;
@property (nonatomic) ConnectMode mode;
@property (nonatomic,strong) NSOperationQueue *readThreadQueue;
@property (nonatomic,strong) NSOperationQueue *writeThreadQueue;
@property (nonatomic, strong) Queue *readQueue;
@property (nonatomic, strong) Queue *writeQueue;
@property (nonatomic) BOOL isReadReturn;
@property (nonatomic) BOOL isWriteReturn;
@property (nonatomic) long nowReadStartTime;
@property (nonatomic) long nowWriteStartTime;
@property (nonatomic) long calculatedReadTime;
@property (nonatomic) long calculatedWriteTime;

@end

@implementation btsocketlibImp

static Byte readDataBytes[kMaxQueueSize];
static btsocketlibImp *singleton  = nil;

+ (btsocketlibImp*) sharedInstance{
    static dispatch_once_t once;
    dispatch_once( &once, ^{
       singleton =  [[btsocketlibImp alloc] init];

    });
    
    singleton.state = DisConnect;
    return singleton;
}

- (id) init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(peripheralDidDisconnect:)
                                                     name:kLGPeripheralDidDisconnect
                                                   object:nil];
        singleton.mode = ServerMode;
        self.readQueue = [[Queue alloc] initWithSize:kMaxQueueSize];
        self.writeQueue = [[Queue alloc] initWithSize:kMaxQueueSize];
        
        self.readThreadQueue = [[NSOperationQueue alloc] init];
        self.writeThreadQueue = [[NSOperationQueue alloc] init];
        self.isReadReturn = true;
        self.isWriteReturn = true;
        
    }
    return self;
}

-(void)startServer{
    
}

-(void)searchDevice{
    NSArray *services = @[[CBUUID UUIDWithString:kServiceUuidYouCanChange]];
    if([[LGCentralManager sharedInstance] isCentralReady]){
        [[LGCentralManager sharedInstance] scanForPeripheralsByInterval:5 services:services options:nil completion:^(NSArray *peripherals) {
            if(peripherals.count > 0){
                self.searchedPeripherals = peripherals;
            }
        }];
    }
}

-(NSString *)getBluetoothIDList{
    if(self.searchedPeripherals == nil){
        NSArray *array = [NSArray array];
        NSDictionary *devices = @{@"devices":array};
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:devices options:NSJSONWritingPrettyPrinted error:&error];
        
        NSString *jsonStr = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonStr;
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

-(void)connectedProccess{
    [self.writeThreadQueue cancelAllOperations];
    [self.writeThreadQueue addOperationWithBlock:^{
        if(self.mode == ClientMode){
            while(true){
                int ms = 1000;
                usleep(kConnectionInterval*ms);
                if(self.isWriteReturn){
                    self.isWriteReturn = false;
                    int maxSize = [[self.connectedPeripheral cbPeripheral] maximumWriteValueLengthForType:CBCharacteristicWriteWithResponse];
                    int size = self.writeQueue.count > maxSize ? maxSize : self.writeQueue.count;
                    if(size <= 0){
                        self.isWriteReturn = true;
                        continue;
                    }
                    Byte sendData[size];
                    for(int i=0;i<size;i++){
                        sendData[i] = [self.writeQueue peek];
                    }
                    self.nowWriteStartTime = [[NSDate date] timeIntervalSince1970]*1000.0;
                    [LGUtils writeData:[NSData dataWithBytes:&sendData length:size]
                           charactUUID:kCharWriteUuidYouCanChange serviceUUID:kServiceUuidYouCanChange peripheral:self.connectedPeripheral completion:^(NSError *error) {
                               if(error != nil){
                               }else{
                                   self.calculatedWriteTime = [[NSDate date] timeIntervalSince1970]*1000.0 - self.nowWriteStartTime;
                                   for(int i=0;i<size;i++){
                                       [self.writeQueue remove];
                                   }
                               }
                               self.isWriteReturn = true;
                           }];
                }
                if(self.state == DisConnect){
                    break;
                }
            }
        }
    }];
    
    [self.readThreadQueue cancelAllOperations];
    [self.readThreadQueue addOperationWithBlock:^{
        if(self.mode == ClientMode){
            while(true){
                int ms = 1000;
                usleep(kConnectionInterval*ms);
                if(self.isReadReturn){
                    self.isReadReturn = false;
                    self.nowReadStartTime = [[NSDate date] timeIntervalSince1970]*1000.0;
                    [LGUtils readDataFromCharactUUID:kCharReadUuidYouCanChange serviceUUID:kServiceUuidYouCanChange peripheral:self.connectedPeripheral completion:^(NSData *data, NSError *error) {
                        self.calculatedReadTime = [[NSDate date] timeIntervalSince1970]*1000.0 - self.nowReadStartTime;
                        int size = (int)[data length];
                        if(size == 0){
                            return;
                        }
                        Byte readData[size];
                        [data getBytes:readData length:size];
                        [self.readQueue add:readData length:size];
                        self.isReadReturn = true;
                    }];
                }
                if(self.state == DisConnect){
                    break;
                }
            }
        }
    }];
}

-(void)send:(Byte *) data length:(int) len{
    [self.writeQueue add:data length:len];
}

-(Byte*)recv:(int)len{
    if(self.readQueue.count<len){
        return nil;
    }
    for(int i = 0;i<len;i++ ){
        readDataBytes[i] = [self.readQueue remove];
    }
    return readDataBytes;
}

-(long) getReadTime{
    return self.calculatedReadTime;
}

-(long) getWriteTime{
    return self.calculatedWriteTime;
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


