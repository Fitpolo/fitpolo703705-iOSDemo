//
//  fitpolo705Interface+StepGauge.h
//  testSDK
//
//  Created by aa on 2018/4/18.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "fitpolo705Interface.h"

//在手环打开监听计步数据的情况下，手环反馈回来的实时计步数据通知
extern NSString *const fitpolo705ListeningStateStepDataNotification;

@interface fitpolo705Interface (StepGauge)

/**
 读取计步数据
 
 @param date 要请求的时间点，返回的是该时间点之后的所有计步数据，格式必须为yyyy-MM-dd-HH-mm
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)readStepDataWithDate:(NSDate *)date
                    sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
                   failBlock:(fitpolo705CommunicationFailedBlock)failedBlock;
/**
 改变计步监测状态,打开监听状态之后，注册fitpolo705ListeningStateStepDataNotification通知，当手环步数发生改变的时候，会把当前的步数反馈给app
 
 @param open YES:open, NO:close
 @param sucBlock 成功回调
 @param failBlock 失败回调
 */
+ (void)stepChangeMeterMonitoringStatus:(BOOL)open
                               sucBlock:(fitpolo705CommunicationSuccessBlock)sucBlock
                              failBlock:(fitpolo705CommunicationFailedBlock)failBlock;

@end
