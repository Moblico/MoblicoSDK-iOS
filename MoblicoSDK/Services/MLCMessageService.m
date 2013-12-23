//
//  MLCMessageService.m
//  MoblicoSDK
//
//  Created by Cameron Knight on 10/8/13.
//  Copyright (c) 2013 Moblico Solutions LLC. All rights reserved.
//

#import "MLCService.h"
#import "MLCService_Private.h"
#import "MLCMessageService.h"
#import "MLCMessage.h"

@implementation MLCMessageService

+ (instancetype)sendMessage:(MLCMessage *)message handler:(MLCServiceStatusCompletionHandler)handler {
    return [self createResource:message handler:handler];
}

+ (instancetype)sendMessageWithText:(NSString *)text toDeviceIds:(NSArray *)deviceIds phoneNumbers:(NSArray *)phoneNumbers emailAddresses:(NSArray *)emailAddresses handler:(MLCServiceStatusCompletionHandler)handler {
    MLCMessage *message = [MLCMessage messageWithText:text deviceIds:deviceIds phoneNumbers:phoneNumbers emailAddresses:emailAddresses];

    return [self sendMessage:message handler:handler];
}

@end
