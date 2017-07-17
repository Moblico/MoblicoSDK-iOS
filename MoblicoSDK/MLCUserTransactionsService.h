//
//  MLCUserTransactionsService.h
//  MoblicoSDK
//
//  Created by Cameron Knight on 2/2/14.
//  Copyright (c) 2014 Moblico Solutions LLC. All rights reserved.
//

#import <MoblicoSDK/MLCService.h>
@class MLCUser;

@interface MLCUserTransactionsService : MLCService

+ (instancetype)findTransactionsForUser:(MLCUser *)user before:(NSUInteger)userTransactionId count:(NSInteger)count handler:(MLCServiceCollectionCompletionHandler)handler;

@end
