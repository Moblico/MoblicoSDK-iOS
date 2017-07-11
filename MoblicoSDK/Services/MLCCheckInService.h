//
//  MLCCheckInService.h
//  MoblicoSDK
//
//  Created by Cameron Knight on 10/25/13.
//  Copyright (c) 2013 Moblico Solutions LLC. All rights reserved.
//

@import CoreLocation;
#import <MoblicoSDK/MLCService.h>

@class MLCLocation;
@class MLCEvent;

@interface MLCCheckInService : MLCService

+ (instancetype)checkInWithLocation:(MLCLocation *)location handler:(MLCServiceResourceCompletionHandler)handler;

+ (instancetype)checkInWithLocation:(MLCLocation *)location event:(MLCEvent *)event handler:(MLCServiceResourceCompletionHandler)handler;

+ (instancetype)checkInWithLocation:(MLCLocation *)location userLocation:(CLLocation *)userLocation beaconIdentifier:(NSString *)beaconIdentifier handler:(MLCServiceResourceCompletionHandler)handler;

+ (instancetype)checkInWithLocation:(MLCLocation *)location userLocation:(CLLocation *)userLocation beaconIdentifier:(NSString *)beaconIdentifier event:(MLCEvent *)event handler:(MLCServiceResourceCompletionHandler)handler;

@end
