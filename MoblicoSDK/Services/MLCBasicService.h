//
//  MLCBasicService.h
//  MoblicoSDK
//
//  Created by Cameron Knight on 3/12/13.
//  Copyright (c) 2013 Moblico Solutions LLC. All rights reserved.
//

#import <MoblicoSDK/MoblicoSDK.h>

@interface MLCBasicService : MLCService

+ (id)create:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceStatusCompletionHandler)handler;
+ (id)update:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceStatusCompletionHandler)handler;
+ (id)destroy:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceStatusCompletionHandler)handler;
+ (id)read:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceResourceCompletionHandler)handler;

+ (id)find:(NSString *)path searchParameters:(NSDictionary *)searchParameters handler:(MLCServiceCollectionCompletionHandler)handler;
+ (Class<MLCEntityProtocol>)classForResource;

@end
