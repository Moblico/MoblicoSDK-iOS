/*
 Copyright 2012 Moblico Solutions LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this work except in compliance with the License.
 You may obtain a copy of the License in the LICENSE file, or at:

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

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
