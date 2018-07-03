//
//  fitpolo705StatusMonitoringManager.h
//  testSDK
//
//  Created by aa on 2018/3/19.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "fitpolo705EnumerateDefine.h"
#import "fitpolo705BlockDefine.h"

@interface fitpolo705StatusMonitoringManager : NSObject

/**
 当前中心与外设的连接状态
 */
@property (nonatomic, assign, readonly)fitpolo705ConnectStatus connectStatus;

/**
 中心蓝牙状态
 */
@property (nonatomic, assign, readonly)fitpolo705CentralManagerState centralBluetoothStatus;

/**
 监测当前外设连接状况
 
 @param statusBlock 当前外设连接状态回调
 */
- (void)startMonitoringConnectStatus:(fitpolo705ConnectStatusChangedBlock)statusBlock;

/**
 监测当前中心的蓝牙状态
 
 @param statusBlock 当前中心蓝牙状态回调
 */
- (void)startMonitoringCentralManagerStatus:(fitpolo705CentralStatusChangedBlock)statusBlock;

@end
