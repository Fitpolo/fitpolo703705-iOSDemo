//
//  CBPeripheral+fitpolo705Characteristic.m
//  fitpolo705SDKDemo
//
//  Created by aa on 2018/7/19.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "CBPeripheral+fitpolo705Characteristic.h"
#import <objc/runtime.h>

#pragma mark -
static const char *readDataCharacteristic = "readDataCharacteristic";
static const char *writeDataCharacteristic = "writeDataCharacteristic";
static const char *stepDataCharacteristic = "stepDataCharacteristic";
static const char *heartRateCharacteristic = "heartRateCharacteristic";
static const char *updateWriteCharacteristic = "updateWriteCharacteristic";
static const char *updateNotifyCharacteristic = "updateNotifyCharacteristic";

@implementation CBPeripheral (fitpolo705Characteristic)

- (void)update705CharacteristicsForService:(CBService *)service{
    if ([service.UUID isEqual:[CBUUID UUIDWithString:normalServiceUUID]]) {
        for (CBCharacteristic *characteristic in [service.characteristics mutableCopy]) {
            [self setNotifyValue:YES forCharacteristic:characteristic];
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:readConfigDataUUID]]) {
                objc_setAssociatedObject(self, &readDataCharacteristic, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:setConfigDataUUID]]){
                objc_setAssociatedObject(self, &writeDataCharacteristic, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:stepMeterDataUUID]]){
                objc_setAssociatedObject(self, &stepDataCharacteristic, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:heartRateDataUUID]]){
                objc_setAssociatedObject(self, &heartRateCharacteristic, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
        return;
    }
    if ([service.UUID isEqual:[CBUUID UUIDWithString:updateServiceUUID]]){
        for (CBCharacteristic *characteristic in [service.characteristics mutableCopy]) {
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:updateWriteUUID]]) {
                objc_setAssociatedObject(self, &updateWriteCharacteristic, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:updateNotifyUUID]]){
                [self setNotifyValue:YES forCharacteristic:characteristic];
                objc_setAssociatedObject(self, &updateNotifyCharacteristic, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
        return;
    }
}

- (BOOL)fitpolo705ConnectSuccess{
    if (!self.readData) {
        return NO;
    }
    if (!self.writeData) {
        return NO;
    }
    if (!self.stepData) {
        return NO;
    }
    if (!self.heartRate) {
        return NO;
    }
    if (!self.updateWrite) {
        return NO;
    }
    if (!self.updateNotify) {
        return NO;
    }
    return YES;
}

- (CBCharacteristic *)readData{
    return objc_getAssociatedObject(self, &readDataCharacteristic);
}

- (CBCharacteristic *)writeData{
    return objc_getAssociatedObject(self, &writeDataCharacteristic);
}

- (CBCharacteristic *)stepData{
    return objc_getAssociatedObject(self, &stepDataCharacteristic);
}

- (CBCharacteristic *)heartRate{
    return objc_getAssociatedObject(self, &heartRateCharacteristic);
}

- (CBCharacteristic *)updateWrite{
    return objc_getAssociatedObject(self, &updateWriteCharacteristic);
}

- (CBCharacteristic *)updateNotify{
    return objc_getAssociatedObject(self, &updateNotifyCharacteristic);
}

@end
