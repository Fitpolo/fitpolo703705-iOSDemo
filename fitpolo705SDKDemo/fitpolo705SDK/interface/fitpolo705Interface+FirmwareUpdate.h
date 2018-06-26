//
//  fitpolo705Interface+FirmwareUpdate.h
//  testSDK
//
//  Created by aa on 2018/4/18.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import "fitpolo705Interface.h"

@interface fitpolo705Interface (FirmwareUpdate)

/**
 手环开启升级固件
 
 @param crcData 本地升级的校验码，两个字节，将本地的固件做crc16得出来的
 @param packageSize 本次升级的固件大小，4个字节
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)peripheralStartUpdateWithCrcData:(NSData *)crcData
                             packageSize:(NSData *)packageSize
                            successBlock:(fitpolo705CommunicationSuccessBlock)successBlock
                             failedBlock:(fitpolo705CommunicationFailedBlock)failedBlock;

@end
