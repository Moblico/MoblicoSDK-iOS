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
#import "MLCLocation.h"
#import "MLCEvent.h"
#import "MLCStatus.h"

@interface MLCCheckIn : MLCEntity

@property (nonatomic) NSUInteger locationId;
@property (nonatomic) NSUInteger eventId;

@end

@interface MLCCheckInService ()
+ (instancetype)checkInWithLocation:(MLCLocation *)location
                       userLocation:(CLLocation *)userLocation
                   beaconIdentifier:(NSString *)beaconIdentifier
                              event:(MLCEvent *)event
                            handler:(MLCServiceResourceCompletionHandler)handler;

@end

@implementation MLCCheckInService

+ (Class<MLCEntityProtocol>)classForResource {
    return [MLCCheckIn class];
}

+ (instancetype)checkInWithLocation:(MLCLocation *)location
                            handler:(MLCServiceResourceCompletionHandler)handler {
    return [self checkInWithLocation:location userLocation:nil beaconIdentifier:nil event:nil handler:handler];
}

+ (instancetype)checkInWithLocation:(MLCLocation *)location event:(MLCEvent *)event
                            handler:(MLCServiceResourceCompletionHandler)handler {
    return [self checkInWithLocation:location userLocation:nil beaconIdentifier:nil event:event handler:handler];
}

+ (instancetype)checkInWithLocation:(MLCLocation *)location userLocation:(CLLocation *)userLocation beaconIdentifier:(NSString *)beaconIdentifier handler:(MLCServiceResourceCompletionHandler)handler {
    return [self checkInWithLocation:location userLocation:userLocation beaconIdentifier:beaconIdentifier event:nil handler:handler];
}

+ (instancetype)checkInWithLocation:(MLCLocation *)location userLocation:(CLLocation *)userLocation beaconIdentifier:(NSString *)beaconIdentifier event:(MLCEvent *)event handler:(MLCServiceResourceCompletionHandler)handler {

    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:6];
    if (location) parameters[@"locationId"] = @(location.locationId);
    if (userLocation) {
        parameters[@"latitude"] = @(userLocation.coordinate.latitude);
        parameters[@"longitude"] = @(userLocation.coordinate.longitude);
        parameters[@"locationAccuracy"] = @(userLocation.horizontalAccuracy);
    }
    if (beaconIdentifier) parameters[@"beaconIdentifier"] = beaconIdentifier;
    if (event) parameters[@"eventId"] = @(event.eventId);
    MLCCheckIn *checkIn = [[MLCCheckIn alloc] initWithJSONObject:parameters];

    return [self createResource:checkIn handler:handler];
}

@end

@implementation MLCCheckIn

+ (NSString *)collectionName {
    return @"checkIn";
}

@end
