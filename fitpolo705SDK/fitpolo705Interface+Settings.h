//
//  fitpolo705Interface+Settings.h
//  testSDK
//
//  Created by aa on 2018/4/18.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "fitpolo705Interface.h"
#import "fitpolo705Models.h"

typedef NS_ENUM(NSInteger, fitpolo705Unit) {
    fitpolo705MetricSystem,         //公制
    fitpolo705Imperial,             //英制
};
typedef NS_ENUM(NSInteger, fitpolo705Gender) {
    fitpolo705Male,             //男性
    fitpolo705Female,           //女性
};
typedef NS_ENUM(NSInteger, fitpolo705TimeFormat) {
    fitpolo70524Hour,         //24小时制
    fitpolo70512Hour,         //12小时制
};
typedef NS_ENUM(NSInteger, fitpolo705DialStyle) {
    fitpolo705DialStyle1,
    fitpolo705DialStyle2,
    fitpolo705DialStyle3,
};
@interface fitpolo705Interface (Settings)

/**
 设置设备闹钟
 
 @param list 闹钟列表，最多8个闹钟。如果list为nil或者个数为0，则认为关闭全部闹钟
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)setAlarmClock:(NSArray <fitpolo705AlarmClockModel *>*)list
             sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
            failBlock:(fitpolo705CommunicationFailedBlock)failedBlock;

/**
 开启ancs提醒
 
 @param ancsModel ancsModel
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)setANCSNoticeOptions:(fitpolo705AncsModel *)ancsModel
                    sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
                   failBlock:(fitpolo705CommunicationFailedBlock)failedBlock;
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
                 failBlock:(fitpolo705CommunicationFailedBlock)failedBlock;
/**
 设置运动目标
 
 @param movingTarget 运动目标1~60000
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)setMovingTarget:(NSInteger)movingTarget
               sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
              failBlock:(fitpolo705CommunicationFailedBlock)failedBlock;
/**
 手环屏幕单位选择
 
 @param unit unit
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)setUnitSwitch:(fitpolo705Unit)unit
             sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
            failBlock:(fitpolo705CommunicationFailedBlock)failedBlock;
/**
 设置设备的时间进制
 
 @param timerFormat 24/12进制
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)setTimeFormat:(fitpolo705TimeFormat)timerFormat
             sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
            failBlock:(fitpolo705CommunicationFailedBlock)failedBlock;
/**
 设置屏幕显示
 
 @param screenModel  screenModel
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)setCustomScreenDisplay:(fitpolo705CustomScreenModel *)screenModel
                      sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
                     failBlock:(fitpolo705CommunicationFailedBlock)failedBlock;
/**
 设置设备是否记住上一次屏幕显示
 
 @param remind YES:记住，当手环亮屏的时候显示上一次屏幕熄灭时候的屏显。NO:当手环亮屏的时候显示时间屏显
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)setRemindLastScreenDisplay:(BOOL)remind
                          sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
                         failBlock:(fitpolo705CommunicationFailedBlock)failedBlock;
/**
 设置心率采集间隔
 
 @param interval 0~30，如果设置为0，则关闭心率采集
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)setHeartRateAcquisitionInterval:(NSInteger)interval
                               sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
                              failBlock:(fitpolo705CommunicationFailedBlock)failedBlock;
/**
 设置勿扰时段
 
 @param isOn YES:打开勿扰功能，NO:关闭勿扰功能,这种状态下，开始时间和结束时间就没有任何意义了
 @param startHour 久坐提醒开始时,0~23
 @param startMinutes 久坐提醒开始分,0~59
 @param endHour 久坐提醒结束时,0~23
 @param endMinutes 久坐提醒结束分,0~59
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)setDoNotDisturbTime:(BOOL)isOn
                  startHour:(NSInteger)startHour
               startMinutes:(NSInteger)startMinutes
                    endHour:(NSInteger)endHour
                 endMinutes:(NSInteger)endMinutes
                   sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
                  failBlock:(fitpolo705CommunicationFailedBlock)failedBlock;
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
                     failBlock:(fitpolo705CommunicationFailedBlock)failedBlock;
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
            failBlock:(fitpolo705CommunicationFailedBlock)failedBlock;
/**
 设置设备日期
 
 @param date 日期,2000年~2099年
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)setDate:(NSDate *)date
       sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
      failBlock:(fitpolo705CommunicationFailedBlock)failedBlock;
/**
 设置设备表盘样式
 
 @param dialStyle 表盘样式
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)setDialStyle:(fitpolo705DialStyle)dialStyle
            sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
           failBlock:(fitpolo705CommunicationFailedBlock)failedBlock;
/**
 手环震动指令
 
 @param successBlock 成功Block
 @param failedBlock 失败Block
 */
+ (void)peripheralVibration:(fitpolo705CommunicationSuccessBlock)successBlock
                failedBlock:(fitpolo705CommunicationFailedBlock)failedBlock;

@end
