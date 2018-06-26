//
//  fitpolo705AncsModel.h
//  testSDK
//
//  Created by aa on 2018/3/15.
//  Copyright © 2018年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface fitpolo705AncsModel : NSObject

/**
 打开短信提醒
 */
@property (nonatomic, assign)BOOL openSMS;

/**
 打开电话提醒
 */
@property (nonatomic, assign)BOOL openPhone;

/**
 打开微信提醒
 */
@property (nonatomic, assign)BOOL openWeChat;

/**
 打开qq提醒
 */
@property (nonatomic, assign)BOOL openQQ;

/**
 打开whatsapp提醒
 */
@property (nonatomic, assign)BOOL openWhatsapp;

/**
 打开facebook提醒
 */
@property (nonatomic, assign)BOOL openFacebook;

/**
 打开twitter提醒
 */
@property (nonatomic, assign)BOOL openTwitter;

/**
 打开skype提醒
 */
@property (nonatomic, assign)BOOL openSkype;

/**
 打开snapchat提醒
 */
@property (nonatomic, assign)BOOL openSnapchat;

/**
 打开Line
 */
@property (nonatomic, assign)BOOL openLine;

@end
