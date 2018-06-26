//
//  fitpolo705Parser.m
//  testSDK
//
//  Created by aa on 2018/3/13.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "fitpolo705Parser.h"
#import "fitpolo705RegularsDefine.h"
#import "fitpolo705AncsModel.h"
#import "fitpolo705CustomScreenModel.h"
#import "fitpolo705LogManager.h"
#import "fitpolo705ScanModel.h"

static NSString *const uuidPatternString = @"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$";

@implementation fitpolo705Parser
+ (NSInteger)getDecimalWithHex:(NSString *)content range:(NSRange)range{
    if (!fitpolo705ValidStr(content)) {
        return 0;
    }
    if (range.location > content.length - 1 || range.length > content.length || (range.location + range.length > content.length)) {
        return 0;
    }
    return strtoul([[content substringWithRange:range] UTF8String],0,16);
}
+ (NSString *)getDecimalStringWithHex:(NSString *)content range:(NSRange)range{
    if (!fitpolo705ValidStr(content)) {
        return @"";
    }
    if (range.location > content.length - 1 || range.length > content.length || (range.location + range.length > content.length)) {
        return @"";
    }
    NSInteger decimalValue = strtoul([[content substringWithRange:range] UTF8String],0,16);
    return [NSString stringWithFormat:@"%ld",(long)decimalValue];
}

/**
 把originalArray数组按照range进行截取，生成一个新的数组并返回该数组

 @param originalArray 原数组
 @param range 截取范围
 @return 截取后生成的数组
 */
+ (NSArray *)interceptionOfArray:(NSArray *)originalArray
                        subRange:(NSRange)range{
    if (!fitpolo705ValidArray(originalArray)) {
        return nil;
    }
    if (range.location > originalArray.count - 1 || range.length > originalArray.count || (range.location + range.length > originalArray.count)) {
        return nil;
    }
    NSMutableArray *desArray = [NSMutableArray array];
    for (NSInteger i = 0; i < range.length; i ++) {
        [desArray addObject:originalArray[range.location + i]];
    }
    return desArray;
}

/**
 对NSData进行CRC16的校验
 
 @param data 目标data
 @return CRC16校验码
 */
+ (NSData *)getCrc16VerifyCode:(NSData *)data{
    if (!fitpolo705ValidData(data)) {
        return nil;
    }
    NSInteger crcWord = 0xffff;
    Byte *dataArray = (Byte *)[data bytes];
    for (NSInteger i = 0; i < data.length; i ++) {
        Byte byte = dataArray[i];
        crcWord ^= (NSInteger)byte & 0x00ff;
        for (NSInteger j = 0; j < 8; j ++) {
            if ((crcWord & 0x0001) == 1) {
                crcWord = crcWord >> 1;
                crcWord = crcWord ^ 0xA001;
            }else{
                crcWord = (crcWord >> 1);
            }
        }
    }
    
    Byte crcL = (Byte)0xff & (crcWord >> 8);
    Byte crcH = (Byte)0xff & (crcWord);
    Byte arrayCrc[] = {crcH, crcL};
    NSData *dataCrc = [NSData dataWithBytes:arrayCrc length:sizeof(arrayCrc)];
    return dataCrc;
}

+ (NSString *)getAncsCommand:(fitpolo705AncsModel *)ancsModel{
    //短信、电话、微信、qq、whatsapp、facebook、twitter、skype、snapchat、Line
    unsigned long lowByte = 0;
    unsigned long highByte = 0;
    if (ancsModel.openSMS) lowByte |= 0x01;
    if (ancsModel.openPhone) lowByte |= 0x02;
    if (ancsModel.openWeChat) lowByte |= 0x04;
    if (ancsModel.openQQ) lowByte |= 0x08;
    if (ancsModel.openWhatsapp) lowByte |= 0x10;
    if (ancsModel.openFacebook) lowByte |= 0x20;
    if (ancsModel.openTwitter) lowByte |= 0x40;
    if (ancsModel.openSkype) lowByte |= 0x80;
    if (ancsModel.openSnapchat) highByte |= 0x01;
    if (ancsModel.openLine) highByte |= 0x02;
    NSString *lowString = [[NSString alloc] initWithFormat:@"%1lx",lowByte];
    if (lowString.length == 1) {
        lowString = [@"0" stringByAppendingString:lowString];
    }
    NSString *highString = [[NSString alloc] initWithFormat:@"%1lx",highByte];
    if (highString.length == 1) {
        highString = [@"0" stringByAppendingString:highString];
    }
    return [highString stringByAppendingString:lowString];
}

+ (NSString *)getAlarmClockType:(fitpolo705AlarmClockType)clockType{
    switch (clockType) {
        case fitpolo705AlarmClockMedicine:
            return @"00";
        case fitpolo705AlarmClockDrink:
            return @"01";
        case fitpolo705AlarmClockSleep:
            return @"04";
        case fitpolo705AlarmClockExcise:
            return @"05";
        case fitpolo705AlarmClockSport:
            return @"06";
        case fitpolo705AlarmClockNormal:
            return @"03";
    }
}
+ (NSString *)getAlarlClockSetInfo:(fitpolo705StatusModel *)statusModel isOn:(BOOL)isOn{
    unsigned long byte = 0;
    if (statusModel.mondayIsOn) byte |= 0x01;
    if (statusModel.tuesdayIsOn) byte |= 0x02;
    if (statusModel.wednesdayIsOn) byte |= 0x04;
    if (statusModel.thursdayIsOn) byte |= 0x08;
    if (statusModel.fridayIsOn) byte |= 0x10;
    if (statusModel.saturdayIsOn) byte |= 0x20;
    if (statusModel.sundayIsOn) byte |= 0x40;
    if (isOn) byte |= 0x80;
    NSString *byteHexString = [NSString stringWithFormat:@"%1lx",byte];
    if (byteHexString.length == 1) {
        byteHexString = [@"0" stringByAppendingString:byteHexString];
    }
    return byteHexString;
}

+ (NSString *)getHeartRateAcquisitionInterval:(fitpolo705HeartRateAcquisitionInterval)intervalType{
    switch (intervalType) {
        case fitpolo705HeartRateAcquisitionIntervalClose:
            return @"00";
        case fitpolo705HeartRateAcquisitionInterval10Min:
            return @"01";
        case fitpolo705HeartRateAcquisitionInterval20Min:
            return @"02";
        case fitpolo705HeartRateAcquisitionInterval30Min:
            return @"03";
    }
}

+ (NSString *)hexStringFromData:(NSData *)sourceData{
    if (!fitpolo705ValidData(sourceData)) {
        return nil;
    }
    Byte *bytes = (Byte *)[sourceData bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[sourceData length];i++){
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

+ (NSString *)getTimeStringWithDate:(NSDate *)date{
    if (!date) {
        return nil;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd-HH-mm"];
    NSString *timeStamp = [formatter stringFromDate:date];
    if (!fitpolo705ValidStr(timeStamp)) {
        return nil;
    }
    NSArray *timeList = [timeStamp componentsSeparatedByString:@"-"];
    if (!fitpolo705ValidArray(timeList) || timeList.count != 5) {
        return nil;
    }
    if ([timeList[0] integerValue] < 2000 || [timeList[0] integerValue] > 2099) {
        return nil;
    }
    unsigned long yearValue = [timeList[0] integerValue] - 2000;
    NSString *hexTimeString = [NSString stringWithFormat:@"%1lx",yearValue];
    if (hexTimeString.length == 1) {
        hexTimeString = [@"0" stringByAppendingString:hexTimeString];
    }
    for (NSInteger i = 1; i < timeList.count; i ++) {
        unsigned long tempValue = [timeList[i] integerValue];
        NSString *hexTempStr = [NSString stringWithFormat:@"%1lx",tempValue];
        if (hexTempStr.length == 1) {
            hexTempStr = [@"0" stringByAppendingString:hexTempStr];
        }
        hexTimeString = [hexTimeString stringByAppendingString:hexTempStr];
    }
    return hexTimeString;
}

+ (BOOL)isMacAddress:(NSString *)macAddress{
    if (!fitpolo705ValidStr(macAddress)) {
        return NO;
    }
    NSString *regex = @"([A-Fa-f0-9]{2}-){5}[A-Fa-f0-9]{2}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pred evaluateWithObject:macAddress];
}
+ (BOOL)isMacAddressLowFour:(NSString *)lowFour{
    if (!fitpolo705ValidStr(lowFour)) {
        return NO;
    }
    NSString *regex = @"([A-Fa-f0-9]{2}-){1}[A-Fa-f0-9]{2}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pred evaluateWithObject:lowFour];
}
+ (BOOL)isUUIDString:(NSString *)uuid{
    if (!fitpolo705ValidStr(uuid)) {
        return NO;
    }
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:uuidPatternString
                                                                          options:NSRegularExpressionCaseInsensitive
                                                                            error:nil];
    NSInteger numberOfMatches = [regex numberOfMatchesInString:uuid
                                                       options:kNilOptions
                                                         range:NSMakeRange(0, uuid.length)];
    return (numberOfMatches > 0);
}

+ (NSData *)stringToData:(NSString *)dataString{
    if (!fitpolo705ValidStr(dataString)) {
        return nil;
    }
    if (!(dataString.length % 2 == 0)) {
        //必须是偶数个字符才是合法的
        return nil;
    }
    Byte bytes[255] = {0};
    NSInteger count = 0;
    for (int i =0; i < dataString.length; i+=2) {
        NSString *strByte = [dataString substringWithRange:NSMakeRange(i,2)];
        unsigned long red = strtoul([strByte UTF8String],0,16);
        Byte b =  (Byte) ((0xff & red) );//( Byte) 0xff&iByte;
        bytes[i/2+0] = b;
        count ++;
    }
    NSData * data = [NSData dataWithBytes:bytes length:count];
    return data;
}

+ (NSArray *)getSleepDetailList:(NSString *)detail{
    if (!fitpolo705ValidStr(detail) || detail.length != 2) {
        return nil;
    }
    NSDictionary *hexDic = @{
                             @"0":@"0000",@"1":@"0001",@"2":@"0010",
                             @"3":@"0011",@"4":@"0100",@"5":@"0101",
                             @"6":@"0110",@"7":@"0111",@"8":@"1000",
                             @"9":@"1001",@"A":@"1010",@"a":@"1010",
                             @"B":@"1011",@"b":@"1011",@"C":@"1100",
                             @"c":@"1100",@"D":@"1101",@"d":@"1101",
                             @"E":@"1110",@"e":@"1110",@"F":@"1111",
                             @"f":@"1111",
                             };
    NSString *binaryString = @"";
    for (int i=0; i<[detail length]; i++) {
        NSRange rage;
        rage.length = 1;
        rage.location = i;
        NSString *key = [detail substringWithRange:rage];
        binaryString = [NSString stringWithFormat:@"%@%@",
                        binaryString,
                        [NSString stringWithFormat:@"%@",[hexDic objectForKey:key]]];
        
    }
    if (binaryString.length != 8) {
        return nil;
    }
    NSMutableArray * list = [[NSMutableArray alloc] init];
    NSInteger index = 0;
    for (NSInteger i = 0; i < 4; i ++) {
        NSString * string = [binaryString substringWithRange:NSMakeRange(index, 2)];
        if ([string isEqualToString:@"11"]) {
            string = @"00";
        }
        [list addObject:string];
        index += 2;
    }
    NSMutableArray * resultArr = (NSMutableArray *)[[list reverseObjectEnumerator] allObjects];
    return resultArr;
}

+ (NSArray *)getSleepDataList:(NSArray *)indexList recordList:(NSArray *)recordList{
    if (!fitpolo705ValidArray(indexList) || !fitpolo705ValidArray(recordList)) {
        return nil;
    }
    NSMutableArray *resultArray = [NSMutableArray array];
    
    for (NSDictionary *dic in indexList) {
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        NSArray *sleepDetailList = [self getDetailSleepList:dic[@"SN"] recordList:recordList];
        [tempDic setObject:sleepDetailList forKey:@"detailedSleep"];
        [resultArray addObject:tempDic];
    }
    return [resultArray copy];
}

+ (NSArray <fitpolo705AlarmClockModel *>*)getAlarmClockDataList:(NSString *)content{
    NSMutableArray *list = [NSMutableArray array];
    for (NSInteger i = 0; i < content.length / 8; i ++) {
        NSString *subContent = [content substringWithRange:NSMakeRange(i * 8, 8)];
        fitpolo705AlarmClockModel *clockModel = [[fitpolo705AlarmClockModel alloc] init];
        clockModel.clockType = [self getClockTypeWithString:[subContent substringWithRange:NSMakeRange(0, 2)]];
        NSDictionary *dic = [self getClockStatusModelWithString:[subContent substringWithRange:NSMakeRange(2, 2)]];
        clockModel.statusModel = dic[@"statusModel"];
        clockModel.isOn = [dic[@"isOn"] boolValue];
        clockModel.hour = [self getDecimalWithHex:subContent range:NSMakeRange(4, 2)];
        clockModel.minutes = [self getDecimalWithHex:subContent range:NSMakeRange(6, 2)];
        [list addObject:clockModel];
    }
    return [list mutableCopy];
}
//bit0为短信，bit1为电话，bit2为微信bit3为QQ，bit4为whatsapp，bit5为facebook，bit6 为twitter，bit7为 skype，bit 8 为snapchat，bit 9 为Line
+ (fitpolo705AncsModel *)getAncsOptionsModel:(NSString *)content{
    NSInteger statusValueHeight = [self getDecimalWithHex:content range:NSMakeRange(0, 2)];
    NSInteger statusValueLow = [self getDecimalWithHex:content range:NSMakeRange(2, 2)];
    fitpolo705AncsModel *ancsModel = [[fitpolo705AncsModel alloc] init];
    ancsModel.openSMS = (statusValueLow & 0x01);
    ancsModel.openPhone = (statusValueLow & 0x02);
    ancsModel.openWeChat = (statusValueLow & 0x04);
    ancsModel.openQQ = (statusValueLow & 0x08);
    ancsModel.openWhatsapp = (statusValueLow & 0x10);
    ancsModel.openFacebook = (statusValueLow & 0x20);
    ancsModel.openTwitter = (statusValueLow & 0x40);
    ancsModel.openSkype = (statusValueLow & 0x80);
    ancsModel.openSnapchat = (statusValueHeight & 0x01);
    ancsModel.openLine = (statusValueHeight & 0x02);
    return ancsModel;
}

+ (NSDictionary *)getSedentaryRemindData:(NSString *)content{
    BOOL isOn = [[content substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"01"];
    NSString *startHour = [self getDecimalStringWithHex:content range:NSMakeRange(2, 2)];
    NSString *startMin = [self getDecimalStringWithHex:content range:NSMakeRange(4, 2)];
    NSString *endHour = [self getDecimalStringWithHex:content range:NSMakeRange(6, 2)];
    NSString *endMin = [self getDecimalStringWithHex:content range:NSMakeRange(8, 2)];
    return @{
                @"isOn":@(isOn),
                @"startHour":startHour,
                @"startMin":startMin,
                @"endHour":endHour,
                @"endMin":endMin,
             };
}
//Bit13跑步4界面, （必须为真）,Bit12跑步3界面,Bit11跑步2界面,Bit10跑步1界面, （必须为真）,Bit9跑步入口界面,（必须为真）,Bit8睡眠界面,Bit7运动时间界面,Bit6里程界面,bit5卡路里界面,bit4 计步界面,bit3血压界面，（必须为假）,bit2心率界面，bit1时间界面，（必须为真）,bit0配对界面，（必须为真）
+ (fitpolo705CustomScreenModel *)getCustomScreenModel:(NSString *)content{
    NSInteger screenHeight = [self getDecimalWithHex:content range:NSMakeRange(0, 2)];
    NSInteger screenLow = [self getDecimalWithHex:content range:NSMakeRange(2, 2)];
    fitpolo705CustomScreenModel *screenModel = [[fitpolo705CustomScreenModel alloc] init];
    screenModel.turnOnHeartRatePage = (screenLow & 0x04);
    screenModel.turnOnStepPage = (screenLow & 0x10);
    screenModel.turnOnCaloriesPage = (screenLow & 0x20);
    screenModel.turnOnSportsDistancePage = (screenLow & 0x40);
    screenModel.turnOnSportsTimePage = (screenLow & 0x80);
    screenModel.turnOnSleepPage = (screenHeight & 0x01);
    screenModel.turnOnSecondRunning = (screenHeight & 0x08);
    screenModel.turnOnThirdRunning = (screenHeight & 0x10);
    return screenModel;
}

+ (NSDictionary *)getUserInfo:(NSString *)content{
    NSString *weight = [self getDecimalStringWithHex:content range:NSMakeRange(0, 2)];
    NSString *height = [self getDecimalStringWithHex:content range:NSMakeRange(2, 2)];
    NSString *month = [self getDecimalStringWithHex:content range:NSMakeRange(6, 2)];
    if (month.length == 1) {
        month = [@"0" stringByAppendingString:month];
    }
    NSString *day = [self getDecimalStringWithHex:content range:NSMakeRange(8, 2)];
    if (day.length == 1) {
        day = [@"0" stringByAppendingString:day];
    }
    NSString *gender = [content substringWithRange:NSMakeRange(10, 2)];
    NSString *stepDistance = [self getDecimalStringWithHex:content range:NSMakeRange(12, 2)];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentTime = [formatter stringFromDate:[NSDate date]];
    NSArray *currentArr = [currentTime componentsSeparatedByString:@"-"];
    NSInteger year = [currentArr[0] integerValue] - [self getDecimalWithHex:content range:NSMakeRange(4, 2)];
    NSString *yearString = [NSString stringWithFormat:@"%ld",(long)year];
    return @{
                @"weight":weight,
                @"height":height,
                @"birthOfDate":[NSString stringWithFormat:@"%@-%@-%@",yearString,month,day],
                @"gender":gender,
                @"stepDistance":stepDistance,
             };
}

+ (NSDictionary *)getHardwareParameters:(NSString *)content{
    //flash的状态
    NSString *flashStatus = [content substringWithRange:NSMakeRange(0, 2)];
    //当前反光阀值
    NSString *reflThreshold = [self getDecimalStringWithHex:content range:NSMakeRange(2, 4)];
    //当前反光值
    NSString *reflective = [self getDecimalStringWithHex:content range:NSMakeRange(6, 4)];
    //生产批次年
    NSString *productYear = [NSString stringWithFormat:@"%ld",(long)([self getDecimalWithHex:content range:NSMakeRange(10, 2)] + 2000)];
    //生产批次周
    NSString *productWeek = [self getDecimalStringWithHex:content range:NSMakeRange(12, 2)];
    return @{
             @"flashStatus":flashStatus,
             @"reflThreshold":reflThreshold,
             @"reflective":reflective,
             @"productYear":productYear,
             @"productWeek":productWeek,
             };
}

+ (NSString *)getFirmwareVersion:(NSString *)content{
    NSString *hardVersion = [self getDecimalStringWithHex:content range:NSMakeRange(0, 4)];
    NSString *function = [self getDecimalStringWithHex:content range:NSMakeRange(4, 4)];
    NSString *softVersion = [self getDecimalStringWithHex:content range:NSMakeRange(8, 4)];
    return [NSString stringWithFormat:@"%@.%@.%@",hardVersion,function,softVersion];
}

//解析睡眠index，记录到本地日志
+ (NSDictionary *)getSleepIndexData:(NSString *)content{
    
    NSString *SN = [self getDecimalStringWithHex:content range:NSMakeRange(0, 2)];
    NSString *startYear = [NSString stringWithFormat:@"%ld",(long)([self getDecimalWithHex:content range:NSMakeRange(2, 2)] + 2000)];
    NSString *startMonth = [self getDecimalStringWithHex:content range:NSMakeRange(4, 2)];
    NSString *startDay = [self getDecimalStringWithHex:content range:NSMakeRange(6, 2)];
    NSString *startHour = [self getDecimalStringWithHex:content range:NSMakeRange(8, 2)];
    NSString *startMin = [self getDecimalStringWithHex:content range:NSMakeRange(10, 2)];
    NSString *endYear = [NSString stringWithFormat:@"%ld",(long)([self getDecimalWithHex:content range:NSMakeRange(12, 2)] + 2000)];
    NSString *endMonth = [self getDecimalStringWithHex:content range:NSMakeRange(14, 2)];
    NSString *endDay = [self getDecimalStringWithHex:content range:NSMakeRange(16, 2)];
    NSString *endHour = [self getDecimalStringWithHex:content range:NSMakeRange(18, 2)];
    NSString *endMin = [self getDecimalStringWithHex:content range:NSMakeRange(20, 2)];
    NSString *deepSleepTime = [self getDecimalStringWithHex:content range:NSMakeRange(22, 4)];
    NSString *lightSleepTime = [self getDecimalStringWithHex:content range:NSMakeRange(26, 4)];
    NSString *awake = [self getDecimalStringWithHex:content range:NSMakeRange(30, 4)];
    
    NSString *tempString1 = [NSString stringWithFormat:@"解析后的睡眠index数据:第%@条index",SN];
    NSString *tempString2 = [NSString stringWithFormat:@"开始于%@-%@-%@ %@:%@",startYear,startMonth,startDay,startHour,startMin];
    NSString *tempString3 = [NSString stringWithFormat:@"结束于%@-%@-%@ %@:%@",endYear,endMonth,endDay,endHour,endMin];
    NSString *tempString4 = [NSString stringWithFormat:@"深睡时长:%@",deepSleepTime];
    NSString *tempString5 = [NSString stringWithFormat:@"浅睡时长:%@",lightSleepTime];
    NSString *tempString6 = [NSString stringWithFormat:@"清醒时长:%@",awake];
    [fitpolo705LogManager writeCommandToLocalFile:@[tempString1,tempString2,tempString3,tempString4,tempString5,tempString6]
                                   withSourceInfo:fitpolo705DataSourceDevice];
    return @{
             @"SN":SN,
             @"startYear":startYear,
             @"startMonth":startMonth,
             @"startDay":startDay,
             @"startHour":startHour,
             @"startMin":startMin,
             @"endYear":endYear,
             @"endMonth":endMonth,
             @"endDay":endDay,
             @"endHour":endHour,
             @"endMin":endMin,
             @"deepSleepTime":deepSleepTime,
             @"lightSleepTime":lightSleepTime,
             @"awake":awake,
             };
}
//解析睡眠record，记录到本地日志
+ (NSDictionary *)getSleepRecordData:(NSString *)content{
    //对应的睡眠详情长度
    NSInteger len = [self getDecimalWithHex:content range:NSMakeRange(4, 2)];
    if (len == 0) {
        return @{};
    }
    NSMutableArray *detailList = [NSMutableArray array];
    NSInteger index = 6;
    for (NSInteger i = 0; i < len; i ++) {
        NSString * hexStr = [content substringWithRange:NSMakeRange(index, 2)];
        NSArray * tempList = [self getSleepDetailList:hexStr];
        if (fitpolo705ValidArray(tempList)) {
            [detailList addObjectsFromArray:tempList];
        }
        index += 2;
    }
    NSString *tempString = @"";
    for (NSString *temp in detailList) {
        tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@" %@",temp]];
    }
    NSString *SN = [self getDecimalStringWithHex:content range:NSMakeRange(0, 2)];
    NSString *fragmentSN = [self getDecimalStringWithHex:content range:NSMakeRange(2, 2)];
    NSString *tempString1 = [NSString stringWithFormat:@"解析后的睡眠index数据:对应第%@条睡眠index数据",SN];
    NSString *tempString2 = [NSString stringWithFormat:@"本条数据index数据下面是第%@条record数据",fragmentSN];
    NSString *tempString3 = [NSString stringWithFormat:@"解析后的睡眠详情:%@",tempString];
    [fitpolo705LogManager writeCommandToLocalFile:@[tempString1,tempString2,tempString3,]
                                   withSourceInfo:fitpolo705DataSourceDevice];
    return @{
             @"SN":SN,
             @"fragmentSN":fragmentSN,
             @"detailList":detailList,
             };
}

+ (NSDictionary *)getSportData:(NSString *)content{
    NSString *SN = [self getDecimalStringWithHex:content range:NSMakeRange(0,2)];
    NSString *year = [NSString stringWithFormat:@"%ld",(long)([self getDecimalWithHex:content range:NSMakeRange(2, 2)] + 2000)];
    NSString *sportDate = [NSString stringWithFormat:@"%@-%@-%@-%@-%@",year,
                           [self getDecimalStringWithHex:content range:NSMakeRange(4, 2)],
                           [self getDecimalStringWithHex:content range:NSMakeRange(6, 2)],
                           [self getDecimalStringWithHex:content range:NSMakeRange(8, 2)],
                           [self getDecimalStringWithHex:content range:NSMakeRange(10, 2)]];
    NSString *sportTime = [self getDecimalStringWithHex:content range:NSMakeRange(12, 4)];
    NSString *stepNumber = [self getDecimalStringWithHex:content range:NSMakeRange(16, 6)];
    NSString *calories = [self getDecimalStringWithHex:content range:NSMakeRange(22, 4)];
    NSString *pace = [self getDecimalStringWithHex:content range:NSMakeRange(26, 4)];
    NSString *distance = [NSString stringWithFormat:@"%.1f",(float)[self getDecimalWithHex:content range:NSMakeRange(30, 4)] / 10.0];
    NSString *string1 = [NSString stringWithFormat:@"第%@条运动数据",SN];
    NSString *string2 = [NSString stringWithFormat:@"运动开始时间:%@",sportDate];
    NSString *string3 = [NSString stringWithFormat:@"运动时长:%@分钟",sportTime];
    NSString *string4 = [NSString stringWithFormat:@"运动消耗的卡路里:%@Cal",calories];
    NSString *string5 = [NSString stringWithFormat:@"运动配速:%@s",pace];
    NSString *string6 = [NSString stringWithFormat:@"运动里程:%@",distance];
    [fitpolo705LogManager writeCommandToLocalFile:@[string1,string2,string3,string4,string5,string6]
                                   withSourceInfo:fitpolo705DataSourceDevice];
    return @{
             @"SN":SN,
             @"sportDate":sportDate,
             @"sportTime":sportTime,
             @"stepNumber":stepNumber,
             @"calories":calories,
             @"pace":pace,
             @"distance":distance,
             };
}

+ (NSString *)getLastChargingTime:(NSString *)content{
    NSString *year = [NSString stringWithFormat:@"%ld",(long)([self getDecimalWithHex:content range:NSMakeRange(0, 2)] + 2000)];
    NSString *sportDate = [NSString stringWithFormat:@"%@-%@-%@-%@-%@",year,
                           [self getDecimalStringWithHex:content range:NSMakeRange(2, 2)],
                           [self getDecimalStringWithHex:content range:NSMakeRange(4, 2)],
                           [self getDecimalStringWithHex:content range:NSMakeRange(6, 2)],
                           [self getDecimalStringWithHex:content range:NSMakeRange(8, 2)]];
    return sportDate;
}

//Bit13跑步4界面, （必须为真）,Bit12跑步3界面,Bit11跑步2界面,Bit10跑步1界面, （必须为真）,Bit9跑步入口界面,（必须为真）,Bit8睡眠界面,Bit7运动时间界面,Bit6里程界面,bit5卡路里界面,bit4 计步界面,bit3血压界面，（必须为假）,bit2心率界面，bit1时间界面，（必须为真）,bit0配对界面，（必须为真）
+ (NSString *)getCustomScreenString:(fitpolo705CustomScreenModel *)screenModel{
    unsigned long highByte = 0;
    unsigned long lowByte = 1;
    lowByte |= 0x03;
    if (screenModel.turnOnHeartRatePage) lowByte |= 0x04;
    lowByte |= 0x08;
    if (screenModel.turnOnStepPage) lowByte |= 0x10;
    if (screenModel.turnOnCaloriesPage) lowByte |= 0x20;
    if (screenModel.turnOnSportsDistancePage) lowByte |= 0x40;
    if (screenModel.turnOnSportsTimePage) lowByte |= 0x80;
    
    if (screenModel.turnOnSleepPage) highByte |= 0x01;
    highByte |= 0x06;
    if (screenModel.turnOnSecondRunning) highByte |= 0x08;
    if (screenModel.turnOnThirdRunning) highByte |= 0x10;
    highByte |= 0x20;
    NSString *highHex = [NSString stringWithFormat:@"%1lx",highByte];
    if (highHex.length == 1) {
        highHex = [@"0" stringByAppendingString:highHex];
    }
    NSString *lowHex = [NSString stringWithFormat:@"%1lx",lowByte];
    if (lowHex.length == 1) {
        lowHex = [@"0" stringByAppendingString:lowHex];
    }
    return [highHex stringByAppendingString:lowHex];
}

+ (NSString *)getTimeSpaceWithStatus:(BOOL)isOn
                           startHour:(NSInteger)startHour
                        startMinutes:(NSInteger)startMinutes
                             endHour:(NSInteger)endHour
                          endMinutes:(NSInteger)endMinutes{
    if (isOn) {
        if (startHour < 0 || startHour > 23) {
            return @"";
        }
        if (startMinutes < 0 || startMinutes > 59) {
            return @"";
        }
        if (endHour < 0 || endHour > 23) {
            return @"";
        }
        if (endMinutes < 0 || endMinutes > 59) {
            return @"";
        }
    }
    //开始的时
    NSString *startHourHex = [NSString stringWithFormat:@"%1lx",(unsigned long)startHour];
    if (startHourHex.length == 1) {
        startHourHex = [@"0" stringByAppendingString:startHourHex];
    }
    //开始的分
    NSString *startMinHex = [NSString stringWithFormat:@"%1lx",(unsigned long)startMinutes];
    if (startMinHex.length == 1) {
        startMinHex = [@"0" stringByAppendingString:startMinHex];
    }
    //结束的时
    NSString *endHourHex = [NSString stringWithFormat:@"%1lx",(unsigned long)endHour];
    if (endHourHex.length == 1) {
        endHourHex = [@"0" stringByAppendingString:endHourHex];
    }
    //结束的分
    NSString *endMinHex = [NSString stringWithFormat:@"%1lx",(unsigned long)endMinutes];
    if (endMinHex.length == 1) {
        endMinHex = [@"0" stringByAppendingString:endMinHex];
    }
    
    return [NSString stringWithFormat:@"%@%@%@%@",startHourHex,startMinHex,endHourHex,endMinHex];
}
//解析读取回来的计步数据，并记录到本地
+ (NSDictionary *)getStepDetailData:(NSString *)content{
    NSString *SN = [self getDecimalStringWithHex:content range:NSMakeRange(0, 2)];
    NSString *year = [NSString stringWithFormat:@"%ld",(long)([self getDecimalWithHex:content range:NSMakeRange(2, 2)] + 2000)];
    NSString *month = [self getDecimalStringWithHex:content range:NSMakeRange(4, 2)];
    NSString *day = [self getDecimalStringWithHex:content range:NSMakeRange(6, 2)];
    NSString *stepNumber = [self getDecimalStringWithHex:content range:NSMakeRange(8, 8)];
    NSString *activityTime = [self getDecimalStringWithHex:content range:NSMakeRange(16, 4)];
    NSString *distance = [NSString stringWithFormat:@"%.1f",(float)[self getDecimalWithHex:content range:NSMakeRange(20, 4)] / 10.0];
    NSString *calories = [self getDecimalStringWithHex:content range:NSMakeRange(24, 4)];
    NSString *tempString1 = [NSString stringWithFormat:@"解析后的计步数据:第%@条数据",SN];
    NSString *tempString2 = [NSString stringWithFormat:@"计步时间:%@-%@-%@",year,month,day];
    NSString *tempString3 = [NSString stringWithFormat:@"步数是:%@",stepNumber];
    NSString *tempString4 = [NSString stringWithFormat:@"运动时间:%@",activityTime];
    NSString *tempString5 = [NSString stringWithFormat:@"运动距离:%@",distance];
    NSString *tempString6 = [NSString stringWithFormat:@"消耗卡路里:%@",calories];
    [fitpolo705LogManager writeCommandToLocalFile:@[tempString1,tempString2,tempString3,tempString4,tempString5,tempString6]
                                   withSourceInfo:fitpolo705DataSourceDevice];
    return @{
             @"SN":SN,
             @"year":year,
             @"month":month,
             @"day":day,
             @"stepNumber":stepNumber,
             @"activityTime":activityTime,
             @"distance":distance,
             @"calories":calories,
             };
}

//解析心率数据，并记录到本地
+ (NSDictionary *)getHeartRateList:(NSString *)content{
    NSMutableArray *list = [NSMutableArray array];
    for (NSInteger i = 0; i < content.length / 12; i ++) {
        NSString *subContemt = [content substringWithRange:NSMakeRange(i * 12, 12)];
        NSString *year = [NSString stringWithFormat:@"%ld",(long)([self getDecimalWithHex:subContemt range:NSMakeRange(0, 2)] + 2000)];
        NSString *month = [self getDecimalStringWithHex:subContemt range:NSMakeRange(2, 2)];
        NSString *day = [self getDecimalStringWithHex:subContemt range:NSMakeRange(4, 2)];
        NSString *hour = [self getDecimalStringWithHex:subContemt range:NSMakeRange(6, 2)];
        NSString *min = [self getDecimalStringWithHex:subContemt range:NSMakeRange(8, 2)];
        NSString *heartRate = [self getDecimalStringWithHex:subContemt range:NSMakeRange(10, 2)];
        NSString *string1 = [NSString stringWithFormat:@"心率时间:%@-%@-%@ %@:%@",year,month,day,hour,min];
        NSString *string2 = [NSString stringWithFormat:@"心率值:%@",heartRate];
        [fitpolo705LogManager writeCommandToLocalFile:@[string1,string2]
                                       withSourceInfo:fitpolo705DataSourceDevice];
        NSDictionary *dic = @{
                              @"year":year,
                              @"month":month,
                              @"day":day,
                              @"hour":hour,
                              @"minute":min,
                              @"heartRate":heartRate
                              };
        [list addObject:dic];
    }
    
    
    return @{
                @"heartList":list,
             };
}

+ (fitpolo705ScanModel *)getScanModelWithParamDic:(NSDictionary *)paramDic peripheral:(CBPeripheral *)peripheral{
    if (!paramDic || paramDic.allValues.count == 0 || !peripheral) {
        return nil;
    }
    NSData *data = paramDic[CBAdvertisementDataManufacturerDataKey];
    if (data.length != 9) {
        return nil;
    }
    NSString *temp = data.description;
    temp = [temp stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"<" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@">" withString:@""];
    NSString *macAddress = [NSString stringWithFormat:@"%@-%@-%@-%@-%@-%@",[temp substringWithRange:NSMakeRange(0, 2)],[temp substringWithRange:NSMakeRange(2, 2)],[temp substringWithRange:NSMakeRange(4, 2)],[temp substringWithRange:NSMakeRange(6, 2)],[temp substringWithRange:NSMakeRange(8, 2)],[temp substringWithRange:NSMakeRange(10, 2)]];
    NSString *deviceType = [temp substringWithRange:NSMakeRange(12, 2)];
    fitpolo705ScanModel *model = [[fitpolo705ScanModel alloc] init];
    model.peripheral = peripheral;
    model.macAddress = macAddress;
    model.peripheralName = paramDic[CBAdvertisementDataLocalNameKey];
    model.typeIdenty = deviceType;
    return model;
}

#pragma mark - Private method
+ (NSArray *)getDetailSleepList:(NSString *)SN recordList:(NSArray *)recordList{
    NSMutableArray * tempList = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < recordList.count; i ++) {
        NSDictionary *recordDic = recordList[i];
        if ([recordDic[@"SN"] isEqualToString:SN]) {
            [tempList addObject:recordDic];
        }
    }
    NSArray *sortedArray = [tempList sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *dic1, NSDictionary *dic2){
        NSInteger index1 = [dic1[@"fragmentSN"] integerValue];
        NSInteger index2 = [dic2[@"fragmentSN"] integerValue];
        return [[NSNumber numberWithInteger:index1]
                compare:[NSNumber numberWithInteger:index2]];
    }];
    NSMutableArray *resultList = [NSMutableArray array];
    for (NSInteger m = 0; m < [sortedArray count]; m ++) {
        NSDictionary *dic = [sortedArray objectAtIndex:m];
        NSArray *list = dic[@"detailList"];
        if (fitpolo705ValidArray(list)) {
            [resultList addObjectsFromArray:list];
        }
    }
    
    return resultList;
}

//0x00:吃药;0x01:喝水;0x03:普通;0x04:睡觉;0x05:锻炼;0x06:跑步
+ (fitpolo705AlarmClockType)getClockTypeWithString:(NSString *)type{
    if ([type isEqualToString:@"00"]) {
        return fitpolo705AlarmClockMedicine;
    }else if ([type isEqualToString:@"01"]){
        return fitpolo705AlarmClockDrink;
    }else if ([type isEqualToString:@"03"]){
        return fitpolo705AlarmClockNormal;
    }else if ([type isEqualToString:@"04"]){
        return fitpolo705AlarmClockSleep;
    }else if ([type isEqualToString:@"05"]){
        return fitpolo705AlarmClockExcise;
    }else if ([type isEqualToString:@"06"]){
        return fitpolo705AlarmClockSport;
    }
    return fitpolo705AlarmClockNormal;
}
//Bit0-Bit6：代表周一至周日，为真代表打开 Bit7：1代表打开闹钟，0代表关闭闹钟
+ (NSDictionary *)getClockStatusModelWithString:(NSString *)modelString{
    NSInteger statusValue = [self getDecimalWithHex:modelString range:NSMakeRange(0, 2)];
    fitpolo705StatusModel *statusModel = [[fitpolo705StatusModel alloc] init];
    statusModel.mondayIsOn = (statusValue & 0x01);
    statusModel.tuesdayIsOn = (statusValue & 0x02);
    statusModel.wednesdayIsOn = (statusValue & 0x04);
    statusModel.thursdayIsOn = (statusValue & 0x08);
    statusModel.fridayIsOn = (statusValue & 0x10);
    statusModel.saturdayIsOn = (statusValue & 0x20);
    statusModel.sundayIsOn = (statusValue & 0x40);
    
    return @{
                @"statusModel":statusModel,
                @"isOn":@(statusValue & 0x80),
             };
}

+ (NSString *)getCommandType:(fitpolo705TaskOperationID)operationID{
    switch (operationID) {
        case fitpolo705GetAlarmClockOperation:
            return @"读取手环闹钟数据";
        case fitpolo705GetAncsOptionsOperation:
            return @"读取手环ancs选项";
        case fitpolo705GetSedentaryRemindOperation:
            return @"读取手环久坐提醒数据";
        case fitpolo705GetMovingTargetOperation:
            return @"读取手环运动目标值";
        case fitpolo705GetUnitDataOperation:
            return @"读取手环单位信息";
        case fitpolo705GetTimeFormatDataOperation:
            return @"读取手环时间进制";
        case fitpolo705GetCustomScreenDisplayOperation:
            return @"读取手环屏幕显示";
        case fitpolo705GetRemindLastScreenDisplayOperation:
            return @"读取是否显示上一次屏幕";
        case fitpolo705GetHeartRateAcquisitionIntervalOperation:
            return @"读取心率采集间隔";
        case fitpolo705GetDoNotDisturbTimeOperation:
            return @"读取勿扰时段";
        case fitpolo705GetPalmingBrightScreenOperation:
            return @"读取翻腕亮屏信息";
        case fitpolo705GetUserInfoOperation:
            return @"读取个人信息";
        case fitpolo705GetSportsDataOperation:
            return @"读取运动信息";
        case fitpolo705GetLastChargingTimeOperation:
            return @"读取上一次手环充电时间";
        case fitpolo705GetBatteryOperation:
            return @"读取手环电池电量";
        case fitpolo705VibrationOperation:
            return @"手环震动";
        case fitpolo705SetUnitOperation:
            return @"设置单位信息";
        case fitpolo705SetANCSOptionsOperation:
            return @"设置ancs通知选项";
        case fitpolo705SetDateOperation:
            return @"设置日期";
        case fitpolo705SetUserInfoOperation:
            return @"设置个人信息";
        case fitpolo705SetTimeFormatOperation:
            return @"设置时间进制格式";
        case fitpolo705OpenPalmingBrightScreenOperation:
            return @"设置翻腕亮屏";
        case fitpolo705SetAlarmClockOperation:
            return @"设置闹钟";
        case fitpolo705RemindLastScreenDisplayOperation:
            return @"设置上一次屏幕显示";
        case fitpolo705SetSedentaryRemindOperation:
            return @"设置久坐提醒";
        case fitpolo705SetHeartRateAcquisitionIntervalOperation:
            return @"设置心率采集间隔";
        case fitpolo705SetScreenDisplayOperation:
            return @"设置屏幕显示";
        case fitpolo705GetHardwareParametersOperation:
            return @"获取硬件参数";
        case fitpolo705GetFirmwareVersionOperation:
            return @"获取固件版本号";
        case fitpolo705GetStepDataOperation:
            return @"获取计步数据";
        case fitpolo705GetSleepIndexOperation:
            return @"获取睡眠index数据";
        case fitpolo705GetSleepRecordOperation:
            return @"获取睡眠record数据";
        case fitpolo705GetHeartDataOperation:
            return @"获取心率数据";
        case fitpolo705StartUpdateOperation:
            return @"开启手环升级";
        case fitpolo705SetMovingTargetOperation:
            return @"设置运动目标";
        case fitpolo705SetDoNotDisturbTimeOperation:
            return @"设置勿扰时段";
        case fitpolo705GetSportHeartDataOperation:
            return @"获取运动心率数据";
        case fitpolo705SetAlarmClockNumbersOperation:
            return @"设置闹钟组数";
        case fitpolo705GetANCSConnectStatusOperation:
            return @"获取手环ancs连接状态";
    }
}

@end
