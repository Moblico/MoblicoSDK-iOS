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

#import <MoblicoSDK/MLCEntity.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *MLCUserTransactionType NS_TYPED_ENUM NS_SWIFT_NAME(UserTransactionType);
FOUNDATION_EXPORT MLCUserTransactionType const MLCUserTransactionTypeUnknown;
FOUNDATION_EXPORT MLCUserTransactionType const MLCUserTransactionTypePointsEarned;
FOUNDATION_EXPORT MLCUserTransactionType const MLCUserTransactionTypePointsSpent;
FOUNDATION_EXPORT MLCUserTransactionType const MLCUserTransactionTypeCurrencySaved;
FOUNDATION_EXPORT MLCUserTransactionType const MLCUserTransactionTypeCurrencySpent;

NS_SWIFT_NAME(UserTransaction)
@interface MLCUserTransaction : MLCEntity

@property (nonatomic) NSUInteger userTransactionId NS_SWIFT_NAME(id);
@property (nonatomic) double amount;
@property (nonatomic, copy) MLCUserTransactionType type;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic, nullable) NSString *details;
@property (strong, nonatomic) NSDate *createDate;

@end

NS_ASSUME_NONNULL_END
