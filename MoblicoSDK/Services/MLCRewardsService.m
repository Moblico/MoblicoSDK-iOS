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

@implementation MLCRewardsService

+ (NSArray *)scopeableResources {
    return @[@"MLCUser", @"MLCLocation"];
}

+ (Class<MLCEntityProtocol>)classForResource {
    return [MLCReward class];
}

+ (id)readRewardWithRewardId:(NSUInteger)rewardId handler:(MLCServiceResourceCompletionHandler)handler {
    return [self readResourceWithUniqueIdentifier:@(rewardId) handler:handler];
}

+ (id)listRewards:(MLCServiceCollectionCompletionHandler)handler {
    return [self listResources:handler];
}

+ (id)listRewardsForUser:(MLCUser *)user handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self listRewardsForResource:(id<MLCEntityProtocol>)user handler:handler];
}

+ (id)listRewardsForLocation:(MLCLocation *)location handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self listRewardsForResource:(id<MLCEntityProtocol>)location handler:handler];
}

+ (id)listRewardsForResource:(id <MLCEntityProtocol>)resource handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self listScopedResourcesForResource:resource handler:handler];
}

+ (id)redeemReward:(MLCReward *)reward withOfferCode:(NSString *)offerCode handler:(MLCServiceStatusCompletionHandler)handler {
    NSString *resource = [NSString pathWithComponents:@[[reward collectionName], [reward uniqueIdentifier], @"redeem"]];
    return [self update:resource parameters:@{@"offerCode": offerCode} handler:handler];
}

+ (id)purchaseReward:(MLCReward *)reward handler:(MLCServiceStatusCompletionHandler)handler {
    NSString *resource = [NSString pathWithComponents:@[[reward collectionName], [reward uniqueIdentifier], @"purchase"]];
    return [self update:resource parameters:nil handler:handler];
}

@end
