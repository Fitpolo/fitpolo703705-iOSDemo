
typedef NS_ENUM(NSInteger, fitpolo705TaskOperationID) {
    fitpolo705DefaultTaskOperationID,           //默认的初始值
#pragma mark - 读取设置
    fitpolo705GetAlarmClockOperation,           //读取闹钟数据
    fitpolo705GetAncsOptionsOperation,          //读取ancs选项
    fitpolo705GetSedentaryRemindOperation,      //读取久坐提醒
    fitpolo705GetMovingTargetOperation,         //读取运动目标
    fitpolo705GetUnitDataOperation,             //读取单位信息
    fitpolo705GetTimeFormatDataOperation,       //读取时间进制
    fitpolo705GetCustomScreenDisplayOperation,  //读取当前显示的屏幕信息
    fitpolo705GetRemindLastScreenDisplayOperation,  //读取是否显示上一次屏幕
    fitpolo705GetHeartRateAcquisitionIntervalOperation,     //读取手环心率采集间隔
    fitpolo705GetDoNotDisturbTimeOperation,     //读取勿扰时段
    fitpolo705GetPalmingBrightScreenOperation,  //获取翻腕亮屏信息
    fitpolo705GetUserInfoOperation,             //获取用户设置的个人信息
    fitpolo705GetDialStyleOperation,            //获取表盘样式
    fitpolo705GetHardwareParametersOperation,    //获取硬件参数
    fitpolo705GetFirmwareVersionOperation,       //获取固件版本号
    fitpolo705GetSleepIndexOperation,            //获取睡眠index数据
    fitpolo705GetSleepRecordOperation,           //获取睡眠record数据
    fitpolo705GetSportsDataOperation,            //获取运动数据
    fitpolo705GetLastChargingTimeOperation,      //获取上一次充电时间
    fitpolo705GetBatteryOperation,               //获取手环电量
    fitpolo705GetANCSConnectStatusOperation,     //获取当前手环跟手机的ancs连接状态
    
#pragma mark - 设置参数
    fitpolo705SetAlarmClockNumbersOperation,     //设置闹钟组数
    fitpolo705SetAlarmClockOperation,            //设置闹钟
    fitpolo705SetSedentaryRemindOperation,       //设置久坐提醒
    fitpolo705SetMovingTargetOperation,          //设置运动目标
    fitpolo705SetUnitOperation,                  //切换进制单位
    fitpolo705SetTimeFormatOperation,            //设置时间进制
    fitpolo705SetScreenDisplayOperation,         //设置屏幕显示
    fitpolo705RemindLastScreenDisplayOperation,  //记住上一次屏幕显示
    fitpolo705SetHeartRateAcquisitionIntervalOperation,  //设置心率采集间隔
    fitpolo705SetDoNotDisturbTimeOperation,      //设置勿扰模式
    fitpolo705OpenPalmingBrightScreenOperation,  //设置翻腕亮屏
    fitpolo705SetUserInfoOperation,              //设置个人信息
    fitpolo705SetDateOperation,                  //设置日期
    fitpolo705SetDialStyleOperation,             //设置表盘样式
    fitpolo705VibrationOperation,                //震动指令
    fitpolo705SetANCSOptionsOperation,           //设置开启ancs的选项
    
#pragma mark - 计步
    fitpolo705GetStepDataOperation,              //获取计步数据
    fitpolo705StepChangeMeterMonitoringStatusOperation ,    //计步数据监听状态
    
    fitpolo705StartUpdateOperation,              //开启升级
    
#pragma mark - 心率
    fitpolo705GetHeartDataOperation,             //获取心率数据
    fitpolo705GetSportHeartDataOperation,        //获取运动心率数据
};
