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

/// Type of Ads supported by Moblico.
typedef NSString *MLCAdsServiceType NS_STRING_ENUM NS_SWIFT_NAME(MLCAdsService.Type);
/// Specifies a Banner ad.
FOUNDATION_EXPORT MLCAdsServiceType const MLCAdsServiceTypeBanner;
/// Specifies a Promo ad.
FOUNDATION_EXPORT MLCAdsServiceType const MLCAdsServiceTypePromo;
/// Specifies a Sponsor ad.
FOUNDATION_EXPORT MLCAdsServiceType const MLCAdsServiceTypeSponsor;

@class MLCAd;

/**
 Callback for read ad.

 @param resource The Ad returned by the service request.
 @param error An error identifier.
 */
MLCServiceCreateResourceCompletionHandler(MLCAdsService, MLCAd);


MLCServiceCreateCollectionCompletionHandler(MLCAdsService, MLCAd);

/**
 Use the MLCAdsService class to retrieve ads from the Moblico Marketing Portal.
 */
NS_SWIFT_NAME(AdsService)
@interface MLCAdsService : MLCService

/**
 Retrieve a collection of ads.

 @param type The type of ads to retrieve.
 @param context Context used by the backend.
 @param handler Collection completion handler.
 @return A MLCAdsService instance which conforms to the MLCServiceProtocol protocol.
 */
+ (instancetype)findAdsWithType:(MLCAdsServiceType)type context:(nullable NSString *)context handler:(MLCAdsServiceCollectionCompletionHandler)handler;

/**
 Retrieve a single ad.

 @param type The type of the ad to retrieve.
 @param context Context used by the backend.
 @param handler Resource completion handler.
 @return A MLCAdsService instance which conforms to the MLCServiceProtocol protocol.
 */
+ (instancetype)readAdWithType:(MLCAdsServiceType)type context:(nullable NSString *)context handler:(MLCAdsServiceResourceCompletionHandler)handler;

@end

NS_ASSUME_NONNULL_END
