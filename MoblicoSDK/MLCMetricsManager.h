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
@property (nonatomic, readonly, copy, nullable) CLLocation *location;

@end

@interface MLCMetricsManager : NSObject

@property (nonatomic, class, strong, readonly, nonnull) MLCMetricsManager *sharedMetricsManager;
@property (nonatomic, weak, nullable) id <MLCMetricsManagerLocationDelegate> locationDelegate;

@end
