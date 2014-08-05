//
//  MLCUserTransactionSummary.h
//  MoblicoSDK
//
//  Created by Cameron Knight on 2/2/14.
//  Copyright (c) 2014 Moblico Solutions LLC. All rights reserved.
//

#import <MoblicoSDK/MLCEntity.h>

@interface MLCUserTransactionsSummary : MLCEntity

@property (nonatomic) double pointsEarned;
@property (nonatomic) NSUInteger pointsEarnedCount;
@property (nonatomic) double pointsSpent;
@property (nonatomic) NSUInteger pointsSpentCount;
@property (nonatomic) double currencySpent;
@property (nonatomic) NSUInteger currencySpentCount;
@property (nonatomic) double currencySaved;
@property (nonatomic) NSUInteger currencySavedCount;

@end
