//
//  fitpolo705OperationManager.h
//  testSDK
//
//  Created by aa on 2018/3/15.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "fitpolo705TaskOperation.h"

@interface fitpolo705OperationManager : NSObject

/**
 添加任务到队列
 
 @param operation operation
 */
- (void)addOperation:(fitpolo705TaskOperation *)operation;

/**
 取消所有任务
 */
- (void)cancelAllOperations;

@end
