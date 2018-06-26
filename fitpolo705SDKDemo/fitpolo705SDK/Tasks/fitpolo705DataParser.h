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

@interface fitpolo705ParseResultModel : NSObject

@property (nonatomic, assign)fitpolo705TaskOperationID operationID;

@property (nonatomic, strong)id returnData;

@end

@interface fitpolo705DataParser : NSObject

@property (nonatomic, strong)NSMutableArray *dataList;

- (void)parseReadDataFromCharacteristic:(CBCharacteristic *)characteristic;

@end
