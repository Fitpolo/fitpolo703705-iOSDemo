//
//  fitpolo705Interface.h
//  testSDK
//
//  Created by aa on 2018/4/18.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "fitpolo705CentralManager.h"
#import "CBPeripheral+Characteristic.h"

@interface fitpolo705Interface : NSObject

#pragma mark - interface
/**
 获取当前手环的闹钟数据
 
 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)readPeripheralAlarmClockDatasWithSucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                                        failBlock:(fitpolo705CommunicationFailedBlock)failBlock;
/**
 获取手环的ancs选项
 
 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)readPeripheralAncsOptionsWithSucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                                    failBlock:(fitpolo705CommunicationFailedBlock)failBlock;
/**
 获取手环的久坐提醒数据
 
 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)readPeripheralSedentaryRemindDataWithSucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                                            failBlock:(fitpolo705CommunicationFailedBlock)failBlock;
/**
 获取手环的运动目标数据
 
 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)readPeripheralMovingTargetWithSucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                                     failBlock:(fitpolo705CommunicationFailedBlock)failBlock;
/**
 获取手环单位信息,@"00":公制,@"01":英制
 
 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)readPeripheralUnitDataWithSucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                                 failBlock:(fitpolo705CommunicationFailedBlock)failBlock;
/**
 获取手环时间进制，@"00":24h,@"01":12h
 
 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)readPeripheralTimeFormatDataWithSucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                                       failBlock:(fitpolo705CommunicationFailedBlock)failBlock;
/**
 读取当前手环显示的屏幕信息
 
 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)readPeripheralCustomScreenDisplayWithSucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                                            failBlock:(fitpolo705CommunicationFailedBlock)failBlock;
/**
 获取手环是否显示上一次屏幕,@(YES):打开，@(NO):关闭
 
 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)readPeripheralRemindLastScreenDisplayWithSucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                                                failBlock:(fitpolo705CommunicationFailedBlock)failBlock;
/**
 获取手环心率采集间隔,单位分钟
 
 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)readPeripheralHeartRateAcquisitionIntervalWithSucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                                                     failBlock:(fitpolo705CommunicationFailedBlock)failBlock;
/**
 获取手环勿扰时间段
 
 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)readPeripheralDoNotDisturbTimeWithSucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                                         failBlock:(fitpolo705CommunicationFailedBlock)failBlock;
/**
 获取翻腕亮屏
 
 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)readPeripheralPalmingBrightScreenWithSucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                                            failBlock:(fitpolo705CommunicationFailedBlock)failBlock;
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
                                 failBlock:(fitpolo705CommunicationFailedBlock)failBlock;
/**
 获取手环表盘样式
 
 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)readPeripheralDialStyleWithSucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                                  failBlock:(fitpolo705CommunicationFailedBlock)failBlock;
/**
 获取手环硬件参数
 
 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)readPeripheralHardwareParametersWithSucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                                           failBlock:(fitpolo705CommunicationFailedBlock)failBlock;
/**
 获取手环固件版本号
 
 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)readPeripheralFirmwareVersionWithSucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                                        failBlock:(fitpolo705CommunicationFailedBlock)failBlock;
/**
 请求睡眠数据
 
 @param date 要请求的时间点，返回的是该时间点之后的所有睡眠数据，格式必须为yyyy-MM-dd-HH-mm
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)readPeripheralSleepDataWithDate:(NSDate *)date
                               sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
                              failBlock:(fitpolo705CommunicationFailedBlock)failedBlock;
/**
 请求运动数据
 
 @param date 要请求的时间点，返回的是该时间点之后的所有运动数据，格式必须为yyyy-MM-dd-HH-mm
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)readPeripheralSportDataWithDate:(NSDate *)date
                               sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
                              failBlock:(fitpolo705CommunicationFailedBlock)failedBlock;
/**
 获取手环上一次充电时间
 
 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)readPeripheralLastChargingTimeWithSucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                                         failBlock:(fitpolo705CommunicationFailedBlock)failBlock;
/**
 获取手环电量
 
 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)readPeripheralBatteryWithSucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                                failBlock:(fitpolo705CommunicationFailedBlock)failBlock;

/**
 获取手环当前ancs连接状态
 
 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)readPeripheralANCSConnectStatusWithSucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                                          failBlock:(fitpolo705CommunicationFailedBlock)failBlock;

@end
