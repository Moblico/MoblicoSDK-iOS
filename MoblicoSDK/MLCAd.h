//
//  MLCAd.h
//  MoblicoSDK
//
//  Created by Cameron Knight on 8/11/15.
//  Copyright (c) 2015 Moblico Solutions LLC. All rights reserved.
//

#import <MoblicoSDK/MLCEntity.h>

@class MLCImage;

@interface MLCAd : MLCEntity
@property (nonatomic) NSUInteger adId;
@property (strong, nonatomic) NSDate *createDate;
@property (strong, nonatomic) NSDate *lastUpdateDate;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *advertiserName;
@property (strong, nonatomic) NSURL *clickToCall;
@property (strong, nonatomic) NSURL *clickToUrl;
@property (strong, nonatomic) MLCImage *image;
@end
