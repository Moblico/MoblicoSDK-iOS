//
//  MLCMetricsManager.m
//  MoblicoSDK
//
//  Created by Cameron Knight on 4/29/14.
//  Copyright (c) 2014 Moblico Solutions LLC. All rights reserved.
//

#import "MLCMetricsManager.h"

@implementation MLCMetricsManager

+ (instancetype)sharedMetricsManager {
	static dispatch_once_t onceToken;
	static MLCMetricsManager *sharedLocationManager;
	dispatch_once(&onceToken, ^{
		sharedLocationManager = [[self alloc] init];
	});

	return sharedLocationManager;
}


@end
