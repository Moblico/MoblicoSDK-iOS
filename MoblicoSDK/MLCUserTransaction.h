//
//  MLCUserTansaction.h
//  MoblicoSDK
//
//  Created by Cameron Knight on 2/2/14.
//  Copyright (c) 2014 Moblico Solutions LLC. All rights reserved.
//

#import <MoblicoSDK/MLCEntity.h>

typedef NS_ENUM(NSInteger, MLCUserTransactionType) {
	MLCUserTransactionTypeUnknown = -1,
	MLCUserTransactionTypePointsEarned,
	MLCUserTransactionTypePointsSpent,
	MLCUserTransactionTypeCurrencySaved,
	MLCUserTransactionTypeCurrencySpent
};

@interface MLCUserTransaction : MLCEntity

@property (nonatomic) NSUInteger userTransactionId;
@property (nonatomic) double amount;
@property (nonatomic) MLCUserTransactionType type;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *details;
@property (nonatomic, strong) NSDate *createDate;

@end
