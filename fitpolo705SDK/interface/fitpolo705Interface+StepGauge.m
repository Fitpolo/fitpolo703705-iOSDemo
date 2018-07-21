//
//  fitpolo705Interface+StepGauge.m
//  testSDK
//
//  Created by aa on 2018/4/18.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "fitpolo705Interface+StepGauge.h"
#import <objc/message.h>
#import "fitpolo705Parser.h"
#import "fitpolo705Defines.h"

//在手环打开监听计步数据的情况下，手环反馈回来的实时计步数据通知
NSString *const fitpolo705ListeningStateStepDataNotification = @"fitpolo705ListeningStateStepDataNotification";

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
        [fitpolo705Parser operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *commandString = [NSString stringWithFormat:@"%@%@",@"b40105",hexTime];
    [[fitpolo705CentralManager sharedInstance] addNeedPartOfDataTaskWithTaskID:fitpolo705GetStepDataOperation
                                                                   commandData:commandString
                                                                characteristic:[fitpolo705CentralManager sharedInstance].connectedPeripheral.stepData
                                                                  successBlock:successBlock
                                                                  failureBlock:failedBlock];
}

/**
 改变计步监测状态,打开监听状态之后，注册fitpolo705ListeningStateStepDataNotification通知，当手环步数发生改变的时候，会把当前的步数反馈给app
 
 @param open YES:open, NO:close
 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)stepChangeMeterMonitoringStatus:(BOOL)open
                               sucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                              failBlock:(fitpolo705CommunicationFailedBlock)failBlock{
    NSString *commandString = (open ? @"b4030101" : @"b4030100");
    [[fitpolo705CentralManager sharedInstance] addTaskWithTaskID:fitpolo705StepChangeMeterMonitoringStatusOperation
                                                        resetNum:NO
                                                     commandData:commandString
                                                  characteristic:[fitpolo705CentralManager sharedInstance].connectedPeripheral.stepData
                                                    successBlock:^(id returnData) {
        [fitpolo705Parser operationSetParamsResult:returnData sucBlock:sucBlock failedBlock:failBlock];
    }
                            failureBlock:failBlock];
}

@end
