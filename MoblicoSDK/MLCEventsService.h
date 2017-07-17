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

#import <MoblicoSDK/MLCService.h>
@class MLCLocation;
@class MLCMedia;
@class MLCEvent;

@interface MLCEventsService : MLCService

+ (instancetype)readEventWithEventId:(NSUInteger)eventId handler:(MLCServiceResourceCompletionHandler)handler;

+ (instancetype)findEventsWithTypeNamed:(NSString *)typeName liveOnly:(BOOL)liveOnly handler:(MLCServiceCollectionCompletionHandler)handler;
+ (instancetype)findEventsWithSearchParameters:(NSDictionary *)searchParameters handler:(MLCServiceCollectionCompletionHandler)handler;

+ (instancetype)listSubEventsForEvent:(MLCEvent *)event handler:(MLCServiceCollectionCompletionHandler)handler;
+ (instancetype)listEventsForLocation:(MLCLocation *)location handler:(MLCServiceCollectionCompletionHandler)handler;
+ (instancetype)listEventsForMedia:(MLCMedia *)media handler:(MLCServiceCollectionCompletionHandler)handler;
+ (instancetype)listEventsForResource:(id<MLCEntityProtocol>)resource handler:(MLCServiceCollectionCompletionHandler)handler;

@end
