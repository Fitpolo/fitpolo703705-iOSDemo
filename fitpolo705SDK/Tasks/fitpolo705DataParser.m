//
//  fitpolo705DataParser.m
//  testSDK
//
//  Created by aa on 2018/3/15.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "fitpolo705DataParser.h"
#import "fitpolo705RegularsDefine.h"
#import "fitpolo705LogManager.h"
#import "fitpolo705Parser.h"
#import "fitpolo705ConstDefines.h"
#import "fitpolo705ServiceDefines.h"
#import "fitpolo705AncsModel.h"
#import "fitpolo705CustomScreenModel.h"

NSString *const fitpolo705CommunicationDataNum = @"fitpolo705CommunicationDataNum";

@implementation fitpolo705ParseResultModel

@end

@implementation fitpolo705DataParser

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"数据解析中心销毁");
}
#pragma mark - Public method
- (void)parseReadDataFromCharacteristic:(CBCharacteristic *)characteristic{
    if (!characteristic) {
        return;
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:readConfigDataUUID]]) {
        //读取参数
        [self parseReadConfigData:characteristic];
    }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:setConfigDataUUID]]){
        //设置数据
        [self parseSetConfigData:characteristic];
    }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:stepMeterDataUUID]]){
        //计步数据
        [self parseStepData:characteristic];
    }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:heartRateDataUUID]]){
        //心率数据
        [self parseHeartRateData:characteristic];
    }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:updateWriteUUID]]){
        //升级写
    }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:updateNotifyUUID]]){
        //升级监听
        [self parseUpdateData:characteristic];
    }
}



#pragma mark - data process method

- (void)parseReadConfigData:(CBCharacteristic *)characteristic{
    NSData *readData = characteristic.value;
    NSString *content = [fitpolo705Parser hexStringFromData:readData];
    if (!fitpolo705ValidData(readData) || !fitpolo705ValidStr(content) || content.length < 6) {
        return;
    }
    NSString *origData = [NSString stringWithFormat:@"手环返回数据:%@",content];
    [fitpolo705LogManager writeCommandToLocalFile:@[origData] withSourceInfo:fitpolo705DataSourceDevice];
    NSString *header = [content substringWithRange:NSMakeRange(0, 2)];
    if (![header isEqualToString:@"b1"]) {
        //应答帧头b1
        return;
    }
    //数据域长度
    NSInteger len = [fitpolo705Parser getDecimalWithHex:content range:NSMakeRange(4, 2)];
    if (content.length - 6 != 2 * len) {
        //长度校验
        return;
    }
    fitpolo705ParseResultModel *model = [[fitpolo705ParseResultModel alloc] init];
    NSString *function = [content substringWithRange:NSMakeRange(2, 2)];
    if ([function isEqualToString:@"01"] && content.length == 8) {
        //闹钟条数
        
        model.returnData = @{
                             fitpolo705CommunicationDataNum:[fitpolo705Parser getDecimalStringWithHex:content range:NSMakeRange(6, 2)]
                             };
        model.operationID = fitpolo705GetAlarmClockOperation;
    }else if ([function isEqualToString:@"02"]){
        //闹钟详情数据
        NSArray *clockList = [fitpolo705Parser getAlarmClockDataList:[content substringWithRange:NSMakeRange(6, 2 * len)]];
        model.returnData = @{
                             @"clockList":clockList,
                             };
        model.operationID = fitpolo705GetAlarmClockOperation;
    }else if ([function isEqualToString:@"03"] && content.length == 14){
        //ancs选项
        fitpolo705AncsModel *ancsModel = [fitpolo705Parser getAncsOptionsModel:[content substringWithRange:NSMakeRange(10, 4)]];
        model.returnData = @{
                                @"ancsOptionsModel":ancsModel,
                             };
        model.operationID = fitpolo705GetAncsOptionsOperation;
    }else if ([function isEqualToString:@"04"] && content.length == 16){
        //久坐提醒数据
        model.returnData = @{
                                @"sedentaryRemind":[fitpolo705Parser getSedentaryRemindData:[content substringWithRange:NSMakeRange(6, 10)]],
                             };
        model.operationID = fitpolo705GetSedentaryRemindOperation;
    }else if ([function isEqualToString:@"06"] && content.length == 10){
        //运动目标
        model.returnData = @{
                             @"movingTarget":[fitpolo705Parser getDecimalStringWithHex:content range:NSMakeRange(6, 4)],
                             };
        model.operationID = fitpolo705GetMovingTargetOperation;
    }else if ([function isEqualToString:@"07"] && content.length == 8){
        //单位信息
        model.returnData = @{
                             @"unit":[content substringWithRange:NSMakeRange(6, 2)],
                             };
        model.operationID = fitpolo705GetUnitDataOperation;
    }else if ([function isEqualToString:@"08"] && content.length == 8){
        //时间进制信息
        model.returnData = @{
                             @"timeFormat":[content substringWithRange:NSMakeRange(6, 2)],
                             };
        model.operationID = fitpolo705GetTimeFormatDataOperation;
    }else if ([function isEqualToString:@"09"] && content.length == 14){
        //当前屏幕显示
        fitpolo705CustomScreenModel *screenModel = [fitpolo705Parser getCustomScreenModel:[content substringWithRange:NSMakeRange(10, 4)]];
        model.returnData = @{
                             @"customScreenModel":screenModel,
                             };
        model.operationID = fitpolo705GetCustomScreenDisplayOperation;
    }else if ([function isEqualToString:@"0a"] && content.length == 8){
        //显示上一次屏幕
        BOOL isOn = [[content substringWithRange:NSMakeRange(6, 2)] isEqualToString:@"01"];
        model.returnData = @{
                             @"isOn":@(isOn),
                             };
        model.operationID = fitpolo705GetRemindLastScreenDisplayOperation;
    }else if ([function isEqualToString:@"0b"] && content.length == 8){
        //心率采集间隔
        model.returnData = @{
                             @"heartRateAcquisitionInterval":[fitpolo705Parser getDecimalStringWithHex:content range:NSMakeRange(6, 2)],
                             };
        model.operationID = fitpolo705GetHeartRateAcquisitionIntervalOperation;
    }else if ([function isEqualToString:@"0c"] && content.length == 16){
        //勿扰时间段
        model.returnData = @{
                             @"periodTime":[fitpolo705Parser getSedentaryRemindData:[content substringWithRange:NSMakeRange(6, 10)]],
                             };
        model.operationID = fitpolo705GetDoNotDisturbTimeOperation;
    }else if ([function isEqualToString:@"0d"] && content.length == 16){
        //翻腕亮屏信息
        model.returnData = @{
                             @"palmingBrightScreen":[fitpolo705Parser getSedentaryRemindData:[content substringWithRange:NSMakeRange(6, 10)]],
                             };
        model.operationID = fitpolo705GetPalmingBrightScreenOperation;
    }else if ([function isEqualToString:@"0e"] && content.length == 20){
        //个人信息
        model.returnData = @{
                             @"userInfo":[fitpolo705Parser getUserInfo:[content substringWithRange:NSMakeRange(6, 14)]],
                             };
        model.operationID = fitpolo705GetUserInfoOperation;
    }else if ([function isEqualToString:@"10"] && content.length == 22){
        //硬件参数
        model.returnData = @{
                             @"hardwareParameters":[fitpolo705Parser getHardwareParameters:[content substringWithRange:NSMakeRange(6, 16)]],
                             };
        model.operationID = fitpolo705GetHardwareParametersOperation;
    }else if ([function isEqualToString:@"11"] && content.length == 18){
        //固件版本号
        model.returnData = @{
                             @"firmwareVersion":[fitpolo705Parser getFirmwareVersion:[content substringWithRange:NSMakeRange(6, 12)]],
                             };
        model.operationID = fitpolo705GetFirmwareVersionOperation;
    }else if ([function isEqualToString:@"12"] && content.length == 10){
        //睡眠概况条数
        model.returnData = @{
                             fitpolo705CommunicationDataNum:[fitpolo705Parser getDecimalStringWithHex:content range:NSMakeRange(6, 4)]
                             };
        model.operationID = fitpolo705GetSleepIndexOperation;
    }else if ([function isEqualToString:@"13"] && content.length == 40){
        //睡眠概况数据
        model.returnData = [fitpolo705Parser getSleepIndexData:[content substringWithRange:NSMakeRange(6, 34)]];
        model.operationID = fitpolo705GetSleepIndexOperation;
    }else if ([function isEqualToString:@"14"] && content.length == 10){
        //睡眠详情条数
        model.returnData = @{
                             fitpolo705CommunicationDataNum:[fitpolo705Parser getDecimalStringWithHex:content range:NSMakeRange(6, 4)]
                             };
        model.operationID = fitpolo705GetSleepRecordOperation;
    }else if ([function isEqualToString:@"15"] && content.length >= 8){
        //睡眠详情数据
        model.returnData = [fitpolo705Parser getSleepRecordData:[content substringWithRange:NSMakeRange(6, content.length - 6)]];
        model.operationID = fitpolo705GetSleepRecordOperation;
    }else if ([function isEqualToString:@"16"] && content.length == 10){
        //运动数据条数
        model.returnData = @{
                             fitpolo705CommunicationDataNum:[fitpolo705Parser getDecimalStringWithHex:content range:NSMakeRange(6, 4)],
                             };
        model.operationID = fitpolo705GetSportsDataOperation;
    }else if ([function isEqualToString:@"17"] && content.length == 40){
        //运动数据
        model.returnData = [fitpolo705Parser getSportData:[content substringWithRange:NSMakeRange(6, 34)]];
        model.operationID = fitpolo705GetSportsDataOperation;
    }else if ([function isEqualToString:@"18"] &&  content.length == 16){
        //上一次充电时间
        model.returnData = @{
                             @"chargingTime":[fitpolo705Parser getLastChargingTime:[content substringWithRange:NSMakeRange(6, 10)]],
                             };
        model.operationID = fitpolo705GetLastChargingTimeOperation;
    }else if ([function isEqualToString:@"19"] && content.length == 8){
        //电池电量
        model.returnData = @{
                             @"battery":[fitpolo705Parser getDecimalStringWithHex:content range:NSMakeRange(6, 2)],
                             };
        model.operationID = fitpolo705GetBatteryOperation;
    }else if ([function isEqualToString:@"1a"] && content.length == 8){
        //手环当前ancs连接状态
        BOOL status = [[content substringWithRange:NSMakeRange(6, 2)] isEqualToString:@"01"];
        model.returnData = @{
                             @"connectStatus":@(status),
                             };
        model.operationID = fitpolo705GetANCSConnectStatusOperation;
    }
    [self addDataToList:model];
}

- (void)parseSetConfigData:(CBCharacteristic *)characteristic{
    NSData *readData = characteristic.value;
    NSString *content = [fitpolo705Parser hexStringFromData:readData];
    NSLog(@"%@",content);
    if (!fitpolo705ValidData(readData) || !fitpolo705ValidStr(content) || content.length != 8) {
        return;
    }
    NSString *origData = [NSString stringWithFormat:@"手环返回数据:%@",content];
    [fitpolo705LogManager writeCommandToLocalFile:@[origData] withSourceInfo:fitpolo705DataSourceDevice];
    NSString *header = [content substringWithRange:NSMakeRange(0, 2)];
    if (![header isEqualToString:@"b3"]) {
        //应答帧头b3
        return;
    }
    fitpolo705ParseResultModel *model = [[fitpolo705ParseResultModel alloc] init];
    NSString *function = [content substringWithRange:NSMakeRange(2, 2)];
    if ([function isEqualToString:@"01"]) {
        //设置闹钟组数
        model.operationID = fitpolo705SetAlarmClockNumbersOperation;
    }else if ([function isEqualToString:@"02"]){
        //设置闹钟数据
        model.operationID = fitpolo705SetAlarmClockOperation;
    }else if ([function isEqualToString:@"03"]){
        //ancs提醒
        model.operationID = fitpolo705SetANCSOptionsOperation;
    }else if ([function isEqualToString:@"04"]){
        //久坐提醒
        model.operationID = fitpolo705SetSedentaryRemindOperation;
    }else if ([function isEqualToString:@"06"]){
        //运动目标
        model.operationID = fitpolo705SetMovingTargetOperation;
    }else if ([function isEqualToString:@"07"]){
        //单位选择
        model.operationID = fitpolo705SetUnitOperation;
    }else if ([function isEqualToString:@"08"]){
        //时间进制
        model.operationID = fitpolo705SetTimeFormatOperation;
    }else if ([function isEqualToString:@"09"]){
        //屏幕显示
        model.operationID = fitpolo705SetScreenDisplayOperation;
    }else if ([function isEqualToString:@"0a"]){
        //上一次屏幕显示
        model.operationID = fitpolo705RemindLastScreenDisplayOperation;
    }else if ([function isEqualToString:@"0b"]){
        //心率采集间隔
        model.operationID = fitpolo705SetHeartRateAcquisitionIntervalOperation;
    }else if ([function isEqualToString:@"0c"]){
        //设置勿扰时段
        model.operationID = fitpolo705SetDoNotDisturbTimeOperation;
    }else if ([function isEqualToString:@"0d"]){
        //设置翻腕亮屏
        model.operationID = fitpolo705OpenPalmingBrightScreenOperation;
    }else if ([function isEqualToString:@"0e"]){
        //个人信息
        model.operationID = fitpolo705SetUserInfoOperation;
    }else if ([function isEqualToString:@"0f"]){
        //设置时间
        model.operationID = fitpolo705SetDateOperation;
    }else if ([function isEqualToString:@"13"]){
        //震动
        model.operationID = fitpolo705VibrationOperation;
    }
    BOOL result = ([[content substringWithRange:NSMakeRange(6, 2)] isEqualToString:@"00"]);
    model.returnData = @{
                         @"result":@(result),
                         };
    [self addDataToList:model];
}

- (void)parseStepData:(CBCharacteristic *)characteristic{
    NSData *readData = characteristic.value;
    NSString *content = [fitpolo705Parser hexStringFromData:readData];
    if (!fitpolo705ValidData(readData) || !fitpolo705ValidStr(content)) {
        return;
    }
    NSString *origData = [NSString stringWithFormat:@"手环返回数据:%@",content];
    [fitpolo705LogManager writeCommandToLocalFile:@[origData] withSourceInfo:fitpolo705DataSourceDevice];
    NSString *header = [content substringWithRange:NSMakeRange(0, 2)];
    if (![header isEqualToString:@"b5"]) {
        //应答帧头b5
        return;
    }
    //数据域长度
    NSInteger len = [fitpolo705Parser getDecimalWithHex:content range:NSMakeRange(4, 2)];
    if (content.length - 6 != 2 * len) {
        //长度校验
        return;
    }
    NSString *function = [content substringWithRange:NSMakeRange(2, 2)];
    fitpolo705ParseResultModel *model = [[fitpolo705ParseResultModel alloc] init];
    if ([function isEqualToString:@"01"] && content.length == 10) {
        //计步数据的条数
        model.returnData = @{
                             fitpolo705CommunicationDataNum:[fitpolo705Parser getDecimalStringWithHex:content range:NSMakeRange(6, 4)]
                             };
        model.operationID = fitpolo705GetStepDataOperation;
    }else if ([function isEqualToString:@"02"] && content.length == 34){
        //计步详情
        model.returnData = [fitpolo705Parser getStepDetailData:[content substringWithRange:NSMakeRange(6, 28)]];
        model.operationID = fitpolo705GetStepDataOperation;
    }
    [self addDataToList:model];
}

- (void)parseHeartRateData:(CBCharacteristic *)characteristic{
    NSData *readData = characteristic.value;
    NSString *content = [fitpolo705Parser hexStringFromData:readData];
    if (!fitpolo705ValidData(readData) || !fitpolo705ValidStr(content) || content.length < 4) {
        return;
    }
    NSString *origData = [NSString stringWithFormat:@"手环返回数据:%@",content];
    [fitpolo705LogManager writeCommandToLocalFile:@[origData] withSourceInfo:fitpolo705DataSourceDevice];
    NSString *header = [content substringWithRange:NSMakeRange(0, 2)];
    if (![header isEqualToString:@"b7"]) {
        //应答帧头b7
        return;
    }
    NSString *function = [content substringWithRange:NSMakeRange(2, 2)];
    fitpolo705ParseResultModel *model = [[fitpolo705ParseResultModel alloc] init];
    if ([function isEqualToString:@"01"] && content.length == 8) {
        //心率数据的条数
        model.returnData = @{
                             fitpolo705CommunicationDataNum:[fitpolo705Parser getDecimalStringWithHex:content range:NSMakeRange(4, 4)]
                             };
        model.operationID = fitpolo705GetHeartDataOperation;
    }else if ([function isEqualToString:@"02"] && content.length >= 16){
        //心率详情
        model.returnData = [fitpolo705Parser getHeartRateList:[content substringWithRange:NSMakeRange(4, content.length - 4)]];
        model.operationID = fitpolo705GetHeartDataOperation;
    }else if ([function isEqualToString:@"04"] && content.length == 8){
        //运动心率的条数
        model.returnData = @{
                             fitpolo705CommunicationDataNum:[fitpolo705Parser getDecimalStringWithHex:content range:NSMakeRange(4, 4)]
                             };
        model.operationID = fitpolo705GetSportHeartDataOperation;
    }else if ([function isEqualToString:@"05"] && content.length >= 16){
        //运动心率详情
        model.returnData = [fitpolo705Parser getHeartRateList:[content substringWithRange:NSMakeRange(4, content.length - 4)]];
        model.operationID = fitpolo705GetSportHeartDataOperation;
    }
    [self addDataToList:model];
}

- (void)parseUpdateData:(CBCharacteristic *)characteristic{
    NSData *readData = characteristic.value;
    NSString *content = [fitpolo705Parser hexStringFromData:readData];
    NSLog(@"升级:%@",content);
    if (!fitpolo705ValidStr(content) || content.length != 4) {
        return;
    }
    NSString *origData = [NSString stringWithFormat:@"手环升级数据:%@",content];
    [fitpolo705LogManager writeCommandToLocalFile:@[origData] withSourceInfo:fitpolo705DataSourceDevice];
    NSString *header = [content substringWithRange:NSMakeRange(0, 2)];
    if ([header isEqualToString:@"96"]) {
        NSString *function = [content substringWithRange:NSMakeRange(2, 2)];
        if ([function isEqualToString:@"28"]) {
            fitpolo705ParseResultModel *model = [[fitpolo705ParseResultModel alloc] init];
            model.returnData = @{};
            model.operationID = fitpolo705StartUpdateOperation;
            [self addDataToList:model];
        }
    }else if ([header isEqualToString:@"a7"]){
        //升级结果
        //抛出升级结果通知，@"00"成功@"01"超时@"02"校验码错误@"03"文件错误
        [[NSNotificationCenter defaultCenter] postNotificationName:fitpolo705PeripheralUpdateResultNotification
                                                            object:nil
                                                          userInfo:@{@"updateResult" : [content substringWithRange:NSMakeRange(2, 2)]}];
    }
}

#pragma mark - Private method
- (void)addDataToList:(fitpolo705ParseResultModel *)dataModel{
    if (!dataModel) {
        return;
    }
    [[self mutableArrayValueForKey:@"dataList"] removeAllObjects];
    [[self mutableArrayValueForKey:@"dataList"] addObject:dataModel];
}

#pragma mark - setter & getter
- (NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

@end
