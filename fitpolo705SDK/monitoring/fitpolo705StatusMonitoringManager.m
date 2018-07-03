//
//  fitpolo705StatusMonitoringManager.m
//  testSDK
//
//  Created by aa on 2018/3/19.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "fitpolo705StatusMonitoringManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "fitpolo705ConstDefines.h"
#import "fitpolo705PeripheralManager.h"
#import "fitpolo705CentralManager.h"

@interface fitpolo705StatusMonitoringManager()

/**
 中心外设之间连接状态改变时的回调
 */
@property (nonatomic, copy)fitpolo705ConnectStatusChangedBlock peripheralStatusChangedBlock;

/**
 中心蓝牙状态改变
 */
@property (nonatomic, copy)fitpolo705CentralStatusChangedBlock centralManagerStatusChangedBlock;

/**
 当前中心与外设的连接状态
 */
@property (nonatomic, assign)fitpolo705ConnectStatus connectStatus;

@end

@implementation fitpolo705StatusMonitoringManager

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"监控中心销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:fitpolo705StartConnectPeripheralNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:fitpolo705ConnectSuccessNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:fitpolo705ConnectFailedNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:fitpolo705DisconnectPeripheralNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:fitpolo705BluetoothStateChangedNotification
                                                  object:nil];
}

- (instancetype)init{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(startConnectPeripheral)
                                                     name:fitpolo705StartConnectPeripheralNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(connectPeripheralSuccess)
                                                     name:fitpolo705ConnectSuccessNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(connectPeripheralFailed)
                                                     name:fitpolo705ConnectFailedNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(peripheralDisconnect)
                                                     name:fitpolo705DisconnectPeripheralNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(centralManagerStateChanged)
                                                     name:fitpolo705BluetoothStateChangedNotification
                                                   object:nil];
        self.connectStatus = [[fitpolo705CentralManager sharedInstance] getCurrentConnectStatus];
    }
    return self;
}

#pragma mark - Public Method
/**
 监测当前外设连接状况
 
 @param statusBlock 当前外设连接状态回调
 */
- (void)startMonitoringConnectStatus:(fitpolo705ConnectStatusChangedBlock)statusBlock{
    if (!statusBlock) {
        return;
    }
    fitpolo705_main_safe(^{statusBlock(self.connectStatus);});
    self.peripheralStatusChangedBlock = statusBlock;
}

/**
 获取当前中心蓝牙状态
 
 @return 当前中心蓝牙状态
 */
- (fitpolo705CentralManagerState)centralBluetoothStatus{
    fitpolo705CentralManager *manager = [fitpolo705CentralManager sharedInstance];
    if (manager.centralManager.state == CBCentralManagerStatePoweredOn) {
        //蓝牙可用
        return fitpolo705CentralManagerStateEnable;
    }
    return fitpolo705CentralManagerStateUnable;
}

/**
 监测当前中心的蓝牙状态
 
 @param statusBlock 当前中心蓝牙状态回调
 */
- (void)startMonitoringCentralManagerStatus:(fitpolo705CentralStatusChangedBlock)statusBlock{
    if (!statusBlock) {
        return;
    }
    fitpolo705CentralManager *manager = [fitpolo705CentralManager sharedInstance];
    if (manager.centralManager.state == CBCentralManagerStatePoweredOn) {
        //蓝牙可用
        fitpolo705_main_safe(^{statusBlock(fitpolo705CentralManagerStateEnable);});
    }else{
        //未知状态
        fitpolo705_main_safe(^{statusBlock(fitpolo705CentralManagerStateUnable);});
    }
    self.centralManagerStatusChangedBlock = statusBlock;
}

#pragma mark - Notification Method

/**
 中心开始连接外设
 */
-(void)startConnectPeripheral{
    self.connectStatus = fitpolo705ConnectStatusConnecting;
    [self connectStatusChanged];
}

/**
 中心连接外设成功
 */
- (void)connectPeripheralSuccess{
    self.connectStatus = fitpolo705ConnectStatusConnected;
    [self connectStatusChanged];
}

/**
 中心连接外设失败
 */
- (void)connectPeripheralFailed{
    self.connectStatus = fitpolo705ConnectStatusConnectedFailed;
    [self connectStatusChanged];
}

/**
 中心外设断开连接
 */
- (void)peripheralDisconnect{
    self.connectStatus = fitpolo705ConnectStatusDisconnect;
    [self connectStatusChanged];
}

/**
 中心蓝牙状态发生改变
 */
- (void)centralManagerStateChanged{
    if (!self.centralManagerStatusChangedBlock) {
        return;
    }
    fitpolo705_main_safe(^{
        fitpolo705CentralManager *manager = [fitpolo705CentralManager sharedInstance];
        if (manager.centralManager.state == CBCentralManagerStatePoweredOn) {
            //蓝牙可用
            self.centralManagerStatusChangedBlock(fitpolo705CentralManagerStateEnable);
        }else{
            //未知状态
            self.centralManagerStatusChangedBlock(fitpolo705CentralManagerStateUnable);
        }
    });
}

#pragma mark - private method
- (void)connectStatusChanged {
    if (!self.peripheralStatusChangedBlock) {
        return;
    }
    fitpolo705_main_safe(^{
        self.peripheralStatusChangedBlock(self.connectStatus);
    });
}

@end
