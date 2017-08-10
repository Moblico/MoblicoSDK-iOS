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

/**
 Type of Ads supported by Moblico.

 - MLCAdServiceTypeBanner: Banner ads
 - MLCAdServiceTypePromo: Promo ads
 - MLCAdServiceTypeSponsor: Sponsor ads
 */
typedef NS_ENUM(NSUInteger, MLCAdServiceType) {
    /// Specifies a Banner ad.
    MLCAdServiceTypeBanner,
    /// Specifies a Promo ad.
    MLCAdServiceTypePromo,
    /// Specifies a Sponsor ad.
    MLCAdServiceTypeSponsor
};

/**
 Use the MLCAdsService class to retrieve ads from the Moblico Marketing Portal.
 */
@interface MLCAdsService : MLCService

/**
 Retrieve a collection of ads.

 @param type The type of ads to retrieve.
 @param context Context used by the backend.
 @param handler Collection completion handler.
 @return A MLCAdsService instance which conforms to the MLCServiceProtocol protocol.
 */
+ (instancetype)findAdsWithType:(MLCAdServiceType)type context:(NSString *)context handler:(MLCServiceCollectionCompletionHandler)handler;

/**
 Retrieve a single ad.

 @param type The type of the ad to retrieve.
 @param context Context used by the backend.
 @param handler Resource completion handler.
 @return A MLCAdsService instance which conforms to the MLCServiceProtocol protocol.
 */
+ (instancetype)readAdWithType:(MLCAdServiceType)type context:(NSString *)context handler:(MLCServiceResourceCompletionHandler)handler;

/**
 Retrieve a single banner ad.

 @param context Context used by the backend.
 @param handler Resource completion handler.
 @return A MLCAdsService instance which conforms to the MLCServiceProtocol protocol.
 */
+ (instancetype)readBannerAdWithContext:(NSString *)context handler:(MLCServiceResourceCompletionHandler)handler;

@end
