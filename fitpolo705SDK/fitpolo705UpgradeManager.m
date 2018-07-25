//
//  fitpolo705UpgradeManager.m
//  testSDK
//
//  Created by aa on 2018/3/20.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "fitpolo705UpgradeManager.h"
#import <objc/message.h>
#import "fitpolo705CentralManager.h"
#import "fitpolo705DataParser.h"
#import "fitpolo705LogManager.h"
#import "fitpolo705Parser.h"
#import "fitpolo705Defines.h"

@interface fitpolo705UpgradeManager()

/**
 升级成功回调
 */
@property (nonatomic, copy)fitpolo705UpdateProcessSuccessBlock updateSuccessBlock;

/**
 升级失败回调
 */
@property (nonatomic, copy)fitpolo705UpdateProcessFailedBlock updateFailedBlock;

/**
 升级进度回调
 */
@property (nonatomic, copy)fitpolo705UpdateProgressBlock updateProgressBlock;

/**
 当前升级进度
 */
@property (nonatomic, assign)NSInteger updateIndex;

/**
 升级过程中定时发送升级数据包的定时器
 */
@property (nonatomic, strong)dispatch_source_t updateTimer;

/**
 发送数据完成之后开启接受结果定时器
 */
@property (nonatomic, strong)dispatch_source_t resultTimer;

/**
 升级线程
 */
@property (nonatomic, strong)dispatch_queue_t updateQueue;

/**
 当前需要连接的外部设备
 */
@property (nonatomic, strong)CBPeripheral *peripheral;

/**
 升级用的数据包
 */
@property (nonatomic, strong)NSData *packageData;

/**
 是否正在升级,升级开始的时候，需要断开手环连接，然后重新连接手环，这个时候手环会处于高速模式，才能进行升级,如果是这种情形下引起的手环连接状态发生改变，主页面需要区分开来
 */
@property (nonatomic, assign)BOOL switchHighModel;

/**
 是否处于升级状态，如果是升级状态，从后台切刀切到前台的时候，不能请求数据
 */
@property (nonatomic, assign)BOOL updating;

@end

@implementation fitpolo705UpgradeManager

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"升级中心销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:fitpolo705PeripheralUpdateResultNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:fitpolo705PeripheralConnectStateChanged object:nil];
}

- (instancetype)init{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(peripheralConnectStateChanged)
                                                     name:fitpolo705PeripheralConnectStateChanged
                                                   object:nil];
    }
    return self;
}

#pragma mark - Private method
- (void)peripheralConnectStateChanged{
    if ([fitpolo705CentralManager sharedInstance].connectStatus == fitpolo705ConnectStatusDisconnect && self.switchHighModel) {
        //由于切换模式造成的断开连接，
        fitpolo705_main_safe(^{
            [self performSelector:@selector(switchPeripheralToHighSpeedModel)
                       withObject:nil
                       afterDelay:5.f];
        });
    }
}

/**
 使手环切换到高速模式，刚连接上手环的一小段时间内，手环处于高度模式，适于升级
 */
- (void)switchPeripheralToHighSpeedModel{
    fitpolo705WS(weakSelf);
    [[fitpolo705CentralManager sharedInstance] connectPeripheral:self.peripheral connectSuccessBlock:^(CBPeripheral *connectedPeripheral, NSString *macAddress, NSString *peripheralName) {
        weakSelf.switchHighModel = NO;
        [weakSelf updateStart];
    } connectFailedBlock:^(NSError *error) {
        if (weakSelf.updateFailedBlock) {
            weakSelf.updateFailedBlock(error);
        }
        weakSelf.switchHighModel = NO;
        weakSelf.updating = NO;
        weakSelf.updateFailedBlock = nil;
        weakSelf.updateSuccessBlock = nil;
        weakSelf.updateProgressBlock = nil;
    }];
}

/**
 开始升级
 */
- (void)updateStart{
    NSDictionary *packDic = [self getDataPackageDic];
    if (!fitpolo705ValidDict(packDic)
        || !fitpolo705ValidData(packDic[@"crc16"])
        || [packDic[@"crc16"] length] != 2
        || !fitpolo705ValidArray(packDic[@"packageList"])
        || !fitpolo705ValidData(packDic[@"packLenData"])
        || [packDic[@"packLenData"] length] != 4) {
        self.updating = NO;
        [fitpolo705Parser operationGetPackageDataErrorBlock:self.updateFailedBlock];
        return;
    }
    NSArray *packageList = packDic[@"packageList"];
    if (!fitpolo705ValidArray(packageList)) {
        self.updating = NO;
        [fitpolo705Parser operationGetPackageDataErrorBlock:self.updateFailedBlock];
        return;
    }
    //一帧一帧发
    self.updateIndex = 0;
    fitpolo705WS(weakSelf);
    [[fitpolo705CentralManager sharedInstance] addUpdateFirmwareTaskWithCrcData:packDic[@"crc16"] packageSize:packDic[@"packLenData"] successBlock:^(id returnData) {
        [weakSelf performSelector:@selector(updateWithPackage:)
                       withObject:packageList
                       afterDelay:1];
    } failedBlock:^(NSError *error) {
        fitpolo705_main_safe(^{
            weakSelf.updating = NO;
            if (weakSelf.updateFailedBlock) {
                weakSelf.updateFailedBlock(error);
            }
        });
    }];
}

/**
 升级数据包的发送
 
 @param packageList 固件包数据列表
 */
- (void)updateWithPackage:(NSArray *)packageList{
    if (!fitpolo705ValidArray(packageList)) {
        [fitpolo705Parser operationGetPackageDataErrorBlock:self.updateFailedBlock];
        return;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateResultNotification:)
                                                 name:fitpolo705PeripheralUpdateResultNotification
                                               object:nil];
    fitpolo705WS(weakSelf);
    self.updateQueue = dispatch_queue_create("updatePeripheralQueue", DISPATCH_QUEUE_CONCURRENT);
    self.updateTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.updateQueue);
    dispatch_source_set_timer(self.updateTimer, DISPATCH_TIME_NOW, 0.02 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.updateTimer, ^{
        if (weakSelf.updateIndex == packageList.count) {
            dispatch_cancel(weakSelf.updateTimer);
            weakSelf.updateIndex = 0;
            //升级结束
            [weakSelf waitForUpdateResult];
            return ;
        }
        NSData *packData = packageList[weakSelf.updateIndex];
        NSData *frameIndexData = [weakSelf setId:weakSelf.updateIndex];
        
        BOOL sendResult = [self sendUpdateDataWithFrameIndexData:frameIndexData packageData:packData];
        if (!sendResult) {
            //升级失败
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:fitpolo705PeripheralUpdateResultNotification
                                                          object:nil];
            dispatch_cancel(weakSelf.updateTimer);
            fitpolo705_main_safe(^{
                weakSelf.updateIndex = 0;
                weakSelf.updating = NO;
                //移除升级结果监听
                [fitpolo705Parser operationUpdateErrorBlock:self.updateFailedBlock];
            });
            return ;
        }
        //升级进度
        CGFloat rate = ((CGFloat)self.updateIndex / packageList.count);
        fitpolo705_main_safe((^{
            if (weakSelf.updateProgressBlock) {
                weakSelf.updateProgressBlock(rate);
            }
        }));
        weakSelf.updateIndex ++;
    });
    dispatch_resume(self.updateTimer);
}

- (void)waitForUpdateResult{
    fitpolo705WS(weakSelf);
    self.resultTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
    dispatch_source_set_timer(self.resultTimer,dispatch_walltime(NULL, 0),2.f * NSEC_PER_SEC, 0);
    NSLog(@"启动结果监听定时器");
    __block NSInteger timerCount = 0;
    dispatch_source_set_event_handler(self.resultTimer, ^{
        timerCount ++;
        if (timerCount < 2) {
            return ;
        }
        NSLog(@"定时器超时");
        dispatch_cancel(weakSelf.resultTimer);
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:fitpolo705PeripheralUpdateResultNotification
                                                      object:nil];
        [fitpolo705Parser operationUpdateErrorBlock:self.updateFailedBlock];
    });
    dispatch_resume(self.resultTimer);
}

#pragma mark - Private Method

/**
 给手环发送升级数据包
 
 @param frameIndexData 发送的数据包帧序号
 @param packageData 要发送的升级数据包
 @return YES发送成功，NO发送失败
 */
- (BOOL)sendUpdateDataWithFrameIndexData:(NSData *)frameIndexData
                             packageData:(NSData *)packageData{
    if (!fitpolo705ValidData(frameIndexData)
        || !fitpolo705ValidData(packageData)) {
        return NO;
    }
    if ([fitpolo705CentralManager sharedInstance].connectStatus != fitpolo705ConnectStatusConnected) {
        //连接状态不可用，则直接发送失败
        return NO;
    }
    NSData *headerData = [fitpolo705Parser stringToData:@"29"];
    NSMutableData *sendData = [NSMutableData dataWithData:headerData];
    [sendData appendData:frameIndexData];
    [sendData appendData:packageData];
    return [[fitpolo705CentralManager sharedInstance] sendUpdateData:sendData];
}

- (NSData *) setId:(NSInteger)Id {
    //用2个字节接收
    Byte bytes[2];
    bytes[0] = (Byte)(Id>>8);
    bytes[1] = (Byte)(Id);
    NSData *data = [NSData dataWithBytes:bytes length:2];
    return data;
}

/**
 获取升级数据包数据
 
 @return 包含升级数据包的数组(数组里面放的都是17个byte的data)和本次升级的crc校验、数据包长度
 */
- (NSDictionary *)getDataPackageDic{
    //不支持心率的升级包名字是BORD_CC_00，支持心率的是BORD_CC_01
    //最新增加ee版本的固件包兼容
    
    if (!fitpolo705ValidData(self.packageData)) {
        return nil;
    }
    NSInteger dataLength = self.packageData.length;
    if (dataLength <= 0) {
        return nil;
    }
    NSData *crc16Data = [fitpolo705Parser getCrc16VerifyCode:self.packageData];
    Byte bytes[4];
    bytes[0] = (Byte)(dataLength>>24);
    bytes[1] = (Byte)(dataLength>>16);
    bytes[2] = (Byte)(dataLength>>8);
    bytes[3] = (Byte)(dataLength);
    NSData *packLenData = [NSData dataWithBytes:bytes length:4];
    NSInteger remainder = dataLength % 17;
    //计算升级所需数据一共多少包
    NSInteger dataPackageFrame = (remainder ? (dataLength / 17 + 1) : (dataLength / 17));
    NSMutableData *sendData = [NSMutableData dataWithData:self.packageData];
    //最后一包数据如果不足17byte，则补0
    NSData *tempData = nil;
    if (remainder > 0) {
        NSInteger needRemaind = 17 - remainder;
        NSString *tempString = @"";
        for (NSInteger i = 0; i < needRemaind; i ++) {
            tempString = [tempString stringByAppendingString:@"00"];
        }
        tempData = [fitpolo705Parser stringToData:tempString];
    }
    if (fitpolo705ValidData(tempData)) {
        [sendData appendData:tempData];
    }
    NSMutableArray *dataPackageArray = [NSMutableArray arrayWithCapacity:dataPackageFrame];
    for (NSInteger i = 0; i < dataPackageFrame; i ++) {
        //将最终的升级数据分包
        NSData *tempData = [sendData subdataWithRange:NSMakeRange(17 * i, 17)];
        [dataPackageArray addObject:tempData];
    }
    return @{
             @"packageList":[dataPackageArray copy],
             @"crc16":crc16Data,
             @"packLenData":packLenData
             };
}

/**
 升级结果通知，开始发送第一帧升级数据的时候开始注册监听结果，最后一帧数据发送的时候需要移除监听，改由开启升级结果任务的方式监听升级结果
 
 @param obj 升级过程中接收到的升级结果，基本上就是一些升级错误原因
 */
- (void)updateResultNotification:(NSNotification *)obj{
    dispatch_async(self.updateQueue, ^{
        NSDictionary * dataDic = [obj userInfo];
        NSString * resultString = dataDic[@"updateResult"];
        if (!fitpolo705ValidStr(resultString)) {
            return;
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:fitpolo705PeripheralUpdateResultNotification
                                                      object:nil];
        if ([resultString isEqualToString:@"00"]) {
            //升级成功
            dispatch_cancel(self.updateTimer);
            if (self.resultTimer) {
                dispatch_cancel(self.resultTimer);
            }
            self.updateIndex = 0;
            self.updating = NO;
            fitpolo705_main_safe(^{
                if (self.updateSuccessBlock) {
                    self.updateSuccessBlock();
                }
            });
            return;
        }
        //升级失败
        dispatch_cancel(self.updateTimer);
        if (self.resultTimer) {
            dispatch_cancel(self.resultTimer);
        }
        self.updateIndex = 0;
        self.updating = NO;
        NSString *errorInfo = @"get package error";
        //@"01"超时@"02"校验码错误@"03"文件错误
        if ([resultString isEqualToString:@"01"]) {
            errorInfo = @"update timeout";
        }else if ([resultString isEqualToString:@"02"]){
            errorInfo = @"crc error";
        }else if ([resultString isEqualToString:@"03"]){
            errorInfo = @"package error";
        }
        fitpolo705_main_safe(^{
            if (self.updateFailedBlock) {
                NSError *error = [[NSError alloc] initWithDomain:@"com.moko.update"
                                                            code:-111111
                                                        userInfo:@{@"errorInfo":errorInfo}];
                self.updateFailedBlock(error);
            }
        });
    });
}

#pragma mark - Public method
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
                              failedBlock:(fitpolo705UpdateProcessFailedBlock)failedBlock{
    NSAssert(successBlock != nil, @"If you need to update, the successBlock can not be nil");
    NSAssert(failedBlock != nil, @"If you need to update, the failedBlock can not be nil");
    if (!fitpolo705ValidData(packageData)) {
        [fitpolo705Parser operationGetPackageDataErrorBlock:failedBlock];
        return;
    }
    if (![fitpolo705CentralManager sharedInstance].connectedPeripheral) {
        [fitpolo705Parser operationDisconnectedErrorBlock:failedBlock];
        return;
    }
    self.peripheral = [fitpolo705CentralManager sharedInstance].connectedPeripheral;
    self.packageData = packageData;
    self.updateSuccessBlock = successBlock;
    self.updateFailedBlock = failedBlock;
    self.updateProgressBlock = progressBlock;
    self.switchHighModel = YES;
    self.updating = YES;
    [[fitpolo705CentralManager sharedInstance] disconnectConnectedPeripheral];
}

@end
