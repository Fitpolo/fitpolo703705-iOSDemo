//
//  fitpolo705Parser.h
//  testSDK
//
//  Created by aa on 2018/3/13.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "fitpolo705AlarmClockModel.h"
#import "fitpolo705EnumerateDefine.h"
#import "fitpolo705TaskIDDefines.h"

@class fitpolo705ScanModel;
@class fitpolo705AncsModel;
@class fitpolo705CustomScreenModel;
@interface fitpolo705Parser : NSObject

+ (NSInteger)getDecimalWithHex:(NSString *)content range:(NSRange)range;
+ (NSString *)getDecimalStringWithHex:(NSString *)content range:(NSRange)range;
+ (NSArray *)interceptionOfArray:(NSArray *)originalArray subRange:(NSRange)range;
+ (NSData *)getCrc16VerifyCode:(NSData *)data;
+ (NSString *)getAncsCommand:(fitpolo705AncsModel *)ancsModel;
+ (NSString *)getAlarmClockType:(fitpolo705AlarmClockType)clockType;
+ (NSString *)getAlarlClockSetInfo:(fitpolo705StatusModel *)statusModel isOn:(BOOL)isOn;
+ (NSString *)getHeartRateAcquisitionInterval:(fitpolo705HeartRateAcquisitionInterval)intervalType;
+ (NSString *)hexStringFromData:(NSData *)sourceData;
+ (NSString *)getTimeStringWithDate:(NSDate *)date;
+ (NSString *)getCommandType:(fitpolo705TaskOperationID)operationID;
+ (NSData *)stringToData:(NSString *)dataString;
+ (NSArray *)getSleepDetailList:(NSString *)detail;
+ (NSArray *)getSleepDataList:(NSArray *)indexList recordList:(NSArray *)recordList;
+ (BOOL)isMacAddress:(NSString *)macAddress;
+ (BOOL)isMacAddressLowFour:(NSString *)lowFour;
+ (BOOL)isUUIDString:(NSString *)uuid;
+ (NSArray *)getAlarmClockDataList:(NSString *)content;
+ (fitpolo705AncsModel *)getAncsOptionsModel:(NSString *)content;
+ (NSDictionary *)getSedentaryRemindData:(NSString *)content;
+ (fitpolo705CustomScreenModel *)getCustomScreenModel:(NSString *)content;
+ (NSDictionary *)getUserInfo:(NSString *)content;
+ (NSDictionary *)getHardwareParameters:(NSString *)content;
+ (NSString *)getFirmwareVersion:(NSString *)content;
//解析睡眠index，记录到本地日志
+ (NSDictionary *)getSleepIndexData:(NSString *)content;
//解析睡眠record，记录到本地日志
+ (NSDictionary *)getSleepRecordData:(NSString *)content;
+ (NSDictionary *)getSportData:(NSString *)content;
+ (NSString *)getLastChargingTime:(NSString *)content;
+ (NSString *)getCustomScreenString:(fitpolo705CustomScreenModel *)screenModel;
+ (NSString *)getTimeSpaceWithStatus:(BOOL)isOn
                           startHour:(NSInteger)startHour
                        startMinutes:(NSInteger)startMinutes
                             endHour:(NSInteger)endHour
                          endMinutes:(NSInteger)endMinutes;
//解析读取回来的计步数据，并记录到本地
+ (NSDictionary *)getStepDetailData:(NSString *)content;
//解析心率数据，并记录到本地
+ (NSDictionary *)getHeartRateList:(NSString *)content;
+ (fitpolo705ScanModel *)getScanModelWithParamDic:(NSDictionary *)paramDic peripheral:(CBPeripheral *)peripheral;

@end
