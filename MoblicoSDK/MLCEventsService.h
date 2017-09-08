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

NS_ASSUME_NONNULL_BEGIN

@class MLCLocation;
@class MLCMedia;
@class MLCEvent;

MLCServiceCreateResourceCompletionHandler(MLCEventsService, MLCEvent);
MLCServiceCreateCollectionCompletionHandler(MLCEventsService, MLCEvent);

NS_SWIFT_NAME(EventsService)
@interface MLCEventsService : MLCService

+ (instancetype)readEventWithEventId:(NSUInteger)eventId handler:(MLCEventsServiceResourceCompletionHandler)handler NS_SWIFT_NAME(readEvent(withId:handler:));

+ (instancetype)listEvents:(MLCEventsServiceCollectionCompletionHandler)handler;

+ (instancetype)findEventsWithType:(NSString *)type handler:(MLCEventsServiceCollectionCompletionHandler)handler;

+ (instancetype)findEventsWithType:(NSString *)type liveOnly:(BOOL)liveOnly handler:(MLCEventsServiceCollectionCompletionHandler)handler;

+ (instancetype)listSubEventsForEvent:(MLCEvent *)event handler:(MLCEventsServiceCollectionCompletionHandler)handler;

+ (instancetype)listEventsForLocation:(MLCLocation *)location handler:(MLCEventsServiceCollectionCompletionHandler)handler;

+ (instancetype)listEventsForMedia:(MLCMedia *)media handler:(MLCEventsServiceCollectionCompletionHandler)handler;

@end

NS_ASSUME_NONNULL_END
