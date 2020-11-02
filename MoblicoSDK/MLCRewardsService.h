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

#import "MLCService.h"

NS_ASSUME_NONNULL_BEGIN

@class MLCReward;
@class MLCUser;
@class MLCLocation;

MLCServiceCreateResourceCompletionHandler(MLCRewardsService, MLCReward);
MLCServiceCreateCollectionCompletionHandler(MLCRewardsService, MLCReward);

NS_SWIFT_NAME(RewardsService)
@interface MLCRewardsService : MLCService

+ (instancetype)readRewardWithRewardId:(NSUInteger)rewardId handler:(MLCRewardsServiceResourceCompletionHandler)handler NS_SWIFT_NAME(readReward(withId:handler:));

+ (instancetype)listRewards:(MLCRewardsServiceCollectionCompletionHandler)handler;

+ (instancetype)listRewardsForUser:(MLCUser *)user handler:(MLCRewardsServiceCollectionCompletionHandler)handler;

+ (instancetype)listRewardsForLocation:(MLCLocation *)location handler:(MLCRewardsServiceCollectionCompletionHandler)handler;

+ (instancetype)redeemReward:(MLCReward *)reward handler:(MLCServiceSuccessCompletionHandler)handler NS_SWIFT_NAME(redeem(_:handler:));

+ (instancetype)redeemReward:(MLCReward *)reward autoPurchase:(BOOL)autoPurchase handler:(MLCServiceSuccessCompletionHandler)handler NS_SWIFT_NAME(redeem(_:autoPurchase:handler:));

+ (instancetype)purchaseReward:(MLCReward *)reward handler:(MLCServiceSuccessCompletionHandler)handler NS_SWIFT_NAME(purchase(_:handler:));

@end

NS_ASSUME_NONNULL_END
