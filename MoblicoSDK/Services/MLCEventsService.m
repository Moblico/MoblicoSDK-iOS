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

@implementation MLCEventsService

+ (NSArray *)scopeableResources {
    return @[@"MLCEvent", @"MLCLocation", @"MLCMedia"];
}

+ (Class<MLCEntityProtocol>)classForResource {
    return [MLCEvent class];
}

+ (id)readEventWithEventId:(NSUInteger)eventId handler:(MLCServiceResourceCompletionHandler)handler {
    return [self readResourceWithUniqueIdentifier:@(eventId) handler:handler];
}

+ (id)findEventsWithSearchParameters:(NSDictionary *)searchParameters handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self findResourcesWithSearchParameters:searchParameters handler:handler];
}

+ (id)findEventsWithTypeNamed:(NSString *)typeName liveOnly:(BOOL)liveOnly handler:(MLCServiceCollectionCompletionHandler)handler {
    NSMutableDictionary *searchParameters = [NSMutableDictionary dictionaryWithCapacity:2];
    if (typeName.length) searchParameters[@"eventTypeName"] = typeName;
    searchParameters[@"liveOnly"] = liveOnly ? @"true" : @"false" ;
    return [self findEventsWithSearchParameters:searchParameters handler:handler];
}

+ (id)listSubEventsForEvent:(MLCEvent *)event handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self listEventsForResource:event handler:handler];
}

+ (id)listEventsForLocation:(MLCLocation *)location handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self listEventsForResource:(id<MLCEntityProtocol>)location handler:handler];
}

+ (id)listEventsForMedia:(MLCMedia *)media handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self listEventsForResource:(id<MLCEntityProtocol>)media handler:handler];
}

+ (id)listEventsForResource:(id<MLCEntityProtocol>)resource handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self listScopedResourcesForResource:resource handler:handler];
}
@end
