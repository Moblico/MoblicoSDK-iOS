//
//  MLCUserTransactionsService.m
//  MoblicoSDK
//
//  Created by Cameron Knight on 2/2/14.
//  Copyright (c) 2014 Moblico Solutions LLC. All rights reserved.
//

#import "MLCUserTransactionsService.h"
#import "MLCService_Private.h"
#import "MLCUserTransaction.h"
#import "MLCUser.h"

@implementation MLCUserTransactionsService

+ (Class<MLCEntity>)classForResource {
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
