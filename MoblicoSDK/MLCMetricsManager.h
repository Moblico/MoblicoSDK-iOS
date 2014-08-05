//
//  MLCMetricsManager.h
//  MoblicoSDK
//
//  Created by Cameron Knight on 4/29/14.
//  Copyright (c) 2014 Moblico Solutions LLC. All rights reserved.
//

@import Foundation;
@import CoreLocation;

@protocol MLCMetricsManagerLocationDelegate <NSObject>
@required
- (CLLocation *)location;

@end


@interface MLCMetricsManager : NSObject
@property (nonatomic, weak) id <MLCMetricsManagerLocationDelegate> locationDelegate;

+ (instancetype)sharedMetricsManager;

@end
