//
//  MLCNotification.h
//  MoblicoSDK
//
//  Created by Cameron Knight on 8/11/15.
//  Copyright (c) 2015 Moblico Solutions LLC. All rights reserved.
//

#import <MoblicoSDK/MLCEntity.h>

@interface MLCNotification : MLCEntity

@property (nonatomic) NSUInteger notificationId;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *title;

@end
