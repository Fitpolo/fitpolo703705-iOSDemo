//
//  fitpolo705Interface+HeartRate.m
//  testSDK
//
//  Created by aa on 2018/4/18.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "fitpolo705Interface+HeartRate.h"
#import <objc/message.h>
#import "fitpolo705Defines.h"
#import "fitpolo705Parser.h"

@implementation fitpolo705Interface (HeartRate)

/**
 读取心率数据
 
 @param date 要请求的时间点，返回的是该时间点之后的所有心率数据，格式必须为yyyy-MM-dd-HH-mm
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)readHeartRateDataWithDate:(NSDate *)date
                         sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
                        failBlock:(fitpolo705CommunicationFailedBlock)failedBlock{
    NSString *hexTime = [fitpolo705Parser getTimeStringWithDate:date];
    if (!fitpolo705ValidStr(hexTime)) {
        [fitpolo705Parser operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *commandString = [NSString stringWithFormat:@"%@%@",@"b60105",hexTime];
    [self addTask:fitpolo705GetHeartDataOperation
    commandString:commandString
         sucBlock:successBlock
        failBlock:failedBlock];
}

/**
 读取运动心率数据
 
 @param date 要请求的时间点，返回的是该时间点之后的所有运动心率数据，格式必须为yyyy-MM-dd-HH-mm
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)readSportHeartRateDataWithDate:(NSDate *)date
                              sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
                             failBlock:(fitpolo705CommunicationFailedBlock)failedBlock{
    NSString *hexTime = [fitpolo705Parser getTimeStringWithDate:date];
    if (!fitpolo705ValidStr(hexTime)) {
        [fitpolo705Parser operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *commandString = [NSString stringWithFormat:@"%@%@",@"b60405",hexTime];
    [self addTask:fitpolo705GetSportHeartDataOperation
    commandString:commandString
         sucBlock:successBlock
        failBlock:failedBlock];
}

#pragma mark - Private method
+ (void)addTask:(fitpolo705TaskOperationID)operationID
  commandString:(NSString *)commandString
       sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
      failBlock:(fitpolo705CommunicationFailedBlock)failedBlock{
    [[fitpolo705CentralManager sharedInstance] addNeedPartOfDataTaskWithTaskID:operationID
                                                                   commandData:commandString
                                                                characteristic:[fitpolo705CentralManager sharedInstance].connectedPeripheral.heartRate
                                          successBlock:^(id returnData) {
                                              NSArray *dataList = returnData[@"result"];
                                              NSMutableArray *resultList = [NSMutableArray array];
                                              for (NSDictionary *dic in dataList) {
                                                  NSArray *heartList = dic[@"heartList"];
                                                  if (fitpolo705ValidArray(heartList)) {
                                                      [resultList addObjectsFromArray:heartList];
                                                  }
                                              }
                                              NSDictionary *resultDic = @{@"msg":@"success",
                                                                          @"code":@"1",
                                                                          @"result":resultList,
                                                                          };
                                              
                                              fitpolo705_main_safe(^{
                                                  if (successBlock) {
                                                      successBlock(resultDic);
                                                  }
                                              });
                                          }
                                          failureBlock:failedBlock];
}

@end
