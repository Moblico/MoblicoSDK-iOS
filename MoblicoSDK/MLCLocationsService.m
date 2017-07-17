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

#import "MLCLocationsService.h"
#import "MLCLocation.h"

@implementation MLCLocationsService

+ (NSArray *)scopeableResources {
    return @[@"MLCEvent", @"MLCDeal", @"MLCReward", @"MLCMerchant"];
}

+ (Class<MLCEntityProtocol>)classForResource {
    return [MLCLocation class];
}

+ (instancetype)readLocationWithLocationId:(NSUInteger)locationId handler:(MLCServiceResourceCompletionHandler)handler {
    return [self readResourceWithUniqueIdentifier:@(locationId) handler:handler];
}

+ (instancetype)findLocationsWithSearchParameters:(NSDictionary *)searchParameters handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self findResourcesWithSearchParameters:searchParameters handler:handler];
}

+ (NSDictionary *)searchParametersForTypeNamed:(NSString *)typeName postalCode:(NSString *)postalCode latitude:(double)latitude longitude:(double)longitude radius:(double)radius {
    NSMutableDictionary *searchParameters = [NSMutableDictionary dictionaryWithCapacity:5];
    if (typeName.length) searchParameters[@"locationTypeName"] = typeName;
    if (postalCode.length) searchParameters[@"zipcode"] = postalCode;
    if (latitude) searchParameters[@"latitude"] = @(latitude);
    if (longitude) searchParameters[@"longitude"] = @(longitude);
    if (radius) searchParameters[@"radius"] = @(radius);

    return searchParameters;
}

+ (instancetype)findLocationsForMerchant:(MLCMerchant *)merchant typeNamed:(NSString *)typeName postalCode:(NSString *)postalCode latitude:(double)latitude longitude:(double)longitude radius:(double)radius handler:(MLCServiceCollectionCompletionHandler)handler {
    
    NSDictionary *searchParameters = [self searchParametersForTypeNamed:typeName
                                                             postalCode:postalCode
                                                               latitude:latitude
                                                              longitude:longitude
                                                                 radius:radius];
    return [self findLocationsForMerchant:merchant
                         searchParameters:searchParameters
                                  handler:handler];
}

+ (instancetype)findLocationsWithTypeNamed:(NSString *)typeName postalCode:(NSString *)postalCode latitude:(double)latitude longitude:(double)longitude radius:(double)radius handler:(MLCServiceCollectionCompletionHandler)handler {
    NSDictionary *searchParameters = [self searchParametersForTypeNamed:typeName postalCode:postalCode latitude:latitude longitude:longitude radius:radius];
    return [self findLocationsWithSearchParameters:searchParameters handler:handler];
}

+ (instancetype)listLocationsForEvent:(MLCEvent *)event handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self listLocationsForResource:(id<MLCEntityProtocol>)event handler:handler];
}

+ (instancetype)listLocationsForDeal:(MLCDeal *)deal handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self listLocationsForResource:(id<MLCEntityProtocol>)deal handler:handler];
}

+ (instancetype)listLocationsForReward:(MLCReward *)reward handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self listLocationsForResource:(id<MLCEntityProtocol>)reward handler:handler];
}

+ (instancetype)findLocationsForMerchant:(MLCMerchant *)merchant searchParameters:(NSDictionary *)searchParameters handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self findScopedResourcesForResource:(id<MLCEntityProtocol>)merchant searchParameters:searchParameters handler:handler];
}

+ (instancetype)listLocationsForMerchant:(MLCMerchant *)merchant handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self listLocationsForResource:(id<MLCEntityProtocol>)merchant handler:handler];
}

+ (instancetype)listLocationsForResource:(id <MLCEntityProtocol>)resource handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self listScopedResourcesForResource:resource handler:handler];
}

@end
