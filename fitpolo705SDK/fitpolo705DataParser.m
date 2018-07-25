//
//  fitpolo705DataParser.m
//  testSDK
//
//  Created by aa on 2018/3/15.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "fitpolo705DataParser.h"
#import "fitpolo705Defines.h"
#import "fitpolo705LogManager.h"
#import "fitpolo705Parser.h"
#import "CBPeripheral+fitpolo705Characteristic.h"
#import "fitpolo705Models.h"

NSString *const fitpolo705CommunicationDataNum = @"fitpolo705CommunicationDataNum";

@implementation fitpolo705DataParser
#pragma mark - Public method
+ (NSDictionary *)parseReadDataFromCharacteristic:(CBCharacteristic *)characteristic{
    if (!characteristic) {
        return nil;
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:readConfigDataUUID]]) {
        //读取参数
        return [self parseReadConfigData:characteristic];
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:setConfigDataUUID]]){
        //设置数据
        return [self parseSetConfigData:characteristic];
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:stepMeterDataUUID]]){
        //计步数据
        return [self parseStepData:characteristic];
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:heartRateDataUUID]]){
        //心率数据
        return [self parseHeartRateData:characteristic];
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:updateNotifyUUID]]){
        //升级监听
        return [self parseUpdateData:characteristic];
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:updateWriteUUID]]){
        //升级写
    }
    return nil;
}



#pragma mark - data process method

+ (NSDictionary *)parseReadConfigData:(CBCharacteristic *)characteristic{
    NSData *readData = characteristic.value;
    NSString *content = [fitpolo705Parser hexStringFromData:readData];
    if (!fitpolo705ValidData(readData) || !fitpolo705ValidStr(content) || content.length < 6) {
        return nil;
    }
    NSString *origData = [NSString stringWithFormat:@"手环返回数据:%@",content];
    [fitpolo705LogManager writeCommandToLocalFile:@[origData] withSourceInfo:fitpolo705DataSourceDevice];
    NSString *header = [content substringWithRange:NSMakeRange(0, 2)];
    if (![header isEqualToString:@"b1"]) {
        //应答帧头b1
        return nil;
    }
    //数据域长度
    NSInteger len = [fitpolo705Parser getDecimalWithHex:content range:NSMakeRange(4, 2)];
    if (content.length - 6 != 2 * len) {
        //长度校验
        return nil;
    }
    NSString *function = [content substringWithRange:NSMakeRange(2, 2)];
    NSDictionary *returnData = nil;
    fitpolo705TaskOperationID operationID = fitpolo705DefaultTaskOperationID;
    if ([function isEqualToString:@"01"] && content.length == 8) {
        //闹钟条数
        returnData = @{
                       fitpolo705CommunicationDataNum:[fitpolo705Parser getDecimalStringWithHex:content range:NSMakeRange(6, 2)]
                       };
        operationID = fitpolo705GetAlarmClockOperation;
    }else if ([function isEqualToString:@"02"]){
        //闹钟详情数据
        NSArray *clockList = [fitpolo705Parser getAlarmClockDataList:[content substringWithRange:NSMakeRange(6, 2 * len)]];
        returnData = @{
                       @"clockList":clockList,
                       };
        operationID = fitpolo705GetAlarmClockOperation;
    }else if ([function isEqualToString:@"03"] && content.length == 14){
        //ancs选项
        fitpolo705AncsModel *ancsModel = [fitpolo705AncsModel fetchAncsOptionsModel:[content substringWithRange:NSMakeRange(10, 4)]];
        returnData = @{
                       @"ancsOptionsModel":ancsModel,
                       };
        operationID = fitpolo705GetAncsOptionsOperation;
    }else if ([function isEqualToString:@"04"] && content.length == 16){
        //久坐提醒数据
        returnData = @{
                       @"sedentaryRemind":[fitpolo705Parser getSedentaryRemindData:[content substringWithRange:NSMakeRange(6, 10)]],
                       };
        operationID = fitpolo705GetSedentaryRemindOperation;
    }else if ([function isEqualToString:@"06"] && content.length == 10){
        //运动目标
        returnData = @{
                       @"movingTarget":[fitpolo705Parser getDecimalStringWithHex:content range:NSMakeRange(6, 4)],
                       };
        operationID = fitpolo705GetMovingTargetOperation;
    }else if ([function isEqualToString:@"07"] && content.length == 8){
        //单位信息
        returnData = @{
                       @"unit":[content substringWithRange:NSMakeRange(6, 2)],
                       };
        operationID = fitpolo705GetUnitDataOperation;
    }else if ([function isEqualToString:@"08"] && content.length == 8){
        //时间进制信息
        returnData = @{
                       @"timeFormat":[content substringWithRange:NSMakeRange(6, 2)],
                       };
        operationID = fitpolo705GetTimeFormatDataOperation;
    }else if ([function isEqualToString:@"09"] && content.length == 14){
        //当前屏幕显示
        fitpolo705CustomScreenModel *screenModel = [fitpolo705CustomScreenModel fetchCustomScreenModel:[content substringWithRange:NSMakeRange(10, 4)]];
        returnData = @{
                       @"customScreenModel":screenModel,
                       };
        operationID = fitpolo705GetCustomScreenDisplayOperation;
    }else if ([function isEqualToString:@"0a"] && content.length == 8){
        //显示上一次屏幕
        BOOL isOn = [[content substringWithRange:NSMakeRange(6, 2)] isEqualToString:@"01"];
        returnData = @{
                       @"isOn":@(isOn),
                       };
        operationID = fitpolo705GetRemindLastScreenDisplayOperation;
    }else if ([function isEqualToString:@"0b"] && content.length == 8){
        //心率采集间隔
        returnData = @{
                       @"heartRateAcquisitionInterval":[fitpolo705Parser getDecimalStringWithHex:content range:NSMakeRange(6, 2)],
                       };
        operationID = fitpolo705GetHeartRateAcquisitionIntervalOperation;
    }else if ([function isEqualToString:@"0c"] && content.length == 16){
        //勿扰时间段
        returnData = @{
                       @"periodTime":[fitpolo705Parser getSedentaryRemindData:[content substringWithRange:NSMakeRange(6, 10)]],
                       };
        operationID = fitpolo705GetDoNotDisturbTimeOperation;
    }else if ([function isEqualToString:@"0d"] && content.length == 16){
        //翻腕亮屏信息
        returnData = @{
                       @"palmingBrightScreen":[fitpolo705Parser getSedentaryRemindData:[content substringWithRange:NSMakeRange(6, 10)]],
                       };
        operationID = fitpolo705GetPalmingBrightScreenOperation;
    }else if ([function isEqualToString:@"0e"] && content.length == 20){
        //个人信息
        returnData = @{
                       @"userInfo":[fitpolo705Parser getUserInfo:[content substringWithRange:NSMakeRange(6, 14)]],
                       };
        operationID = fitpolo705GetUserInfoOperation;
    }else if ([function isEqualToString:@"0f"] && content.length == 8){
        //表盘样式
        returnData = @{
                       @"dialStyle":[content substringWithRange:NSMakeRange(6, 2)],
                       };
        operationID = fitpolo705GetDialStyleOperation;
    }else if ([function isEqualToString:@"10"] && content.length == 22){
        //硬件参数
        returnData = @{
                       @"hardwareParameters":[fitpolo705Parser getHardwareParameters:[content substringWithRange:NSMakeRange(6, 16)]],
                       };
        operationID = fitpolo705GetHardwareParametersOperation;
    }else if ([function isEqualToString:@"11"] && content.length == 18){
        //固件版本号
        returnData = @{
                       @"firmwareVersion":[fitpolo705Parser getFirmwareVersion:[content substringWithRange:NSMakeRange(6, 12)]],
                       };
        operationID = fitpolo705GetFirmwareVersionOperation;
    }else if ([function isEqualToString:@"12"] && content.length == 10){
        //睡眠概况条数
        returnData = @{
                       fitpolo705CommunicationDataNum:[fitpolo705Parser getDecimalStringWithHex:content range:NSMakeRange(6, 4)]
                       };
        operationID = fitpolo705GetSleepIndexOperation;
    }else if ([function isEqualToString:@"13"] && content.length == 40){
        //睡眠概况数据
        returnData = [fitpolo705Parser getSleepIndexData:[content substringWithRange:NSMakeRange(6, 34)]];
        operationID = fitpolo705GetSleepIndexOperation;
    }else if ([function isEqualToString:@"14"] && content.length == 10){
        //睡眠详情条数
        returnData = @{
                       fitpolo705CommunicationDataNum:[fitpolo705Parser getDecimalStringWithHex:content range:NSMakeRange(6, 4)]
                       };
        operationID = fitpolo705GetSleepRecordOperation;
    }else if ([function isEqualToString:@"15"] && content.length >= 8){
        //睡眠详情数据
        returnData = [fitpolo705Parser getSleepRecordData:[content substringWithRange:NSMakeRange(6, content.length - 6)]];
        operationID = fitpolo705GetSleepRecordOperation;
    }else if ([function isEqualToString:@"16"] && content.length == 10){
        //运动数据条数
        returnData = @{
                             fitpolo705CommunicationDataNum:[fitpolo705Parser getDecimalStringWithHex:content range:NSMakeRange(6, 4)],
                             };
        operationID = fitpolo705GetSportsDataOperation;
    }else if ([function isEqualToString:@"17"] && content.length == 40){
        //运动数据
        returnData = [fitpolo705Parser getSportData:[content substringWithRange:NSMakeRange(6, 34)]];
        operationID = fitpolo705GetSportsDataOperation;
    }else if ([function isEqualToString:@"18"] &&  content.length == 16){
        //上一次充电时间
        returnData = @{
                             @"chargingTime":[fitpolo705Parser getLastChargingTime:[content substringWithRange:NSMakeRange(6, 10)]],
                             };
        operationID = fitpolo705GetLastChargingTimeOperation;
    }else if ([function isEqualToString:@"19"] && content.length == 8){
        //电池电量
        returnData = @{
                             @"battery":[fitpolo705Parser getDecimalStringWithHex:content range:NSMakeRange(6, 2)],
                             };
        operationID = fitpolo705GetBatteryOperation;
    }else if ([function isEqualToString:@"1a"] && content.length == 8){
        //手环当前ancs连接状态
        BOOL status = [[content substringWithRange:NSMakeRange(6, 2)] isEqualToString:@"01"];
        returnData = @{
                             @"connectStatus":@(status),
                             };
        operationID = fitpolo705GetANCSConnectStatusOperation;
    }
    return [self dataParserGetDataSuccess:returnData operationID:operationID];
}

+ (NSDictionary *)parseSetConfigData:(CBCharacteristic *)characteristic{
    NSData *readData = characteristic.value;
    NSString *content = [fitpolo705Parser hexStringFromData:readData];
    NSLog(@"%@",content);
    if (!fitpolo705ValidData(readData) || !fitpolo705ValidStr(content) || content.length != 8) {
        return nil;
    }
    NSString *origData = [NSString stringWithFormat:@"手环返回数据:%@",content];
    [fitpolo705LogManager writeCommandToLocalFile:@[origData] withSourceInfo:fitpolo705DataSourceDevice];
    NSString *header = [content substringWithRange:NSMakeRange(0, 2)];
    if (![header isEqualToString:@"b3"]) {
        //应答帧头b3
        return nil;
    }
    NSDictionary *returnData = nil;
    fitpolo705TaskOperationID operationID = fitpolo705DefaultTaskOperationID;
    NSString *function = [content substringWithRange:NSMakeRange(2, 2)];
    if ([function isEqualToString:@"01"]) {
        //设置闹钟组数
        operationID = fitpolo705SetAlarmClockNumbersOperation;
    }else if ([function isEqualToString:@"02"]){
        //设置闹钟数据
        operationID = fitpolo705SetAlarmClockOperation;
    }else if ([function isEqualToString:@"03"]){
        //ancs提醒
        operationID = fitpolo705SetANCSOptionsOperation;
    }else if ([function isEqualToString:@"04"]){
        //久坐提醒
        operationID = fitpolo705SetSedentaryRemindOperation;
    }else if ([function isEqualToString:@"06"]){
        //运动目标
        operationID = fitpolo705SetMovingTargetOperation;
    }else if ([function isEqualToString:@"07"]){
        //单位选择
        operationID = fitpolo705SetUnitOperation;
    }else if ([function isEqualToString:@"08"]){
        //时间进制
        operationID = fitpolo705SetTimeFormatOperation;
    }else if ([function isEqualToString:@"09"]){
        //屏幕显示
        operationID = fitpolo705SetScreenDisplayOperation;
    }else if ([function isEqualToString:@"0a"]){
        //上一次屏幕显示
        operationID = fitpolo705RemindLastScreenDisplayOperation;
    }else if ([function isEqualToString:@"0b"]){
        //心率采集间隔
        operationID = fitpolo705SetHeartRateAcquisitionIntervalOperation;
    }else if ([function isEqualToString:@"0c"]){
        //设置勿扰时段
        operationID = fitpolo705SetDoNotDisturbTimeOperation;
    }else if ([function isEqualToString:@"0d"]){
        //设置翻腕亮屏
        operationID = fitpolo705OpenPalmingBrightScreenOperation;
    }else if ([function isEqualToString:@"0e"]){
        //个人信息
        operationID = fitpolo705SetUserInfoOperation;
    }else if ([function isEqualToString:@"0f"]){
        //设置时间
        operationID = fitpolo705SetDateOperation;
    }else if ([function isEqualToString:@"10"]){
        //设置表盘样式
        operationID = fitpolo705SetDialStyleOperation;
    }else if ([function isEqualToString:@"13"]){
        //震动
        operationID = fitpolo705VibrationOperation;
    }
    BOOL result = ([[content substringWithRange:NSMakeRange(6, 2)] isEqualToString:@"00"]);
    returnData = @{
                   @"result":@(result),
                   };
    return [self dataParserGetDataSuccess:returnData operationID:operationID];
}

+ (NSDictionary *)parseStepData:(CBCharacteristic *)characteristic{
    NSData *readData = characteristic.value;
    NSString *content = [fitpolo705Parser hexStringFromData:readData];
    if (!fitpolo705ValidData(readData) || !fitpolo705ValidStr(content)) {
        return nil;
    }
    NSString *origData = [NSString stringWithFormat:@"手环返回数据:%@",content];
    [fitpolo705LogManager writeCommandToLocalFile:@[origData] withSourceInfo:fitpolo705DataSourceDevice];
    NSString *header = [content substringWithRange:NSMakeRange(0, 2)];
    if (![header isEqualToString:@"b5"]) {
        //应答帧头b5
        return nil;
    }
    //数据域长度
    NSInteger len = [fitpolo705Parser getDecimalWithHex:content range:NSMakeRange(4, 2)];
    if (content.length - 6 != 2 * len) {
        //长度校验
        return nil;
    }
    NSString *function = [content substringWithRange:NSMakeRange(2, 2)];
    NSDictionary *returnData = nil;
    fitpolo705TaskOperationID operationID = fitpolo705DefaultTaskOperationID;
    if ([function isEqualToString:@"01"] && content.length == 10) {
        //计步数据的条数
        returnData = @{
                             fitpolo705CommunicationDataNum:[fitpolo705Parser getDecimalStringWithHex:content range:NSMakeRange(6, 4)]
                             };
        operationID = fitpolo705GetStepDataOperation;
    }else if ([function isEqualToString:@"02"] && content.length == 34){
        //计步详情
        returnData = [fitpolo705Parser getStepDetailData:[content substringWithRange:NSMakeRange(6, 28)]];
        operationID = fitpolo705GetStepDataOperation;
    }else if ([function isEqualToString:@"03"] && content.length == 8){
        //计步监听状态设置
        BOOL result = ([[content substringWithRange:NSMakeRange(6, 2)] isEqualToString:@"00"]);
        returnData = @{
                             @"result":@(result),
                             };
        operationID = fitpolo705StepChangeMeterMonitoringStatusOperation;
    }else if ([function isEqualToString:@"04"] && content.length == 26){
        //手环反馈过来的计步实时数据
        NSDictionary *dataDic = [fitpolo705Parser getListeningStateStepData:[content substringWithRange:NSMakeRange(6, 20)]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"fitpolo705ListeningStateStepDataNotification"
                                                            object:nil
                                                          userInfo:@{@"stepData" : dataDic}];
    }
    return [self dataParserGetDataSuccess:returnData operationID:operationID];
}

+ (NSDictionary *)parseHeartRateData:(CBCharacteristic *)characteristic{
    NSData *readData = characteristic.value;
    NSString *content = [fitpolo705Parser hexStringFromData:readData];
    if (!fitpolo705ValidData(readData) || !fitpolo705ValidStr(content) || content.length < 4) {
        return nil;
    }
    NSString *origData = [NSString stringWithFormat:@"手环返回数据:%@",content];
    [fitpolo705LogManager writeCommandToLocalFile:@[origData] withSourceInfo:fitpolo705DataSourceDevice];
    NSString *header = [content substringWithRange:NSMakeRange(0, 2)];
    if (![header isEqualToString:@"b7"]) {
        //应答帧头b7
        return nil;
    }
    NSString *function = [content substringWithRange:NSMakeRange(2, 2)];
    NSDictionary *returnData = nil;
    fitpolo705TaskOperationID operationID = fitpolo705DefaultTaskOperationID;
    if ([function isEqualToString:@"01"] && content.length == 8) {
        //心率数据的条数
        returnData = @{
                             fitpolo705CommunicationDataNum:[fitpolo705Parser getDecimalStringWithHex:content range:NSMakeRange(4, 4)]
                             };
        operationID = fitpolo705GetHeartDataOperation;
    }else if ([function isEqualToString:@"02"] && content.length >= 16){
        //心率详情
        returnData = [fitpolo705Parser getHeartRateList:[content substringWithRange:NSMakeRange(4, content.length - 4)]];
        operationID = fitpolo705GetHeartDataOperation;
    }else if ([function isEqualToString:@"04"] && content.length == 8){
        //运动心率的条数
        returnData = @{
                             fitpolo705CommunicationDataNum:[fitpolo705Parser getDecimalStringWithHex:content range:NSMakeRange(4, 4)]
                             };
        operationID = fitpolo705GetSportHeartDataOperation;
    }else if ([function isEqualToString:@"05"] && content.length >= 16){
        //运动心率详情
        returnData = [fitpolo705Parser getHeartRateList:[content substringWithRange:NSMakeRange(4, content.length - 4)]];
        operationID = fitpolo705GetSportHeartDataOperation;
    }
    return [self dataParserGetDataSuccess:returnData operationID:operationID];
}

+ (NSDictionary *)parseUpdateData:(CBCharacteristic *)characteristic{
    NSData *readData = characteristic.value;
    NSString *content = [fitpolo705Parser hexStringFromData:readData];
    if (!fitpolo705ValidStr(content) || content.length != 4) {
        return nil;
    }
    NSString *origData = [NSString stringWithFormat:@"手环升级数据:%@",content];
    [fitpolo705LogManager writeCommandToLocalFile:@[origData] withSourceInfo:fitpolo705DataSourceDevice];
    NSString *header = [content substringWithRange:NSMakeRange(0, 2)];
    if ([header isEqualToString:@"96"]) {
        NSString *function = [content substringWithRange:NSMakeRange(2, 2)];
        if ([function isEqualToString:@"28"]) {
            return [self dataParserGetDataSuccess:@{@"result":@(1)} operationID:fitpolo705StartUpdateOperation];
        }
    }
    return nil;
}

#pragma mark - Private method
+ (NSDictionary *)dataParserGetDataSuccess:(NSDictionary *)returnData operationID:(fitpolo705TaskOperationID)operationID{
    if (!returnData) {
        return nil;
    }
    return @{@"returnData":returnData,@"operationID":@(operationID)};
}

@end
