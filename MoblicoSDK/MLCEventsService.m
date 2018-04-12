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

#import "MLCEventsService.h"
#import "MLCEvent.h"
#import "MLCLocation.h"
#import "MLCMedia.h"

@implementation MLCEventsService

+ (NSArray<Class> *)scopeableResources {
    return @[[MLCEvent class], [MLCLocation class], [MLCMedia class]];
}

+ (Class)classForResource {
    return [MLCEvent class];
}

+ (instancetype)readEventWithEventId:(NSUInteger)eventId handler:(MLCEventsServiceResourceCompletionHandler)handler {
    return [self readResourceWithUniqueIdentifier:@(eventId) handler:handler];
}

+ (instancetype)listEvents:(MLCEventsServiceCollectionCompletionHandler)handler {
    return [self findEventsWithSearchParameters:@{} handler:handler];
}

+ (instancetype)findEventsWithSearchParameters:(NSDictionary *)searchParameters handler:(MLCEventsServiceCollectionCompletionHandler)handler {
    return [self findResourcesWithSearchParameters:searchParameters handler:handler];
}

+ (instancetype)findEventsWithType:(NSString *)type handler:(MLCEventsServiceCollectionCompletionHandler)handler {
    NSDictionary *searchParameters;

    if (type.length) {
        searchParameters = @{@"type": type};
    }

    return [self findEventsWithSearchParameters:searchParameters handler:handler];
}
+ (instancetype)findEventsWithType:(NSString *)type liveOnly:(BOOL)liveOnly handler:(MLCEventsServiceCollectionCompletionHandler)handler {
    NSMutableDictionary *searchParameters = [NSMutableDictionary dictionaryWithCapacity:2];
    if (type.length) searchParameters[@"type"] = type;
    searchParameters[@"liveOnly"] = liveOnly ? @"true" : @"false";

    return [self findEventsWithSearchParameters:searchParameters handler:handler];
}

+ (instancetype)listSubEventsForEvent:(MLCEvent *)event handler:(MLCEventsServiceCollectionCompletionHandler)handler {
    return [self listEventsForResource:event handler:handler];
}

+ (instancetype)listEventsForLocation:(MLCLocation *)location handler:(MLCEventsServiceCollectionCompletionHandler)handler {
    return [self listEventsForResource:location handler:handler];
}

+ (instancetype)listEventsForMedia:(MLCMedia *)media handler:(MLCEventsServiceCollectionCompletionHandler)handler {
    return [self listEventsForResource:media handler:handler];
}

+ (instancetype)listEventsForResource:(MLCEntity *)resource handler:(MLCEventsServiceCollectionCompletionHandler)handler {
    return [self findScopedResourcesForResource:resource searchParameters:@{} handler:handler];
}

@end
