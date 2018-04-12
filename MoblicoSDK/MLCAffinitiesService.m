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

#import "MLCAffinitiesService.h"
#import "MLCAffinity.h"
#import "MLCLocation.h"

@implementation MLCAffinitiesService

+ (Class)classForResource {
    return [MLCAffinity class];
}

+ (NSArray<Class> *)scopeableResources {
    return @[[MLCLocation class]];
}

+ (instancetype)listAffinities:(MLCAffinitiesServiceCollectionCompletionHandler)handler {
    return [self findResourcesWithSearchParameters:@{} handler:handler];
}

+ (instancetype)listAffinitiesForLocation:(MLCLocation *)location handler:(MLCAffinitiesServiceCollectionCompletionHandler)handler {
    return [self listAffinitiesForResource:location handler:handler];
}

+ (instancetype)listAffinitiesForResource:(MLCEntity *)resource handler:(MLCAffinitiesServiceCollectionCompletionHandler)handler {
    return [self findScopedResourcesForResource:resource searchParameters:@{} handler:handler];
}

@end
