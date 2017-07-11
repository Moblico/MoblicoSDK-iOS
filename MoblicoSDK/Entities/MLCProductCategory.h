//
//  MLCProductCategory.h
//  MoblicoSDK
//
//  Created by Cameron Knight on 7/1/14.
//  Copyright (c) 2014 Moblico Solutions LLC. All rights reserved.
//

#import <MoblicoSDK/MoblicoSDK.h>

@class MLCProductType;

@interface MLCProductCategory : MLCEntity

@property (nonatomic) NSUInteger productCategoryId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray<MLCProductType *> *productTypes;

@end
