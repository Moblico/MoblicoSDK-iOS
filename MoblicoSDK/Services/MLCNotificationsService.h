//
//  MLCNotificationsService.h
//  MoblicoSDK
//
//  Created by Cameron Knight on 8/11/15.
//  Copyright (c) 2015 Moblico Solutions LLC. All rights reserved.
//

#import <MoblicoSDK/MLCService.h>

@interface MLCNotificationsService : MLCService

+ (instancetype)readNotificationWithNotificationId:(NSUInteger)notificationId handler:(MLCServiceResourceCompletionHandler)handler;

@end
