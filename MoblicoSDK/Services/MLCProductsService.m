//
//  MLCProductsService.m
//  MoblicoSDK
//
//  Created by Cameron Knight on 7/1/14.
//  Copyright (c) 2014 Moblico Solutions LLC. All rights reserved.
//

#import "MLCProductsService.h"
#import "MLCProduct.h"
#import "MLCService_Private.h"

@implementation MLCProductsService

+ (Class<MLCEntity>)classForResource {
    return [MLCProduct class];
}

+ (instancetype)findProductsWithFilters:(NSString *)filters handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self findProductsWithFilters:filters productTypes:nil handler:handler];
}

+ (instancetype)findProductsWithProductTypes:(NSArray *)productTypes handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self findProductsWithFilters:nil productTypes:productTypes handler:handler];
}

+ (instancetype)findProductsWithFilters:(NSString *)filters productTypes:(NSArray *)productTypes handler:(MLCServiceCollectionCompletionHandler)handler {
    NSMutableDictionary *parameters = [@{} mutableCopy];

    if (productTypes.count) {
        parameters[@"productTypes"] = productTypes;
    }

    if (filters.length) {
        parameters[@"filters"] = filters;
    }

    if (parameters.count) {
        return [self findResourcesWithSearchParameters:parameters handler:handler];
    }

    return [self listResources:handler];
}


@end
