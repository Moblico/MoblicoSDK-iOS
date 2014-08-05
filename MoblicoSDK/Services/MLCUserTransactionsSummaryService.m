//
//  MLCUserTransactionsSummaryService.m
//  MoblicoSDK
//
//  Created by Cameron Knight on 2/3/14.
//  Copyright (c) 2014 Moblico Solutions LLC. All rights reserved.
//

#import "MLCService_Private.h"
#import "MLCUserTransactionsSummaryService.h"
#import "MLCUserTransactionsSummary.h"
#import "MLCUser.h"

@implementation MLCUserTransactionsSummaryService

+ (Class<MLCEntity>)classForResource {
    return [MLCUserTransactionsSummary class];
}

+ (instancetype)readTransactionsSummaryForUser:(MLCUser *)user handler:(MLCServiceResourceCompletionHandler)handler {
    NSString *path = [NSString pathWithComponents:@[
                                                    [MLCUser collectionName],
                                                    [user uniqueIdentifier],
                                                    [[self classForResource] collectionName]
                                                    ]];

    return [self read:path parameters:nil handler:handler];
}

@end
