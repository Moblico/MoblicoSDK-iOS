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
    NSArray *parentArray = [super ignoredPropertiesDuringSerialization];

    return [@[@"dealId", @"availableRedemptions", @"redeemable", @"isRedeemable"] arrayByAddingObjectsFromArray:parentArray];
}

- (void)setDealId:(NSUInteger)dealId {
    self.rewardId = dealId;
}

- (NSUInteger)dealId {
    return self.rewardId;
}

- (BOOL)isRedeemable {
    return self.availableRedemptions != 0;
}

- (NSInteger)availableRedemptions {
	if (self.numberOfPurchases <= 0) return 0;
	if (self.numberOfUsesPerCode <= 0) return NSIntegerMax;

    return (self.numberOfPurchases * self.numberOfUsesPerCode) - self.redeemedCount;
}

- (NSComparisonResult)compare:(MLCReward *)other {
    BOOL thisIsRedeemable = self.isRedeemable;

    NSComparisonResult result = [@(other.isRedeemable) compare:@(thisIsRedeemable)];

    if (result != NSOrderedSame) {
        return result;
    }

    if (!thisIsRedeemable) {
        result = [@(self.points) compare:@(other.points)];
    }

    if (result != NSOrderedSame) {
        return result;
    }

    return [super compare:other];

//    if (result == NSOrderedSame) {
//        result = [@(reward1.points) compare:@(reward2.points)];
//        if (result == NSOrderedSame || reward1.availableRedemptions) {
//            NSStringCompareOptions options = NSCaseInsensitiveSearch | NSNumericSearch | NSDiacriticInsensitiveSearch | NSWidthInsensitiveSearch | NSForcedOrderingSearch;
//            result = [reward1.name compare:reward2.name options:options];
//        }
//    }
//
//    return result;
//
//
//    NSComparisonResult results = [@(other.availableRedemptions) compare:@(self.availableRedemptions)];
//    if (results != NSOrderedSame) {
//        return results;
//    }
//
//    return [super compare:other];
}

@end
