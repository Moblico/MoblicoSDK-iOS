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
    NSComparisonResult titleOrder = [self.title localizedStandardCompare:product.title];
    NSComparisonResult revDateOrder = [self.revDate compare:product.revDate];

    if (order == MLCProductCompareOrderRevDate) {
        return revDateOrder ?: titleOrder;
    }

    return titleOrder ?: revDateOrder;
}

- (NSComparisonResult)compare:(MLCProduct *)location {
    return [self compare:location order:MLCProductCompareOrderTitle];
}


@end
