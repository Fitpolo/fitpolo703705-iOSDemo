//
//  CBPeripheral+Characteristic.h
//  fitpolo705SDKDemo
//
//  Created by aa on 2018/7/19.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

#pragma mark - /*=======================  扫描过滤服务  =======================*/
static NSString *const scanServiceUUID = @"FFC0";

#pragma mark - /*=======================  通用服务  =========================*/
static NSString *const normalServiceUUID = @"FFB0";

/*======================= 通用服务下面的特征UUID ====================*/

/*=======================  读取手环当前配置信息UUID(W/N) ================*/
static NSString *const readConfigDataUUID = @"FFB0";

/*=======================  设置手环当前配置信息UUID(W/N) ================*/
static NSString *const setConfigDataUUID = @"FFB1";

/*=======================  计步数据UUID(W/N)  ========================*/
static NSString *const stepMeterDataUUID = @"FFB2";

/*=======================  心率数据UUID(W/N)  ========================*/
static NSString *const heartRateDataUUID = @"FFB3";

#pragma mark - /*=======================  升级服务  =========================*/
static NSString *const updateServiceUUID = @"FFC0";

/*====================  升级服务下面的特征  =====================*/
static NSString *const updateWriteUUID = @"FFC1";

static NSString *const updateNotifyUUID = @"FFC2";

@interface CBPeripheral (fitpolo705Characteristic)

@property (nonatomic, strong, readonly)CBCharacteristic *readData;

@property (nonatomic, strong, readonly)CBCharacteristic *writeData;

@property (nonatomic, strong, readonly)CBCharacteristic *stepData;

@property (nonatomic, strong, readonly)CBCharacteristic *heartRate;

@property (nonatomic, strong, readonly)CBCharacteristic *updateWrite;

@property (nonatomic, strong, readonly)CBCharacteristic *updateNotify;

- (void)update705CharacteristicsForService:(CBService *)service;
- (BOOL)fitpolo705ConnectSuccess;

@end
