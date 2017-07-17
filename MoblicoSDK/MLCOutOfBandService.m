//
//  MLCOutOfBandService.m
//  MoblicoSDK
//
//  Created by Cameron Knight on 2/17/14.
//  Copyright (c) 2014 Moblico Solutions LLC. All rights reserved.
//

#import "MLCOutOfBandService.h"
#import "MLCService_Private.h"

@implementation MLCOutOfBandService

+ (instancetype)outOfBandServiceWithEndPoint:(NSString *)endPoint parameters:(NSDictionary *)parameters handler:(MLCServiceJSONCompletionHandler)handler {
    NSString *path = [@"outofband" stringByAppendingPathComponent:endPoint];
    return [self serviceForMethod:MLCServiceRequestMethodGET path:path parameters:parameters handler:^(MLCService *service, id jsonObject, NSError *error, NSHTTPURLResponse *response) {
        handler(jsonObject, error, response);
        service.dispatchGroup = nil;
    }];
}

@end
