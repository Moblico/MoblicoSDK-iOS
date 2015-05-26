//
//  MLCProductsService.h
//  MoblicoSDK
//
//  Created by Cameron Knight on 7/1/14.
//  Copyright (c) 2014 Moblico Solutions LLC. All rights reserved.
//

#import <MoblicoSDK/MoblicoSDK.h>

@interface MLCProductsService : MLCService

+ (instancetype)findProductsWithFilters:(NSString *)filters handler:(MLCServiceCollectionCompletionHandler)handler;
+ (instancetype)findProductsWithProductTypes:(NSArray *)productTypes handler:(MLCServiceCollectionCompletionHandler)handler;

+ (instancetype)findProductsWithFilters:(NSString *)filters productTypes:(NSArray *)productTypes handler:(MLCServiceCollectionCompletionHandler)handler;

@end
