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

#import "MLCDeal.h"

/**
 Moblico rewards encompass many of the attributes of coupons,
 promotions and loyalty programs. Rewards can be associated to
 Locations (i.e merchants) and Moblico also provides several
 mechanisms for Reward redemption.
 
 Rewards are loaded and managed using Moblico's admin tool.
 
 A MLCReward object encapsulates the data of a reward stored in the Moblico Admin Portal.
 
 MLCReward is a subclass of MLCDeal and represents a deal with associated affinity.
 */
@interface MLCReward : MLCDeal

/**
 A unique identifier for this reward.
 */
@property (nonatomic) NSUInteger rewardId;

/**
 The amount of points this reward is worth.
 */
@property (nonatomic) NSInteger points;

/**
 The number of times the user has purchased this reward.
 */
@property (nonatomic) NSInteger numberOfPurchases;

/**
 The maximum number of times a user is allowed to purchase this reward.
 */
@property (nonatomic) NSInteger maxPurchases;

/**
 The date this deal will become avaiilable for purchase.
 */
@property (strong, nonatomic) NSDate *startPurchaseDate;

/**
 The date this deal will no longer be avaiilable for purchase.
 */
@property (strong, nonatomic) NSDate *endPurchaseDate;

/**
 Specifies whether this reward will be redeemed automatically.

 Rewards that are not cardRedemptionEnabled must be redeemed using
 the Moblico Redemption Tool or using in app redemption.
 */
@property (nonatomic) BOOL cardRedemptionEnabled;

/**
 The number of redemptions availble for this reward.
 
 The number of availble redemptions is calculated by:
 
    numberOfPurchases * numberOfUsesPerCode - redeemedCount

 */
@property (nonatomic, readonly) NSInteger availableRedemptions;

@end
