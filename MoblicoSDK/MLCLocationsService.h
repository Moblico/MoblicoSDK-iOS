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

typedef NSString *MLCLocationsServiceParameter NS_TYPED_ENUM NS_SWIFT_NAME(MLCLocationsService.Parameter);
FOUNDATION_EXPORT MLCLocationsServiceParameter const MLCLocationsServiceParameterMerchantId;
FOUNDATION_EXPORT MLCLocationsServiceParameter const MLCLocationsServiceParameterCLLocation;
FOUNDATION_EXPORT MLCLocationsServiceParameter const MLCLocationsServiceParameterLatitude;
FOUNDATION_EXPORT MLCLocationsServiceParameter const MLCLocationsServiceParameterLongitude;
FOUNDATION_EXPORT MLCLocationsServiceParameter const MLCLocationsServiceParameterCheckInEnabled;
FOUNDATION_EXPORT MLCLocationsServiceParameter const MLCLocationsServiceParameterNotificationEnabled;
FOUNDATION_EXPORT MLCLocationsServiceParameter const MLCLocationsServiceParameterRadius;
FOUNDATION_EXPORT MLCLocationsServiceParameter const MLCLocationsServiceParameterType;
FOUNDATION_EXPORT MLCLocationsServiceParameter const MLCLocationsServiceParameterPostalCode;
FOUNDATION_EXPORT MLCLocationsServiceParameter const MLCLocationsServiceParameterPage;

typedef NSDictionary<MLCLocationsServiceParameter, id> *MLCLocationsServiceParameters NS_SWIFT_NAME(MLCLocationsService.Parameters);

@class MLCEvent;
@class MLCDeal;
@class MLCReward;
@class MLCMerchant;
@class MLCLocation;

MLCServiceCreateResourceCompletionHandler(MLCLocationsService, MLCLocation);
MLCServiceCreateCollectionCompletionHandler(MLCLocationsService, MLCLocation);

NS_SWIFT_NAME(LocationsService)
@interface MLCLocationsService : MLCService

+ (instancetype)readLocationWithLocationId:(NSUInteger)locationId handler:(MLCLocationsServiceResourceCompletionHandler)handler NS_SWIFT_NAME(readLocation(withId:handler:));


+ (instancetype)listLocations:(MLCLocationsServiceCollectionCompletionHandler)handler;

+ (instancetype)findLocationsWithParameters:(MLCLocationsServiceParameters)parameters handler:(MLCLocationsServiceCollectionCompletionHandler)handler NS_SWIFT_NAME(findLocations(with:handler:));

+ (instancetype)listLocationsForMerchant:(MLCMerchant *)merchant handler:(MLCLocationsServiceCollectionCompletionHandler)handler;

+ (instancetype)findLocationsForMerchant:(MLCMerchant *)merchant parameters:(MLCLocationsServiceParameters)parameters handler:(MLCLocationsServiceCollectionCompletionHandler)handler;

+ (instancetype)listLocationsForEvent:(MLCEvent *)event handler:(MLCLocationsServiceCollectionCompletionHandler)handler;

+ (instancetype)listLocationsForDeal:(MLCDeal *)deal handler:(MLCLocationsServiceCollectionCompletionHandler)handler;

+ (instancetype)listLocationsForReward:(MLCReward *)reward handler:(MLCLocationsServiceCollectionCompletionHandler)handler;

@end

NS_ASSUME_NONNULL_END

