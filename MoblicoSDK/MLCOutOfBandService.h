//
//  MLCOutOfBandService.h
//  MoblicoSDK
//
//  Created by Cameron Knight on 2/17/14.
//  Copyright (c) 2014 Moblico Solutions LLC. All rights reserved.
//

#import <MoblicoSDK/MoblicoSDK.h>

@interface MLCOutOfBandService : MLCService

+ (instancetype)outOfBandServiceWithEndPoint:(NSString *)endPoint parameters:(NSDictionary *)parameters handler:(MLCServiceJSONCompletionHandler)handler;

@end
