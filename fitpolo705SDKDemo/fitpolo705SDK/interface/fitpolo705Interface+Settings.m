//
//  fitpolo705Interface+Settings.m
//  testSDK
//
//  Created by aa on 2018/4/18.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "fitpolo705Interface+Settings.h"
#import "fitpolo705AlarmClockModel.h"
#import "fitpolo705BlockDefine.h"
#import "fitpolo705RegularsDefine.h"
#import "fitpolo705Parser.h"
#import "fitpolo705PeripheralManager.h"
#import "fitpolo705CustomScreenModel.h"
#import "fitpolo705CentralManager.h"

@implementation fitpolo705Interface (Settings)

#pragma mark - /*****************************  设置接口部分  *****************************/

/**
 设置设备闹钟
 
 @param list 闹钟列表，最多8个闹钟。如果list为nil或者个数为0，则认为关闭全部闹钟
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)setAlarmClock:(NSArray <fitpolo705AlarmClockModel *>*)list
             sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
            failBlock:(fitpolo705CommunicationFailedBlock)failedBlock{
    if (!fitpolo705ValidArray(list)) {
        //关闭全部闹钟
        [self setClockTotalNumbersToPeripheral:0 sucBlock:successBlock failBlock:failedBlock];
        return;
    }
    if (list.count > 8) {
        //报错
        fitpolo705_main_safe(^{
            if (failedBlock) {
                NSError *failedError = [[NSError alloc] initWithDomain:fitpolo705CustomErrorDomain
                                                                  code:fitpolo705ParamsError
                                                              userInfo:@{@"errorInfo":@"Most can be set eight clock!"}];
                failedBlock(failedError);
            }
        });
    }
    fitpolo705WS(weakSelf);
    if (list.count <= 4) {
        //一组
        //先发送组数
        [self setClockTotalNumbersToPeripheral:1 sucBlock:^(id returnData) {
            NSArray *tempList = [fitpolo705Parser interceptionOfArray:list subRange:NSMakeRange(0, list.count)];
            [weakSelf setClockDatasToPeripheral:tempList sucBlock:successBlock failBlock:failedBlock];
        } failBlock:failedBlock];
        return;
    }
    //两组
    
    [self setClockTotalNumbersToPeripheral:2 sucBlock:^(id returnData) {
        NSArray *firstList = [fitpolo705Parser interceptionOfArray:list subRange:NSMakeRange(0, 4)];
        [weakSelf setClockDatasToPeripheral:firstList sucBlock:^(id returnData) {
            NSArray *secList = [fitpolo705Parser interceptionOfArray:list subRange:NSMakeRange(4, list.count - 4)];
            [weakSelf setClockDatasToPeripheral:secList sucBlock:successBlock failBlock:failedBlock];
        } failBlock:failedBlock];
    } failBlock:failedBlock];
}

/**
 开启ancs提醒
 
 @param ancsModel ancsModel
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)setANCSNoticeOptions:(fitpolo705AncsModel *)ancsModel
                    sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
                   failBlock:(fitpolo705CommunicationFailedBlock)failedBlock{
    if (!ancsModel) {
        fitpolo705ParamsError(failedBlock);
        return;
    }
    
    NSString *options = [fitpolo705Parser getAncsCommand:ancsModel];
    NSString *commandString = [NSString stringWithFormat:@"%@%@%@",@"b20304",@"0000",options];
    [self initTaskWithTaskID:fitpolo705SetANCSOptionsOperation
               commandString:commandString
                    sucBlock:successBlock
                   failBlock:failedBlock];
}

/**
 设置设备久坐提醒功能
 
 @param isOn YES:打开久坐提醒，NO:关闭久坐提醒,这种状态下，开始时间和结束时间就没有任何意义了
 @param startHour 久坐提醒开始时,0~23
 @param startMinutes 久坐提醒开始分,0~59
 @param endHour 久坐提醒结束时,0~23
 @param endMinutes 久坐提醒结束分,0~59
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)setSedentaryRemind:(BOOL)isOn
                 startHour:(NSInteger)startHour
              startMinutes:(NSInteger)startMinutes
                   endHour:(NSInteger)endHour
                endMinutes:(NSInteger)endMinutes
                  sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
                 failBlock:(fitpolo705CommunicationFailedBlock)failedBlock{
    NSString *tempTime = [fitpolo705Parser getTimeSpaceWithStatus:isOn
                                                        startHour:startHour
                                                     startMinutes:startMinutes
                                                          endHour:endHour
                                                       endMinutes:endMinutes];
    if (!fitpolo705ValidStr(tempTime)) {
        fitpolo705ParamsError(failedBlock);
        return;
    }
    NSString *status = (isOn ? @"01" : @"00");
    NSString *commandString = [NSString stringWithFormat:@"%@%@%@",@"b20405",status,tempTime];
    [self initTaskWithTaskID:fitpolo705SetSedentaryRemindOperation
               commandString:commandString
                    sucBlock:successBlock
                   failBlock:failedBlock];
}

/**
 设置运动目标
 
 @param movingTarget 运动目标1~60000
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)setMovingTarget:(NSInteger)movingTarget
               sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
              failBlock:(fitpolo705CommunicationFailedBlock)failedBlock{
    if (movingTarget < 1 || movingTarget > 60000) {
        fitpolo705ParamsError(failedBlock);
        return;
    }
    NSString *targetHex = [NSString stringWithFormat:@"%1lx",(unsigned long)movingTarget];
    if (targetHex.length == 1) {
        targetHex = [@"000" stringByAppendingString:targetHex];
    }else if (targetHex.length == 2){
        targetHex = [@"00" stringByAppendingString:targetHex];
    }else if (targetHex.length == 3){
        targetHex = [@"0" stringByAppendingString:targetHex];
    }
    NSString *commandString = [@"b20602" stringByAppendingString:targetHex];
    [self initTaskWithTaskID:fitpolo705SetMovingTargetOperation
               commandString:commandString
                    sucBlock:successBlock
                   failBlock:failedBlock];
}

/**
 手环屏幕单位选择
 
 @param unit unit
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)setUnitSwitch:(fitpolo705Unit)unit
             sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
            failBlock:(fitpolo705CommunicationFailedBlock)failedBlock{
    NSString *unitString = (unit == fitpolo705MetricSystem ? @"00" : @"01");
    NSString *commandString = [@"b20701" stringByAppendingString:unitString];
    [self initTaskWithTaskID:fitpolo705SetUnitOperation
               commandString:commandString
                    sucBlock:successBlock
                   failBlock:failedBlock];
}

/**
 设置设备的时间进制
 
 @param timerFormat 24/12进制
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)setTimeFormat:(fitpolo705TimeFormat)timerFormat
             sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
            failBlock:(fitpolo705CommunicationFailedBlock)failedBlock{
    NSString *format = (timerFormat == fitpolo70524Hour ? @"00" : @"01");
    NSString *commandString = [@"b20801" stringByAppendingString:format];
    [self initTaskWithTaskID:fitpolo705SetTimeFormatOperation
               commandString:commandString
                    sucBlock:successBlock
                   failBlock:failedBlock];
}

/**
 设置屏幕显示
 
 @param screenModel  screenModel
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)setCustomScreenDisplay:(fitpolo705CustomScreenModel *)screenModel
                      sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
                     failBlock:(fitpolo705CommunicationFailedBlock)failedBlock{
    if (!screenModel) {
        fitpolo705ParamsError(failedBlock);
        return;
    }
    NSString *commandString1 = [fitpolo705Parser getCustomScreenString:screenModel];
    NSString *commandString = [@"b209040000" stringByAppendingString:commandString1];
    [self initTaskWithTaskID:fitpolo705SetScreenDisplayOperation
               commandString:commandString
                    sucBlock:successBlock
                   failBlock:failedBlock];
}

/**
 设置设备是否记住上一次屏幕显示
 
 @param remind YES:记住，当手环亮屏的时候显示上一次屏幕熄灭时候的屏显。NO:当手环亮屏的时候显示时间屏显
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)setRemindLastScreenDisplay:(BOOL)remind
                          sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
                         failBlock:(fitpolo705CommunicationFailedBlock)failedBlock{
    NSString *status = (remind ? @"01" : @"00");
    NSString *commandString = [@"b20a01" stringByAppendingString:status];
    [self initTaskWithTaskID:fitpolo705RemindLastScreenDisplayOperation
               commandString:commandString
                    sucBlock:successBlock
                   failBlock:failedBlock];
}

/**
 设置心率采集间隔
 
 @param interval 0~30，如果设置为0，则关闭心率采集
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)setHeartRateAcquisitionInterval:(NSInteger)interval
                               sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
                              failBlock:(fitpolo705CommunicationFailedBlock)failedBlock{
    NSString *intervalHex = [NSString stringWithFormat:@"%1lx",(unsigned long)interval];
    if (intervalHex.length == 1) {
        intervalHex = [@"0" stringByAppendingString:intervalHex];
    }
    NSString *commandString = [@"b20b01" stringByAppendingString:intervalHex];
    [self initTaskWithTaskID:fitpolo705SetHeartRateAcquisitionIntervalOperation
               commandString:commandString
                    sucBlock:successBlock
                   failBlock:failedBlock];
}

/**
 设置勿扰时段
 
 @param isOn YES:打开勿扰功能，NO:关闭勿扰功能,这种状态下，开始时间和结束时间就没有任何意义了
 @param startHour 勿扰时段开始时,0~23
 @param startMinutes 勿扰时段开始分,0~59
 @param endHour 勿扰时段结束时,0~23
 @param endMinutes 勿扰时段结束分,0~59
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)setDoNotDisturbTime:(BOOL)isOn
                  startHour:(NSInteger)startHour
               startMinutes:(NSInteger)startMinutes
                    endHour:(NSInteger)endHour
                 endMinutes:(NSInteger)endMinutes
                   sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
                  failBlock:(fitpolo705CommunicationFailedBlock)failedBlock{
    NSString *tempTime = [fitpolo705Parser getTimeSpaceWithStatus:isOn
                                                        startHour:startHour
                                                     startMinutes:startMinutes
                                                          endHour:endHour
                                                       endMinutes:endMinutes];
    if (!fitpolo705ValidStr(tempTime)) {
        fitpolo705ParamsError(failedBlock);
        return;
    }
    NSString *status = (isOn ? @"01" : @"00");
    NSString *commandString = [NSString stringWithFormat:@"%@%@%@",@"b20c05",status,tempTime];
    [self initTaskWithTaskID:fitpolo705SetDoNotDisturbTimeOperation
               commandString:commandString
                    sucBlock:successBlock
                   failBlock:failedBlock];
}

/**
 设置翻腕亮屏的时间段
 
 @param open YES:打开翻腕亮屏，NO:关闭翻腕亮屏,这种状态下，开始时间和结束时间就没有任何意义了
 @param startHour 翻腕亮屏开始时,0~23
 @param startMinutes 翻腕亮屏开始分,0~59
 @param endHour 翻腕亮屏结束时,0~23
 @param endMinutes 翻腕亮屏结束分,0~59
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)setPalmingBrightScreen:(BOOL)open
                     startHour:(NSInteger)startHour
                  startMinutes:(NSInteger)startMinutes
                       endHour:(NSInteger)endHour
                    endMinutes:(NSInteger)endMinutes
                      sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
                     failBlock:(fitpolo705CommunicationFailedBlock)failedBlock{
    NSString *tempTime = [fitpolo705Parser getTimeSpaceWithStatus:open
                                                        startHour:startHour
                                                     startMinutes:startMinutes
                                                          endHour:endHour
                                                       endMinutes:endMinutes];
    if (!fitpolo705ValidStr(tempTime)) {
        fitpolo705ParamsError(failedBlock);
        return;
    }
    NSString *status = (open ? @"01" : @"00");
    NSString *commandString = [NSString stringWithFormat:@"%@%@%@",@"b20d05",status,tempTime];
    [self initTaskWithTaskID:fitpolo705OpenPalmingBrightScreenOperation
               commandString:commandString
                    sucBlock:successBlock
                   failBlock:failedBlock];
}

/**
 设置个人信息给设备
 
 @param weight 用户体重，范围30~150，单位kg
 @param height 用户身高，范围100~200，单位cm
 @param date 用户生日，
 @param gender 用户性别
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)setUserWeight:(NSInteger)weight
               height:(NSInteger)height
          dateOfBirth:(NSDate *)date
               gender:(fitpolo705Gender)gender
             sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
            failBlock:(fitpolo705CommunicationFailedBlock)failedBlock{
    if (weight < 30
        || weight > 150
        || height < 100
        || height > 200
        || !date) {
        //参数错误
        fitpolo705ParamsError(failedBlock);
        return;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentTime = [formatter stringFromDate:[NSDate date]];
    NSString *birthTime = [formatter stringFromDate:date];
    NSArray *currentArr = [currentTime componentsSeparatedByString:@"-"];
    NSArray *birthArr = [birthTime componentsSeparatedByString:@"-"];
    NSInteger age = [currentArr[0] integerValue] - [birthArr[0] integerValue];
    NSString *ageString = [NSString stringWithFormat:@"%1lx",(unsigned long)age];
    if (ageString.length == 1) {
        ageString = [@"0" stringByAppendingString:ageString];
    }
    NSString *heightString = [NSString stringWithFormat:@"%1lx",(unsigned long)height];
    if (heightString.length == 1) {
        heightString = [@"0" stringByAppendingString:heightString];
    }
    NSString *weightString = [NSString stringWithFormat:@"%1lx",(unsigned long)weight];
    if (weightString.length == 1) {
        weightString = [@"0" stringByAppendingString:weightString];
    }
    //步距的计算方法:步长=身高*0.45 ,并且向下取整，程昂修改于2017年6月10号
    NSInteger stepAway = floor(height * 0.45);
    NSString *stepAwayString = [NSString stringWithFormat:@"%1lx",(unsigned long)stepAway];
    if (stepAwayString.length == 1) {
        stepAwayString = [@"0" stringByAppendingString:stepAwayString];
    }
    NSString *genderString = (gender == fitpolo705Male ? @"00" : @"01");
    NSString *month = [NSString stringWithFormat:@"%1lx",(unsigned long)[birthArr[1] integerValue]];
    if (month.length == 1) {
        month = [@"0" stringByAppendingString:month];
    }
    NSString *day = [NSString stringWithFormat:@"%1lx",(unsigned long)[birthArr[2] integerValue]];
    if (day.length == 1) {
        day = [@"0" stringByAppendingString:day];
    }
    NSString *commandString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@",
                               @"b20e07",
                               weightString,
                               heightString,
                               ageString,
                               month,
                               day,
                               genderString,
                               stepAwayString];
    [self initTaskWithTaskID:fitpolo705SetUserInfoOperation
               commandString:commandString
                    sucBlock:successBlock
                   failBlock:failedBlock];
}

/**
 设置设备日期
 
 @param date 日期,2000年~2099年
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)setDate:(NSDate *)date
       sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
      failBlock:(fitpolo705CommunicationFailedBlock)failedBlock{
    if (!date) {
        fitpolo705ParamsError(failedBlock);
        return;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    NSString *dateString = [formatter stringFromDate:date];
    NSArray *dateList = [dateString componentsSeparatedByString:@"-"];
    if (!fitpolo705ValidArray(dateList) || dateList.count != 6) {
        fitpolo705ParamsError(failedBlock);
        return;
    }
    NSInteger year = [dateList[0] integerValue];
    if (year < 2000 || year > 2099) {
        fitpolo705_main_safe(^{
            if (failedBlock) {
                NSError *failedError = [[NSError alloc] initWithDomain:fitpolo705CustomErrorDomain
                                                                  code:fitpolo705ParamsError
                                                              userInfo:@{@"errorInfo":@"Set the date should be between 2000 to 2099"}];
                failedBlock(failedError);
            }
        });
        return;
    }
    NSString *yearString = [NSString stringWithFormat:@"%1lx",(long)(year - 2000)];
    if (yearString.length == 1) {
        yearString = [@"0" stringByAppendingString:yearString];
    }
    for (NSInteger i = 1; i < [dateList count]; i ++) {
        unsigned long tempValue = [dateList[i] integerValue];
        NSString *hexTempStr = [NSString stringWithFormat:@"%1lx",tempValue];
        if (hexTempStr.length == 1) {
            hexTempStr = [@"0" stringByAppendingString:hexTempStr];
        }
        yearString = [yearString stringByAppendingString:hexTempStr];
    }
    NSString *commandString = [@"b20f06" stringByAppendingString:yearString];
    [self initTaskWithTaskID:fitpolo705SetDateOperation
               commandString:commandString
                    sucBlock:successBlock
                   failBlock:failedBlock];
}

/**
 手环震动指令
 
 @param successBlock 成功Block
 @param failedBlock 失败Block
 */
+ (void)peripheralVibration:(fitpolo705CommunicationSuccessBlock)successBlock
                failedBlock:(fitpolo705CommunicationFailedBlock)failedBlock{
    NSString *commandString = @"b21303030a0a";
    [self initTaskWithTaskID:fitpolo705VibrationOperation
               commandString:commandString
                    sucBlock:successBlock
                   failBlock:failedBlock];
}

#pragma mark - Private method
+ (void)initTaskWithTaskID:(fitpolo705TaskOperationID)taskID
             commandString:(NSString *)commandString
                  sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
                 failBlock:(fitpolo705CommunicationFailedBlock)failedBlock{
    fitpolo705PeripheralManager *peripheralManager = [fitpolo705CentralManager sharedInstance].peripheralManager;
    [peripheralManager addTaskWithTaskID:taskID resetNum:NO commandData:commandString characteristic:fitpolo705SetConfigCharacteristic successBlock:^(id returnData) {
        BOOL resultStatus = [returnData[@"result"][@"result"] boolValue];
        if (!resultStatus) {
            fitpolo705SetParamError(failedBlock);
            return ;
        }
        NSDictionary *resultDic = @{@"msg":@"success",
                                    @"code":@"1",
                                    @"result":@{},
                                    };
        fitpolo705_main_safe(^{
            if (successBlock) {
                successBlock(resultDic);
            }
        });
    } failureBlock:failedBlock];
}

/**
 发送闹钟组数
 
 @param numbers 组数，最多2组
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)setClockTotalNumbersToPeripheral:(NSInteger)numbers
                                sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
                               failBlock:(fitpolo705CommunicationFailedBlock)failedBlock{
    if (numbers > 2 || numbers < 0) {
        fitpolo705ParamsError(failedBlock);
        return;
    }
    NSString *numbersHex = [NSString stringWithFormat:@"%1lx",(long)numbers];
    if (numbersHex.length == 1) {
        numbersHex = [@"0" stringByAppendingString:numbersHex];
    }
    NSString *commandString = [@"b20101" stringByAppendingString:numbersHex];
    [self initTaskWithTaskID:fitpolo705SetAlarmClockNumbersOperation
               commandString:commandString
                    sucBlock:successBlock
                   failBlock:failedBlock];
}

/**
 发送闹钟数据
 
 @param list 闹钟该数据，最大4个
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)setClockDatasToPeripheral:(NSArray <fitpolo705AlarmClockModel *>*)list
                         sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
                        failBlock:(fitpolo705CommunicationFailedBlock)failedBlock{
    if (!fitpolo705ValidArray(list)) {
        fitpolo705ParamsError(failedBlock);
        return;
    }
    NSString *clockDatas = @"";
    for (NSInteger i = 0; i < list.count; i ++) {
        fitpolo705AlarmClockModel *clockModel = list[i];
        if (clockModel.hour < 0 || clockModel.hour > 23) {
            fitpolo705ParamsError(failedBlock);
            return;
        }
        if (clockModel.minutes < 0 || clockModel.minutes > 59) {
            fitpolo705ParamsError(failedBlock);
            return;
        }
        NSString *clockType = [fitpolo705Parser getAlarmClockType:clockModel.clockType];
        NSString *clockSetting = [fitpolo705Parser getAlarlClockSetInfo:clockModel.statusModel isOn:clockModel.isOn];
        NSString *hexHour = [NSString stringWithFormat:@"%1lx",(unsigned long)clockModel.hour];
        if (hexHour.length == 1) {
            hexHour = [@"0" stringByAppendingString:hexHour];
        }
        NSString *hexMin = [NSString stringWithFormat:@"%1lx",(unsigned long)clockModel.minutes];
        if (hexMin.length == 1) {
            hexMin = [@"0" stringByAppendingString:hexMin];
        }
        NSString *tempDatas = [NSString stringWithFormat:@"%@%@%@%@",clockType,clockSetting,hexHour,hexMin];
        clockDatas = [clockDatas stringByAppendingString:tempDatas];
    }
    NSString *lenHex = [NSString stringWithFormat:@"%1lx",(unsigned long)(clockDatas.length / 2)];
    if (lenHex.length == 1) {
        lenHex = [@"0" stringByAppendingString:lenHex];
    }
    NSString *commandString = [NSString stringWithFormat:@"%@%@%@",@"b202",lenHex,clockDatas];
    [self initTaskWithTaskID:fitpolo705SetAlarmClockOperation
               commandString:commandString
                    sucBlock:successBlock
                   failBlock:failedBlock];
}

@end
