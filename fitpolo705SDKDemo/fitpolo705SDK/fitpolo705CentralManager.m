//
//  fitpolo705CentralManager.m
//  testSDK
//
//  Created by aa on 2018/3/13.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "fitpolo705CentralManager.h"
#import <objc/runtime.h>
#import "fitpolo705LogManager.h"
#import "fitpolo705Parser.h"
#import "fitpolo705PeripheralManager.h"
#import "fitpolo705ScanModel.h"

typedef NS_ENUM(NSInteger, currentManagerAction) {
    currentManagerActionDefault,
    currentManagerActionScan,
    currentManagerActionConnectPeripheral,
    currentManagerActionConnectPeripheralWithScan,
};

static const char *connectedModelKey = "connectedModelKey";

static NSInteger const scanConnectMacCount = 2;

static fitpolo705CentralManager *manager = nil;
static dispatch_once_t onceToken;

@interface fitpolo705CentralManager()<CBCentralManagerDelegate>

/**
 中心设备
 */
@property (nonatomic, strong)CBCentralManager *centralManager;

/**
 设备管理者
 */
@property (nonatomic, strong)fitpolo705PeripheralManager *peripheralManager;

/**
 扫描定时器
 */
@property (nonatomic, strong)dispatch_source_t scanTimer;

/**
 连接定时器，超过指定时间将会视为连接失败
 */
@property (nonatomic, strong)dispatch_source_t connectTimer;

@property (nonatomic, copy)fitpolo705ConnectPeripheralFailedBlock connectFailBlock;

@property (nonatomic, copy)fitpolo705ConnectPeripheralSuccessBlock connectSucBlock;

/**
 当前运行方式
 */
@property (nonatomic, assign)currentManagerAction managerAction;

/**
 完成了一个扫描周期
 */
@property (nonatomic, assign)BOOL scanTimeout;

/**
 用扫描方式连接设备的时候，未扫到设备次数，超过指定次数需要结束扫描，连接设备失败
 */
@property (nonatomic, assign)NSInteger scanConnectCount;

/**
 扫描方式连接设备时候的标识符，UUID、mac地址、mac地址低四位
 */
@property (nonatomic, copy)NSString *identifier;

/**
 当前连接状态
 */
@property (nonatomic, assign)fitpolo705ConnectStatus connectStatus;

/**
 扫描或者通过扫描方式连接设备的时候，需要给出指定设备的类型，703、705目前共用一套SDK
 */
@property (nonatomic, assign)operationPeripheralType peripheralType;

@end

@implementation fitpolo705CentralManager

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"中心销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:fitpolo705PeripheralConnectedFailedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:fitpolo705PeripheralConnectedSuccessNotification object:nil];
}

//生成唯一的实例
-(instancetype) initUniqueInstance {
    if (self = [super init]) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(connectPeripheralFailed)
                                                     name:fitpolo705PeripheralConnectedFailedNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(connectPeripheralSuccess) name:fitpolo705PeripheralConnectedSuccessNotification
                                                   object:nil];
    }
    return self;
}

+ (fitpolo705CentralManager *)sharedInstance{
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [[super alloc] initUniqueInstance];
        }
    });
    return manager;
}

+ (void)attempDealloc{
    onceToken = 0; // 只有置成0,GCD才会认为它从未执行过.它默认为0.这样才能保证下次再次调用shareInstance的时候,再次创建对象.
    manager = nil;
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    [[NSNotificationCenter defaultCenter] postNotificationName:fitpolo705BluetoothStateChangedNotification object:nil];
    if (central.state == CBCentralManagerStatePoweredOn) {
        return;
    }
    self.connectStatus = fitpolo705ConnectStatusDisconnect;
    [[NSNotificationCenter defaultCenter] postNotificationName:fitpolo705DisconnectPeripheralNotification object:nil];
    if (self.managerAction == currentManagerActionDefault) {
        return;
    }
    if (self.managerAction == currentManagerActionScan) {
        self.managerAction = currentManagerActionDefault;
        self.peripheralType = operationPeripheralTypeUnknow;
        [self.centralManager stopScan];
        fitpolo705_main_safe(^{
            if ([self.scanDelegate respondsToSelector:@selector(fitpolo705StopScan)]) {
                [self.scanDelegate fitpolo705StopScan];
            }
        });
        return;
    }
    [self.peripheralManager cancelConnect];
    [self connectPeripheralFailed];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    if (RSSI.integerValue == 127) {
        return;
    }
    NSLog(@"扫描到的设备广播数据:%@",advertisementData);
    [self scanNewPeripheral:peripheral advDic:advertisementData];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    [self.peripheralManager connectPeripheral:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    [[NSNotificationCenter defaultCenter] postNotificationName:fitpolo705ConnectFailedNotification
                                                        object:nil
                                                      userInfo:nil];
    [self.peripheralManager cancelConnect];
    [self connectPeripheralFailed];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"断开连接");
    [[NSNotificationCenter defaultCenter] postNotificationName:fitpolo705DisconnectPeripheralNotification
                                                        object:nil
                                                      userInfo:nil];
    self.connectStatus = fitpolo705ConnectStatusDisconnect;
    [self.peripheralManager cancelConnect];
}

#pragma mark - Public method
- (void)startScanPeripheral:(operationPeripheralType)peripheralType{
    if (self.centralManager.state != CBCentralManagerStatePoweredOn || peripheralType == operationPeripheralTypeUnknow) {
        //蓝牙状态不可用
        return;
    }
    self.peripheralType = peripheralType;
    self.managerAction = currentManagerActionScan;
    fitpolo705_main_safe(^{
        if ([self.scanDelegate respondsToSelector:@selector(fitpolo705StartScan)]) {
            [self.scanDelegate fitpolo705StartScan];
        }
    });
    //日志
    [fitpolo705LogManager writeCommandToLocalFile:@[@"开始扫描"] withSourceInfo:fitpolo705DataSourceAPP];
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"FFC0"]]
                                                options:nil];
    
}

/**
 停止扫描
 */
- (void)stopScan{
    [self.centralManager stopScan];
    self.managerAction = currentManagerActionDefault;
    self.peripheralType = operationPeripheralTypeUnknow;
    fitpolo705_main_safe(^{
        if ([self.scanDelegate respondsToSelector:@selector(fitpolo705StopScan)]) {
            [self.scanDelegate fitpolo705StopScan];
        }
    });
}

/**
 根据标识符和连接方式来连接指定的外设
 
 @param identifier 要连接外设的标识符,目前支持设备UUID、设备mac地址(xx-xx-xx-xx-xx-xx)、设备mac地址低四位(xx-xx)三种连接方式。
 @param connectType 连接方式
 @param peripheralType 连接设备的类型，703/705
 @param successBlock 连接设备成功回调
 @param failedBlock 连接设备失败回调
 */
- (void)connectPeripheralWithIdentifier:(NSString *)identifier
                            connectType:(fitpolo705ConnectPeripheralType)connectType
                         peripheralType:(operationPeripheralType)peripheralType
                    connectSuccessBlock:(fitpolo705ConnectPeripheralSuccessBlock)successBlock
                       connectFailBlock:(fitpolo705ConnectPeripheralFailedBlock)failedBlock{
    if (self.centralManager.state != CBCentralManagerStatePoweredOn) {
        //蓝牙状态不可用
        fitpolo705BleStateError(failedBlock);
        return;
    }
    if (peripheralType == operationPeripheralTypeUnknow) {
        //
        if (failedBlock) {
            fitpolo705_main_safe(^{
                NSError *error = [[NSError alloc] initWithDomain:fitpolo705CustomErrorDomain
                                                            code:fitpolo705ConnectedFailed
                                                        userInfo:@{@"errorInfo":@"Must specify the connection type"}];
                failedBlock(error);
            });
        }
        return;
    }
    NSString *msg = @"";
    if (connectType == fitpolo705ConnectPeripheralWithUUID && [fitpolo705Parser isUUIDString:identifier]) {
        //uuid方式连接
        msg = @"通过uuid方式连接设备";
    }else if (connectType == fitpolo705ConnectPeripheralWithMacAddress && [fitpolo705Parser isMacAddress:identifier]){
        //mac地址连接
        msg = @"通过mac方式连接设备";
    }else if (connectType == fitpolo705ConnectPeripheralWithMacAddressLowFour && [fitpolo705Parser isMacAddressLowFour:identifier]){
        //mac低四位连接
        msg = @"通过mac低四位方式连接设备";
    }else{
        //参数错误
        if (failedBlock) {
            fitpolo705_main_safe(^{
                NSError *error = [[NSError alloc] initWithDomain:fitpolo705CustomErrorDomain
                                                            code:fitpolo705ConnectedFailed
                                                        userInfo:@{@"errorInfo":@"Params error"}];
                failedBlock(error);
            });
        }
        return;
    }
    self.peripheralType = peripheralType;
    if (self.peripheralManager.connectedPeripheral) {
        [self.centralManager cancelPeripheralConnection:self.peripheralManager.connectedPeripheral];
    }
    [self.peripheralManager cancelConnect];
    self.identifier = nil;
    self.identifier = [identifier lowercaseString];
    self.managerAction = currentManagerActionConnectPeripheralWithScan;
    self.connectSucBlock = nil;
    self.connectSucBlock = successBlock;
    self.connectFailBlock = nil;
    self.connectFailBlock = failedBlock;
    [self startConnectPeripheralWithScan];
}

/**
 连接指定设备
 
 @param peripheral 目标设备
 @param connectSuccessBlock 连接成功回调
 @param connectFailedBlock 连接失败回调
 */
- (void)connectPeripheral:(CBPeripheral *)peripheral
      connectSuccessBlock:(fitpolo705ConnectPeripheralSuccessBlock)connectSuccessBlock
       connectFailedBlock:(fitpolo705ConnectPeripheralFailedBlock)connectFailedBlock{
    if (!peripheral) {
        if (connectFailedBlock) {
            fitpolo705_main_safe(^{
                NSError *error = [[NSError alloc] initWithDomain:fitpolo705CustomErrorDomain
                                                            code:fitpolo705ConnectedFailed
                                                        userInfo:@{@"errorInfo":@"Target device does not exist"}];
                connectFailedBlock(error);
            });
        }
        return;
    }
    if (self.centralManager.state != CBCentralManagerStatePoweredOn) {
        //蓝牙状态不可用
        fitpolo705BleStateError(connectFailedBlock);
        return;
    }
    if (self.peripheralManager.connectedPeripheral) {
        [self.centralManager cancelPeripheralConnection:self.peripheralManager.connectedPeripheral];
    }
    //必须强持有peripheral
    fitpolo705ScanModel *model = [[fitpolo705ScanModel alloc] init];
    model.peripheral = peripheral;
    [self setConnectedModel:model];
    [self.peripheralManager cancelConnect];
    self.managerAction = currentManagerActionConnectPeripheral;
    self.connectSucBlock = nil;
    self.connectSucBlock = connectSuccessBlock;
    self.connectFailBlock = nil;
    self.connectFailBlock = connectFailedBlock;
    [self centralConnectPeripheral:peripheral];
}

/**
 断开当前连接的外设
 */
- (void)disconnectConnectedPeripheral{
    CBPeripheral *peripheral = self.peripheralManager.connectedPeripheral;
    if (!peripheral || self.centralManager.state != CBCentralManagerStatePoweredOn) {
        return;
    }
    [self.centralManager cancelPeripheralConnection:peripheral];
    [self setConnectedModel:nil];
    self.managerAction = currentManagerActionDefault;
}

/**
 获取当前外设的连接状态
 
 @return connect status
 */
- (fitpolo705ConnectStatus)getCurrentConnectStatus{
    return self.connectStatus;
}

#pragma mark - Private method
- (void)startConnectPeripheralWithScan{
    [self.centralManager stopScan];
    self.scanTimeout = NO;
    self.scanTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,dispatch_get_global_queue(0, 0));
    //开始时间
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 5.0 * NSEC_PER_SEC);
    //间隔时间
    uint64_t interval = 5.0 * NSEC_PER_SEC;
    dispatch_source_set_timer(self.scanTimer, start, interval, 0);
    fitpolo705WS(weakSelf);
    dispatch_source_set_event_handler(self.scanTimer, ^{
        [weakSelf scanTimerTimeoutProcess];
    });
    dispatch_resume(self.scanTimer);
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"FFC0"]]
                                                options:nil];
}
#pragma mark - Action method

- (void)resetOriSettings{
    if (self.connectTimer) {
        dispatch_cancel(self.connectTimer);
    }
    if (self.scanTimer) {
        dispatch_cancel(self.scanTimer);
    }
    if (self.managerAction == currentManagerActionConnectPeripheralWithScan) {
        [self.centralManager stopScan];
    }
    self.managerAction = currentManagerActionDefault;
    self.peripheralType = operationPeripheralTypeUnknow;
    self.scanTimeout = NO;
    self.scanConnectCount = 0;
}

- (void)connectPeripheralFailed{
    [self resetOriSettings];
    [self setConnectedModel:nil];
    self.connectStatus = fitpolo705ConnectStatusConnectedFailed;
    [[NSNotificationCenter defaultCenter] postNotificationName:fitpolo705ConnectFailedNotification object:nil];
    fitpolo705_main_safe(^{
        if (self.connectFailBlock) {
            NSError *error = [[NSError alloc] initWithDomain:fitpolo705CustomErrorDomain
                                                        code:fitpolo705ConnectedFailed
                                                    userInfo:@{@"errorInfo":@"Connected Failed"}];
            self.connectFailBlock(error);
        }
    });
}

- (void)connectPeripheralSuccess{
    [self resetOriSettings];
    fitpolo705ScanModel *model = [self connectedModel];
    self.connectStatus = fitpolo705ConnectStatusConnected;
    [[NSNotificationCenter defaultCenter] postNotificationName:fitpolo705ConnectSuccessNotification object:nil];
    NSString *tempString1 = [NSString stringWithFormat:@"连接的设备名字:%@",model.peripheralName];
    NSString *tempString2 = [NSString stringWithFormat:@"设备UUID:%@",model.peripheral.identifier.UUIDString];
    NSString *tempString3 = [NSString stringWithFormat:@"设备MAC地址:%@",model.macAddress];
    NSLog(@"%@--%@--%@",tempString1,tempString2,tempString3);
    [fitpolo705LogManager writeCommandToLocalFile:@[tempString1,
                                                    tempString2,
                                                    tempString3]
                                   withSourceInfo:fitpolo705DataSourceAPP];
    fitpolo705_main_safe(^{
        if (self.connectSucBlock) {
            self.connectSucBlock(model.peripheral, model.macAddress, model.peripheralName);
        }
    });
}

#pragma mark - Process method
- (void)scanTimerTimeoutProcess{
    [self.centralManager stopScan];
    if (self.managerAction != currentManagerActionConnectPeripheralWithScan) {
        return;
    }
    self.scanTimeout = YES;
    self.scanConnectCount ++;
    //扫描方式来连接设备
    if (self.scanConnectCount > scanConnectMacCount) {
        //如果扫描连接超时，则直接连接失败，停止扫描
        [self connectPeripheralFailed];
        return;
    }
    //如果小于最大的扫描连接次数，则开启下一轮扫描
    self.scanTimeout = NO;
    [fitpolo705LogManager writeCommandToLocalFile:@[@"开启新一轮扫描设备去连接"] withSourceInfo:fitpolo705DataSourceAPP];
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"FFC0"]]
                                                options:nil];
}

- (void)initConnectTimer{
    dispatch_queue_t connectQueue = dispatch_queue_create("connectPeripheralQueue", DISPATCH_QUEUE_CONCURRENT);
    self.connectTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,connectQueue);
    //开始时间
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 20 * NSEC_PER_SEC);
    //间隔时间
    uint64_t interval = 20 * NSEC_PER_SEC;
    dispatch_source_set_timer(self.connectTimer, start, interval, 0);
    fitpolo705WS(weakSelf);
    dispatch_source_set_event_handler(self.connectTimer, ^{
        [weakSelf connectPeripheralFailed];
        [self.peripheralManager cancelConnect];
    });
    dispatch_resume(self.connectTimer);
}

- (void)centralConnectPeripheral:(CBPeripheral *)peripheral{
    if (!peripheral) {
        return;
    }
    if (self.scanTimer) {
        dispatch_cancel(self.scanTimer);
    }
    [self.centralManager stopScan];
    [[NSNotificationCenter defaultCenter] postNotificationName:fitpolo705StartConnectPeripheralNotification
                                                        object:nil
                                                      userInfo:nil];
    self.connectStatus = fitpolo705ConnectStatusConnecting;
    [self initConnectTimer];
    [self.centralManager connectPeripheral:peripheral
                                   options:@{}];
}

#pragma mark - delegate method process

- (void)scanNewPeripheral:(CBPeripheral *)peripheral advDic:(NSDictionary *)advDic{
    if (self.managerAction == currentManagerActionDefault || !peripheral || !fitpolo705ValidDict(advDic) || self.peripheralType == operationPeripheralTypeUnknow) {
        return;
    }
    fitpolo705ScanModel *peripheralModel = [fitpolo705Parser getScanModelWithParamDic:advDic peripheral:peripheral];
    if (![self isRequirementsPeripheral:peripheralModel]) {
        return;
    }
    if (self.managerAction == currentManagerActionScan) {
        //扫描情况下
        if ([self.scanDelegate respondsToSelector:@selector(fitpolo705ScanNewPeripheral:)]) {
            NSDictionary *dic = @{
                                  @"peripheral":peripheralModel.peripheral,
                                  @"macAddress":peripheralModel.macAddress,
                                  @"peripheralName":peripheralModel.peripheralName,
                                  };
            [self.scanDelegate fitpolo705ScanNewPeripheral:dic];
        }
        return;
    }
    if (self.managerAction != currentManagerActionConnectPeripheralWithScan || self.scanTimeout || self.scanConnectCount > 2) {
        return;
    }
    
    if (![self isTargetPeripheral:peripheralModel]) {
        return;
    }
    [self setConnectedModel:peripheralModel];
    //开始连接目标设备
    [self centralConnectPeripheral:peripheral];
}

/**
 扫描到的设备是否符合要求
 
 @param peripheralModel 扫描到的设备
 @return YES符合，NO不符合
 */
- (BOOL)isRequirementsPeripheral:(fitpolo705ScanModel *)peripheralModel{
    if (!peripheralModel || !fitpolo705ValidStr(peripheralModel.typeIdenty)) {
        return NO;
    }
    BOOL canNext = NO;
    if (self.peripheralType == operationPeripheralTypeFitpolo703 && [peripheralModel.typeIdenty isEqualToString:@"03"]) {
        //703
        canNext = YES;
    }else if (self.peripheralType == operationPeripheralTypeFitpolo705 && [peripheralModel.typeIdenty isEqualToString:@"05"]){
        //705
        canNext = YES;
    }
    if (canNext) {
        NSString *name = [NSString stringWithFormat:@"扫描到的设备名字:%@",
                          peripheralModel.peripheralName];
        NSString *uuid = [NSString stringWithFormat:@"设备UUID:%@",
                          peripheralModel.peripheral.identifier.UUIDString];
        NSString *mac = [NSString stringWithFormat:@"设备MAC地址:%@",
                         peripheralModel.macAddress];
        [fitpolo705LogManager writeCommandToLocalFile:@[name,uuid,mac] withSourceInfo:fitpolo705DataSourceAPP];
    }
    return canNext;
}

/**
 判断该设备是否是需要连接的目标设备
 
 @param peripheralModel 扫描到的设备model
 @return YES目标设备，NO不是目标设备
 */
- (BOOL)isTargetPeripheral:(fitpolo705ScanModel *)peripheralModel{
    if (!peripheralModel || !peripheralModel.peripheral) {
        return NO;
    }
    NSString *macLow = [[peripheralModel.macAddress lowercaseString] substringWithRange:NSMakeRange(12, 5)];
    if ([self.identifier isEqualToString:macLow]) {
        return YES;
    }
    if ([self.identifier isEqualToString:[peripheralModel.macAddress lowercaseString]]) {
        return YES;
    }
    if ([self.identifier isEqualToString:peripheralModel.peripheral.identifier.UUIDString]) {
        return YES;
    }
    return NO;
}

#pragma mark - setter & getter

- (void)setConnectedModel:(fitpolo705ScanModel *)model{
    objc_setAssociatedObject(self, &connectedModelKey, model, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (fitpolo705ScanModel *)connectedModel{
    return objc_getAssociatedObject(self, &connectedModelKey);
}

- (fitpolo705PeripheralManager *)peripheralManager{
    if (!_peripheralManager) {
        _peripheralManager = [fitpolo705PeripheralManager new];
    }
    return _peripheralManager;
}

@end

