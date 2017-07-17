//
//  MLCAdsService.h
//  MoblicoSDK
//
//  Created by Cameron Knight on 8/11/15.
//  Copyright (c) 2015 Moblico Solutions LLC. All rights reserved.
//

#import <MoblicoSDK/MLCService.h>

typedef NS_ENUM(NSUInteger, MLCAdServiceType) {
    MLCAdServiceTypeBanner,
    MLCAdServiceTypePromo,
    MLCAdServiceTypeSponsor
};

@interface MLCAdsService : MLCService

+ (instancetype)findAdsWithType:(MLCAdServiceType)type context:(NSString *)context handler:(MLCServiceCollectionCompletionHandler)handler;
+ (instancetype)readAdWithType:(MLCAdServiceType)type context:(NSString *)context handler:(MLCServiceResourceCompletionHandler)handler;
+ (instancetype)readBannerAdWithContext:(NSString *)context handler:(MLCServiceResourceCompletionHandler)handler;

@end
