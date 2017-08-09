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
