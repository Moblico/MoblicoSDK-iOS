//
//  MLCMerchantsService.h
//  MoblicoSDK
//
//  Created by Cameron Knight on 7/27/15.
//  Copyright © 2015 Moblico Solutions LLC. All rights reserved.
//

#import <MoblicoSDK/MoblicoSDK.h>

@interface MLCMerchantsService : MLCService

+ (instancetype)readMerchantWithMerchantId:(NSUInteger)merchantId handler:(MLCServiceResourceCompletionHandler)handler;

+ (instancetype)findMerchantsWithBeaconRegionEnabled:(BOOL)beaconRegionEnabled handler:(MLCServiceCollectionCompletionHandler)handler;

+ (instancetype)listMerchants:(MLCServiceCollectionCompletionHandler)handler;

@end
