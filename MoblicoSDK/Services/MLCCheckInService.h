//
//  MLCCheckInService.h
//  MoblicoSDK
//
//  Created by Cameron Knight on 10/25/13.
//  Copyright (c) 2013 Moblico Solutions LLC. All rights reserved.
//

#import <MoblicoSDK/MLCService.h>
@class MLCLocation;
@class MLCEvent;

@interface MLCCheckInService : MLCService

+ (instancetype)checkInWithLocation:(MLCLocation *)location handler:(MLCServiceStatusCompletionHandler)handler;
+ (instancetype)checkInWithLocation:(MLCLocation *)location event:(MLCEvent *)event handler:(MLCServiceStatusCompletionHandler)handler;

@end
