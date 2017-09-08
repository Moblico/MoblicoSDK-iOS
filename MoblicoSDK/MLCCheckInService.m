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

MLCCheckInServiceParameter const MLCCheckInServiceParameterCLLocation = @"clLocation";
MLCCheckInServiceParameter const MLCCheckInServiceParameterLatitude = @"latitude";
MLCCheckInServiceParameter const MLCCheckInServiceParameterLongitude = @"longitude";
MLCCheckInServiceParameter const MLCCheckInServiceParameterLocationAccuracy = @"locationAccuracy";
MLCCheckInServiceParameter const MLCCheckInServiceParameterPostalCode = @"zipcode";
MLCCheckInServiceParameter const MLCCheckInServiceParameterEvent = @"event";
MLCCheckInServiceParameter const MLCCheckInServiceParameterEventId = @"eventId";
MLCCheckInServiceParameter const MLCCheckInServiceParameterScanType = @"scanType";
MLCCheckInServiceParameter const MLCCheckInServiceParameterBeaconIdentifier = @"beaconIdentifier";

@interface MLCCheckIn : MLCEntity

@property (nonatomic) NSUInteger locationId;
@property (nonatomic) NSUInteger eventId;
@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;
@property (nonatomic) CLLocationAccuracy locationAccuracy;
@property (nonatomic, copy) NSString *beaconIdentifier;

@end

@interface MLCCheckInService ()

@end

@implementation MLCCheckInService

+ (NSMutableDictionary *)sanitizeParameters:(MLCCheckInServiceParameters)parameters {
    NSMutableDictionary *params = [parameters mutableCopy];
    params[MLCCheckInServiceParameterScanType] = [MLCEntity stringFromValue:params[MLCCheckInServiceParameterScanType]];
    params[MLCCheckInServiceParameterPostalCode] = [MLCEntity stringFromValue:params[MLCCheckInServiceParameterPostalCode]];
    params[MLCCheckInServiceParameterBeaconIdentifier] = [MLCEntity stringFromValue:params[MLCCheckInServiceParameterBeaconIdentifier]];
    params[MLCCheckInServiceParameterEventId] = [MLCEntity stringFromValue:params[MLCCheckInServiceParameterEventId]];
    MLCEvent *event = params[MLCCheckInServiceParameterEvent];
    if (event) {
        params[MLCCheckInServiceParameterEvent] = nil;
        params[MLCCheckInServiceParameterEventId] = [MLCEntity stringFromValue:@(event.eventId)];
    }
    NSString *latitude = [MLCEntity stringFromValue:params[MLCCheckInServiceParameterLatitude]];
    NSString *longitude = [MLCEntity stringFromValue:params[MLCCheckInServiceParameterLongitude]];
    NSString *locationAccuracy = [MLCEntity stringFromValue:params[MLCCheckInServiceParameterLocationAccuracy]];
    CLLocation *location = params[MLCCheckInServiceParameterCLLocation];
    if (location) {
        params[MLCCheckInServiceParameterCLLocation] = nil;
        latitude = [MLCEntity stringFromValue:@(location.coordinate.latitude)];
        longitude = [MLCEntity stringFromValue:@(location.coordinate.longitude)];
        locationAccuracy = [MLCEvent stringFromValue:@(location.horizontalAccuracy)];
    }

    NSUInteger maxLength = 16;
    params[MLCCheckInServiceParameterLatitude] = [latitude substringToIndex:MIN(latitude.length, maxLength)];
    params[MLCCheckInServiceParameterLongitude] = [longitude substringToIndex:MIN(longitude.length, maxLength)];
    params[MLCCheckInServiceParameterLocationAccuracy] = [locationAccuracy substringToIndex:MIN(locationAccuracy.length, maxLength)];

    return params;
}

+ (Class)classForResource {
    return [MLCCheckIn class];
}

+ (instancetype)checkInWithLocation:(MLCLocation *)location
                            handler:(MLCServiceSuccessCompletionHandler)handler {
    return [self checkInWithLocation:location parameters:@{} handler:handler];
}

+ (instancetype)checkInWithLocation:(MLCLocation *)location parameters:(nonnull MLCCheckInServiceParameters)parameters handler:(MLCServiceSuccessCompletionHandler)handler {
    NSMutableDictionary *params = [self sanitizeParameters:parameters];
    params[@"locationId"] = @(location.locationId);
    return [self create:@"checkIn" parameters:params handler:^(__unused MLCEntity *resource, NSError *error) {
        handler(error == nil, error);
    }];
}

@end

@implementation MLCCheckIn

+ (NSString *)collectionName {
    return @"checkIn";
}

@end
