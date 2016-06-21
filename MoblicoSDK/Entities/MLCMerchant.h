//
//  MLCMerchant.h
//  MoblicoSDK
//
//  Created by Cameron Knight on 7/27/15.
//  Copyright © 2015 Moblico Solutions LLC. All rights reserved.
//

#import <MoblicoSDK/MoblicoSDK.h>
@import CoreLocation;

@interface MLCMerchant : MLCEntity

@property (nonatomic) NSUInteger merchantId;
@property (copy, nonatomic) NSString *externalId;
@property (nonatomic)  NSUInteger ownerUserId;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *redemptionType;
@property (copy, nonatomic) NSString *status;
@property (strong, nonatomic) NSDate *lastUpdateDate;
@property (nonatomic) BOOL beaconRegionEnabled;
@property (copy, nonatomic) NSString *beaconIdentifier;
@property (copy, nonatomic) NSString *beaconEnterNotificationText;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (copy, nonatomic) NSDictionary *attributes;

@end
