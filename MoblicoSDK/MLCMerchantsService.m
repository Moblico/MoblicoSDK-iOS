//
//  MLCMerchantsService.m
//  MoblicoSDK
//
//  Created by Cameron Knight on 7/27/15.
//  Copyright © 2015 Moblico Solutions LLC. All rights reserved.
//

#import "MLCMerchantsService.h"
#import "MLCService_Private.h"
#import "MLCMerchant.h"
@implementation MLCMerchantsService

+ (Class<MLCEntityProtocol>)classForResource {
    return [MLCMerchant class];
}

+ (instancetype)readMerchantWithMerchantId:(NSUInteger)merchantId handler:(MLCServiceResourceCompletionHandler)handler {
    return [self readResourceWithUniqueIdentifier:@(merchantId) handler:handler];
}

+ (instancetype)findMerchantsWithBeaconRegionEnabled:(BOOL)beaconRegionEnabled handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self findResourcesWithSearchParameters:@{@"beaconRegionEnabled": @(beaconRegionEnabled)} handler:handler];
}

+ (instancetype)listMerchants:(MLCServiceCollectionCompletionHandler)handler {
    return [self listResources:handler];
}

@end
