//
//  fitpolo705PeripheralManager.m
//  testSDK
//
//  Created by aa on 2018/3/15.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "fitpolo705PeripheralManager.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "fitpolo705LogManager.h"
#import "fitpolo705DataParser.h"
#import "fitpolo705OperationManager.h"
#import "fitpolo705Parser.h"
#import "fitpolo705ServiceDefines.h"
#import "fitpolo705ConstDefines.h"
#import "fitpolo705RegularsDefine.h"

@interface characteristicModel : NSObject

@property (nonatomic, strong)CBCharacteristic *readDataCharacteristic;

@property (nonatomic, strong)CBCharacteristic *setDataCharacteristic;

@property (nonatomic, strong)CBCharacteristic *stepDataCharacteristic;

@property (nonatomic, strong)CBCharacteristic *heartRateCharacteristic;

@property (nonatomic, strong)CBCharacteristic *updateWriteCharacteristic;

@property (nonatomic, strong)CBCharacteristic *updateNotifyCharacteristic;

@end

@implementation characteristicModel

@end

@interface fitpolo705PeripheralManager()<CBPeripheralDelegate>

@property (nonatomic, strong)CBPeripheral *peripheral;

@property (nonatomic, strong)characteristicModel *characterModel;

/**
 必须拿到所有的服务才算是连接成功了
 */
@property (nonatomic, assign)NSInteger serviceCount;

/**
 数据解析中心
 */
@property (nonatomic, strong)fitpolo705DataParser *dataParser;

/**
 线程管理者
 */
@property (nonatomic, strong)fitpolo705OperationManager *operationManager;

@end

@implementation fitpolo705PeripheralManager

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"外设销毁");
    [self.operationManager cancelAllOperations];
}
#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:fitpolo705PeripheralConnectedFailedNotification object:nil userInfo:nil];
        return;
    }
    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:normalServiceUUID]]) {
            //通用服务
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:readConfigDataUUID],
                                                  [CBUUID UUIDWithString:setConfigDataUUID],
                                                  [CBUUID UUIDWithString:stepMeterDataUUID],
                                                  [CBUUID UUIDWithString:heartRateDataUUID]]
                                     forService:service];
        }else if ([service.UUID isEqual:[CBUUID UUIDWithString:updateServiceUUID]]){
            //升级服务
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:updateWriteUUID],
                                                  [CBUUID UUIDWithString:updateNotifyUUID]]
                                     forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:fitpolo705PeripheralConnectedFailedNotification object:nil userInfo:nil];
        return;
    }
    if ([service.UUID isEqual:[CBUUID UUIDWithString:normalServiceUUID]]) {
        [self setNormalService:service];
    }else if ([service.UUID isEqual:[CBUUID UUIDWithString:updateServiceUUID]]){
        [self setUpdateService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"read data from peripheral error:%@", [error localizedDescription]);
        return;
    }
    [self.dataParser parseReadDataFromCharacteristic:characteristic];
}

#pragma mark - delegate process
- (void)setNormalService:(CBService *)service{
    if (![service.UUID isEqual:[CBUUID UUIDWithString:normalServiceUUID]]) {
        return;
    }
    for (CBCharacteristic *characteristic in [service.characteristics mutableCopy]) {
        if (![self notifyCharacteristic:characteristic]) {
            return;
        }
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:readConfigDataUUID]]) {
            self.characterModel.readDataCharacteristic = characteristic;
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:setConfigDataUUID]]){
            self.characterModel.setDataCharacteristic = characteristic;
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:stepMeterDataUUID]]){
            self.characterModel.stepDataCharacteristic = characteristic;
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:heartRateDataUUID]]){
            self.characterModel.heartRateCharacteristic = characteristic;
        }
    }
    self.serviceCount ++;
    [self setCharacteristicSuccess];
}

- (void)setUpdateService:(CBService *)service{
    if (![service.UUID isEqual:[CBUUID UUIDWithString:updateServiceUUID]]) {
        return;
    }
    for (CBCharacteristic *characteristic in [service.characteristics mutableCopy]) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:updateWriteUUID]]) {
            self.characterModel.updateWriteCharacteristic = characteristic;
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:updateNotifyUUID]]){
            if (![self notifyCharacteristic:characteristic]) {
                return;
            }
            self.characterModel.updateNotifyCharacteristic = characteristic;
        }
    }
    self.serviceCount ++;
    [self setCharacteristicSuccess];
}

- (BOOL )notifyCharacteristic:(CBCharacteristic *)characteristic{
    if (!self.peripheral || !characteristic) {
        return NO;
    }
    [self.peripheral setNotifyValue:YES forCharacteristic:characteristic];
    return YES;
}

- (void)setCharacteristicSuccess{
    if (self.serviceCount < 2) {
        return;
    }
    if (!self.peripheral || ![self hasGetAllCharacteristics]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:fitpolo705PeripheralConnectedFailedNotification object:nil userInfo:nil];
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:fitpolo705PeripheralConnectedSuccessNotification object:nil userInfo:nil];
}

- (BOOL)hasGetAllCharacteristics{
    if (!self.characterModel.readDataCharacteristic || !self.characterModel.setDataCharacteristic || !self.characterModel.stepDataCharacteristic || !self.characterModel.heartRateCharacteristic || !self.characterModel.updateNotifyCharacteristic || !self.characterModel.updateWriteCharacteristic) {
        return NO;
    }
    return YES;
}

#pragma mark - Public method
- (void)connectPeripheral:(CBPeripheral *)peripheral{
    if (!peripheral) {
        [[NSNotificationCenter defaultCenter] postNotificationName:fitpolo705PeripheralConnectedFailedNotification object:nil userInfo:nil];
        return;
    }
    self.peripheral = nil;
    self.peripheral = peripheral;
    self.characterModel = nil;
    self.peripheral.delegate = self;
    self.serviceCount = 0;
    [self.peripheral discoverServices:@[[CBUUID UUIDWithString:normalServiceUUID],
                                        [CBUUID UUIDWithString:updateServiceUUID]]];
}

- (void)cancelConnect{
    self.peripheral = nil;
    self.characterModel = nil;
    [self.operationManager cancelAllOperations];
}

- (CBPeripheral *)connectedPeripheral{
    return self.peripheral;
}

- (CBCharacteristic *)getCharacterWithType:(fitpolo705Characteristic)characteristicType{
    switch (characteristicType) {
        case fitpolo705SetConfigCharacteristic:
            return self.characterModel.setDataCharacteristic;
        case fitpolo705ReadConfigCharacteristic:
            return self.characterModel.readDataCharacteristic;
        case fitpolo705StepMeterCharacteristic:
            return self.characterModel.stepDataCharacteristic;
        case fitpolo705HeartRateCharacteristic:
            return self.characterModel.heartRateCharacteristic;
        case fitpolo705UpdateWriteCharacteristic:
            return self.characterModel.updateWriteCharacteristic;
    }
}

#pragma mark - 数据通信处理方法
- (void)sendCommandToPeripheral:(NSString *)commandData characteristic:(CBCharacteristic *)characteristic{
    if (!self.peripheral || !fitpolo705ValidStr(commandData) || !characteristic) {
        return;
    }
    NSData *data = [fitpolo705Parser stringToData:commandData];
    if (!fitpolo705ValidData(data)) {
        return;
    }
    [self.peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
}

- (void)writeDataToLog:(NSString *)commandData operation:(fitpolo705TaskOperationID)operationID{
    if (!fitpolo705ValidStr(commandData)) {
        return;
    }
    NSString *commandType = [fitpolo705Parser getCommandType:operationID];
    NSString *string = [NSString stringWithFormat:@"%@:%@",commandType,commandData];
    [fitpolo705LogManager writeCommandToLocalFile:@[string] withSourceInfo:fitpolo705DataSourceAPP];
}

- (BOOL)sendUpdateData:(NSData *)updateData{
    if (!self.characterModel.updateWriteCharacteristic || !self.characterModel.updateNotifyCharacteristic) {
        return NO;
    }
    if (!fitpolo705ValidData(updateData)) {
        return NO;
    }
    [self.peripheral writeValue:updateData forCharacteristic:self.characterModel.updateWriteCharacteristic type:CBCharacteristicWriteWithoutResponse];
    NSString *string = [NSString stringWithFormat:@"%@:%@",@"固件升级数据",[fitpolo705Parser hexStringFromData:updateData]];
    [fitpolo705LogManager writeCommandToLocalFile:@[string] withSourceInfo:fitpolo705DataSourceAPP];
    return YES;
}

- (fitpolo705TaskOperation *)generateOperationWithOperationID:(fitpolo705TaskOperationID)operationID
                                                     resetNum:(BOOL)resetNum
                                                  commandData:(NSString *)commandData
                                               characteristic:(fitpolo705Characteristic)characteristic
                                                 successBlock:(fitpolo705CommunicationSuccessBlock)successBlock
                                                 failureBlock:(fitpolo705CommunicationFailedBlock)failureBlock{
    if (![self canSendData]) {
        fitpolo705ConnectError(failureBlock);
        return nil;
    }
    if (!fitpolo705ValidStr(commandData)) {
        fitpolo705ParamsError(failureBlock);
        return nil;
    }
    CBCharacteristic *character = [self getCharacterWithType:characteristic];
    if (!character) {
        fitpolo705CharacteristicError(failureBlock);
        return nil;
    }
    fitpolo705WS(weakSelf);
    fitpolo705TaskOperation *operation = [[fitpolo705TaskOperation alloc] initOperationWithID:operationID resetNum:resetNum commandBlock:^{
        [weakSelf sendCommandToPeripheral:commandData characteristic:character];
        [weakSelf writeDataToLog:commandData operation:operationID];
    } completeBlock:^(NSError *error, fitpolo705TaskOperationID operationID, id returnData) {
        if (error) {
            fitpolo705_main_safe(^{
                if (failureBlock) {
                    failureBlock(error);
                }
            });
            return ;
        }
        if (!returnData) {
            fitpolo705RequestPeripheralDataError(failureBlock);
            return ;
        }
        NSString *lev = returnData[fitpolo705DataStatusLev];
        if ([lev isEqualToString:@"1"]) {
            //通用无附加信息的
            NSArray *dataList = (NSArray *)returnData[fitpolo705DataInformation];
            if (!fitpolo705ValidArray(dataList)) {
                fitpolo705RequestPeripheralDataError(failureBlock);
                return;
            }
            NSDictionary *resultDic = @{@"msg":@"success",
                                        @"code":@"1",
                                        @"result":dataList[0],
                                        };
            fitpolo705_main_safe(^{
                if (successBlock) {
                    successBlock(resultDic);
                }
            });
            return;
        }
        //对于有附加信息的
        if (![lev isEqualToString:@"2"]) {
            //
            return;
        }
        NSDictionary *resultDic = @{@"msg":@"success",
                                    @"code":@"1",
                                    @"result":returnData[fitpolo705DataInformation],
                                    };
        fitpolo705_main_safe(^{
            if (successBlock) {
                successBlock(resultDic);
            }
        });
    }];
    return operation;
}


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
             failureBlock:(fitpolo705CommunicationFailedBlock)failureBlock{
    
    fitpolo705TaskOperation *operation = [self generateOperationWithOperationID:operationID
                                                                       resetNum:resetNum
                                                                    commandData:commandData
                                                                 characteristic:characteristic
                                                                   successBlock:successBlock
                                                                   failureBlock:failureBlock];
    if (!operation) {
        return;
    }
    [self.operationManager addOperation:operation];
}

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
                           failureBlock:(fitpolo705CommunicationFailedBlock)failureBlock{
    fitpolo705TaskOperation *operation = [self generateOperationWithOperationID:operationID
                                                                       resetNum:YES
                                                                    commandData:commandData
                                                                 characteristic:characteristic
                                                                   successBlock:successBlock
                                                                   failureBlock:failureBlock];
    SEL selNeedPartOfData = sel_registerName("needPartOfData:");
    if ([operation respondsToSelector:selNeedPartOfData]) {
        ((void (*)(id, SEL, NSNumber*))(void *) objc_msgSend)((id)operation, selNeedPartOfData, @(YES));
    }
    if (!operation) {
        return;
    }
    [self.operationManager addOperation:operation];
}

#pragma mark - Private method

- (BOOL)canSendData{
    if (!self.peripheral) {
        return NO;
    }
    return (self.peripheral.state == CBPeripheralStateConnected);
}

#pragma mark - setter & getter
- (characteristicModel *)characterModel{
    if (!_characterModel) {
        _characterModel = [[characteristicModel alloc] init];
    }
    return _characterModel;
}

- (fitpolo705DataParser *)dataParser{
    if (!_dataParser) {
        _dataParser = [[fitpolo705DataParser alloc] init];
    }
    return _dataParser;
}

- (fitpolo705OperationManager *)operationManager{
    if (!_operationManager) {
        _operationManager = [[fitpolo705OperationManager alloc] init];
    }
    return _operationManager;
}

@end
