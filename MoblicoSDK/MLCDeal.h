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

#import <MoblicoSDK/MLCEntity.h>

NS_ASSUME_NONNULL_BEGIN

@class MLCImage;

/**
 Moblico deals encompass many of the attributes of coupons.
 Deals can be associated to Locations (i.e merchants) and Moblico
 also provides several mechanisms for Deal redemption.
 
 Deals are loaded and managed using Moblico's admin tool.
 
 A MLCDeal object encapsulates the data of a deal stored in
 the Moblico Admin Portal.
 */
NS_SWIFT_NAME(Deal)
@interface MLCDeal : MLCEntity

/**
 A unique identifier for this deal.
 */
@property (nonatomic) NSUInteger dealId NS_SWIFT_NAME(id);

/**
 The name for this deal.
 */
@property (copy, nonatomic) NSString *name;

/**
 The details for this deal.
 */
@property (copy, nonatomic, nullable) NSString *details;

/**
 The offer code for this deal.
 */
@property (copy, nonatomic, nullable) NSString *offerCode;

/**
 The legalese for this deal.
 */
@property (copy, nonatomic, nullable) NSString *legalese;

/**
 The promo text for this deal.
 */
@property (copy, nonatomic, nullable) NSString *promoText;

/**
 The name of the URL for this deal.
 */
@property (copy, nonatomic, nullable) NSString *urlName;

/**
 The URL for this deal.
 */
@property (strong, nonatomic, nullable) NSURL *url;

/**
 The date this deal was created.
 */
@property (strong, nonatomic) NSDate *createDate;

/**
 The date this deal was last updated.
 */
@property (strong, nonatomic) NSDate *lastUpdateDate;

/**
 The date this deal will become active.
 */
@property (strong, nonatomic, nullable) NSDate *startDate;

/**
 The date this deal will no longer be active.
 */
@property (strong, nonatomic, nullable) NSDate *endDate;

/**
 The number of times this deal has been redeemed.
 */
@property (nonatomic) NSInteger redeemedCount;

/**
 The number of uses per offer code for this deal.
 */
@property (nonatomic) NSInteger numberOfUsesPerCode;

/**
 Specifies whether this deal can be redeemed in app.

 Deals that are not appRedemptionEnabled must be redeemed using
 the Moblico Redemption Tool.
 */
@property (nonatomic) BOOL appRedemptionEnabled;

/**
 The image for this deal.
 
 @see MLCImage
 */
@property (strong, nonatomic, nullable) MLCImage *image;

@property (assign, nonatomic, getter=isGoalEnabled) BOOL goalEnabled;
@property (assign, nonatomic, getter=isWellnessEnabled) BOOL wellnessEnabled;
@property (assign, nonatomic) NSInteger currentGoalAmount;
@property (assign, nonatomic) NSInteger targetGoalAmount;
@property (assign, nonatomic) NSInteger currentGoalQuantity;
@property (assign, nonatomic) NSInteger currentGoalQuantity2;
@property (assign, nonatomic) NSInteger targetGoalQuantity;
@property (assign, nonatomic) NSInteger targetGoalQuantity2;
@property (assign, nonatomic) NSInteger totalMetGoals;
@property (assign, nonatomic) NSInteger maximumMetGoals;

@property (nonatomic, assign, readonly) NSInteger remainingMetGoals;

- (NSComparisonResult)compare:(MLCDeal *)other;

@end

NS_ASSUME_NONNULL_END
