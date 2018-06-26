//
//  fitpolo705Interface+FirmwareUpdate.m
//  testSDK
//
//  Created by aa on 2018/4/18.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "fitpolo705Interface+FirmwareUpdate.h"
#import "fitpolo705RegularsDefine.h"
#import "fitpolo705Parser.h"
#import "fitpolo705CentralManager.h"
#import "fitpolo705OperationManager.h"
#import "fitpolo705PeripheralManager.h"

@implementation fitpolo705Interface (FirmwareUpdate)

/**
 手环开启升级固件
 
 @param crcData 本地升级的校验码，两个字节，将本地的固件做crc16得出来的
 @param packageSize 本次升级的固件大小，4个字节
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)peripheralStartUpdateWithCrcData:(NSData *)crcData
                             packageSize:(NSData *)packageSize
                            successBlock:(fitpolo705CommunicationSuccessBlock)successBlock
                             failedBlock:(fitpolo705CommunicationFailedBlock)failedBlock{
    if (!fitpolo705ValidData(crcData) || !fitpolo705ValidData(packageSize)) {
        fitpolo705ParamsError(failedBlock);
        return;
    }
    NSData *headerData = [fitpolo705Parser stringToData:@"28"];
    NSMutableData *commandData = [NSMutableData dataWithData:headerData];
    [commandData appendData:crcData];
    [commandData appendData:packageSize];
    NSString *commandString = [fitpolo705Parser hexStringFromData:commandData];
    fitpolo705PeripheralManager *peripheralManager = [fitpolo705CentralManager sharedInstance].peripheralManager;
    fitpolo705TaskOperation *operation = [peripheralManager generateOperationWithOperationID:fitpolo705StartUpdateOperation resetNum:NO commandData:commandString characteristic:fitpolo705UpdateWriteCharacteristic successBlock:successBlock failureBlock:failedBlock];
    if (!operation) {
        return;
    }
    operation.receiveTimeout = 5.f;
    [peripheralManager.operationManager addOperation:operation];
}

@end
