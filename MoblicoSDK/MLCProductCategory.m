//
//  MLCProductCategory.m
//  MoblicoSDK
//
//  Created by Cameron Knight on 7/1/14.
//  Copyright (c) 2014 Moblico Solutions LLC. All rights reserved.
//

#import "MLCProductCategory.h"

@implementation MLCProductCategory

+ (NSString *)collectionName {
    return @"product_categories";
}

- (instancetype)initWithJSONObject:(NSDictionary *)jsonObject {
    self = [super initWithJSONObject:jsonObject];

    if ([self.productTypes isKindOfClass:[NSArray class]]) {
        NSMutableArray *productTypes = [NSMutableArray arrayWithCapacity:self.productTypes.count];

        for (id object in self.productTypes) {
            MLCProductType *productType = [[MLCProductType alloc] initWithJSONObject:object];
            if (productType) {
                [productTypes addObject:productType];
            }
        }

        self.productTypes = productTypes;
    }

    return self;
}

@end
