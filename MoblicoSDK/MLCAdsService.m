//
//  MLCAdsService.m
//  MoblicoSDK
//
//  Created by Cameron Knight on 8/11/15.
//  Copyright (c) 2015 Moblico Solutions LLC. All rights reserved.
//

#import "MLCAdsService.h"
#import "MLCService_Private.h"
#import "MLCAd.h"

@implementation MLCAdsService

+ (Class<MLCEntityProtocol>)classForResource {
    return [MLCAd class];
}

+ (NSString *)stringFromAdType:(MLCAdServiceType)type {
    if (type == MLCAdServiceTypeBanner) {
        return @"AD_BANNER";
    }

    if (type == MLCAdServiceTypePromo) {
        return @"AD_PROMO";
    }

    if (type == MLCAdServiceTypeSponsor) {
        return @"AD_SPONSOR";
    }

    return nil;
}

+ (instancetype)findAdsWithType:(MLCAdServiceType)type context:(NSString *)context handler:(MLCServiceCollectionCompletionHandler)handler {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:2];
    NSString *adTypeName = [self stringFromAdType:type];
    if (adTypeName) {
        parameters[@"type"] = adTypeName;
    }
    if (context) {
        parameters[@"context"] = context;
    }

    return [self find:@"promos" searchParameters:parameters handler:handler];
}

+ (instancetype)readAdWithType:(MLCAdServiceType)type context:(NSString *)context handler:(MLCServiceResourceCompletionHandler)handler {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:2];
    NSString *adTypeName = [self stringFromAdType:type];
    if (adTypeName) {
        parameters[@"type"] = adTypeName;
    }
    if (context) {
        parameters[@"context"] = context;
    }
    return [self read:@"ad" parameters:parameters handler:handler];
}

+ (instancetype)readBannerAdWithContext:(NSString *)context handler:(MLCServiceResourceCompletionHandler)handler {
    return [self readAdWithType:MLCAdServiceTypeBanner context:context handler:handler];
}

@end
