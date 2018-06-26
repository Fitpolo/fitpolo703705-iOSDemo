//
//  fitpolo705CentralManager.h
//  testSDK
//
//  Created by aa on 2018/3/13.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "fitpolo705Defines.h"

typedef NS_ENUM(NSInteger, fitpolo705ConnectPeripheralType) {
    fitpolo705ConnectPeripheralWithUUID,                //通过uuid方式连接
    fitpolo705ConnectPeripheralWithMacAddress,          //通过mac地址连接
    fitpolo705ConnectPeripheralWithMacAddressLowFour,   //通过mac地址低四位连接
};

typedef NS_ENUM(NSInteger, operationPeripheralType) {
    operationPeripheralTypeUnknow,                   //未知设备
    operationPeripheralTypeFitpolo703,               //703设备
    operationPeripheralTypeFitpolo705,               //705设备
};

/**
 中心设备连接外设失败的Block
 
 @param error 错误信息
 */
typedef void(^fitpolo705ConnectPeripheralFailedBlock)(NSError *error);

/**
 设备连接成功回调

 @param connectedPeripheral 当前已经连接的设备
 @param macAddress 已经连接的设备的mac地址
 (只有connectPeripheralWithIdentifier:
                         connectType:
                      peripheralType:
                 connectSuccessBlock:
                    connectFailBlock:方法连接的设备才会有值)
 @param peripheralName 已经连接的设备的名称
 (只有connectPeripheralWithIdentifier:
                         connectType:
                      peripheralType:
                 connectSuccessBlock:
                    connectFailBlock:方法连接的设备才会有值)
 */
typedef void(^fitpolo705ConnectPeripheralSuccessBlock)(CBPeripheral *connectedPeripheral, NSString *macAddress, NSString *peripheralName);

@protocol fitpolo705ScanPeripheralDelegate;
@class fitpolo705PeripheralManager;

@interface fitpolo705CentralManager : NSObject

/**
 中心
 */
@property (nonatomic, strong, readonly)CBCentralManager *centralManager;

/**
 扫描回调
 */
@property (nonatomic, weak)id <fitpolo705ScanPeripheralDelegate>scanDelegate;

/**
 设备管理者
 */
@property (nonatomic, strong, readonly)fitpolo705PeripheralManager *peripheralManager;

// 外部调用将产生编译错误
+ (instancetype) alloc __attribute__((unavailable("alloc not available, call sharedInstance instead")));
- (instancetype) init __attribute__((unavailable("init not available, call sharedInstance instead")));
+ (instancetype) new __attribute__((unavailable("new not available, call sharedInstance instead")));

+ (fitpolo705CentralManager *)sharedInstance;

/**
 销毁单例
 */
+ (void)attempDealloc;


/**
 开始扫描设备

 @param peripheralType 设备类型
 */
- (void)startScanPeripheral:(operationPeripheralType)peripheralType;

/**
 停止扫描
 */
- (void)stopScan;

/**
 根据标识符和连接方式来连接指定的外设
 
 @param identifier 要连接外设的标识符,目前支持设备UUID、设备mac地址(xx-xx-xx-xx-xx-xx)、设备mac地址低四位(xx-xx)三种连接方式。
 @param connectType 连接方式
 @param peripheralType 连接设备的类型，703/705
 @param successBlock 连接设备成功回调
 @param failedBlock 连接设备失败回调
 */
- (void)connectPeripheralWithIdentifier:(NSString *)identifier
                            connectType:(fitpolo705ConnectPeripheralType)connectType
                         peripheralType:(operationPeripheralType)peripheralType
                    connectSuccessBlock:(fitpolo705ConnectPeripheralSuccessBlock)successBlock
                       connectFailBlock:(fitpolo705ConnectPeripheralFailedBlock)failedBlock;

/**
 连接指定设备
 
 @param peripheral 目标设备
 @param connectSuccessBlock 连接成功回调
 @param connectFailedBlock 连接失败回调
 */
- (void)connectPeripheral:(CBPeripheral *)peripheral
      connectSuccessBlock:(fitpolo705ConnectPeripheralSuccessBlock)connectSuccessBlock
       connectFailedBlock:(fitpolo705ConnectPeripheralFailedBlock)connectFailedBlock;

/**
 断开当前连接的外设
 */
- (void)disconnectConnectedPeripheral;

/**
 获取当前外设的连接状态

 @return connect status
 */
- (fitpolo705ConnectStatus)getCurrentConnectStatus;

@end

@protocol fitpolo705ScanPeripheralDelegate <NSObject>

@optional
- (void)fitpolo705StartScan;
- (void)fitpolo705ScanNewPeripheral:(NSDictionary *)dic;
- (void)fitpolo705StopScan;

@end
