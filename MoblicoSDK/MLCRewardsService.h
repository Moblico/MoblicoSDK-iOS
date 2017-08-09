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
@class MLCReward;
@class MLCUser;
@class MLCLocation;

@interface MLCRewardsService : MLCService

+ (instancetype)readRewardWithRewardId:(NSUInteger)rewardId handler:(MLCServiceResourceCompletionHandler)handler;
+ (instancetype)listRewards:(MLCServiceCollectionCompletionHandler)handler;
+ (instancetype)listRewardsForUser:(MLCUser *)user handler:(MLCServiceCollectionCompletionHandler)handler;
+ (instancetype)listRewardsForLocation:(MLCLocation *)location handler:(MLCServiceCollectionCompletionHandler)handler;
+ (instancetype)listRewardsForResource:(id<MLCEntityProtocol>)resource handler:(MLCServiceCollectionCompletionHandler)handler;
+ (instancetype)redeemReward:(MLCReward *)reward handler:(MLCServiceSuccessCompletionHandler)handler;;
+ (instancetype)redeemReward:(MLCReward *)reward autoPurchase:(BOOL)autoPurchase handler:(MLCServiceSuccessCompletionHandler)handler;
+ (instancetype)purchaseReward:(MLCReward *)reward handler:(MLCServiceSuccessCompletionHandler)handler;
@end
