/*
 Copyright 2012 Moblico Solutions LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this work except in compliance with the License.
 You may obtain a copy of the License in the LICENSE file, or at:

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

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
        _type = [[self class] userTransactionTypeFromString:jsonObject[@"type"]];
    }

    return self;
}

+ (NSDictionary *)serialize:(MLCEntity *)entity {
    NSMutableDictionary *dictionary = [[super serialize:entity] mutableCopy];
    if ([entity isKindOfClass:[MLCUserTransaction class]]) {
        MLCUserTransaction *transaction = (MLCUserTransaction *)entity;
        dictionary[@"type"] = [self stringForUserTransactionType:transaction.type];
    }
    return dictionary;
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
            break;
    }

    return MLCUserTransactionTypeUnknownString;
}

@end
