//
//  fitpolo705Interface.m
//  testSDK
//
//  Created by aa on 2018/4/18.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "fitpolo705Interface.h"
#import <objc/message.h>
#import "fitpolo705TaskOperation.h"
#import "fitpolo705Defines.h"
#import "fitpolo705Parser.h"

typedef NS_ENUM(NSInteger, fitpolo705RequestDataWithTimeStamp) {
    fitpolo705RequestSleepIndexDataWithTimeStamp,   //时间戳请求睡眠index数据
    fitpolo705RequestSleepRecordDataWithTimeStamp,  //时间戳请求睡眠record数据
    fitpolo705RequestSportsDataWithTimeStamp,       //时间戳请求运动数据
};

@implementation fitpolo705Interface

#pragma mark - /***********************************读取类接口,特征FFB0********************************/

/**
 获取手环的闹钟数据,返回的是fitpolo705AlarmClockModel类型的数组
 
 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)readPeripheralAlarmClockDatasWithSucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                                        failBlock:(fitpolo705CommunicationFailedBlock)failBlock{
    NSString *commandString = @"b00100";
    [self addTaskWithTaskID:fitpolo705GetAlarmClockOperation resetNum:YES commandString:commandString sucBlock:^(id returnData) {
        NSArray *list = returnData[@"result"];
        if (!list) {
            [fitpolo705Parser operationRequestDataErrorBlock:failBlock];
            return ;
        }
        NSMutableArray *resultList = [NSMutableArray array];
        for (NSDictionary *dic in list) {
            NSArray *tempList = dic[@"clockList"];
            if (fitpolo705ValidArray(tempList)) {
                [resultList addObjectsFromArray:tempList];
            }
        }
        NSDictionary *resultDic = @{@"msg":@"success",
                                    @"code":@"1",
                                    @"result":resultList,
                                    };
        fitpolo705_main_safe(^{
            if (sucBlock) {
                sucBlock(resultDic);
            }
        });
    } failBlock:failBlock];
}

/**
 获取手环的ancs选项
 
 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)readPeripheralAncsOptionsWithSucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                                    failBlock:(fitpolo705CommunicationFailedBlock)failBlock{
    NSString *commandString = @"b00300";
    [self addTaskWithTaskID:fitpolo705GetAncsOptionsOperation
                   resetNum:NO
              commandString:commandString
                   sucBlock:sucBlock
                  failBlock:failBlock];
}

/**
 获取手环的久坐提醒数据
 
 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)readPeripheralSedentaryRemindDataWithSucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                                            failBlock:(fitpolo705CommunicationFailedBlock)failBlock{
    NSString *commandString = @"b00400";
    [self addTaskWithTaskID:fitpolo705GetSedentaryRemindOperation
                   resetNum:NO
              commandString:commandString
                   sucBlock:sucBlock
                  failBlock:failBlock];
}

/**
 获取手环的运动目标数据
 
 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)readPeripheralMovingTargetWithSucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                                     failBlock:(fitpolo705CommunicationFailedBlock)failBlock{
    NSString *commandString = @"b00600";
    [self addTaskWithTaskID:fitpolo705GetMovingTargetOperation
                   resetNum:NO
              commandString:commandString
                   sucBlock:sucBlock
                  failBlock:failBlock];
}

/**
 获取手环单位信息,@"00":公制,@"01":英制
 
 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)readPeripheralUnitDataWithSucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                                 failBlock:(fitpolo705CommunicationFailedBlock)failBlock{
    NSString *commandString = @"b00700";
    [self addTaskWithTaskID:fitpolo705GetUnitDataOperation
                   resetNum:NO
              commandString:commandString
                   sucBlock:sucBlock
                  failBlock:failBlock];
}

/**
 获取手环时间进制，@"00":24h,@"01":12h
 
 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)readPeripheralTimeFormatDataWithSucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                                       failBlock:(fitpolo705CommunicationFailedBlock)failBlock{
    NSString *commandString = @"b00800";
    [self addTaskWithTaskID:fitpolo705GetTimeFormatDataOperation
                   resetNum:NO
              commandString:commandString
                   sucBlock:sucBlock
                  failBlock:failBlock];
}

/**
 读取当前手环显示的屏幕信息
 
 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)readPeripheralCustomScreenDisplayWithSucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                                            failBlock:(fitpolo705CommunicationFailedBlock)failBlock{
    NSString *commandString = @"b00900";
    [self addTaskWithTaskID:fitpolo705GetCustomScreenDisplayOperation
                   resetNum:NO
              commandString:commandString
                   sucBlock:sucBlock
                  failBlock:failBlock];
}

/**
 获取手环是否显示上一次屏幕
 
 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)readPeripheralRemindLastScreenDisplayWithSucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                                                failBlock:(fitpolo705CommunicationFailedBlock)failBlock{
    NSString *commandString = @"b00a00";
    [self addTaskWithTaskID:fitpolo705GetRemindLastScreenDisplayOperation
                   resetNum:NO
              commandString:commandString
                   sucBlock:sucBlock
                  failBlock:failBlock];
}

/**
 获取手环心率采集间隔,单位分钟
 
 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)readPeripheralHeartRateAcquisitionIntervalWithSucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                                                     failBlock:(fitpolo705CommunicationFailedBlock)failBlock{
    NSString *commandString = @"b00b00";
    [self addTaskWithTaskID:fitpolo705GetHeartRateAcquisitionIntervalOperation
                   resetNum:NO
              commandString:commandString
                   sucBlock:sucBlock
                  failBlock:failBlock];
}

/**
 获取手环勿扰时间段
 
 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)readPeripheralDoNotDisturbTimeWithSucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                                         failBlock:(fitpolo705CommunicationFailedBlock)failBlock{
    NSString *commandString = @"b00c00";
    [self addTaskWithTaskID:fitpolo705GetDoNotDisturbTimeOperation
                   resetNum:NO
              commandString:commandString
                   sucBlock:sucBlock
                  failBlock:failBlock];
}

/**
 获取翻腕亮屏
 
 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)readPeripheralPalmingBrightScreenWithSucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                                            failBlock:(fitpolo705CommunicationFailedBlock)failBlock{
    NSString *commandString = @"b00d00";
    [self addTaskWithTaskID:fitpolo705GetPalmingBrightScreenOperation
                   resetNum:NO
              commandString:commandString
                   sucBlock:sucBlock
                  failBlock:failBlock];
}

/**
 获取手环里面设置的个人信息
 {
 @"weight":50,  //体重，单位KG
 @"height":175, //身高，单位cm
 @"age":age,    //年龄
 @"gender":00,  //性别，@"00":male,@"01":female
 @"stepDistance":24,//步幅,单位cm
 };
 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)readPeripheralUserInfoWithSucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                                 failBlock:(fitpolo705CommunicationFailedBlock)failBlock{
    NSString *commandString = @"b00e00";
    [self addTaskWithTaskID:fitpolo705GetUserInfoOperation
                   resetNum:NO
              commandString:commandString
                   sucBlock:sucBlock
                  failBlock:failBlock];
}

/**
 获取手环表盘样式

 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)readPeripheralDialStyleWithSucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                                  failBlock:(fitpolo705CommunicationFailedBlock)failBlock{
    NSString *commandString = @"b00f00";
    [self addTaskWithTaskID:fitpolo705GetDialStyleOperation
                   resetNum:NO
              commandString:commandString
                   sucBlock:sucBlock
                  failBlock:failBlock];
}

/**
 获取手环硬件参数
 
 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)readPeripheralHardwareParametersWithSucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                                           failBlock:(fitpolo705CommunicationFailedBlock)failBlock{
    NSString *commandString = @"b01000";
    [self addTaskWithTaskID:fitpolo705GetHardwareParametersOperation
                   resetNum:NO
              commandString:commandString
                   sucBlock:sucBlock
                  failBlock:failBlock];
}

/**
 获取手环固件版本号
 
 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)readPeripheralFirmwareVersionWithSucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                                        failBlock:(fitpolo705CommunicationFailedBlock)failBlock{
    NSString *commandString = @"b01100";
    [self addTaskWithTaskID:fitpolo705GetFirmwareVersionOperation
                   resetNum:NO
              commandString:commandString
                   sucBlock:sucBlock
                  failBlock:failBlock];
}

/**
 请求睡眠数据
 
 @param date 要请求的时间点，返回的是该时间点之后的所有睡眠数据，格式必须为yyyy-MM-dd-HH-mm
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)readPeripheralSleepDataWithDate:(NSDate *)date
                               sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
                              failBlock:(fitpolo705CommunicationFailedBlock)failedBlock{
    fitpolo705WS(weakSelf);
    [self requestPeripheralDataWithDate:date dataType:fitpolo705RequestSleepIndexDataWithTimeStamp sucBlock:^(id sleepIndexData) {
        NSArray *indexList = sleepIndexData[@"result"];
        if (!indexList) {
            [fitpolo705Parser operationRequestDataErrorBlock:failedBlock];
            return;
        }
        if (indexList.count == 0) {
            NSDictionary *resultDic = @{@"msg":@"success",
                                        @"code":@"1",
                                        @"result":@[],
                                        };
            fitpolo705_main_safe(^{
                if (successBlock) {
                    successBlock(resultDic);
                }
            });
            return;
        }
        [weakSelf requestPeripheralDataWithDate:date dataType:fitpolo705RequestSleepRecordDataWithTimeStamp sucBlock:^(id sleepRecordData) {
            NSArray *recordList = sleepRecordData[@"result"];
            if (!fitpolo705ValidArray(recordList)) {
                [fitpolo705Parser operationRequestDataErrorBlock:failedBlock];
                return;
            }
            NSArray *sleepList = [fitpolo705Parser getSleepDataList:indexList recordList:recordList];
            if (!fitpolo705ValidArray(sleepList)) {
                [fitpolo705Parser operationRequestDataErrorBlock:failedBlock];
                return;
            }
            NSDictionary *resultDic = @{@"msg":@"success",
                                        @"code":@"1",
                                        @"result":sleepList,
                                        };
            fitpolo705_main_safe(^{
                if (successBlock) {
                    successBlock(resultDic);
                }
            });
        } failBlock:failedBlock];
    } failBlock:failedBlock];
}

/**
 请求运动数据
 
 @param date 要请求的时间点，返回的是该时间点之后的所有运动数据，格式必须为yyyy-MM-dd-HH-mm
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)readPeripheralSportDataWithDate:(NSDate *)date
                               sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
                              failBlock:(fitpolo705CommunicationFailedBlock)failedBlock{
    [self requestPeripheralDataWithDate:date
                               dataType:fitpolo705RequestSportsDataWithTimeStamp
                               sucBlock:successBlock
                              failBlock:failedBlock];
}

/**
 获取手环上一次充电时间
 
 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)readPeripheralLastChargingTimeWithSucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                                         failBlock:(fitpolo705CommunicationFailedBlock)failBlock{
    NSString *commandString = @"b01800";
    [self addTaskWithTaskID:fitpolo705GetLastChargingTimeOperation
                   resetNum:NO
              commandString:commandString
                   sucBlock:sucBlock
                  failBlock:failBlock];
}

/**
 获取手环电量
 
 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)readPeripheralBatteryWithSucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                                failBlock:(fitpolo705CommunicationFailedBlock)failBlock{
    NSString *commandString = @"b01900";
    [self addTaskWithTaskID:fitpolo705GetBatteryOperation
                   resetNum:NO
              commandString:commandString
                   sucBlock:sucBlock
                  failBlock:failBlock];
}

/**
 获取手环当前ancs连接状态

 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)readPeripheralANCSConnectStatusWithSucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                                          failBlock:(fitpolo705CommunicationFailedBlock)failBlock{
    NSString *commandString = @"b01a00";
    [self addTaskWithTaskID:fitpolo705GetANCSConnectStatusOperation
                   resetNum:NO
              commandString:commandString
                   sucBlock:sucBlock
                  failBlock:failBlock];
}

#pragma mark - private method

+ (void)addTaskWithTaskID:(fitpolo705TaskOperationID)taskID
                 resetNum:(BOOL)resetNum
            commandString:(NSString *)commandString
                 sucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                failBlock:(fitpolo705CommunicationFailedBlock)failBlock{
    [[fitpolo705CentralManager sharedInstance] addTaskWithTaskID:taskID
                                                        resetNum:resetNum
                                                     commandData:commandString
                                                  characteristic:[fitpolo705CentralManager sharedInstance].connectedPeripheral.readData
                                                    successBlock:sucBlock
                                                    failureBlock:failBlock];
}

+ (void)requestPeripheralDataWithDate:(NSDate *)date
                             dataType:(fitpolo705RequestDataWithTimeStamp)dataType
                             sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
                            failBlock:(fitpolo705CommunicationFailedBlock)failedBlock{
    NSString *hexTime = [fitpolo705Parser getTimeStringWithDate:date];
    if (!fitpolo705ValidStr(hexTime)) {
        [fitpolo705Parser operationParamsErrorBlock:failedBlock];
        return;
    }
    //默认是睡眠概况
    NSString *function = @"12";
    fitpolo705TaskOperationID operationID = fitpolo705GetSleepIndexOperation;
    if (dataType == fitpolo705RequestSleepRecordDataWithTimeStamp) {
        //睡眠详情
        function = @"14";
        operationID = fitpolo705GetSleepRecordOperation;
    }else if (dataType == fitpolo705RequestSportsDataWithTimeStamp){
        //运动数据
        function = @"16";
        operationID = fitpolo705GetSportsDataOperation;
    }
    NSString *commandString = [NSString stringWithFormat:@"%@%@%@%@",@"b0",function,@"05",hexTime];
    [[fitpolo705CentralManager sharedInstance] addNeedPartOfDataTaskWithTaskID:operationID
                                                                   commandData:commandString
                                                                characteristic:[fitpolo705CentralManager sharedInstance].connectedPeripheral.readData
                                                                  successBlock:successBlock
                                                                  failureBlock:failedBlock];
}

@end
