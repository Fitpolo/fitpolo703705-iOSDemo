//
//  fitpolo705PeripheralManager.h
//  testSDK
//
//  Created by aa on 2018/3/15.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "fitpolo705TaskOperation.h"
#import "fitpolo705BlockDefine.h"

@class fitpolo705OperationManager;
@class fitpolo705DataParser;

typedef NS_ENUM(NSInteger, fitpolo705Characteristic) {
    fitpolo705SetConfigCharacteristic,
    fitpolo705ReadConfigCharacteristic,
    fitpolo705StepMeterCharacteristic,
    fitpolo705HeartRateCharacteristic,
    fitpolo705UpdateWriteCharacteristic,
};

@interface fitpolo705PeripheralManager : NSObject

/**
 数据解析中心
 */
@property (nonatomic, strong, readonly)fitpolo705DataParser *dataParser;

/**
 线程管理者
 */
@property (nonatomic, strong, readonly)fitpolo705OperationManager *operationManager;


- (void)connectPeripheral:(CBPeripheral *)peripheral;

- (void)cancelConnect;

- (CBPeripheral *)connectedPeripheral;

- (BOOL)sendUpdateData:(NSData *)updateData;

- (fitpolo705TaskOperation *)generateOperationWithOperationID:(fitpolo705TaskOperationID)operationID
                                                     resetNum:(BOOL)resetNum
                                                  commandData:(NSString *)commandData
                                               characteristic:(fitpolo705Characteristic)characteristic
                                                 successBlock:(fitpolo705CommunicationSuccessBlock)successBlock
                                                 failureBlock:(fitpolo705CommunicationFailedBlock)failureBlock;

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
           characteristic:(fitpolo705Characteristic)characteristic
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
                         characteristic:(fitpolo705Characteristic)characteristic
                           successBlock:(fitpolo705CommunicationSuccessBlock)successBlock
                           failureBlock:(fitpolo705CommunicationFailedBlock)failureBlock;

@end


