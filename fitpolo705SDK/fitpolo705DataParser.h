//
//  fitpolo705DataParser.h
//  testSDK
//
//  Created by aa on 2018/3/15.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "fitpolo705TaskIDDefines.h"

extern NSString *const fitpolo705CommunicationDataNum;

@interface fitpolo705DataParser : NSObject

+ (NSDictionary *)parseReadDataFromCharacteristic:(CBCharacteristic *)characteristic;

@end
