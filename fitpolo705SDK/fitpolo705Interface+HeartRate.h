//
//  fitpolo705Interface+HeartRate.h
//  testSDK
//
//  Created by aa on 2018/4/18.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "fitpolo705Interface.h"

@interface fitpolo705Interface (HeartRate)

/**
 读取心率数据
 
 @param date 要请求的时间点，返回的是该时间点之后的所有计步数据，格式必须为yyyy-MM-dd-HH-mm
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)readHeartRateDataWithDate:(NSDate *)date
                         sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
                        failBlock:(fitpolo705CommunicationFailedBlock)failedBlock;
/**
 读取运动心率数据
 
 @param date 要请求的时间点，返回的是该时间点之后的所有运动心率数据，格式必须为yyyy-MM-dd-HH-mm
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)readSportHeartRateDataWithDate:(NSDate *)date
                              sucBlock:(fitpolo705CommunicationSuccessBlock)successBlock
                             failBlock:(fitpolo705CommunicationFailedBlock)failedBlock;

@end
