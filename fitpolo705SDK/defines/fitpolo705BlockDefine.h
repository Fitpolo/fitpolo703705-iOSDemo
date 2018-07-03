
#import <CoreBluetooth/CoreBluetooth.h>
#import "fitpolo705EnumerateDefine.h"

static NSString * const fitpolo705CustomErrorDomain = @"com.moko.fitpoloBluetoothSDK";

#define fitpolo705_main_safe(block)\
if ([NSThread isMainThread]) {\
    block();\
} else {\
    dispatch_async(dispatch_get_main_queue(), block);\
}

#define fitpolo705ConnectError(block)\
if(block){\
    fitpolo705_main_safe(^{\
        NSError *error = [[NSError alloc] initWithDomain:fitpolo705CustomErrorDomain\
                        code:fitpolo705PeripheralDisconnected\
                        userInfo:@{@"errorInfo":@"The current connection device is in disconnect"}];\
        block(error);\
    });\
}\

#define fitpolo705ParamsError(block)\
if(block){\
    fitpolo705_main_safe(^{\
        NSError *error = [[NSError alloc] initWithDomain:fitpolo705CustomErrorDomain\
                        code:fitpolo705ParamsError\
                        userInfo:@{@"errorInfo":@"input parameter error"}];\
        block(error);\
    });\
}\

#define fitpolo705CommunicationTimeout(block)\
if(block){\
    fitpolo705_main_safe(^{\
        NSError *error = [[NSError alloc] initWithDomain:fitpolo705CustomErrorDomain\
                        code:fitpolo705CommunicationTimeOut\
                        userInfo:@{@"errorInfo":@"Data communication timeout"}];\
        block(error);\
    });\
}\

#define fitpolo705RequestPeripheralDataError(block)\
if(block){\
    fitpolo705_main_safe(^{\
        NSError *error = [[NSError alloc] initWithDomain:fitpolo705CustomErrorDomain\
                        code:fitpolo705RequestPeripheralDataError\
                        userInfo:@{@"errorInfo":@"Request bracelet data error"}];\
        block(error);\
    });\
}\

#define fitpolo705BleStateError(block)\
if(block){\
    fitpolo705_main_safe(^{\
        NSError *error = [[NSError alloc] initWithDomain:fitpolo705CustomErrorDomain\
                        code:fitpolo705BlueDisable\
                        userInfo:@{@"errorInfo":@"mobile phone bluetooth is currently unavailable"}];\
        block(error);\
    });\
}\

#define fitpolo705CharacteristicError(block)\
if(block){\
    fitpolo705_main_safe(^{\
        NSError *error = [[NSError alloc] initWithDomain:fitpolo705CustomErrorDomain\
                        code:fitpolo705CharacteristicError\
                        userInfo:@{@"errorInfo":@"characteristic error"}];\
    block(error);\
    });\
}\

#define fitpolo705SetParamError(block)\
if(block){\
    fitpolo705_main_safe(^{\
        NSError *error = [[NSError alloc] initWithDomain:fitpolo705CustomErrorDomain\
                        code:fitpolo705SetParamsError\
                        userInfo:@{@"errorInfo":@"Set the parameter error"}];\
    block(error);\
    });\
}\

/**
 数据通信成功
 
 @param returnData 返回的Json数据
 */
typedef void(^fitpolo705CommunicationSuccessBlock)(id returnData);

/**
 数据通信失败
 
 @param error 失败原因
 */
typedef void(^fitpolo705CommunicationFailedBlock)(NSError *error);

/**
 监测当前中心和外设连接状态
 
 @param status 连接状态
 */
typedef void(^fitpolo705ConnectStatusChangedBlock)(fitpolo705ConnectStatus status);

/**
 监测当前中心的蓝牙状态
 
 @param status 蓝牙状态
 */
typedef void(^fitpolo705CentralStatusChangedBlock)(fitpolo705CentralManagerState status);
