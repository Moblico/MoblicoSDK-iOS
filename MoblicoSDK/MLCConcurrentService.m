//
//  MLCConcurrentService.m
//  MoblicoSDK
//
//  Created by Cameron Knight on 3/28/17.
//  Copyright © 2017 Moblico Solutions LLC. All rights reserved.
//

#import "MLCConcurrentService.h"
#import "MLCService_Private.h"

@interface MLCConcurrentService ()
@property (nonatomic, copy) NSArray<__kindof MLCService *> *services;
@property (nonatomic, copy) MLCConcurrentServiceCompletionHandler concurrentServiceCompletionHandler;
@end

@implementation MLCConcurrentService

+ (instancetype)concurrentServiceWithServices:(NSArray<__kindof MLCService *> *)services completionHandler:(MLCConcurrentServiceCompletionHandler)completionHandler {
    MLCConcurrentService *service = [[self alloc] init];
    service.services = services;
    service.concurrentServiceCompletionHandler = completionHandler;

    return service;
}

- (void)start {
    dispatch_group_t group = dispatch_group_create();

    for (MLCService *service in self.services) {
        service.dispatchGroup = group;
        [service start];
    }

	__block MLCConcurrentServiceCompletionHandler handler = self.concurrentServiceCompletionHandler;
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (handler != nil) {
            handler();
        }
    });
}

- (void)cancel {
    self.concurrentServiceCompletionHandler = nil;
    for (MLCService *service in self.services) {
        [service cancel];
        service.dispatchGroup = nil;
    }
}

@end
