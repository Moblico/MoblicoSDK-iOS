//
//  MLCProductCategoriesService.m
//  MoblicoSDK
//
//  Created by Cameron Knight on 7/1/14.
//  Copyright (c) 2014 Moblico Solutions LLC. All rights reserved.
//

#import "MLCProductCategoriesService.h"
#import "MLCService_Private.h"
#import "MLCProductCategory.h"

@implementation MLCProductCategoriesService

+ (Class<MLCEntityProtocol>)classForResource {
    return [MLCProductCategory class];
}

+ (instancetype)listProductCategories:(MLCServiceCollectionCompletionHandler)handler {
    return [self listResources:handler];
}

@end
