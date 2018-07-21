//
//  fitpolo705Parser.h
//  testSDK
//
//  Created by aa on 2018/3/13.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "fitpolo705Models.h"
#import "fitpolo705TaskIDDefines.h"

/*
 自定义的错误码
 */
typedef NS_ENUM(NSInteger, fitpolo705CustomErrorCode){
    fitpolo705BlueDisable = -10000,                                     //当前手机蓝牙不可用
    fitpolo705ConnectedFailed = -10001,                                 //连接外设失败
    fitpolo705PeripheralDisconnected = -10002,                          //当前外部连接的设备处于断开状态
    fitpolo705CharacteristicError = -10003,                             //特征为空
    fitpolo705RequestPeripheralDataError = -10004,                      //请求手环数据出错
    fitpolo705ParamsError = -10005,                                     //输入的参数有误
    fitpolo705SetParamsError = -10006,                                  //设置参数出错
    fitpolo705GetPackageError = -10007,                                 //升级固件的时候，传过来的固件数据出错
    fitpolo705UpdateError = -10008,                                     //升级失败
};

@interface fitpolo705Parser : NSObject

#pragma mark - blocks
+ (NSError *)getErrorWithCode:(fitpolo705CustomErrorCode)code message:(NSString *)message;
+ (void)operationCentralBlePowerOffBlock:(void (^)(NSError *error))block;
+ (void)operationConnectFailedBlock:(void (^)(NSError *error))block;
+ (void)operationDisconnectedErrorBlock:(void (^)(NSError *error))block;
+ (void)operationCharacteristicErrorBlock:(void (^)(NSError *error))block;
+ (void)operationRequestDataErrorBlock:(void (^)(NSError *error))block;
+ (void)operationParamsErrorBlock:(void (^)(NSError *error))block;
+ (void)operationSetParamsErrorBlock:(void (^)(NSError *error))block;
+ (void)operationGetPackageDataErrorBlock:(void (^)(NSError *error))block;
+ (void)operationUpdateErrorBlock:(void (^)(NSError *error))block;
+ (void)operationSetParamsResult:(id)returnData
                        sucBlock:(void (^)(id returnData))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock;

#pragma mark - parser
+ (NSInteger)getDecimalWithHex:(NSString *)content range:(NSRange)range;
+ (NSString *)getDecimalStringWithHex:(NSString *)content range:(NSRange)range;
+ (NSArray *)interceptionOfArray:(NSArray *)originalArray subRange:(NSRange)range;
+ (NSData *)getCrc16VerifyCode:(NSData *)data;
+ (NSString *)hexStringFromData:(NSData *)sourceData;
+ (NSString *)getTimeStringWithDate:(NSDate *)date;
+ (NSData *)stringToData:(NSString *)dataString;
+ (NSArray *)getSleepDetailList:(NSString *)detail;
+ (NSArray *)getSleepDataList:(NSArray *)indexList recordList:(NSArray *)recordList;
+ (BOOL)isMacAddress:(NSString *)macAddress;
+ (BOOL)isMacAddressLowFour:(NSString *)lowFour;
+ (BOOL)isUUIDString:(NSString *)uuid;
+ (BOOL)checkIdenty:(NSString *)identy;
+ (NSArray <fitpolo705AlarmClockModel *>*)getAlarmClockDataList:(NSString *)content;
+ (NSDictionary *)getSedentaryRemindData:(NSString *)content;
+ (NSDictionary *)getUserInfo:(NSString *)content;
+ (NSDictionary *)getHardwareParameters:(NSString *)content;
+ (NSString *)getFirmwareVersion:(NSString *)content;
//解析睡眠index，记录到本地日志
+ (NSDictionary *)getSleepIndexData:(NSString *)content;
//解析睡眠record，记录到本地日志
+ (NSDictionary *)getSleepRecordData:(NSString *)content;
+ (NSDictionary *)getSportData:(NSString *)content;
+ (NSString *)getLastChargingTime:(NSString *)content;
+ (NSString *)getTimeSpaceWithStatus:(BOOL)isOn
                           startHour:(NSInteger)startHour
                        startMinutes:(NSInteger)startMinutes
                             endHour:(NSInteger)endHour
                          endMinutes:(NSInteger)endMinutes;
//解析读取回来的计步数据，并记录到本地
+ (NSDictionary *)getStepDetailData:(NSString *)content;
//解析心率数据，并记录到本地
+ (NSDictionary *)getHeartRateList:(NSString *)content;
/**
 监听状态下手环返回的实时计步数据
 
 @param content 手环原始数据
 @return @{}
 */
+ (NSDictionary *)getListeningStateStepData:(NSString *)content;

@end
