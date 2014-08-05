//
//  MLCUserTransactionsSummaryService.h
//  MoblicoSDK
//
//  Created by Cameron Knight on 2/3/14.
//  Copyright (c) 2014 Moblico Solutions LLC. All rights reserved.
//

#import <MoblicoSDK/MLCService.h>
@class MLCUser;

@interface MLCUserTransactionsSummaryService : MLCService

+ (instancetype)readTransactionsSummaryForUser:(MLCUser *)user handler:(MLCServiceResourceCompletionHandler)handler;

@end
