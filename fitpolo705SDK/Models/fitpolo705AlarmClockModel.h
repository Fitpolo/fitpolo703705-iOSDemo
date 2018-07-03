//
//  fitpolo705AlarmClockModel.h
//  testSDK
//
//  Created by aa on 2018/3/16.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@end

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

@end
