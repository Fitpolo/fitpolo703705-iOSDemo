//
//  fitpolo705CentralManager.h
//  testSDK
//
//  Created by aa on 2018/3/13.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "fitpolo705TaskIDDefines.h"

extern NSString *const fitpolo705PeripheralConnectStateChanged;
extern NSString *const fitpolo705PeripheralUpdateResultNotification;

typedef NS_ENUM(NSInteger, operationPeripheralType) {
    operationPeripheralTypeUnknow,                   //未知设备
    operationPeripheralTypeFitpolo703,               //703设备
    operationPeripheralTypeFitpolo705,               //705设备
};
typedef NS_ENUM(NSInteger, fitpolo705ConnectStatus) {
    fitpolo705ConnectStatusUnknow,                                           //未知状态
    fitpolo705ConnectStatusConnecting,                                       //正在连接
    fitpolo705ConnectStatusConnected,                                        //连接成功
    fitpolo705ConnectStatusConnectedFailed,                                  //连接失败
    fitpolo705ConnectStatusDisconnect,                                       //连接断开
};
typedef NS_ENUM(NSInteger, fitpolo705CentralManagerState) {
    fitpolo705CentralManagerStateEnable,                           //可用状态
    fitpolo705CentralManagerStateUnable,                           //不可用
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
/**
 数据通信成功
 
 @param returnData 返回的Json数据
 */
typedef void(^fitpolo705CommunicationSuccessBlock)(id returnData);

/**
 数据通信失败
 
 @param error 失败原因
 */
typedef void(^fitpolo705CommunicationFailedBlock)(NSError *error);

@class fitpolo705CentralManager;
@protocol fitpolo705ScanPeripheralDelegate <NSObject>
/**
 中心开始扫描

 @param centralManager 中心
 */
- (void)centralManagerStartScan:(fitpolo705CentralManager *)centralManager;
/**
 扫描到新的设备

 @param peripheral 扫描到的设备
 @param macAddress 设备的mac地址
 @param peripheralName 设备的名称
 @param centralManager 中心
 */
- (void)centralManagerScanningNewPeripheral:(CBPeripheral *)peripheral
                                 macAddress:(NSString *)macAddress
                             peripheralName:(NSString *)peripheralName
                             centralManager:(fitpolo705CentralManager *)centralManager;
/**
 中心停止扫描

 @param centralManager 中心
 */
- (void)centralManagerStopScan:(fitpolo705CentralManager *)centralManager;

@end

@protocol fitpolo705CentralManagerStateDelegate <NSObject>

/**
 中心蓝牙状态改变

 @param managerState 中心蓝牙状态
 @param manager 中心
 */
- (void)centralManagerStateChanged:(fitpolo705CentralManagerState)managerState manager:(fitpolo705CentralManager *)manager;

/**
 中心与外设连接状态改变

 @param connectState 外设连接状态
 @param manager 中心
 */
- (void)centralManagerConnectStateChanged:(fitpolo705ConnectStatus)connectState manager:(fitpolo705CentralManager *)manager;

@end

@class fitpolo705TaskOperation;
@interface fitpolo705CentralManager : NSObject

/**
 中心
 */
@property (nonatomic, strong, readonly)CBCentralManager *centralManager;

@property (nonatomic, strong, readonly)CBPeripheral *connectedPeripheral;

/**
 扫描代理
 */
@property (nonatomic, weak)id <fitpolo705ScanPeripheralDelegate>scanDelegate;

/**
 中心状态代理
 */
@property (nonatomic, weak)id <fitpolo705CentralManagerStateDelegate>managerStateDelegate;

/**
 当前连接状态
 */
@property (nonatomic, assign, readonly)fitpolo705ConnectStatus connectStatus;

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
 @param peripheralType 连接设备的类型，703/705
 @param successBlock 连接设备成功回调
 @param failedBlock 连接设备失败回调
 */
- (void)connectPeripheralWithIdentifier:(NSString *)identifier
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

#pragma mark - task
- (BOOL)sendUpdateData:(NSData *)updateData;
/**
 添加一个通信任务(app-->peripheral)到队列
 
 @param operationID 任务ID
 @param resetNum 是否需要由外设返回通信数据总条数
 @param commandData 通信数据
 @param characteristic 通信所使用的特征
 @param successBlock 通信成功回调
 @param failureBlock 通信失败回调
 */
- (void)addTaskWithTaskID:(fitpolo705TaskOperationID)operationID
                 resetNum:(BOOL)resetNum
              commandData:(NSString *)commandData
           characteristic:(CBCharacteristic *)characteristic
             successBlock:(fitpolo705CommunicationSuccessBlock)successBlock
             failureBlock:(fitpolo705CommunicationFailedBlock)failureBlock;
/**
 添加一个通信任务(app-->peripheral)到队列,当获任务结束只获取到部分数据的时候，返回这部分数据到成功回调
 
 @param operationID 任务ID
 @param commandData 通信数据
 @param characteristic 通信所使用的特征
 @param successBlock 通信成功回调
 @param failureBlock 通信失败回调
 */
- (void)addNeedPartOfDataTaskWithTaskID:(fitpolo705TaskOperationID)operationID
                            commandData:(NSString *)commandData
                         characteristic:(CBCharacteristic *)characteristic
                           successBlock:(fitpolo705CommunicationSuccessBlock)successBlock
                           failureBlock:(fitpolo705CommunicationFailedBlock)failureBlock;
/**
 手环开启升级固件
 
 @param crcData 本地升级的校验码，两个字节，将本地的固件做crc16得出来的
 @param packageSize 本次升级的固件大小，4个字节
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)addUpdateFirmwareTaskWithCrcData:(NSData *)crcData
                             packageSize:(NSData *)packageSize
                            successBlock:(fitpolo705CommunicationSuccessBlock)successBlock
                             failedBlock:(fitpolo705CommunicationFailedBlock)failedBlock;

@end
