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

#import "MLCRewardsService.h"
#import "MLCReward.h"
#import "MLCService_Private.h"
#import "MLCUser.h"
#import "MLCLocation.h"

@implementation MLCRewardsService

+ (NSArray<Class> *)scopeableResources {
    return @[[MLCUser class], [MLCLocation class]];
}

+ (Class)classForResource {
    return [MLCReward class];
}

+ (instancetype)readRewardWithRewardId:(NSUInteger)rewardId handler:(MLCRewardsServiceResourceCompletionHandler)handler {
    return [self readResourceWithUniqueIdentifier:@(rewardId) handler:handler];
}

+ (instancetype)listRewards:(MLCRewardsServiceCollectionCompletionHandler)handler {
    return [self findResourcesWithSearchParameters:@{} handler:handler];
}

+ (instancetype)listRewardsForUser:(MLCUser *)user handler:(MLCRewardsServiceCollectionCompletionHandler)handler {
    return [self listRewardsForResource:user handler:handler];
}

+ (instancetype)listRewardsForLocation:(MLCLocation *)location handler:(MLCRewardsServiceCollectionCompletionHandler)handler {
    return [self listRewardsForResource:location handler:handler];
}

+ (instancetype)listRewardsForResource:(MLCEntity *)resource handler:(MLCRewardsServiceCollectionCompletionHandler)handler {
    return [self findScopedResourcesForResource:resource searchParameters:@{} handler:handler];
}

+ (instancetype)redeemReward:(MLCReward *)reward handler:(MLCServiceSuccessCompletionHandler)handler {
    return [self redeemReward:reward autoPurchase:NO handler:handler];
}

+ (instancetype)redeemReward:(MLCReward *)reward autoPurchase:(BOOL)autoPurchase handler:(MLCServiceSuccessCompletionHandler)handler {
    NSString *path = [NSString pathWithComponents:@[[[reward class] collectionName], reward.uniqueIdentifier, @"redeem"]];

    NSDictionary *parameters = @{@"offerCode": reward.offerCode, @"autoPurchase": autoPurchase ? @"true" : @"false"};

    return [self _update:path parameters:parameters handler:handler];
}

+ (instancetype)purchaseReward:(MLCReward *)reward handler:(MLCServiceSuccessCompletionHandler)handler {
    NSString *path = [NSString pathWithComponents:@[[[reward class] collectionName], reward.uniqueIdentifier, @"purchase"]];

    return [self _update:path parameters:nil handler:handler];
}

@end
