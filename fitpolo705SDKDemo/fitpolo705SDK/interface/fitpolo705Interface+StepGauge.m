//
//  fitpolo705Interface+StepGauge.m
//  testSDK
//
//  Created by aa on 2018/4/18.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "fitpolo705Interface+StepGauge.h"
#import <objc/message.h>
#import "fitpolo705PeripheralManager.h"
#import "fitpolo705Parser.h"
#import "fitpolo705OperationManager.h"
#import "fitpolo705CentralManager.h"

@implementation fitpolo705Interface (StepGauge)

/**
 读取计步数据
 
 @param date 要请求的时间点，返回的是该时间点之后的所有计步数据，格式必须为yyyy-MM-dd-HH-mm
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)readStepDataWithDate:(NSDate *)date
                    sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
                   failBlock:(fitpolo705CommunicationFailedBlock)failedBlock{
    NSString *hexTime = [fitpolo705Parser getTimeStringWithDate:date];
    if (!fitpolo705ValidStr(hexTime)) {
        fitpolo705ParamsError(failedBlock);
        return;
    }
    NSString *commandString = [NSString stringWithFormat:@"%@%@",@"b40105",hexTime];
    fitpolo705PeripheralManager *peripheralManager = [fitpolo705CentralManager sharedInstance].peripheralManager;
    [peripheralManager addNeedPartOfDataTaskWithTaskID:fitpolo705GetStepDataOperation
                                           commandData:commandString
                                        characteristic:fitpolo705StepMeterCharacteristic
                                          successBlock:successBlock
                                          failureBlock:failedBlock];
}

@end
