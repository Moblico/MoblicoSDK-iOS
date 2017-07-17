//
//  MLCProductCategoriesService.h
//  MoblicoSDK
//
//  Created by Cameron Knight on 7/1/14.
//  Copyright (c) 2014 Moblico Solutions LLC. All rights reserved.
//

#import <MoblicoSDK/MoblicoSDK.h>

@interface MLCProductCategoriesService : MLCService

+ (instancetype)listProductCategories:(MLCServiceCollectionCompletionHandler)handler;

@end
