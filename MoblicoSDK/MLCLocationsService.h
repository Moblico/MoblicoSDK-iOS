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
@class MLCEvent;
@class MLCDeal;
@class MLCReward;
@class MLCMerchant;

@interface MLCLocationsService : MLCService

+ (instancetype)readLocationWithLocationId:(NSUInteger)locationId handler:(MLCServiceResourceCompletionHandler)handler;

+ (instancetype)findLocationsWithTypeNamed:(NSString *)typeName postalCode:(NSString *)postalCode latitude:(double)latitude longitude:(double)longitude radius:(double)radius handler:(MLCServiceCollectionCompletionHandler)handler;
+ (instancetype)findLocationsWithSearchParameters:(NSDictionary *)searchParameters handler:(MLCServiceCollectionCompletionHandler)handler;

+ (instancetype)findLocationsForMerchant:(MLCMerchant *)merchant typeNamed:(NSString *)typeName postalCode:(NSString *)postalCode latitude:(double)latitude longitude:(double)longitude radius:(double)radius handler:(MLCServiceCollectionCompletionHandler)handler;
+ (instancetype)findLocationsForMerchant:(MLCMerchant *)merchant searchParameters:(NSDictionary *)searchParameters handler:(MLCServiceCollectionCompletionHandler)handler;

+ (instancetype)listLocationsForMerchant:(MLCMerchant *)merchant handler:(MLCServiceCollectionCompletionHandler)handler;
+ (instancetype)listLocationsForEvent:(MLCEvent *)event handler:(MLCServiceCollectionCompletionHandler)handler;
+ (instancetype)listLocationsForDeal:(MLCDeal *)deal handler:(MLCServiceCollectionCompletionHandler)handler;
+ (instancetype)listLocationsForReward:(MLCReward *)reward handler:(MLCServiceCollectionCompletionHandler)handler;
+ (instancetype)listLocationsForResource:(id<MLCEntityProtocol>)resource handler:(MLCServiceCollectionCompletionHandler)handler;

@end