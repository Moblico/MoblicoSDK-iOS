//
//  MLCInvalidService.m
//  MoblicoSDK
//
//  Created by Cameron Knight on 2/5/13.
//  Copyright (c) 2013 Moblico Solutions LLC. All rights reserved.
//

#import "MLCInvalidService.h"

@implementation MLCInvalidService

+ (id)invalidServiceWithError:(NSError *)error handler:(MLCInvalidServiceCompletionHandler)handler {
    MLCInvalidService * service = [[self alloc] init];
    service.error = error;
    service.handler = handler;
    return service;
}

- (void)start {
    self.handler(nil, self.error, nil);
}

- (void)cancel {
    
}

@end
