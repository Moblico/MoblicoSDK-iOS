//
//  MLCCredentialsService.m
//  MoblicoSDK
//
//  Created by Cameron Knight on 4/14/16.
//  Copyright © 2016 Moblico Solutions LLC. All rights reserved.
//

#import "MLCService_Private.h"
#import "MLCCredentialsService.h"
#import "MLCCredential.h"

@implementation MLCCredentialsService

+ (Class<MLCEntityProtocol>)classForResource {
    return [MLCCredential class];
}

+ (instancetype)listCredentials:(MLCServiceCollectionCompletionHandler)handler {
    return [self listResources:handler];
}

@end
