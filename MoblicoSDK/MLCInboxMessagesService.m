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

#import "MLCInboxMessagesService.h"
#import "MLCService_Private.h"
#import "MLCUser.h"
#import "MLCInboxMessage.h"
#import "MLCServiceManager.h"

@implementation MLCInboxMessagesService

+ (NSArray<Class> *)scopeableResources {
    return @[[MLCUser class]];
}

+ (Class)classForResource {
    return [MLCInboxMessage class];
}

+ (instancetype)listInboxMessages:(MLCInboxMessagesServiceCollectionCompletionHandler)handler {
    MLCUser *user = MLCServiceManager.sharedServiceManager.currentUser;
    return [self findScopedResourcesForResource:user searchParameters:@{} handler:handler];
}

+ (instancetype)destroyInboxMessage:(MLCInboxMessage *)message handler:(MLCServiceSuccessCompletionHandler)handler {
    MLCUser *user = MLCServiceManager.sharedServiceManager.currentUser;
    NSString *path = [NSString pathWithComponents:@[[MLCUser collectionName], user.uniqueIdentifier, [MLCInboxMessage collectionName], message.uniqueIdentifier]];

    return [self _destroy:path parameters:nil handler:handler];
}

@end
