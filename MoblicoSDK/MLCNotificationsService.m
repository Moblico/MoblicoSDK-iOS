//
//  MLCNotificationsService.m
//  MoblicoSDK
//
//  Created by Cameron Knight on 8/11/15.
//  Copyright (c) 2015 Moblico Solutions LLC. All rights reserved.
//

#import "MLCNotificationsService.h"
#import "MLCService_Private.h"
#import "MLCNotification.h"

@implementation MLCNotificationsService

+ (Class<MLCEntityProtocol>)classForResource {
    return [MLCNotification class];
}

+ (instancetype)readNotificationWithNotificationId:(NSUInteger)notificationId handler:(MLCServiceResourceCompletionHandler)handler {
    return [self readResourceWithUniqueIdentifier:@(notificationId) handler:handler];
}

@end
