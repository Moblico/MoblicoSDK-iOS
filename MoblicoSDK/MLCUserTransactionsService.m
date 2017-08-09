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

#import "MLCUserTransactionsService.h"
#import "MLCService_Private.h"
#import "MLCUserTransaction.h"
#import "MLCUser.h"

@implementation MLCUserTransactionsService

+ (Class<MLCEntityProtocol>)classForResource {
    return [MLCUserTransaction class];
}

+ (NSArray *)scopeableResources {
    return @[@"MLCUser"];
}

+ (instancetype)findTransactionsForUser:(MLCUser *)user before:(NSUInteger)userTransactionId count:(NSInteger)count handler:(MLCServiceCollectionCompletionHandler)handler {
    NSDictionary *searchParameters = nil;

    if (count && userTransactionId) {
		searchParameters = @{@"count": @(count), @"before": @(userTransactionId)};
	} else if (count) {
		searchParameters = @{@"count": @(count)};
	} else if (userTransactionId) {
		searchParameters = @{@"before": @(userTransactionId)};
	}

    return [self findScopedResourcesForResource:user searchParameters:searchParameters handler:handler];
}

@end
