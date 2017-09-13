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

MLCUserTransactionType const MLCUserTransactionTypePointsEarned = @"POINTS_EARNED";
MLCUserTransactionType const MLCUserTransactionTypePointsSpent = @"POINTS_SPENT";
MLCUserTransactionType const MLCUserTransactionTypeCurrencySaved = @"CURRENCY_SAVED";
MLCUserTransactionType const MLCUserTransactionTypeCurrencySpent = @"CURRENCY_SPENT";
MLCUserTransactionType const MLCUserTransactionTypeUnknown = @"UNKNOWN";

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

+ (MLCUserTransactionType)userTransactionTypeFromString:(NSString *)string {
    if (![string isKindOfClass:[NSString class]]) return MLCUserTransactionTypeUnknown;

    NSString *uppercaseString = string.uppercaseString;
    if ([uppercaseString isEqualToString:MLCUserTransactionTypePointsEarned]) return MLCUserTransactionTypePointsEarned;
    if ([uppercaseString isEqualToString:MLCUserTransactionTypePointsSpent]) return MLCUserTransactionTypePointsSpent;
    if ([uppercaseString isEqualToString:MLCUserTransactionTypeCurrencySaved]) return MLCUserTransactionTypeCurrencySaved;
    if ([uppercaseString isEqualToString:MLCUserTransactionTypeCurrencySpent]) return MLCUserTransactionTypeCurrencySpent;

    return MLCUserTransactionTypeUnknown;
}

@end
