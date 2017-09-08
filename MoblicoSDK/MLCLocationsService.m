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

#import "MLCService_Private.h"
#import "MLCEntity_Private.h"
#import "MLCLocationsService.h"
#import "MLCLocation.h"
#import "MLCEvent.h"
#import "MLCDeal.h"
#import "MLCReward.h"
#import "MLCMerchant.h"

MLCLocationsServiceParameter const MLCLocationsServiceParameterType = @"type";
MLCLocationsServiceParameter const MLCLocationsServiceParameterPostalCode = @"zipcode";
MLCLocationsServiceParameter const MLCLocationsServiceParameterLatitude = @"latitude";
MLCLocationsServiceParameter const MLCLocationsServiceParameterLongitude = @"longitude";
MLCLocationsServiceParameter const MLCLocationsServiceParameterRadius = @"radius";
MLCLocationsServiceParameter const MLCLocationsServiceParameterPage = @"page";
MLCLocationsServiceParameter const MLCLocationsServiceParameterMerchantId = @"merchantId";
MLCLocationsServiceParameter const MLCLocationsServiceParameterCheckInEnabled = @"checkInEnabled";
MLCLocationsServiceParameter const MLCLocationsServiceParameterNotificationEnabled = @"notificationEnabled";
MLCLocationsServiceParameter const MLCLocationsServiceParameterCLLocation = @"clLocation";


@implementation MLCLocationsService

+ (NSMutableDictionary *)sanitizeParameters:(MLCLocationsServiceParameters)parameters {
    NSMutableDictionary *params = [parameters mutableCopy];
    params[MLCLocationsServiceParameterType] = [MLCEntity stringFromValue:params[MLCLocationsServiceParameterType]];
    params[MLCLocationsServiceParameterPostalCode] = [MLCEntity stringFromValue:params[MLCLocationsServiceParameterPostalCode]];
    params[MLCLocationsServiceParameterRadius] = [MLCEntity stringFromValue:params[MLCLocationsServiceParameterRadius]];
    params[MLCLocationsServiceParameterPage] = [MLCEntity stringFromValue:params[MLCLocationsServiceParameterPage]];
    params[MLCLocationsServiceParameterMerchantId] = [MLCEntity stringFromValue:params[MLCLocationsServiceParameterMerchantId]];
    params[MLCLocationsServiceParameterCheckInEnabled] = [MLCEntity stringFromValue:params[MLCLocationsServiceParameterCheckInEnabled]];
    params[MLCLocationsServiceParameterNotificationEnabled] = [MLCEntity stringFromValue:params[MLCLocationsServiceParameterNotificationEnabled]];

    NSString *latitude = [MLCEntity stringFromValue:params[MLCLocationsServiceParameterLatitude]];
    NSString *longitude = [MLCEntity stringFromValue:params[MLCLocationsServiceParameterLongitude]];
    CLLocation *location = params[MLCLocationsServiceParameterCLLocation];
    if (location) {
        params[MLCLocationsServiceParameterCLLocation] = nil;
        latitude = [MLCEntity stringFromValue:@(location.coordinate.latitude)];
        longitude = [MLCEntity stringFromValue:@(location.coordinate.longitude)];
    }

    NSUInteger maxLength = 16;
    params[MLCLocationsServiceParameterLatitude] = [latitude substringToIndex:MIN(latitude.length, maxLength)];
    params[MLCLocationsServiceParameterLongitude] = [longitude substringToIndex:MIN(longitude.length, maxLength)];

    return params;
}

+ (NSArray<Class> *)scopeableResources {
    return @[[MLCEvent class], [MLCDeal class], [MLCReward class], [MLCMerchant class]];
}

+ (Class)classForResource {
    return [MLCLocation class];
}

+ (instancetype)readLocationWithLocationId:(NSUInteger)locationId handler:(MLCLocationsServiceResourceCompletionHandler)handler {
    return [self readResourceWithUniqueIdentifier:@(locationId) handler:handler];
}

+ (instancetype)listLocations:(MLCLocationsServiceCollectionCompletionHandler)handler {
    return [self listResources:handler];
}

+ (instancetype)findLocationsWithParameters:(MLCLocationsServiceParameters)parameters handler:(MLCLocationsServiceCollectionCompletionHandler)handler {
    return [self findResourcesWithSearchParameters:[self sanitizeParameters:parameters] handler:handler];
}

+ (instancetype)listLocationsForEvent:(MLCEvent *)event handler:(MLCLocationsServiceCollectionCompletionHandler)handler {
    return [self listLocationsForResource:event handler:handler];
}

+ (instancetype)listLocationsForDeal:(MLCDeal *)deal handler:(MLCLocationsServiceCollectionCompletionHandler)handler {
    return [self listLocationsForResource:deal handler:handler];
}

+ (instancetype)listLocationsForReward:(MLCReward *)reward handler:(MLCLocationsServiceCollectionCompletionHandler)handler {
    return [self listLocationsForResource:reward handler:handler];
}

+ (instancetype)findLocationsForMerchant:(MLCMerchant *)merchant parameters:(MLCLocationsServiceParameters)parameters handler:(MLCLocationsServiceCollectionCompletionHandler)handler {
    NSMutableDictionary *searchParameters = [self sanitizeParameters:parameters];
    [searchParameters removeObjectForKey:MLCLocationsServiceParameterMerchantId];
    return [self findScopedResourcesForResource:merchant searchParameters:searchParameters handler:handler];
}

+ (instancetype)listLocationsForMerchant:(MLCMerchant *)merchant handler:(MLCLocationsServiceCollectionCompletionHandler)handler {
    return [self listLocationsForResource:merchant handler:handler];
}

+ (instancetype)listLocationsForResource:resource handler:(MLCLocationsServiceCollectionCompletionHandler)handler {
    return [self listScopedResourcesForResource:resource handler:handler];
}

@end
