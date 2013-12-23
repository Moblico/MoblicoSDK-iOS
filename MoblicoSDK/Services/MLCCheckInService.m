//
//  MLCCheckInService.m
//  MoblicoSDK
//
//  Created by Cameron Knight on 10/25/13.
//  Copyright (c) 2013 Moblico Solutions LLC. All rights reserved.
//

#import "MLCCheckInService.h"
#import "MLCService_Private.h"
#import "MLCEntity_Private.h"

@interface MLCCheckIn : MLCEntity
@property (nonatomic) NSUInteger locationId;
@property (nonatomic) NSUInteger eventId;
@end

@implementation MLCCheckInService

+ (instancetype)checkInWithLocation:(MLCLocation *)location handler:(MLCServiceStatusCompletionHandler)handler {
    return [self checkInWithLocation:location event:nil handler:handler];
}

+ (instancetype)checkInWithLocation:(MLCLocation *)location event:(MLCEvent *)event handler:(MLCServiceStatusCompletionHandler)handler {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:2];
    if (location) parameters[@"locationId"] = @(location.locationId);
    if (event) parameters[@"eventId"] = @(event.eventId);

    MLCCheckIn *checkIn = [MLCCheckIn deserialize:parameters];

    return [self createResource:checkIn handler:handler];
}

@end


@implementation MLCCheckIn

+ (NSString *)collectionName {
    return @"checkIn";
}

@end
