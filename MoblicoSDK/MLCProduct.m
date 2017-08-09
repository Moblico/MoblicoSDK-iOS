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

#import "MLCProduct.h"

@implementation MLCProduct

- (NSComparisonResult)compare:(MLCProduct *)product order:(MLCProductCompareOrder)order {

    NSComparisonResult titleOrder = [self compare:product
                                              key:@"title"
                                         selector:@selector(localizedStandardCompare:)];

    NSComparisonResult revDateOrder = [self compare:product
                                                key:@"revDate"
                                           selector:@selector(compare:)];

    if (order == MLCProductCompareOrderRevDate) {
        return revDateOrder ?: titleOrder;
    }

    return titleOrder ?: revDateOrder;
}

- (NSComparisonResult)compare:(MLCProduct *)product {
    return [self compare:product order:MLCProductCompareOrderTitle];
}

- (NSComparisonResult)compare:(MLCProduct *)product key:(NSString *)key selector:(SEL)comparator {
    id first = [self valueForKey:key];
    id second = [product valueForKey:key];

    if (!first && !second) {
        return NSOrderedSame;
    }

    if (!first) {
        return NSOrderedDescending;
    }

    if (!second) {
        return NSOrderedAscending;
    }

    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:first
                                                                            selector:comparator
                                                                              object:second];
    [operation start];
    NSComparisonResult value;
    [operation.result getValue:&value];
    return value;
}

@end
