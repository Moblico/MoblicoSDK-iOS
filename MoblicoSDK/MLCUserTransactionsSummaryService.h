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

#import "MLCService.h"

NS_ASSUME_NONNULL_BEGIN

@class MLCUser;
@class MLCUserTransactionsSummary;

MLCServiceCreateResourceCompletionHandler(MLCUserTransactionsSummaryService, MLCUserTransactionsSummary);

NS_SWIFT_NAME(UserTransactionsSummaryService)
@interface MLCUserTransactionsSummaryService : MLCService

+ (instancetype)readUserTransactionsSummaryForUser:(MLCUser *)user handler:(MLCUserTransactionsSummaryServiceResourceCompletionHandler)handler;

@end

NS_ASSUME_NONNULL_END
