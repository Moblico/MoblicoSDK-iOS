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
#import "MLCEntity_Private.h"
#import "MLCImage.h"

@implementation MLCDeal

+ (NSArray *)ignoredPropertiesDuringSerialization {
    return @[@"lastUpdateDate"];
}

- (instancetype)initWithJSONObject:(NSDictionary *)jsonObject {
    self = [super initWithJSONObject:jsonObject];

    if ([self.image isKindOfClass:[NSDictionary class]]) {
        NSDictionary *image = (NSDictionary *)self.image;

        if (image.count) {
            self.image = [[MLCImage alloc] initWithJSONObject:image];
        } else {
            self.image = nil;
        }
    }

    return self;
}

+ (NSDictionary *)serialize:(MLCDeal *)deal {
    NSMutableDictionary *serializedObject = [[super serialize:deal] mutableCopy];
    
    if (deal.image) {
        serializedObject[@"image"] = [[deal.image class] serialize:deal.image];
    }
    
    return [serializedObject mutableCopy];
}

- (NSComparisonResult)compare:(MLCDeal *)other {
    NSComparisonResult results = [self.endDate compare:other.endDate];
    if (results != NSOrderedSame) {
        return results;
    }
    
    results = [self.name localizedStandardCompare:other.name];

    if (results != NSOrderedSame) {
        return results;
    }

    return [@(self.dealId) compare:@(other.dealId)];
}

- (NSInteger)remainingMetGoals {
    if (self.maximumMetGoals < 1) {
        return -1;
    }

    return self.maximumMetGoals - self.totalMetGoals;
}

@end
