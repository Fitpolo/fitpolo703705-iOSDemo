//
//  fitpolo705Models.m
//  fitpolo705SDKDemo
//
//  Created by aa on 2018/7/20.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "fitpolo705Models.h"
#import "fitpolo705Parser.h"
#import "fitpolo705Defines.h"

@implementation fitpolo705Models
@end

@implementation fitpolo705StatusModel

+ (fitpolo705StatusModel *)fetchStatusModel:(NSString *)content{
    if (!fitpolo705ValidStr(content) || content.length < 2) {
        return nil;
    }
    NSInteger statusValue = [fitpolo705Parser getDecimalWithHex:content range:NSMakeRange(0, 2)];
    fitpolo705StatusModel *statusModel = [[fitpolo705StatusModel alloc] init];
    statusModel.mondayIsOn = (statusValue & 0x01);
    statusModel.tuesdayIsOn = (statusValue & 0x02);
    statusModel.wednesdayIsOn = (statusValue & 0x04);
    statusModel.thursdayIsOn = (statusValue & 0x08);
    statusModel.fridayIsOn = (statusValue & 0x10);
    statusModel.saturdayIsOn = (statusValue & 0x20);
    statusModel.sundayIsOn = (statusValue & 0x40);
    return statusModel;
}

- (NSString *)fetchAlarlClockSetInfo:(BOOL)isOn{
    unsigned long byte = 0;
    if (self.mondayIsOn) byte |= 0x01;
    if (self.tuesdayIsOn) byte |= 0x02;
    if (self.wednesdayIsOn) byte |= 0x04;
    if (self.thursdayIsOn) byte |= 0x08;
    if (self.fridayIsOn) byte |= 0x10;
    if (self.saturdayIsOn) byte |= 0x20;
    if (self.sundayIsOn) byte |= 0x40;
    if (isOn) byte |= 0x80;
    NSString *byteHexString = [NSString stringWithFormat:@"%1lx",byte];
    if (byteHexString.length == 1) {
        byteHexString = [@"0" stringByAppendingString:byteHexString];
    }
    return byteHexString;
}

@end

@implementation fitpolo705AlarmClockModel

- (void)updateAlarmClockModel:(NSString *)content{
    if (!fitpolo705ValidStr(content) || content.length != 8) {
        return;
    }
    self.clockType = [self getClockTypeWithString:[content substringWithRange:NSMakeRange(0, 2)]];
    self.statusModel = [fitpolo705StatusModel fetchStatusModel:[content substringWithRange:NSMakeRange(2, 2)]];
    NSInteger statusValue = [fitpolo705Parser getDecimalWithHex:content range:NSMakeRange(2, 2)];
    self.isOn = (statusValue & 0x80);
    self.hour = [fitpolo705Parser getDecimalWithHex:content range:NSMakeRange(4, 2)];
    self.minutes = [fitpolo705Parser getDecimalWithHex:content range:NSMakeRange(6, 2)];
}

- (NSString *)fetchCommand{
    if (self.hour < 0 || self.hour > 23 || self.minutes < 0 || self.minutes > 59) {
        return nil;
    }
    NSString *clockType = [self fetchAlarmClockType];
    NSString *clockSetting = [self.statusModel fetchAlarlClockSetInfo:self.isOn];
    NSString *hexHour = [NSString stringWithFormat:@"%1lx",(unsigned long)self.hour];
    if (hexHour.length == 1) {
        hexHour = [@"0" stringByAppendingString:hexHour];
    }
    NSString *hexMin = [NSString stringWithFormat:@"%1lx",(unsigned long)self.minutes];
    if (hexMin.length == 1) {
        hexMin = [@"0" stringByAppendingString:hexMin];
    }
    NSString *commandString = [NSString stringWithFormat:@"%@%@%@%@",clockType,clockSetting,hexHour,hexMin];
    return commandString;
}

- (NSString *)fetchAlarmClockType{
    switch (self.clockType) {
        case fitpolo705AlarmClockMedicine:
            return @"00";
        case fitpolo705AlarmClockDrink:
            return @"01";
        case fitpolo705AlarmClockNormal:
            return @"03";
        case fitpolo705AlarmClockSleep:
            return @"04";
        case fitpolo705AlarmClockExcise:
            return @"05";
        case fitpolo705AlarmClockSport:
            return @"06";
    }
}

//0x00:吃药;0x01:喝水;0x03:普通;0x04:睡觉;0x05:锻炼;0x06:跑步
- (fitpolo705AlarmClockType)getClockTypeWithString:(NSString *)type{
    if (!fitpolo705ValidStr(type) || type.length != 2) {
        return fitpolo705AlarmClockNormal;
    }
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

@end

@implementation fitpolo705AncsModel
//bit0为短信，bit1为电话，bit2为微信bit3为QQ，bit4为whatsapp，bit5为facebook，bit6 为twitter，bit7为 skype，bit 8 为snapchat，bit 9 为Line
+ (fitpolo705AncsModel *)fetchAncsOptionsModel:(NSString *)content{
    if (!content || content.length != 4) {
        return nil;
    }
    NSInteger statusValueHeight = [fitpolo705Parser getDecimalWithHex:content range:NSMakeRange(0, 2)];
    NSInteger statusValueLow = [fitpolo705Parser getDecimalWithHex:content range:NSMakeRange(2, 2)];
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

- (NSString *)ancsCommand{
    //短信、电话、微信、qq、whatsapp、facebook、twitter、skype、snapchat、Line
    unsigned long lowByte = 0;
    unsigned long highByte = 0;
    if (self.openSMS) lowByte |= 0x01;
    if (self.openPhone) lowByte |= 0x02;
    if (self.openWeChat) lowByte |= 0x04;
    if (self.openQQ) lowByte |= 0x08;
    if (self.openWhatsapp) lowByte |= 0x10;
    if (self.openFacebook) lowByte |= 0x20;
    if (self.openTwitter) lowByte |= 0x40;
    if (self.openSkype) lowByte |= 0x80;
    if (self.openSnapchat) highByte |= 0x01;
    if (self.openLine) highByte |= 0x02;
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

@end

@implementation fitpolo705CustomScreenModel
//Bit13跑步4界面, （必须为真）,Bit12跑步3界面,Bit11跑步2界面,Bit10跑步1界面, （必须为真）,Bit9跑步入口界面,（必须为真）,Bit8睡眠界面,Bit7运动时间界面,Bit6里程界面,bit5卡路里界面,bit4 计步界面,bit3血压界面，（必须为假）,bit2心率界面，bit1时间界面，（必须为真）,bit0配对界面，（必须为真）
+ (fitpolo705CustomScreenModel *)fetchCustomScreenModel:(NSString *)content{
    if (!content || content.length != 4) {
        return nil;
    }
    NSInteger screenHeight = [fitpolo705Parser getDecimalWithHex:content range:NSMakeRange(0, 2)];
    NSInteger screenLow = [fitpolo705Parser getDecimalWithHex:content range:NSMakeRange(2, 2)];
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
//Bit13跑步4界面, （必须为真）,Bit12跑步3界面,Bit11跑步2界面,Bit10跑步1界面, （必须为真）,Bit9跑步入口界面,（必须为真）,Bit8睡眠界面,Bit7运动时间界面,Bit6里程界面,bit5卡路里界面,bit4 计步界面,bit3血压界面，（必须为假）,bit2心率界面，bit1时间界面，（必须为真）,bit0配对界面，（必须为真）
- (NSString *)customScreenCommand{
    unsigned long highByte = 0;
    unsigned long lowByte = 1;
    lowByte |= 0x03;
    if (self.turnOnHeartRatePage) lowByte |= 0x04;
    lowByte |= 0x08;
    if (self.turnOnStepPage) lowByte |= 0x10;
    if (self.turnOnCaloriesPage) lowByte |= 0x20;
    if (self.turnOnSportsDistancePage) lowByte |= 0x40;
    if (self.turnOnSportsTimePage) lowByte |= 0x80;
    
    if (self.turnOnSleepPage) highByte |= 0x01;
    highByte |= 0x06;
    if (self.turnOnSecondRunning) highByte |= 0x08;
    if (self.turnOnThirdRunning) highByte |= 0x10;
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

@end
