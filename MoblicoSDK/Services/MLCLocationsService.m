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
    return @[@"MLCEvent", @"MLCDeal", @"MLCReward"];
}

+ (Class<MLCEntity>)classForResource {
    return [MLCLocation class];
}

+ (instancetype)readLocationWithLocationId:(NSUInteger)locationId handler:(MLCServiceResourceCompletionHandler)handler {
    return [self readResourceWithUniqueIdentifier:@(locationId) handler:handler];
}

+ (instancetype)findLocationsWithSearchParameters:(NSDictionary *)searchParameters handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self findResourcesWithSearchParameters:searchParameters handler:handler];
}

+ (instancetype)findLocationsWithTypeNamed:(NSString *)typeName postalCode:(NSString *)postalCode latitude:(double)latitude longitude:(double)longitude radius:(double)radius handler:(MLCServiceCollectionCompletionHandler)handler {
    NSMutableDictionary * searchParameters = [NSMutableDictionary dictionaryWithCapacity:5];
    if (typeName.length) searchParameters[@"locationTypeName"] = typeName;
    if (postalCode.length) searchParameters[@"postalCode"] = postalCode;
    if (latitude) searchParameters[@"latitude"] = @(latitude);
    if (longitude) searchParameters[@"longitude"] = @(longitude);
    if (radius) searchParameters[@"radius"] = @(radius);
    
    return [self findLocationsWithSearchParameters:searchParameters handler:handler];
}

+ (instancetype)listLocationsForEvent:(MLCEvent *)event handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self listLocationsForResource:(id<MLCEntity>)event handler:handler];
}

+ (instancetype)listLocationsForDeal:(MLCDeal *)deal handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self listLocationsForResource:(id<MLCEntity>)deal handler:handler];
}

+ (instancetype)listLocationsForReward:(MLCReward *)reward handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self listLocationsForResource:(id<MLCEntity>)reward handler:handler];
}

+ (instancetype)listLocationsForResource:(id <MLCEntity>)resource handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self listScopedResourcesForResource:resource handler:handler];
}
@end
