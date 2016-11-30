//
//  MLCProduct.m
//  MoblicoSDK
//
//  Created by Cameron Knight on 7/1/14.
//  Copyright (c) 2014 Moblico Solutions LLC. All rights reserved.
//

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
