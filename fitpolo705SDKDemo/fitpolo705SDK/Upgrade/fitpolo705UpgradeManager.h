//
//  fitpolo705UpgradeManager.h
//  testSDK
//
//  Created by aa on 2018/3/20.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 升级成功回调
 */
typedef void(^fitpolo705UpdateProcessSuccessBlock)(void);

/**
 升级失败回调
 
 @param error 错误原因
 */
typedef void(^fitpolo705UpdateProcessFailedBlock)(NSError *error);

/**
 进度回调
 
 @param progress 当前升级进度
 */
typedef void(^fitpolo705UpdateProgressBlock)(CGFloat progress);

@interface fitpolo705UpgradeManager : NSObject

/**
 是否正在升级,升级开始的时候，需要断开手环连接，然后重新连接手环，这个时候手环会处于高速模式，才能进行升级,如果是这种情形下引起的手环连接状态发生改变，主页面需要区分开来
 */
@property (nonatomic, assign)BOOL switchHighModel;

/**
 是否处于升级状态，如果是升级状态，从后台切刀切到前台的时候，不能请求数据
 */
@property (nonatomic, assign)BOOL updating;

/**
 开启手环固件升级流程
 
 @param packageData 升级数据包
 @param successBlock 成功回调
 @param progressBlock 升级进度回调
 @param failedBlock 失败回调
 */
- (void)startUpdateProcessWithPackageData:(NSData *)packageData
                             successBlock:(fitpolo705UpdateProcessSuccessBlock)successBlock
                            progressBlock:(fitpolo705UpdateProgressBlock)progressBlock
                              failedBlock:(fitpolo705UpdateProcessFailedBlock)failedBlock;

@end
