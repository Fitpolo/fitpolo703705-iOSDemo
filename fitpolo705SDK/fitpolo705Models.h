//
//  fitpolo705Models.h
//  fitpolo705SDKDemo
//
//  Created by aa on 2018/7/20.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface fitpolo705Models : NSObject

@end

#pragma mark - fitpolo705StatusModel
/**
 闹钟类型
 
 - alarmClockNormal: 普通闹钟
 */
typedef NS_ENUM(NSInteger, fitpolo705AlarmClockType) {
    fitpolo705AlarmClockNormal,           //普通
    fitpolo705AlarmClockMedicine,         //吃药
    fitpolo705AlarmClockDrink,            //喝水
    fitpolo705AlarmClockSleep,            //睡眠
    fitpolo705AlarmClockExcise,           //锻炼
    fitpolo705AlarmClockSport,            //运动
};

@interface fitpolo705StatusModel : NSObject
/**
 周一是否打开
 */
@property (nonatomic, assign)BOOL mondayIsOn;
/**
 周二是否打开
 */
@property (nonatomic, assign)BOOL tuesdayIsOn;
/**
 周三是否打开
 */
@property (nonatomic, assign)BOOL wednesdayIsOn;
/**
 周四是否打开
 */
@property (nonatomic, assign)BOOL thursdayIsOn;
/**
 周五是否打开
 */
@property (nonatomic, assign)BOOL fridayIsOn;
/**
 周六是否打开
 */
@property (nonatomic, assign)BOOL saturdayIsOn;
/**
 周日是否打开
 */
@property (nonatomic, assign)BOOL sundayIsOn;

+ (fitpolo705StatusModel *)fetchStatusModel:(NSString *)content;

- (NSString *)fetchAlarlClockSetInfo:(BOOL)isOn;

@end

#pragma mark - fitpolo705AlarmClockModel

@interface fitpolo705AlarmClockModel : NSObject

/**
 闹钟类型
 */
@property (nonatomic, assign)fitpolo705AlarmClockType clockType;
/**
 是否打开
 */
@property (nonatomic, assign)BOOL isOn;
/**
 闹钟时
 */
@property (nonatomic, assign)NSInteger hour;
/**
 闹钟分
 */
@property (nonatomic, assign)NSInteger minutes;
/**
 闹钟状态
 */
@property (nonatomic, strong)fitpolo705StatusModel *statusModel;

- (void)updateAlarmClockModel:(NSString *)content;

- (NSString *)fetchCommand;

@end

#pragma mark - fitpolo705AncsModel
@interface fitpolo705AncsModel : NSObject

/**
 打开短信提醒
 */
@property (nonatomic, assign)BOOL openSMS;

/**
 打开电话提醒
 */
@property (nonatomic, assign)BOOL openPhone;

/**
 打开微信提醒
 */
@property (nonatomic, assign)BOOL openWeChat;

/**
 打开qq提醒
 */
@property (nonatomic, assign)BOOL openQQ;

/**
 打开whatsapp提醒
 */
@property (nonatomic, assign)BOOL openWhatsapp;

/**
 打开facebook提醒
 */
@property (nonatomic, assign)BOOL openFacebook;

/**
 打开twitter提醒
 */
@property (nonatomic, assign)BOOL openTwitter;

/**
 打开skype提醒
 */
@property (nonatomic, assign)BOOL openSkype;

/**
 打开snapchat提醒
 */
@property (nonatomic, assign)BOOL openSnapchat;

/**
 打开Line
 */
@property (nonatomic, assign)BOOL openLine;

+ (fitpolo705AncsModel *)fetchAncsOptionsModel:(NSString *)content;

- (NSString *)ancsCommand;

@end

#pragma mark - fitpolo705CustomScreenModel
@interface fitpolo705CustomScreenModel : NSObject

//心率页面
@property (nonatomic, assign)BOOL turnOnHeartRatePage;
//计步页面
@property (nonatomic, assign)BOOL turnOnStepPage;
//卡路里页面
@property (nonatomic, assign)BOOL turnOnCaloriesPage;
//运动距离页面
@property (nonatomic, assign)BOOL turnOnSportsDistancePage;
//运动时间页面
@property (nonatomic, assign)BOOL turnOnSportsTimePage;
//睡眠页面
@property (nonatomic, assign)BOOL turnOnSleepPage;
//跑步2页面
@property (nonatomic, assign)BOOL turnOnSecondRunning;
//跑步3页面
@property (nonatomic, assign)BOOL turnOnThirdRunning;

+ (fitpolo705CustomScreenModel *)fetchCustomScreenModel:(NSString *)content;

- (NSString *)customScreenCommand;

@end
