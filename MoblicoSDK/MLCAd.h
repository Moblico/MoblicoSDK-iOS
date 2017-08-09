//
//  MLCAd.h
//  MoblicoSDK
//
//  Created by Cameron Knight on 8/11/15.
//  Copyright (c) 2015 Moblico Solutions LLC. All rights reserved.
//

#import <MoblicoSDK/MLCEntity.h>

@class MLCImage;

/// A MLCAd object encapsulates the data for an ad stored in the Moblico Marketing Portal.
@interface MLCAd : MLCEntity
/// Unique identifier for this ad.
@property (nonatomic) NSUInteger adId;
/// Date this ad was created.
@property (strong, nonatomic) NSDate *createDate;
/// Date this ad was last modified.
@property (strong, nonatomic) NSDate *lastUpdateDate;
/// Name of the ad.
@property (strong, nonatomic) NSString *name;
/// Name of the advertiser.
@property (strong, nonatomic) NSString *advertiserName;
/// URL of type `tel:`.
@property (strong, nonatomic) NSURL *clickToCall;
/// URL of type `http:|https:`.
@property (strong, nonatomic) NSURL *clickToUrl;
/// Image of the ad.
@property (strong, nonatomic) MLCImage *image;
@end
