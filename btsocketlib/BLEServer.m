//
//  BLEServer.m
//  btsocketlib
//
//  Created by 中村太郎 on 2018/10/19.
//  Copyright © 2018年 中村太郎. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEServer.h"
#import "btsocketlibImp.h"
#import "Queue.h"

@interface BLEServer() <CBPeripheralManagerDelegate>

@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CBMutableService *service;
@property (nonatomic, strong) CBMutableCharacteristic *writeCharacteristic;
@property (nonatomic, strong) CBMutableCharacteristic *readCharacteristic;
@property (nonatomic, strong) Queue *readQueue;
@property (nonatomic, strong) Queue *writeQueue;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic) ConnectState state;

@end

@implementation BLEServer

- (id) init {
    if (self = [super init]) {
        self.readQueue = [[Queue alloc] initWithSize:kMaxQueueSize];
        self.writeQueue = [[Queue alloc] initWithSize:kMaxQueueSize];
        self.uuid = [[[NSUUID UUID] UUIDString] substringWithRange:NSMakeRange(0, 4)];
        [self setupBluetooth];
    }
    
    return self;
}

- (void)setupBluetooth{
    CBUUID *serviceUUID = [CBUUID UUIDWithString:kServiceUuidYouCanChange];
    self.service = [[CBMutableService alloc] initWithType:serviceUUID
                                                  primary:YES];
    
    CBCharacteristicProperties rpropertie = (
                                             CBCharacteristicPropertyRead
                                             );
    CBCharacteristicProperties wpropertie = (
                                             CBCharacteristicPropertyWrite|CBCharacteristicWriteWithResponse
                                             );
    CBAttributePermissions rpermission = (CBAttributePermissionsReadable);
    
    CBAttributePermissions wpermission = (CBAttributePermissionsWriteable);
    
    CBUUID *wcharUUID = [CBUUID UUIDWithString:kCharWriteUuidYouCanChange];
    self.writeCharacteristic
    = [[CBMutableCharacteristic alloc] initWithType:wcharUUID
                                         properties:wpropertie
                                              value:nil
                                        permissions:wpermission];
    
    CBUUID *rcharUUID = [CBUUID UUIDWithString:kCharReadUuidYouCanChange];
    self.readCharacteristic
    = [[CBMutableCharacteristic alloc] initWithType:rcharUUID
                                         properties:rpropertie
                                              value:nil
                                        permissions:rpermission];
    
    self.service.characteristics = @[self.writeCharacteristic,self.readCharacteristic];
    
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral.state == CBManagerStatePoweredOn ) {
        [self.peripheralManager addService:self.service];
    }
}

- (void)startAdvertizing{
    NSDictionary *advertisementData = @{CBAdvertisementDataLocalNameKey:self.uuid,CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:kServiceUuidYouCanChange]]};
    [self.peripheralManager startAdvertising:advertisementData];
}

-(NSString *)getDeviceID{
    return self.uuid;
}

-(void)stopAdvertizing{
    [self.peripheralManager stopAdvertising];
}

-(Queue *)getReadQueue{
    return self.readQueue;
}

-(void)addWriteQueue:(Queue *) queue{
    for(int i = 0;i<queue.count;i++){
        [self.writeQueue enqueue:[queue dequeue]];
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral
                                       error:(NSError *)error
{
    if (error) {
        NSLog(@"***Advertising Failed… error:%@***", error);
        return;
    }
    NSLog(@"***Advertising Succeeded!***");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
            didAddService:(CBService *)service
                    error:(NSError *)error
{
    if (error){
        NSLog(@"***error:%@***", error);
              return;
    }
    [self startAdvertizing];
    NSLog(@"***service:%@***", service);
    
}


- (void)peripheralManager:(CBPeripheralManager *)peripheral
    didReceiveReadRequest:(CBATTRequest *)request
{
    if ([request.characteristic.UUID isEqual:self.readCharacteristic.UUID])
    {
        // Set the characteristic's value to the request
        int size = self.writeQueue.count > MaxSize ? MaxSize : self.writeQueue.count;
        if(size == 0){
            [self.peripheralManager respondToRequest:request
                                          withResult:CBATTErrorSuccess];
            return;
        }
        Byte sendData[size];
        for(int i=0;i<size;i++){
            sendData[i] = [self.writeQueue remove];
        }
        NSData *data = [NSData dataWithBytes:sendData length:size];
        self.readCharacteristic.value = data;
        request.value = data;
        
        // Respond to the request
        [self.peripheralManager respondToRequest:request
                                      withResult:CBATTErrorSuccess];
    }
}

- (void)  peripheralManager:(CBPeripheralManager *)peripheral
    didReceiveWriteRequests:(nonnull NSArray<CBATTRequest *> *)requests{
    for (CBATTRequest *aRequest in requests)
    {
        if ([aRequest.characteristic.UUID isEqual:self.writeCharacteristic.UUID])
        {
            // Set the request's value
            // to the correspondent characteristic
            int size = [aRequest.value length];
            if(size == 0) {
                continue;
            }
            Byte wdata[size];
            self.writeCharacteristic.value = aRequest.value;
            [aRequest.value getBytes:wdata length:size];
            [self.readQueue add:wdata length:size];
        }
    }
    
    [self.peripheralManager respondToRequest:requests[0]
                                  withResult:CBATTErrorSuccess];
}

@end
