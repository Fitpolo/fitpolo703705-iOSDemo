//
//  fitpolo705CustomScreenModel.h
//  testSDK
//
//  Created by aa on 2018/4/11.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@end
