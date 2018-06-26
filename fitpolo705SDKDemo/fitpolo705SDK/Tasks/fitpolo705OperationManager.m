//
//  fitpolo705OperationManager.m
//  testSDK
//
//  Created by aa on 2018/3/15.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "fitpolo705OperationManager.h"

@interface fitpolo705OperationManager()

@property (nonatomic, strong)NSOperationQueue *operationQueue;

@end

@implementation fitpolo705OperationManager

- (void)dealloc{
    NSLog(@"队列销毁");
    [self.operationQueue cancelAllOperations];
}

#pragma mark - Public method
/**
 添加任务到队列
 
 @param operation operation
 */
- (void)addOperation:(fitpolo705TaskOperation *)operation{
    if (!operation) {
        return;
    }
    [self.operationQueue addOperation:operation];
}

/**
 取消所有任务
 */
- (void)cancelAllOperations{
    [self.operationQueue cancelAllOperations];
}


#pragma mark - setter & getter
- (NSOperationQueue *)operationQueue{
    if (!_operationQueue) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
    }
    return _operationQueue;
}

@end
