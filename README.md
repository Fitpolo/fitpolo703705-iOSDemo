# fitpolo703705-iOSDemo

支持pod，pod 'fitpolo705SDK',
#### 1.扫描
```
#import "fitpolo705SDK.h"

[fitpolo705CentralManager sharedInstance].scanDelegate = self;

//扫描705设备
[[fitpolo705CentralManager sharedInstance] startScanPeripheral:operationPeripheralTypeFitpolo705];
/*
//扫描703设备
[[fitpolo705CentralManager sharedInstance] startScanPeripheral:operationPeripheralTypeFitpolo703];
*/

/*
扫描代理
@protocol fitpolo705ScanPeripheralDelegate <NSObject>

- (void)fitpolo705CentralStartScan:(fitpolo705CentralManager *)centralManager{
    NSLog(@"start scan");
}

- (void)fitpolo705CentralScanningNewPeripheral:(CBPeripheral *)peripheral macAddress:(NSString *)macAddress peripheralName:(NSString *)peripheralName centralManager:(fitpolo705CentralManager *)centralManager{
    NSLog(@"scan new peripheral:%@===%@====%@",peripheral.identifier.UUIDString,macAddress,peripheralName);
}

- (void)fitpolo705CentralStopScan:(fitpolo705CentralManager *)centralManager{
    NSLog(@"stop scan");
}
@end
*/

```

#### 2.连接设备

##### 2.1 中心蓝牙状态改变和外设连接状态改变
```
[fitpolo705CentralManager sharedInstance].managerStateDelegate = self;

#pragma mark - fitpolo705CentralManagerStateDelegate
- (void)fitpolo705CentralStateChanged:(fitpolo705CentralManagerState)managerState manager:(fitpolo705CentralManager *)manager{
    NSLog(@"中心蓝牙状态发生改变");
}

- (void)fitpolo705PeripheralConnectStateChanged:(fitpolo705ConnectStatus)connectState manager:(fitpolo705CentralManager *)manager{
    NSLog(@"外设连接状态发生改变::::%@",@(connectState));
}
```

##### 2.2 通过identifier来连接设备

```
[[fitpolo705CentralManager sharedInstance] connectPeripheralWithIdentifier:@"26-CB"peripheralType:operationPeripheralTypeFitpolo705 connectSuccessBlock:^(CBPeripheral *connectedPeripheral, NSString *macAddress, NSString *peripheralName) {
        //Connect Success
		//Do some work
    } connectFailBlock:^(NSError *error) {
        //Connect Failed
	   // Do some work
    }];
```

##### 2.3连接指定设备

```
[[fitpolo705CentralManager sharedInstance] connectPeripheral:peripheral
                                         connectSuccessBlock:^(CBPeripheral *connectedPeripheral, NSString *macAddress, NSString *peripheralName) {
    //Connect Success
		//Do some work
        }                                   connectFailBlock:^(NSError *error) {
     //Connect Failed
	   // Do some work
    }];
```

#### 3.数据接口调用
fitpolo705Interface包含了所有的数据接口部分，所有接口采用block形式回调。
```fitpolo705Interface.h```里面包含了所有的获取手环数据的接口，```fitpolo705Interface+Settings.h```里面包含了所有的设置手环参数的接口，```fitpolo705Interface+StepGauge.h```里面包含了所有计步相关的接口，```fitpolo705Interface+HeartRate.h```包含了所有心率相关接口，```fitpolo705UpgradeManager```包含了固件升级相关接口


