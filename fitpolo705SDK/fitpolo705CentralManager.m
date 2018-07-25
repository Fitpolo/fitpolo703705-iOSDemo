//
//  fitpolo705CentralManager.m
//  testSDK
//
//  Created by aa on 2018/3/13.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "fitpolo705CentralManager.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "fitpolo705LogManager.h"
#import "fitpolo705Parser.h"
#import "fitpolo705Defines.h"
#import "CBPeripheral+fitpolo705Characteristic.h"
#import "fitpolo705TaskOperation.h"

@interface CBPeripheral (fitpolo705Scan)

/**
 703广播标识符为03,705广播标识符为05
 */
@property (nonatomic, copy, readonly)NSString *typeIdenty;

@property (nonatomic, copy, readonly)NSString *macAddress;

@property (nonatomic, copy, readonly)NSString *peripheralName;

/**
 根据广播内容设备peripheral相关信息
 
 @param advDic 扫描到的广播信息
 */
- (void)parseAdvData:(NSDictionary *)advDic;

/**
 扫描方式连接设备的情况下，需要判断当前设备是否是目标设备
 
 @param identifier 连接标识符
 @return YES:目标设备，NO:非目标设备
 */
- (BOOL)isTargetPeripheral:(NSString *)identifier;

@end

static const char *peripheralNameKey = "peripheralNameKey";
static const char *macAddressKey = "macAddressKey";
static const char *typeIdentyKey = "typeIdentyKey";

@implementation CBPeripheral (fitpolo705Scan)

- (void)parseAdvData:(NSDictionary *)advDic{
    if (!advDic || advDic.allValues.count == 0) {
        return;
    }
    NSData *data = advDic[CBAdvertisementDataManufacturerDataKey];
    if (data.length != 9) {
        return;
    }
    NSString *temp = data.description;
    temp = [temp stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"<" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@">" withString:@""];
    NSString *macAddress = [NSString stringWithFormat:@"%@-%@-%@-%@-%@-%@",
                            [temp substringWithRange:NSMakeRange(0, 2)],
                            [temp substringWithRange:NSMakeRange(2, 2)],
                            [temp substringWithRange:NSMakeRange(4, 2)],
                            [temp substringWithRange:NSMakeRange(6, 2)],
                            [temp substringWithRange:NSMakeRange(8, 2)],
                            [temp substringWithRange:NSMakeRange(10, 2)]];
    NSString *deviceType = [temp substringWithRange:NSMakeRange(12, 2)];
    if (macAddress) {
        objc_setAssociatedObject(self, &macAddressKey, macAddress, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    if (deviceType) {
        objc_setAssociatedObject(self, &typeIdentyKey, deviceType, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    if (advDic[CBAdvertisementDataLocalNameKey]) {
        objc_setAssociatedObject(self, &peripheralNameKey, advDic[CBAdvertisementDataLocalNameKey], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

/**
 扫描方式连接设备的情况下，需要判断当前设备是否是目标设备
 
 @param identifier 连接标识符
 @return YES:目标设备，NO:非目标设备
 */
- (BOOL)isTargetPeripheral:(NSString *)identifier{
    if (!identifier) {
        return NO;
    }
    NSString *macLow = [[self.macAddress lowercaseString] substringWithRange:NSMakeRange(12, 5)];
    if ([identifier isEqualToString:macLow]) {
        return YES;
    }
    if ([identifier isEqualToString:[self.macAddress lowercaseString]]) {
        return YES;
    }
    if ([identifier isEqualToString:self.identifier.UUIDString]) {
        return YES;
    }
    return NO;
}

- (NSString *)peripheralName{
    return objc_getAssociatedObject(self, &peripheralNameKey);
}

- (NSString *)macAddress{
    return objc_getAssociatedObject(self, &macAddressKey);
}

- (NSString *)typeIdenty{
    return objc_getAssociatedObject(self, &typeIdentyKey);
}
@end

typedef NS_ENUM(NSInteger, currentManagerAction) {
    currentManagerActionDefault,
    currentManagerActionScan,
    currentManagerActionConnectPeripheral,
    currentManagerActionConnectPeripheralWithScan,
};
static NSInteger const scanConnectMacCount = 2;
static fitpolo705CentralManager *manager = nil;
static dispatch_once_t onceToken;
NSString *const fitpolo705PeripheralConnectStateChanged = @"fitpolo705PeripheralConnectStateChanged";
//外设固件升级结果通知,由于升级固件采用的是无应答定时器发送数据包，所以当产生升级结果的时候，需要靠这个通知来结束升级过程
NSString *const fitpolo705PeripheralUpdateResultNotification = @"fitpolo705PeripheralUpdateResultNotification";

@interface fitpolo705CentralManager()<CBCentralManagerDelegate,CBPeripheralDelegate>

@property (nonatomic, strong)CBCentralManager *centralManager;

@property (nonatomic, strong)CBPeripheral *connectedPeripheral;

@property (nonatomic, strong)dispatch_queue_t centralManagerQueue;

@property (nonatomic, copy)fitpolo705ConnectPeripheralFailedBlock connectFailBlock;

@property (nonatomic, copy)fitpolo705ConnectPeripheralSuccessBlock connectSucBlock;

@property (nonatomic, strong)dispatch_source_t scanTimer;

@property (nonatomic, strong)dispatch_source_t connectTimer;

@property (nonatomic, assign)currentManagerAction managerAction;

@property (nonatomic, assign)BOOL scanTimeout;

@property (nonatomic, assign)NSInteger scanConnectCount;

@property (nonatomic, copy)NSString *identifier;

@property (nonatomic, assign)fitpolo705ConnectStatus connectStatus;

@property (nonatomic, assign)fitpolo705CentralManagerState centralStatus;

@property (nonatomic, assign)operationPeripheralType peripheralType;

@property (nonatomic, strong)NSOperationQueue *operationQueue;

@end

@implementation fitpolo705CentralManager

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"中心销毁");
}

//生成唯一的实例
-(instancetype) initInstance {
    if (self = [super init]) {
        _centralManagerQueue = dispatch_queue_create("moko.com.centralManager", DISPATCH_QUEUE_SERIAL);
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:_centralManagerQueue];
    }
    return self;
}

+ (fitpolo705CentralManager *)sharedInstance{
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [[super alloc] initInstance];
        }
    });
    return manager;
}

+ (void)singletonDestroyed{
    onceToken = 0; // 只有置成0,GCD才会认为它从未执行过.它默认为0.这样才能保证下次再次调用shareInstance的时候,再次创建对象.
    manager = nil;
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    fitpolo705CentralManagerState managerState = fitpolo705CentralManagerStateUnable;
    if (central.state == CBCentralManagerStatePoweredOn) {
        managerState = fitpolo705CentralManagerStateEnable;
    }
    self.centralStatus = managerState;
    if ([self.managerStateDelegate respondsToSelector:@selector(fitpolo705CentralStateChanged:manager:)]) {
        fitpolo705_main_safe(^{
            [self.managerStateDelegate fitpolo705CentralStateChanged:managerState manager:manager];
        });
    }
    if (central.state == CBCentralManagerStatePoweredOn) {
        return;
    }
    if (self.connectedPeripheral) {
        self.connectedPeripheral = nil;
        [self updateManagerStateConnectState:fitpolo705ConnectStatusDisconnect];
        [self.operationQueue cancelAllOperations];
    }
    if (self.managerAction == currentManagerActionDefault) {
        return;
    }
    if (self.managerAction == currentManagerActionScan) {
        self.managerAction = currentManagerActionDefault;
        self.peripheralType = operationPeripheralTypeUnknow;
        [self.centralManager stopScan];
        fitpolo705_main_safe(^{
            if ([self.scanDelegate respondsToSelector:@selector(fitpolo705CentralStopScan:)]) {
                [self.scanDelegate fitpolo705CentralStopScan:manager];
            }
        });
        return;
    }
    if (self.managerAction == currentManagerActionConnectPeripheralWithScan) {
        [self.centralManager stopScan];
    }
    [self connectPeripheralFailed];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    dispatch_async(_centralManagerQueue, ^{
        [self scanNewPeripheral:peripheral advDic:advertisementData];
    });
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    self.connectedPeripheral = peripheral;
    self.connectedPeripheral.delegate = self;
    [self.connectedPeripheral discoverServices:@[[CBUUID UUIDWithString:normalServiceUUID],[CBUUID UUIDWithString:updateServiceUUID]]];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    [self connectPeripheralFailed];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"断开连接");
    self.connectedPeripheral = nil;
    [self updateManagerStateConnectState:fitpolo705ConnectStatusDisconnect];
    [self.operationQueue cancelAllOperations];
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        [self connectPeripheralFailed];
        return;
    }
    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:normalServiceUUID]]) {
            //通用服务
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:readConfigDataUUID],
                                                  [CBUUID UUIDWithString:setConfigDataUUID],
                                                  [CBUUID UUIDWithString:stepMeterDataUUID],
                                                  [CBUUID UUIDWithString:heartRateDataUUID]]
                                     forService:service];
        }else if ([service.UUID isEqual:[CBUUID UUIDWithString:updateServiceUUID]]){
            //升级服务
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:updateWriteUUID],
                                                  [CBUUID UUIDWithString:updateNotifyUUID]]
                                     forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        [self connectPeripheralFailed];
        return;
    }
    [self.connectedPeripheral update705CharacteristicsForService:service];
    if ([self.connectedPeripheral fitpolo705ConnectSuccess]) {
        [self connectPeripheralSuccess];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"read data from peripheral error:%@", [error localizedDescription]);
        return;
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:updateNotifyUUID]]){
        //升级监听
        NSString *content = [fitpolo705Parser hexStringFromData:characteristic.value];
        if (!fitpolo705ValidStr(content) || content.length != 4) {
            return;
        }
        NSString *header = [content substringWithRange:NSMakeRange(0, 2)];
        if ([header isEqualToString:@"a7"]){
            //升级结果
            NSString *origData = [NSString stringWithFormat:@"手环升级数据:%@",content];
            [fitpolo705LogManager writeCommandToLocalFile:@[origData] withSourceInfo:fitpolo705DataSourceDevice];
            //抛出升级结果通知，@"00"成功@"01"超时@"02"校验码错误@"03"文件错误
            [[NSNotificationCenter defaultCenter] postNotificationName:fitpolo705PeripheralUpdateResultNotification
                                                                object:nil
                                                              userInfo:@{@"updateResult" : [content substringWithRange:NSMakeRange(2, 2)]}];
            return;
        }
    }
    @synchronized(self.operationQueue) {
        NSArray *operations = [self.operationQueue.operations copy];
        for (fitpolo705TaskOperation *operation in operations) {
            if (operation.executing) {
                [operation peripheral:peripheral didUpdateValueForCharacteristic:characteristic error:NULL];
                break;
            }
        }
    }
}

#pragma mark - Public method
#pragma mark - scan
- (void)startScanPeripheral:(operationPeripheralType)peripheralType{
    if (self.centralManager.state != CBCentralManagerStatePoweredOn || peripheralType == operationPeripheralTypeUnknow) {
        //蓝牙状态不可用
        return;
    }
    self.peripheralType = peripheralType;
    self.managerAction = currentManagerActionScan;
    if ([self.scanDelegate respondsToSelector:@selector(fitpolo705CentralStartScan:)]) {
        fitpolo705_main_safe(^{
            [self.scanDelegate fitpolo705CentralStartScan:manager];
        });
    }
    //日志
    [fitpolo705LogManager writeCommandToLocalFile:@[@"开始扫描"] withSourceInfo:fitpolo705DataSourceAPP];
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"FFC0"]] options:nil];
}

/**
 停止扫描
 */
- (void)stopScan{
    [self.centralManager stopScan];
    self.managerAction = currentManagerActionDefault;
    self.peripheralType = operationPeripheralTypeUnknow;
    if ([self.scanDelegate respondsToSelector:@selector(fitpolo705CentralStopScan:)]) {
        fitpolo705_main_safe(^{
            [self.scanDelegate fitpolo705CentralStopScan:manager];
        });
    }
}

#pragma mark - connect

/**
 根据标识符和连接方式来连接指定的外设
 
 @param identifier 要连接外设的标识符,目前支持设备UUID、设备mac地址(xx-xx-xx-xx-xx-xx)、设备mac地址低四位(xx-xx)三种连接方式。
 @param peripheralType 连接设备的类型，703/705
 @param successBlock 连接设备成功回调
 @param failedBlock 连接设备失败回调
 */
- (void)connectPeripheralWithIdentifier:(NSString *)identifier
                         peripheralType:(operationPeripheralType)peripheralType
                    connectSuccessBlock:(fitpolo705ConnectPeripheralSuccessBlock)successBlock
                       connectFailBlock:(fitpolo705ConnectPeripheralFailedBlock)failedBlock{
    if (self.centralManager.state != CBCentralManagerStatePoweredOn) {
        //蓝牙状态不可用
        [fitpolo705Parser operationCentralBlePowerOffBlock:failedBlock];
        return;
    }
    if (![fitpolo705Parser checkIdenty:identifier]) {
        //参数错误
        [fitpolo705Parser operationConnectFailedBlock:failedBlock];
        return;
    }
    fitpolo705WS(weakSelf);
    [self connectWithIdentifier:identifier peripheralType:peripheralType successBlock:^(CBPeripheral *connectedPeripheral, NSString *macAddress, NSString *peripheralName) {
        if (successBlock) {
            successBlock(connectedPeripheral, macAddress, peripheralName);
        }
        [weakSelf clearConnectBlock];
    } failBlock:^(NSError *error) {
        if (failedBlock) {
            failedBlock(error);
        }
        [weakSelf clearConnectBlock];
    }];
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
    if (self.centralManager.state != CBCentralManagerStatePoweredOn) {
        //蓝牙状态不可用
        [fitpolo705Parser operationCentralBlePowerOffBlock:connectFailedBlock];
        return;
    }
    if (!peripheral) {
        [fitpolo705Parser operationConnectFailedBlock:connectFailedBlock];
        return;
    }
    fitpolo705WS(weakSelf);
    [self connectWithPeripheral:peripheral sucBlock:^(CBPeripheral *connectedPeripheral, NSString *macAddress, NSString *peripheralName) {
        if (connectSuccessBlock) {
            connectSuccessBlock(connectedPeripheral, macAddress, peripheralName);
        }
        [weakSelf clearConnectBlock];
    } failedBlock:^(NSError *error) {
        if (connectFailedBlock) {
            connectFailedBlock(error);
        }
        [weakSelf clearConnectBlock];
    }];
}

/**
 断开当前连接的外设
 */
- (void)disconnectConnectedPeripheral{
    if (!self.connectedPeripheral || self.centralManager.state != CBCentralManagerStatePoweredOn) {
        return;
    }
    [self.centralManager cancelPeripheralConnection:self.connectedPeripheral];
    self.connectedPeripheral = nil;
    self.managerAction = currentManagerActionDefault;
    [self.operationQueue cancelAllOperations];
    [self updateManagerStateConnectState:fitpolo705ConnectStatusDisconnect];
}

#pragma mark - task
- (BOOL)sendUpdateData:(NSData *)updateData{
    if (!fitpolo705ValidData(updateData) || !self.connectedPeripheral.updateWrite || !self.connectedPeripheral.updateNotify) {
        return NO;
    }
    [self.connectedPeripheral writeValue:updateData
                       forCharacteristic:self.connectedPeripheral.updateWrite
                                    type:CBCharacteristicWriteWithoutResponse];
    NSString *string = [NSString stringWithFormat:@"%@:%@",@"固件升级数据",[fitpolo705Parser hexStringFromData:updateData]];
    [fitpolo705LogManager writeCommandToLocalFile:@[string] withSourceInfo:fitpolo705DataSourceAPP];
    return YES;
}

/**
 添加一个通信任务(app-->peripheral)到队列
 
 @param operationID 任务ID
 @param resetNum 是否需要由外设返回通信数据总条数
 @param commandData 通信数据
 @param characteristic 通信所使用的特征
 @param successBlock 通信成功回调
 @param failureBlock 通信失败回调
 */
- (void)addTaskWithTaskID:(fitpolo705TaskOperationID)operationID
                 resetNum:(BOOL)resetNum
              commandData:(NSString *)commandData
           characteristic:(CBCharacteristic *)characteristic
             successBlock:(fitpolo705CommunicationSuccessBlock)successBlock
             failureBlock:(fitpolo705CommunicationFailedBlock)failureBlock{
    
    fitpolo705TaskOperation *operation = [self generateOperationWithOperationID:operationID
                                                                       resetNum:resetNum
                                                                    commandData:commandData
                                                                 characteristic:characteristic
                                                                   successBlock:successBlock
                                                                   failureBlock:failureBlock];
    if (!operation) {
        return;
    }
    @synchronized(self.operationQueue) {
        [self.operationQueue addOperation:operation];
    }
}

/**
 添加一个通信任务(app-->peripheral)到队列,当获任务结束只获取到部分数据的时候，返回这部分数据到成功回调
 
 @param operationID 任务ID
 @param commandData 通信数据
 @param characteristic 通信所使用的特征
 @param successBlock 通信成功回调
 @param failureBlock 通信失败回调
 */
- (void)addNeedPartOfDataTaskWithTaskID:(fitpolo705TaskOperationID)operationID
                            commandData:(NSString *)commandData
                         characteristic:(CBCharacteristic *)characteristic
                           successBlock:(fitpolo705CommunicationSuccessBlock)successBlock
                           failureBlock:(fitpolo705CommunicationFailedBlock)failureBlock{
    fitpolo705TaskOperation *operation = [self generateOperationWithOperationID:operationID
                                                                       resetNum:YES
                                                                    commandData:commandData
                                                                 characteristic:characteristic
                                                                   successBlock:successBlock
                                                                   failureBlock:failureBlock];
    if (!operation) {
        return;
    }
    SEL selNeedPartOfData = sel_registerName("needPartOfData:");
    if ([operation respondsToSelector:selNeedPartOfData]) {
        ((void (*)(id, SEL, NSNumber*))(void *) objc_msgSend)((id)operation, selNeedPartOfData, @(YES));
    }
    @synchronized(self.operationQueue) {
        [self.operationQueue addOperation:operation];
    }
}

/**
 手环开启升级固件
 
 @param crcData 本地升级的校验码，两个字节，将本地的固件做crc16得出来的
 @param packageSize 本次升级的固件大小，4个字节
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)addUpdateFirmwareTaskWithCrcData:(NSData *)crcData
                             packageSize:(NSData *)packageSize
                            successBlock:(fitpolo705CommunicationSuccessBlock)successBlock
                             failedBlock:(fitpolo705CommunicationFailedBlock)failedBlock{
    if (!fitpolo705ValidData(crcData) || !fitpolo705ValidData(packageSize)) {
        [fitpolo705Parser operationParamsErrorBlock:failedBlock];
        return;
    }
    NSData *headerData = [fitpolo705Parser stringToData:@"28"];
    NSMutableData *commandData = [NSMutableData dataWithData:headerData];
    [commandData appendData:crcData];
    [commandData appendData:packageSize];
    NSString *commandString = [fitpolo705Parser hexStringFromData:commandData];
    fitpolo705TaskOperation *operation = [self generateOperationWithOperationID:fitpolo705StartUpdateOperation resetNum:NO commandData:commandString characteristic:self.connectedPeripheral.updateWrite successBlock:successBlock failureBlock:failedBlock];
    if (!operation) {
        return;
    }
    operation.receiveTimeout = 5.f;
    @synchronized(self.operationQueue) {
        [self.operationQueue addOperation:operation];
    }
}

#pragma mark - Private method
- (void)connectWithPeripheral:(CBPeripheral *)peripheral
                     sucBlock:(fitpolo705ConnectPeripheralSuccessBlock)sucBlock
                  failedBlock:(fitpolo705ConnectPeripheralFailedBlock)failedBlock{
    if (self.connectedPeripheral) {
        [self.centralManager cancelPeripheralConnection:self.connectedPeripheral];
        [self.operationQueue cancelAllOperations];
    }
    self.connectedPeripheral = nil;
    self.connectedPeripheral = peripheral;
    self.managerAction = currentManagerActionConnectPeripheral;
    self.connectSucBlock = sucBlock;
    self.connectFailBlock = failedBlock;
    [self centralConnectPeripheral:peripheral];
}

- (void)connectWithIdentifier:(NSString *)identifier
               peripheralType:(operationPeripheralType)peripheralType
                 successBlock:(fitpolo705ConnectPeripheralSuccessBlock)successBlock
                    failBlock:(fitpolo705ConnectPeripheralFailedBlock)failedBlock{
    self.peripheralType = peripheralType;
    if (self.connectedPeripheral) {
        [self.centralManager cancelPeripheralConnection:self.connectedPeripheral];
        [self.operationQueue cancelAllOperations];
    }
    self.connectedPeripheral = nil;
    self.identifier = [identifier lowercaseString];
    self.managerAction = currentManagerActionConnectPeripheralWithScan;
    self.connectSucBlock = successBlock;
    self.connectFailBlock = failedBlock;
    //通过扫描方式连接设备的时候，开始扫描应该视为开始连接
    [self updateManagerStateConnectState:fitpolo705ConnectStatusConnecting];
    [self startConnectPeripheralWithScan];
}

- (void)startConnectPeripheralWithScan{
    [self.centralManager stopScan];
    self.scanTimeout = NO;
    self.scanTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,_centralManagerQueue);
    dispatch_source_set_timer(self.scanTimer, dispatch_time(DISPATCH_TIME_NOW, 5.0 * NSEC_PER_SEC), 5.0 * NSEC_PER_SEC, 0);
    fitpolo705WS(weakSelf);
    dispatch_source_set_event_handler(self.scanTimer, ^{
        [weakSelf scanTimerTimeoutProcess];
    });
    dispatch_resume(self.scanTimer);
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"FFC0"]] options:nil];
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
    if (self.connectedPeripheral) {
        [self.centralManager cancelPeripheralConnection:self.connectedPeripheral];
        self.connectedPeripheral.delegate = nil;
    }
    self.connectedPeripheral = nil;
    [self updateManagerStateConnectState:fitpolo705ConnectStatusConnectedFailed];
    [fitpolo705Parser operationConnectFailedBlock:self.connectFailBlock];
}

- (void)connectPeripheralSuccess{
    [self resetOriSettings];
    [self updateManagerStateConnectState:fitpolo705ConnectStatusConnected];
    NSString *tempString1 = [NSString stringWithFormat:@"连接的设备名字:%@",self.connectedPeripheral.peripheralName];
    NSString *tempString2 = [NSString stringWithFormat:@"设备UUID:%@",self.connectedPeripheral.identifier.UUIDString];
    NSString *tempString3 = [NSString stringWithFormat:@"设备MAC地址:%@",self.connectedPeripheral.macAddress];
    NSLog(@"%@--%@--%@",tempString1,tempString2,tempString3);
    [fitpolo705LogManager writeCommandToLocalFile:@[tempString1,
                                                    tempString2,
                                                    tempString3]
                                   withSourceInfo:fitpolo705DataSourceAPP];
    fitpolo705_main_safe(^{
        if (self.connectSucBlock) {
            self.connectSucBlock(self.connectedPeripheral, self.connectedPeripheral.macAddress, self.connectedPeripheral.peripheralName);
        }
    });
}

- (void)clearConnectBlock{
    if (self.connectSucBlock) {
        self.connectSucBlock = nil;
    }
    if (self.connectFailBlock) {
        self.connectFailBlock = nil;
    }
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
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"FFC0"]] options:nil];
}

- (void)initConnectTimer{
    self.connectTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,_centralManagerQueue);
    dispatch_source_set_timer(self.connectTimer, dispatch_time(DISPATCH_TIME_NOW, 20 * NSEC_PER_SEC),  20 * NSEC_PER_SEC, 0);
    fitpolo705WS(weakSelf);
    dispatch_source_set_event_handler(self.connectTimer, ^{
        [weakSelf connectPeripheralFailed];
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
    [self updateManagerStateConnectState:fitpolo705ConnectStatusConnecting];
    [self initConnectTimer];
    [self.centralManager connectPeripheral:peripheral options:@{}];
}

#pragma mark - delegate method process

- (void)scanNewPeripheral:(CBPeripheral *)peripheral advDic:(NSDictionary *)advDic{
    if (self.managerAction == currentManagerActionDefault
        || self.peripheralType == operationPeripheralTypeUnknow
        || !fitpolo705ValidDict(advDic)) {
        return;
    }
    [peripheral parseAdvData:advDic];
    if (![self isRequirementsPeripheral:peripheral]) {
        return;
    }
    if (self.managerAction == currentManagerActionScan) {
        //扫描情况下
        if ([self.scanDelegate respondsToSelector:@selector(fitpolo705CentralScanningNewPeripheral:macAddress:peripheralName:centralManager:)]) {
            fitpolo705_main_safe(^{
                [self.scanDelegate fitpolo705CentralScanningNewPeripheral:peripheral
                                                               macAddress:peripheral.macAddress
                                                           peripheralName:peripheral.peripheralName
                                                           centralManager:manager];
            });
        }
        return;
    }
    if (self.managerAction != currentManagerActionConnectPeripheralWithScan
        || self.scanTimeout
        || self.scanConnectCount > 2) {
        return;
    }
    if (![peripheral isTargetPeripheral:self.identifier]) {
        return;
    }
    self.connectedPeripheral = peripheral;
    //开始连接目标设备
    [self centralConnectPeripheral:peripheral];
}

/**
 扫描到的设备是否符合要求
 
 @param peripheral 扫描到的设备
 @return YES符合，NO不符合
 */
- (BOOL)isRequirementsPeripheral:(CBPeripheral *)peripheral{
    if (!fitpolo705ValidStr(peripheral.typeIdenty)) {
        return NO;
    }
    BOOL require = NO;
    if ((self.peripheralType == operationPeripheralTypeFitpolo703 && [peripheral.typeIdenty isEqualToString:@"03"])
        || (self.peripheralType == operationPeripheralTypeFitpolo705 && [peripheral.typeIdenty isEqualToString:@"05"])) {
        //703 03 705 05
        require = YES;
    }
    if (require) {
        NSString *name = [NSString stringWithFormat:@"扫描到的设备名字:%@", peripheral.peripheralName];
        NSString *uuid = [NSString stringWithFormat:@"设备UUID:%@", peripheral.identifier.UUIDString];
        NSString *mac = [NSString stringWithFormat:@"设备MAC地址:%@", peripheral.macAddress];
        [fitpolo705LogManager writeCommandToLocalFile:@[name,uuid,mac] withSourceInfo:fitpolo705DataSourceAPP];
    }
    return require;
}

- (void)updateManagerStateConnectState:(fitpolo705ConnectStatus)state{
    self.connectStatus = state;
    [[NSNotificationCenter defaultCenter] postNotificationName:fitpolo705PeripheralConnectStateChanged object:nil];
    if ([self.managerStateDelegate respondsToSelector:@selector(fitpolo705PeripheralConnectStateChanged:manager:)]) {
        fitpolo705_main_safe(^{
            [self.managerStateDelegate fitpolo705PeripheralConnectStateChanged:state manager:manager];
        });
    }
}

#pragma mark - 数据通信处理方法
- (void)sendCommandToPeripheral:(NSString *)commandData characteristic:(CBCharacteristic *)characteristic{
    if (!self.connectedPeripheral || !fitpolo705ValidStr(commandData) || !characteristic) {
        return;
    }
    NSData *data = [fitpolo705Parser stringToData:commandData];
    if (!fitpolo705ValidData(data)) {
        return;
    }
    [self.connectedPeripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
}

- (BOOL)canSendData{
    if (!self.connectedPeripheral) {
        return NO;
    }
    return (self.connectedPeripheral.state == CBPeripheralStateConnected);
}

- (fitpolo705TaskOperation *)generateOperationWithOperationID:(fitpolo705TaskOperationID)operationID
                                                     resetNum:(BOOL)resetNum
                                                  commandData:(NSString *)commandData
                                               characteristic:(CBCharacteristic *)characteristic
                                                 successBlock:(fitpolo705CommunicationSuccessBlock)successBlock
                                                 failureBlock:(fitpolo705CommunicationFailedBlock)failureBlock{
    if (!fitpolo705ValidStr(commandData)) {
        [fitpolo705Parser operationParamsErrorBlock:failureBlock];
        return nil;
    }
    if (![self canSendData]) {
        [fitpolo705Parser operationDisconnectedErrorBlock:failureBlock];
        return nil;
    }
    if (!characteristic) {
        [fitpolo705Parser operationCharacteristicErrorBlock:failureBlock];
        return nil;
    }
    fitpolo705WS(weakSelf);
    fitpolo705TaskOperation *operation = [[fitpolo705TaskOperation alloc] initOperationWithID:operationID resetNum:resetNum commandBlock:^{
        [weakSelf sendCommandToPeripheral:commandData characteristic:characteristic];
        [fitpolo705LogManager writeCommandToLocalFile:commandData withSourceInfo:fitpolo705DataSourceAPP operationID:operationID];
    } completeBlock:^(NSError *error, fitpolo705TaskOperationID operationID, id returnData) {
        if (error) {
            fitpolo705_main_safe(^{
                if (failureBlock) {
                    failureBlock(error);
                }
            });
            return ;
        }
        if (!returnData) {
            [fitpolo705Parser operationRequestDataErrorBlock:failureBlock];
            return ;
        }
        NSString *lev = returnData[fitpolo705DataStatusLev];
        if ([lev isEqualToString:@"1"]) {
            //通用无附加信息的
            NSArray *dataList = (NSArray *)returnData[fitpolo705DataInformation];
            if (!fitpolo705ValidArray(dataList)) {
                [fitpolo705Parser operationRequestDataErrorBlock:failureBlock];
                return;
            }
            NSDictionary *resultDic = @{@"msg":@"success",
                                        @"code":@"1",
                                        @"result":dataList[0],
                                        };
            fitpolo705_main_safe(^{
                if (successBlock) {
                    successBlock(resultDic);
                }
            });
            return;
        }
        //对于有附加信息的
        NSDictionary *resultDic = @{@"msg":@"success",
                                    @"code":@"1",
                                    @"result":returnData[fitpolo705DataInformation],
                                    };
        fitpolo705_main_safe(^{
            if (successBlock) {
                successBlock(resultDic);
            }
        });
    }];
    return operation;
}

#pragma mark - setter & getter
- (NSOperationQueue *)operationQueue{
    if (!_operationQueue) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
    }
    return _operationQueue;
}

@end

