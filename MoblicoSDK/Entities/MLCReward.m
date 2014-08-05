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

#import "MLCReward.h"
#import "MLCEntity_Private.h"

@implementation MLCReward

+ (NSArray *)ignoredPropertiesDuringSerialization {
    NSArray *parrentArray = [super ignoredPropertiesDuringSerialization];

    return [@[@"dealId"] arrayByAddingObjectsFromArray:parrentArray];
}

- (void)setDealId:(NSUInteger)dealId {
    self.rewardId = dealId;
}

- (NSUInteger)dealId {
    return self.rewardId;
}

- (NSInteger)availableRedemptions {
	if (self.numberOfPurchases <= 0) return 0;
	if (self.numberOfUsesPerCode == 0) return NSIntegerMax;

    return (self.numberOfPurchases * self.numberOfUsesPerCode) - self.redeemedCount;
}

@end