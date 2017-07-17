//
//  MLCUserTansaction.m
//  MoblicoSDK
//
//  Created by Cameron Knight on 2/2/14.
//  Copyright (c) 2014 Moblico Solutions LLC. All rights reserved.
//

#import "MLCUserTransaction.h"

static NSString *const MLCUserTransactionTypePointsEarnedString = @"POINTS_EARNED";
static NSString *const MLCUserTransactionTypePointsSpentString = @"POINTS_SPENT";
static NSString *const MLCUserTransactionTypeCurrencySavedString = @"CURRENCY_SAVED";
static NSString *const MLCUserTransactionTypeCurrencySpentString = @"CURRENCY_SPENT";
static NSString *const MLCUserTransactionTypeUnknownString = @"UNKNOWN";

@implementation MLCUserTransaction

+ (NSString *)collectionName {
    return @"transactions";
}

- (instancetype)initWithJSONObject:(NSDictionary *)jsonObject {
    self = [super initWithJSONObject:jsonObject];

    if (self) {
        self.type = [[self class] userTransactionTypeFromString:jsonObject[@"type"]];
    }

    return self;
}

+ (MLCUserTransactionType)userTransactionTypeFromString:(NSString *)string {
    if (![string isKindOfClass:[NSString class]]) return MLCUserTransactionTypeUnknown;

    NSString *uppercaseString = string.uppercaseString;
	if ([uppercaseString isEqualToString:MLCUserTransactionTypePointsEarnedString]) return MLCUserTransactionTypePointsEarned;
	if ([uppercaseString isEqualToString:MLCUserTransactionTypePointsSpentString]) return MLCUserTransactionTypePointsSpent;
	if ([uppercaseString isEqualToString:MLCUserTransactionTypeCurrencySavedString]) return MLCUserTransactionTypeCurrencySaved;
	if ([uppercaseString isEqualToString:MLCUserTransactionTypeCurrencySpentString]) return MLCUserTransactionTypeCurrencySpent;

	return MLCUserTransactionTypeUnknown;
}

+ (NSString *)stringForUserTransactionType:(MLCUserTransactionType)type {
	switch (type) {
		case MLCUserTransactionTypePointsEarned:
			return MLCUserTransactionTypePointsEarnedString;

		case MLCUserTransactionTypeCurrencySaved:
			return MLCUserTransactionTypeCurrencySavedString;

		case MLCUserTransactionTypeCurrencySpent:
			return MLCUserTransactionTypeCurrencySpentString;

		case MLCUserTransactionTypePointsSpent:
			return MLCUserTransactionTypePointsSpentString;

        case MLCUserTransactionTypeUnknown:
            ;
	}
    
	return MLCUserTransactionTypeUnknownString;
}

@end
