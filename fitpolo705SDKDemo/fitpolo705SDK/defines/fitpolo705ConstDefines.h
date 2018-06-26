
#pragma mark -=====================HCKCentralManager与外设连接状态的通知部分=====================
//中心开始连接外设
static NSString *const fitpolo705StartConnectPeripheralNotification = @"fitpolo705StartConnectPeripheralNotification";
//连接设备成功
static NSString *const fitpolo705ConnectSuccessNotification = @"fitpolo705ConnectSuccessNotification";
//连接设备失败
static NSString *const fitpolo705ConnectFailedNotification = @"fitpolo705ConnectFailedNotification";
//与外设断开连接
static NSString *const fitpolo705DisconnectPeripheralNotification = @"fitpolo705DisconnectPeripheralNotification";
//中心蓝牙状态改变
static NSString *const fitpolo705BluetoothStateChangedNotification = @"fitpolo705BluetoothStateChangedNotification";

/*=========================  peripheralManager连接结果通知  =========================*/
//peripheralManager连接设备失败
static NSString *const fitpolo705PeripheralConnectedFailedNotification = @"fitpolo705PeripheralConnectedFailedNotification";
//peripheralManager连接设备成功
static NSString *const fitpolo705PeripheralConnectedSuccessNotification = @"fitpolo705PeripheralConnectedSuccessNotification";

//外设固件升级结果通知,由于升级固件采用的是无应答定时器发送数据包，所以当产生升级结果的时候，需要靠这个通知来结束升级过程
static NSString *const fitpolo705PeripheralUpdateResultNotification = @"fitpolo705PeripheralUpdateResultNotification";

