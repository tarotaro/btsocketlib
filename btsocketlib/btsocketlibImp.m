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
#import "BLEServer.h"
#import "Queue.h"


@interface btsocketlibImp()

@property (nonatomic, strong) NSArray * searchedPeripherals;
@property (nonatomic, strong) LGPeripheral *connectedPeripheral;
@property (nonatomic) ConnectState state;
@property (nonatomic) ConnectMode mode;
@property (nonatomic,strong) NSOperationQueue *readThreadQueue;
@property (nonatomic,strong) NSOperationQueue *writeThreadQueue;
@property (nonatomic,strong) LGCharacteristic *readChar;
@property (nonatomic,strong) LGCharacteristic *writeChar;
@property (nonatomic, strong) Queue *readQueue;
@property (nonatomic, strong) Queue *writeQueue;
@property (nonatomic,strong) NSMutableArray * deviceList;
@property (nonatomic) BOOL isReadReturn;
@property (nonatomic) BOOL isWriteReturn;
@property (nonatomic) long nowReadStartTime;
@property (nonatomic) long nowWriteStartTime;
@property (nonatomic) long calculatedReadTime;
@property (nonatomic) long calculatedWriteTime;


@property (nonatomic, strong) BLEServer *bleServer;

@end

@implementation btsocketlibImp

static Byte readDataBytes[kMaxQueueSize];
static btsocketlibImp *singleton  = nil;

+ (btsocketlibImp*) sharedInstance{
    static dispatch_once_t once;
    dispatch_once( &once, ^{
       singleton =  [[btsocketlibImp alloc] init];
    });
    
    return singleton;
}

- (id) init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(peripheralDidDisconnect:)
                                                     name:kLGPeripheralDidDisconnect
                                                   object:nil];
        singleton.mode = ServerMode;
        singleton.state = DisConnect;
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
    self.mode = ServerMode;
    self.bleServer = [[BLEServer alloc] init];    
}

-(NSString *)getUuidForName{
    if(self.bleServer != nil){
        return [self.bleServer getDeviceID];
    }
    return nil;
}

-(void)searchDevice{
    NSArray *services = @[[CBUUID UUIDWithString:kServiceUuidYouCanChange]];
    if ([[LGCentralManager sharedInstance] isScanning]){
        return;
    }

    while(true){
        if([[LGCentralManager sharedInstance] isCentralReady]){
            [[LGCentralManager sharedInstance] scanForPeripheralsByInterval:10 services:services options:nil completion:^(NSArray *peripherals) {
                if(peripherals.count > 0){
                    self.searchedPeripherals = peripherals;
                }
            }];
        }
        if ([[LGCentralManager sharedInstance] isScanning]){
            break;
        }
        
    }

}

-(NSString *)getBluetoothList{
    if(self.searchedPeripherals == nil){
        NSArray *array = [NSArray array];
        NSDictionary *devices = @{@"devices":array};
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:devices options:NSJSONWritingPrettyPrinted error:&error];
        
        NSString *jsonStr = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonStr;
    }
    
    self.deviceList = [NSMutableArray array];
    for(int i = 0;i < self.searchedPeripherals.count;i++){
        LGPeripheral *ph= self.searchedPeripherals[i];
        NSDictionary *data = ph.advertisingData[CBAdvertisementDataServiceDataKey];
        NSString *pname;
        NSString *uuid;
        if(data != nil){
            pname =[[NSString alloc] initWithData:data[[CBUUID UUIDWithString:kServiceUuidYouCanChange]] encoding:NSUTF8StringEncoding];
        }else{
            //iOSは、CBAdvertisementDataServiceDataKeyが送れないようなので、
            //peripheralのローカルネームで代用
            pname = ph.name;
            uuid = ph.advertisingData[CBAdvertisementDataLocalNameKey];
        }
        NSString *name = pname == nil ? @"NoName" : pname;
        uuid = uuid == nil ? pname : uuid;
        NSDictionary *dic = @{@"device":name,@"address":ph.UUIDString,@"uuid":uuid};
        [self.deviceList addObject:dic];
    }

    NSDictionary *devices = @{@"devices":self.deviceList};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:devices options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonStr = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonStr;
}

-(void)connectByUuid:(NSString *)uuid{
    LGPeripheral *select = nil;
    for(int i = 0 ;i< self.searchedPeripherals.count ;i++){
        NSDictionary * devDic = self.deviceList[i];
        if([[devDic objectForKey:@"uuid"] isEqualToString:uuid]){
            select = self.searchedPeripherals[i];
            break;
        }
    }
    if (self == nil){
        self.state = Failed;
    }
    self.state = Connecting;
    [[LGCentralManager sharedInstance] stopScanForPeripherals];
    [select connectWithCompletion:^(NSError *error) {
        if(error != nil){
            self.state = Failed;
            self.mode = ServerMode;
        }else{
            self.connectedPeripheral = select;
            self.state = Connected;
            self.mode = ClientMode;
            [self connectedAfter];
        }
    }];
    
}

-(void)connectByListIndex:(int)index{
    if(index > self.searchedPeripherals.count || index < 0){
        self.state = Failed;
        return;
    }
    
     self.state = Connecting;
    LGPeripheral *select = self.searchedPeripherals[index];
    [[LGCentralManager sharedInstance] stopScanForPeripherals];
    [select connectWithCompletion:^(NSError *error) {
        if(error != nil){
            self.state = Failed;
            self.mode = ServerMode;
        }else{
            self.connectedPeripheral = select;
            self.state = Connected;
            self.mode = ClientMode;
            [self connectedAfter];
        }
    }];
}
-(void)connectedAfter{
    NSArray *services = @[[CBUUID UUIDWithString:kServiceUuidYouCanChange]];
    [self.connectedPeripheral discoverServices:services completion:^(NSArray *services, NSError *error) {
        if (services.count > 0){
            [services[0] discoverCharacteristicsWithCompletion:^(NSArray *characteristics, NSError *error) {
                for(LGCharacteristic *ch in characteristics){
                    if([[ch.UUIDString lowercaseString] isEqualToString:[kCharWriteUuidYouCanChange lowercaseString]]||[[ch.UUIDString lowercaseString] isEqualToString:[kCharWritesUuid lowercaseString]]){
                        self.writeChar = ch;
                    }else{
                        self.readChar = ch;
                    }
                }
                [self sendedProccess];
            }];
        }
    }];
}
     

-(void)sendedProccess{
    [self.writeThreadQueue cancelAllOperations];
    [self.writeThreadQueue addOperationWithBlock:^{
        if(self.mode == ClientMode){
            while(true){
                int ms = 1000;
                usleep(kConnectionInterval*ms);
                if(self.isWriteReturn && [[LGCentralManager sharedInstance] isCentralReady]){
                    self.isWriteReturn = false;
                    int maxSize = /*MaxSize;*/[[self.connectedPeripheral cbPeripheral] maximumWriteValueLengthForType:CBCharacteristicWriteWithResponse];
                    int size = self.writeQueue.count > maxSize ? maxSize : self.writeQueue.count;
                    if(size <= 0){
                        self.isWriteReturn = true;
                        continue;
                    }
                    Byte sendData[size];
                    for(int i=0;i<size;i++){
                        sendData[i] = [self.writeQueue objectAtIndex:i];
                    }
                    self.nowWriteStartTime = [[NSDate date] timeIntervalSince1970]*1000.0;
                    /*[LGUtils writeData:[NSData dataWithBytes:sendData length:size] charactUUID:kCharWritesUuid serviceUUID:kServicesUuid peripheral:self.connectedPeripheral completion:^(NSError *error) {*/
                    [self.writeChar writeValue:[NSData dataWithBytes:sendData length:size] completion:^(NSError *error) {
                               if(error != nil){
                                   self.isWriteReturn = true;
                               }else{
                                   self.calculatedWriteTime = [[NSDate date] timeIntervalSince1970]*1000.0 - self.nowWriteStartTime;
                                   for(int i=0;i<size;i++){
                                       [self.writeQueue remove];
                                   }
                                   self.isWriteReturn = true;
                               }
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
                if(self.isReadReturn && [[LGCentralManager sharedInstance] isCentralReady]){
                    self.isReadReturn = false;
                    self.nowReadStartTime = [[NSDate date] timeIntervalSince1970]*1000.0;
                    /*[LGUtils readDataFromCharactUUID:kCharReadsUuid serviceUUID:kServicesUuid peripheral:self.connectedPeripheral completion:^(NSData *data, NSError *error) {*/
                    [self.readChar readValueWithBlock:^(NSData *data, NSError *error) {
                        if(error!= nil){
                            self.isReadReturn = true;
                        }else{
                            self.calculatedReadTime = [[NSDate date] timeIntervalSince1970]*1000.0 - self.nowReadStartTime;
                            int size = (int)[data length];
                            if(size == 0){
                                self.isReadReturn = true;
                                return;
                            }
                            Byte readData[size];
                            [data getBytes:readData length:size];
                            [self.readQueue add:readData length:size];
                            self.isReadReturn = true;
                            
                        }
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
    if(self.mode ==ClientMode){
        [self.writeQueue add:data length:len];
    }else{
        [self.writeQueue add:data length:len];
        [self.bleServer addWriteQueue:self.writeQueue];
    }
}

-(BOOL)recv:(Byte *)data length:(int)len{
    Queue * getQueue = nil;
    if(self.mode == ClientMode){
        getQueue = self.readQueue;
    }else{
        getQueue = [self.bleServer getReadQueue];
    }
    if(getQueue == nil||getQueue.count<len){
        return false;
    }
    for(int i = 0;i<len;i++ ){
        data[i] = [getQueue remove];
    }
    return true;
}

-(long) getReadTime{
    return self.calculatedReadTime;
}

-(long) getWriteTime{
    return self.calculatedWriteTime;
}

-(int)getConnectState{
    if(self.mode == ClientMode){
        return self.state;
    }else{
        if (self.bleServer != nil && [self.bleServer getReadQueue].count){
            self.state = Connected;
            return Connected;
        }else{
            if(self.state != Connected){
                return DisConnect;
            }else{
                return Connected;
            }
        }
    }
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


