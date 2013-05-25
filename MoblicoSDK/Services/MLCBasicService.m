//
//  MLCBasicService.m
//  MoblicoSDK
//
//  Created by Cameron Knight on 3/12/13.
//  Copyright (c) 2013 Moblico Solutions LLC. All rights reserved.
//

#import "MLCBasicService.h"
#import "MLCService_Private.h"
@implementation MLCBasicService

+ (id)create:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceStatusCompletionHandler)handler {
    return [super create:path parameters:parameters handler:handler];
}

+ (id)update:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceStatusCompletionHandler)handler {
    return [super update:path parameters:parameters handler:handler];
}

+ (id)destroy:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceStatusCompletionHandler)handler {
    return [super destroy:path parameters:parameters handler:handler];
}

+ (id)read:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceResourceCompletionHandler)handler {
    return [super read:path parameters:parameters handler:handler];
}

+ (id)find:(NSString *)path searchParameters:(NSDictionary *)searchParameters handler:(MLCServiceCollectionCompletionHandler)handler {
    return [super find:path searchParameters:searchParameters handler:handler];
}

+ (Class<MLCEntityProtocol>)classForResource {
    return [super classForResource];
}


@end
