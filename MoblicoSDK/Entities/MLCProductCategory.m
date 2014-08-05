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

+ (instancetype)deserialize:(NSDictionary *)jsonObject {

    MLCProductCategory *productCategory = [super deserialize:jsonObject];

    if (![productCategory.productTypes isKindOfClass:[NSArray class]]) return productCategory;

    NSMutableArray *productTypes = [NSMutableArray arrayWithCapacity:productCategory.productTypes.count];

    for (id object in productCategory.productTypes) {
        MLCProductType *productType = [MLCProductType deserialize:object];
        if (productType) {
            [productTypes addObject:productType];
        }
    }

    productCategory.productTypes = productTypes;

    return productCategory;
}

@end
