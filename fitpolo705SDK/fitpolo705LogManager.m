//
//  fitpolo705LogManager.m
//  testSDK
//
//  Created by aa on 2018/3/14.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "fitpolo705LogManager.h"
#import <objc/runtime.h>
#import "fitpolo705Defines.h"

static const char *formatterKey = "formatterKey";
static NSString *const localFileName = @"/HCKCommunicationData.txt";

@implementation fitpolo705LogManager

#pragma mark - Public method

/**
 写入命令到本地文件,本地目前只保留一周的数据
 
 @param dataList 要写入的数据，可以写入一系列的数据，数组里面必须是字符串
 @param source app-->device或者是device-->app
 */
+ (void)writeCommandToLocalFile:(NSArray *)dataList
                 withSourceInfo:(fitpolo705DataDirection )source{
    if (!fitpolo705ValidArray(dataList)) {
        return;
    }
    NSString *sourceInfo = (source == fitpolo705DataSourceAPP ? @"app:" : @"device:");
    NSString *path = [self getCachesDirectory];
    NSString *filePath = [path stringByAppendingString:localFileName];
    BOOL exit = [self fileExistInPath:filePath isDirectory:NO];
    if (!exit) {
        BOOL createResult = [self createFileInPath:path fileName:localFileName];
        if (!createResult) {
            NSLog(@"创建文件出错");
            return;
        }
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:filePath error:&error];
    if (error || !fitpolo705ValidDict(fileAttributes)) {
        return;
    }
    NSDate *createDate = fileAttributes[@"NSFileCreationDate"];
    NSString *createTimeInfo = [[self formatter] stringFromDate:createDate];
    
    if (!fitpolo705ValidStr(createTimeInfo)) {
        NSLog(@"写入错误");
        return;
    }
    NSArray *timeArr = [createTimeInfo componentsSeparatedByString:@" "];
    if (!fitpolo705ValidArray(timeArr)) {
        NSLog(@"写入错误");
        return;
    }
    NSString *createTime = timeArr[0];
    if (!fitpolo705ValidStr(createTime)) {
        NSLog(@"写入错误");
        return;
    }
    
    NSString *datestr = [self.formatter stringFromDate:[NSDate date]];
    NSArray *dateArr = [datestr componentsSeparatedByString:@" "];
    NSString *dateInfo = dateArr[0];
    NSInteger week = [self getWeekInfoWithDateString:dateInfo];
    if (week == 1 && ![dateInfo isEqualToString:createTime]) {
        BOOL deleteResult = [self deleteFileInPath:filePath];
        if (deleteResult) {
            BOOL createResult = [self createFileInPath:path fileName:localFileName];
            if (!createResult) {
                NSLog(@"创建文件出错");
                return;
            }
        }
    }
    @synchronized(self) {
        //写数据部分
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
        [fileHandle seekToEndOfFile];   //将节点跳到文件的末尾
        for (NSString *tempData in dataList) {
            NSString *stringToWrite = [NSString stringWithFormat:@"\n%@  %@%@",datestr,sourceInfo,tempData];
            //        NSLog(@"写入的数据:%@",stringToWrite);
            NSData *stringData = [stringToWrite dataUsingEncoding:NSUTF8StringEncoding];
            [fileHandle writeData:stringData];
        }
        [fileHandle closeFile];
    }
}

+ (void)writeCommandToLocalFile:(NSString *)data
                 withSourceInfo:(fitpolo705DataDirection)source
                    operationID:(fitpolo705TaskOperationID)operationID{
    NSString *commandType = [self getCommandType:operationID];
    NSString *string = [NSString stringWithFormat:@"%@:%@",commandType,data];
    [self writeCommandToLocalFile:@[string] withSourceInfo:source];
}

/**
 读取本地存储的命令数据
 
 @return 存储的命令数据
 */
+ (NSData *)readCommandDataFromLocalFile{
    NSString *path = [self getCachesDirectory];
    NSString *filePath = [path stringByAppendingString:localFileName];
    NSString *fileString = [self readFileInPath:filePath];
    if (!fitpolo705ValidStr(fileString)) {
        return nil;
    }
    NSData *fileData = [fileString dataUsingEncoding:NSUTF8StringEncoding];
    return fileData;
}

#pragma mark - Private method

/**
 获取Caches文件目录
 
 @return Caches文件目录
 */
+ (NSString *)getCachesDirectory{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES)lastObject];
}

/**
 根据传过来的日期，判断是周几
 
 @param dateString 时间格式必须是yyyy-MM-dd
 @return 返回对应的星期几
 */
+ (NSInteger)getWeekInfoWithDateString:(NSString *)dateString{
    if (!fitpolo705ValidStr(dateString)) {
        return 0;
    }
    NSArray * dateArr = [dateString componentsSeparatedByString:@"-"];
    
    if (!fitpolo705ValidArray(dateArr)
        || dateArr.count != 3) {
        return 0;
    }
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:[dateArr[2] integerValue]];
    [comps setMonth:[dateArr[1] integerValue]];
    [comps setYear:[dateArr[0] integerValue]];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [gregorian dateFromComponents:comps];
    NSDateComponents *weekdayComponents = [gregorian components:NSCalendarUnitWeekday
                                                       fromDate:date];
    NSInteger weekday = [weekdayComponents weekday];
    NSInteger week = 0;
    switch (weekday) {
        case 1:
            week = 7;
            break;
        case 2:
            week = 1;
            break;
        case 3:
            week = 2;
            break;
        case 4:
            week = 3;
            break;
        case 5:
            week = 4;
            break;
        case 6:
            week = 5;
            break;
        case 7:
            week = 6;
            break;
        default: week = 0;
            break;
    }
    
    return week;
}

/**
 指定路径下面是否存在文件或者文件夹
 
 @param path 指定的路径
 @param isDirectory 是否是文件夹，YES:文件夹,NO:文件
 @return YES:存在，NO:不存在
 */
+ (BOOL)fileExistInPath:(NSString *)path
            isDirectory:(BOOL)isDirectory{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:path
                                     isDirectory:&isDirectory];
    return existed;
}


/**
 创建文件
 
 @param path 要创建文件的路径
 @param fileName 文件名字
 @return YES:创建成功，NO:创建失败
 */
+ (BOOL)createFileInPath:(NSString *)path
                fileName:(NSString *)fileName{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *newFilePath = [path stringByAppendingPathComponent:fileName];
    BOOL res = [fileManager createFileAtPath:newFilePath
                                    contents:nil
                                  attributes:nil];
    if (res) {
        //文件创建成功
        return YES;
    }else{
        //文件创建失败
        return NO;
    }
}

/**
 删除文件
 
 @param path 文件路径
 @return YES:删除成功，NO:删除失败
 */
+ (BOOL)deleteFileInPath:(NSString *)path{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL res = [fileManager removeItemAtPath:path
                                       error:nil];
    if (res) {
        //文件删除成功
        return YES;
    }else{
        //文件删除失败
        return NO;
    }
}

/**
 读取文件
 
 @param path 文件路径
 @return 读取的数据
 */
+ (NSString *)readFileInPath:(NSString *)path{
    NSString *content=[NSString stringWithContentsOfFile:path
                                                encoding:NSUTF8StringEncoding
                                                   error:nil];
    return content;
}

+ (NSDateFormatter *)formatter{
    NSDateFormatter *formatter = objc_getAssociatedObject(self, &formatterKey);
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        objc_setAssociatedObject(self, &formatterKey, formatter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return formatter;
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
        case fitpolo705GetDialStyleOperation:
            return @"获取手环表盘样式";
        case fitpolo705SetDialStyleOperation:
            return @"设置表盘样式";
        case fitpolo705StepChangeMeterMonitoringStatusOperation:
            return @"改变计步监听功能状态";
        case fitpolo705DefaultTaskOperationID:
            return @"";
    }
}

@end

