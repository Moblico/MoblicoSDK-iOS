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


+ (instancetype)findProductsWithProductTypes:(NSArray *)productTypes handler:(MLCServiceCollectionCompletionHandler)handler {

    if ([productTypes count]) {
        return [self findResourcesWithSearchParameters:@{@"productTypes": productTypes} handler:handler];
    }

    return [self listResources:handler];
}

@end
