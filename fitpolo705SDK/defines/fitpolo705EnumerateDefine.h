
/*
 自定义的错误码
 */
typedef NS_ENUM(NSInteger, fitpolo705CustomErrorCode){
    fitpolo705BlueDisable = -10000,                                     //当前手机蓝牙不可用
    fitpolo705ConnectedFailed = -10001,                                 //连接外设失败
    fitpolo705PeripheralDisconnected = -10002,                          //当前外部连接的设备处于断开状态
    fitpolo705CharacteristicError = -10003,                             //特征为空
    fitpolo705RequestPeripheralDataError = -10004,                      //请求手环数据出错
    fitpolo705ParamsError = -10005,                                     //输入的参数有误
    fitpolo705SetParamsError = -10006,                                  //设置参数出错
};

typedef NS_ENUM(NSInteger, fitpolo705ConnectStatus) {
    fitpolo705ConnectStatusUnknow,                                           //未知状态
    fitpolo705ConnectStatusConnecting,                                       //正在连接
    fitpolo705ConnectStatusConnected,                                        //连接成功
    fitpolo705ConnectStatusConnectedFailed,                                  //连接失败
    fitpolo705ConnectStatusDisconnect,                                       //连接断开
};

typedef NS_ENUM(NSInteger, fitpolo705CentralManagerState) {
    fitpolo705CentralManagerStateEnable,                           //可用状态
    fitpolo705CentralManagerStateUnable,                           //不可用
};

typedef NS_ENUM(NSInteger, fitpolo705Unit) {
    fitpolo705MetricSystem,         //公制
    fitpolo705Imperial,             //英制
};

typedef NS_ENUM(NSInteger, fitpolo705Gender) {
    fitpolo705Male,             //男性
    fitpolo705Female,           //女性
};

typedef NS_ENUM(NSInteger, fitpolo705TimeFormat) {
    fitpolo70524Hour,         //24小时制
    fitpolo70512Hour,         //12小时制
};

typedef NS_ENUM(NSInteger, fitpolo705AlarmClockIndex) {
    fitpolo705AlarmClockIndexFirst,         //第一组闹钟
    fitpolo705AlarmClockIndexSecond,        //第二组闹钟
};

typedef NS_ENUM(NSInteger, fitpolo705HeartRateAcquisitionInterval) {
    fitpolo705HeartRateAcquisitionIntervalClose,    //关闭心率采集功能
    fitpolo705HeartRateAcquisitionInterval10Min,    //10分钟
    fitpolo705HeartRateAcquisitionInterval20Min,    //20分钟
    fitpolo705HeartRateAcquisitionInterval30Min,    //30分钟
};

