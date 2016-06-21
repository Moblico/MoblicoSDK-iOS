//
//  MLCCredentialsService.h
//  MoblicoSDK
//
//  Created by Cameron Knight on 4/14/16.
//  Copyright © 2016 Moblico Solutions LLC. All rights reserved.
//

#import <MoblicoSDK/MLCService.h>

@interface MLCCredentialsService : MLCService

+ (instancetype)listCredentials:(MLCServiceCollectionCompletionHandler)handler;

@end
