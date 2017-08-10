/*
 Copyright 2012 Moblico Solutions LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this work except in compliance with the License.
 You may obtain a copy of the License in the LICENSE file, or at:

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "MLCCheckInService.h"
#import "MLCService_Private.h"
#import "MLCEntity_Private.h"
#import "MLCLocation.h"
#import "MLCEvent.h"

@interface MLCCheckIn : MLCEntity

@property (nonatomic) NSUInteger locationId;
@property (nonatomic) NSUInteger eventId;
@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;
@property (nonatomic) CLLocationAccuracy locationAccuracy;
@property (nonatomic, copy) NSString *beaconIdentifier;

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

    return [self create:@"checkIn" parameters:parameters handler:handler];
}

@end

@implementation MLCCheckIn

+ (NSString *)collectionName {
    return @"checkIn";
}

@end
