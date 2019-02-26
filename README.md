# fitpolo703705-iOSDemo
Support pod，pod 'fitpolo705SDK',
#### 1.scan
```
#import "fitpolo705SDK.h"

[fitpolo705CentralManager sharedInstance].scanDelegate = self;

//scan 705 device
[[fitpolo705CentralManager sharedInstance] startScanPeripheral:operationPeripheralTypeFitpolo705];
/*
//sacn703 device
[[fitpolo705CentralManager sharedInstance] startScanPeripheral:operationPeripheralTypeFitpolo703];
*/

/*
scanning agent
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

#### 2.connect device

##### 2.1 Central Bluetooth status change and peripheral connection status change
```
[fitpolo705CentralManager sharedInstance].managerStateDelegate = self;

#pragma mark - fitpolo705CentralManagerStateDelegate
- (void)fitpolo705CentralStateChanged:(fitpolo705CentralManagerState)managerState manager:(fitpolo705CentralManager *)manager{
NSLog(@" Central Bluetooth status change");
}

- (void)fitpolo705PeripheralConnectStateChanged:(fitpolo705ConnectStatus)connectState manager:(fitpolo705CentralManager *)manager{
NSLog(@"peripheral connection status change::::%@",@(connectState));
}
```

##### 2.2 through identifier to connect device

```
[[fitpolo705CentralManager sharedInstance] connectPeripheralWithIdentifier:@"26-CB"peripheralType:operationPeripheralTypeFitpolo705 connectSuccessBlock:^(CBPeripheral *connectedPeripheral, NSString *macAddress, NSString *peripheralName) {
//Connect Success
//Do some work
} connectFailBlock:^(NSError *error) {
//Connect Failed
// Do some work
}];
```

##### 2.3connect appointed device

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

#### 3.Data interface call
fitpolo705Interface Contains all the data interface parts, all interfaces callback in block form。
```fitpolo705Interface.h```contains all the interfaces for getting the bracelet data.，```fitpolo705Interface+Settings.h```contains all the interfaces for setting the bracelet parameters.，```fitpolo705Interface+StepGauge.h```contains all the interfaces related step counter，```fitpolo705Interface+HeartRate.h```contains all the interfaces related heart rate，```fitpolo705UpgradeManager``` contains interfaces related upgrade firmware

