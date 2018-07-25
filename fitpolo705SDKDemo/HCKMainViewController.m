//
//  HCKMainViewController.m
//  testSDK
//
//  Created by aa on 2018/3/20.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "HCKMainViewController.h"
#import "fitpolo705SDK.h"
#import "fitpolo705Defines.h"

static NSString *const mainCellIdenty = @"mainCellIdenty";

@interface HCKMainViewController ()<UITableViewDelegate, UITableViewDataSource, fitpolo705ScanPeripheralDelegate, fitpolo705CentralManagerStateDelegate>

@property (nonatomic, strong)UIButton *button;

@property (nonatomic, strong)UITableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@property (nonatomic, strong)fitpolo705UpgradeManager *updateManager;

@end

@implementation HCKMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationItem setTitle:@"Test"];
    [self.view addSubview:self.button];
    [self.view addSubview:self.tableView];
    [self loadData];
    [fitpolo705CentralManager sharedInstance].scanDelegate = self;
    [fitpolo705CentralManager sharedInstance].managerStateDelegate = self;
}

#pragma mark -

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:mainCellIdenty];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:mainCellIdenty];
    }
    cell.textLabel.text = self.dataList[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self didSelectedRow:indexPath.row];
}

#pragma mark - fitpolo705ScanPeripheralDelegate
- (void)fitpolo705CentralStartScan:(fitpolo705CentralManager *)centralManager{
    NSLog(@"start scan");
}

- (void)fitpolo705CentralScanningNewPeripheral:(CBPeripheral *)peripheral macAddress:(NSString *)macAddress peripheralName:(NSString *)peripheralName centralManager:(fitpolo705CentralManager *)centralManager{
    NSLog(@"scan new peripheral:%@===%@====%@",peripheral.identifier.UUIDString,macAddress,peripheralName);
}

- (void)fitpolo705CentralStopScan:(fitpolo705CentralManager *)centralManager{
    NSLog(@"stop scan");
}

#pragma mark - fitpolo705CentralManagerStateDelegate
- (void)fitpolo705CentralStateChanged:(fitpolo705CentralManagerState)managerState manager:(fitpolo705CentralManager *)manager{
    NSLog(@"中心蓝牙状态发生改变");
}

- (void)fitpolo705PeripheralConnectStateChanged:(fitpolo705ConnectStatus)connectState manager:(fitpolo705CentralManager *)manager{
    NSLog(@"外设连接状态发生改变::::%@",@(connectState));
}

#pragma mark -

- (void)loadData{
    [self.dataList addObject:@"Read alarm data"];
    [self.dataList addObject:@"Read ancs option"];
    [self.dataList addObject:@"Read sedentary reminder data"];
    [self.dataList addObject:@"read motion target"];
    [self.dataList addObject:@"Read unit information"];
    [self.dataList addObject:@"read time"];
    [self.dataList addObject:@"read current screen display"];
    [self.dataList addObject:@"whether show last screen"];
    [self.dataList addObject:@"read heart rate collection interval"];
    [self.dataList addObject:@"Do not disturb time period"];
    [self.dataList addObject:@"Get Screen display info by switch wrist"];
    [self.dataList addObject:@"Read personal information"];
    [self.dataList addObject:@"hardware parameters"];
    [self.dataList addObject:@"firmware version number"];
    [self.dataList addObject:@"read sleep data"];
    [self.dataList addObject:@"read motion data"];
    [self.dataList addObject:@"read last charge time"];
    [self.dataList addObject:@"Read bracelet battery power"];
    
    [self.dataList addObject:@"Set sedentary reminder"];
    [self.dataList addObject:@"Set motion target"];
    [self.dataList addObject:@"set unit"];
    [self.dataList addObject:@"set time base"];
    [self.dataList addObject:@"sets the screen display"];
    [self.dataList addObject:@"last screen display"];
    [self.dataList addObject:@"heart rate collection interval"];
    [self.dataList addObject:@"Set Do not disturb mode"];
    [self.dataList addObject:@"set switch wrist to light up the screen"];
    [self.dataList addObject:@"set personal information"];
    [self.dataList addObject:@"set time"];
    [self.dataList addObject:@"vibrate"];

    
    [self.dataList addObject:@"Get pedometer data"];
    
    [self.dataList addObject:@"Get heart rate data"];
    [self.dataList addObject:@"Get heart rate date for exercise"];
    
    [self.dataList addObject:@"set alarm"];
    [self.dataList addObject:@"firmware update"];
    
    [self.dataList addObject:@"destroy singleton"];
    [self.tableView reloadData];
}

- (void)buttonPressed{
    fitpolo705WS(weakSelf);//@"E4-E2"
    [[fitpolo705CentralManager sharedInstance] connectPeripheralWithIdentifier:@"26-CB"peripheralType:operationPeripheralTypeFitpolo705 connectSuccessBlock:^(CBPeripheral *connectedPeripheral, NSString *macAddress, NSString *peripheralName) {
        [weakSelf showAlertWithMsg:@"Connect Success"];
    } connectFailBlock:^(NSError *error) {
        [weakSelf showAlertWithMsg:error.userInfo[@"errorInfo"]];
    }];
}

- (void)didSelectedRow:(NSInteger)row{
    if (row == 0) {
        [fitpolo705Interface readPeripheralAlarmClockDatasWithSucBlock:^(id returnData) {
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }else if (row == 1){
        [fitpolo705Interface readPeripheralAncsOptionsWithSucBlock:^(id returnData) {
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }else if (row == 2){
        [fitpolo705Interface readPeripheralSedentaryRemindDataWithSucBlock:^(id returnData) {
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }else if (row == 3){
        [fitpolo705Interface readPeripheralMovingTargetWithSucBlock:^(id returnData) {
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }else if (row == 4){
        [fitpolo705Interface readPeripheralUnitDataWithSucBlock:^(id returnData) {
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }else if (row == 5){
        [fitpolo705Interface readPeripheralTimeFormatDataWithSucBlock:^(id returnData) {
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }else if (row == 6){
        [fitpolo705Interface readPeripheralCustomScreenDisplayWithSucBlock:^(id returnData) {
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }else if (row == 7){
        [fitpolo705Interface readPeripheralRemindLastScreenDisplayWithSucBlock:^(id returnData) {
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }else if (row == 8){
        [fitpolo705Interface readPeripheralHeartRateAcquisitionIntervalWithSucBlock:^(id returnData) {
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }else if (row == 9){
        [fitpolo705Interface readPeripheralDoNotDisturbTimeWithSucBlock:^(id returnData) {
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }else if (row == 10){
        [fitpolo705Interface readPeripheralPalmingBrightScreenWithSucBlock:^(id returnData) {
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }else if (row == 11){
        [fitpolo705Interface readPeripheralUserInfoWithSucBlock:^(id returnData) {
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }else if (row == 12){
        [fitpolo705Interface readPeripheralHardwareParametersWithSucBlock:^(id returnData) {
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }else if (row == 13){
        [fitpolo705Interface readPeripheralFirmwareVersionWithSucBlock:^(id returnData) {
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }else if (row == 14){
        NSString *temp = @"2005-12-20 10:00";
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSDate *date = [formatter dateFromString:temp];
        [fitpolo705Interface readPeripheralSleepDataWithDate:date sucBlock:^(id returnData) {
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }else if (row == 15){
        NSString *temp = @"2005-12-20 10:00";
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSDate *date = [formatter dateFromString:temp];
        [fitpolo705Interface readPeripheralSportDataWithDate:date sucBlock:^(id returnData) {
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }else if (row == 16){
        [fitpolo705Interface readPeripheralLastChargingTimeWithSucBlock:^(id returnData) {
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }else if (row == 17){
        [fitpolo705Interface readPeripheralBatteryWithSucBlock:^(id returnData) {
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }else if (row == 18){
        [fitpolo705Interface setSedentaryRemind:YES startHour:12 startMinutes:0 endHour:15 endMinutes:0 sucBlock:^(id returnData) {
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }else if (row == 19){
        [fitpolo705Interface setMovingTarget:9000 sucBlock:^(id returnData) {
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }else if (row == 20){
        [fitpolo705Interface setUnitSwitch:fitpolo705Imperial sucBlock:^(id returnData) {
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }else if (row == 21){
        [fitpolo705Interface setTimeFormat:fitpolo70524Hour sucBlock:^(id returnData) {
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }else if (row == 22){
        fitpolo705CustomScreenModel *model = [[fitpolo705CustomScreenModel alloc] init];
        model.turnOnSleepPage = YES;
        model.turnOnStepPage = YES;
        [fitpolo705Interface setCustomScreenDisplay:model sucBlock:^(id returnData) {
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }else if (row == 23){
        [fitpolo705Interface setRemindLastScreenDisplay:YES sucBlock:^(id returnData) {
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }else if (row == 24){
        [fitpolo705Interface setHeartRateAcquisitionInterval:20 sucBlock:^(id returnData) {
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }else if (row == 25){
        [fitpolo705Interface setDoNotDisturbTime:YES startHour:12 startMinutes:22 endHour:15 endMinutes:22 sucBlock:^(id returnData) {
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }else if (row == 26){
        [fitpolo705Interface setPalmingBrightScreen:YES startHour:15 startMinutes:21 endHour:15 endMinutes:22 sucBlock:^(id returnData) {
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }else if (row == 27){
        
    }else if (row == 28){
        [fitpolo705Interface setDate:[NSDate date] sucBlock:^(id returnData) {
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }else if (row == 29){
        [fitpolo705Interface peripheralVibration:^(id returnData) {
            NSLog(@"%@",returnData);
        } failedBlock:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }else if (row == 30){
        NSString *temp = @"2005-12-20 10:00";
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSDate *date = [formatter dateFromString:temp];
        [fitpolo705Interface readStepDataWithDate:date sucBlock:^(id returnData) {
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }else if (row == 31){
        NSString *temp = @"2005-12-20 10:00";
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSDate *date = [formatter dateFromString:temp];
        [fitpolo705Interface readHeartRateDataWithDate:date sucBlock:^(id returnData) {
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }else if (row == 32){
        NSString *temp = @"2005-12-20 10:00";
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSDate *date = [formatter dateFromString:temp];
        [fitpolo705Interface readSportHeartRateDataWithDate:date sucBlock:^(id returnData) {
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }else if (row == 33){
        NSMutableArray *list = [NSMutableArray array];
        for (NSInteger i = 0; i < 6; i ++) {
            fitpolo705AlarmClockModel *model = [[fitpolo705AlarmClockModel alloc] init];
            model.clockType = fitpolo705AlarmClockMedicine;
            fitpolo705StatusModel *statusModel = [[fitpolo705StatusModel alloc] init];
            statusModel.tuesdayIsOn = YES;
            statusModel.thursdayIsOn = YES;
            model.statusModel = statusModel;
            model.hour = 18;
            model.minutes = 8;
            [list addObject:model];
        }
        [fitpolo705Interface setAlarmClock:list sucBlock:^(id returnData) {
            NSLog(@"%@",returnData);
        } failBlock:^(NSError *error) {
            NSLog(@"%@",error.description);
        }];
    }else if (row == 34){
        fitpolo705WS(weakSelf);
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"BORD_805_01" ofType:@"bin"];
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        [self.updateManager startUpdateProcessWithPackageData:fileData successBlock:^{
            [weakSelf showAlertWithMsg:@"Success"];
        } progressBlock:^(CGFloat progress) {
            //            NSLog(@"升级进度:%f",progress);
        } failedBlock:^(NSError *error) {
            [weakSelf showAlertWithMsg:error.description];
        }];
    }else if (row == self.dataList.count - 1){
        self.updateManager = nil;
        [fitpolo705CentralManager singletonDestroyed];
    }
}

- (void)showAlertWithMsg:(NSString *)msg{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Dismiss"
                                                                             message:msg
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:moreAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

//29-37
- (UILabel *)getLabel{
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor blueColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont systemFontOfSize:15.f];
    return label;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(15, 70.f, self.view.frame.size.width - 2 * 15, 400.f) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (UIButton *)button{
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setFrame:CGRectMake(15.f, self.view.frame.size.height - 40.f - 35.f, self.view.frame.size.width - 2 * 15, 40.f)];
        [_button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_button setTitle:@"button" forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}

- (NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (fitpolo705UpgradeManager *)updateManager{
    if (!_updateManager) {
        _updateManager = [fitpolo705UpgradeManager new];
    }
    return _updateManager;
}

@end
