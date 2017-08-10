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

#import "MLCService_Private.h"
#import "MLCGroupsService.h"
#import "MLCGroup.h"
#import "MLCUser.h"
#import "MLCServiceManager.h"
#import "MLCInvalidService.h"

@implementation MLCGroupsService

+ (NSArray *)scopeableResources {
    return @[@"MLCUser"];
}

+ (Class<MLCEntityProtocol>)classForResource {
    return [MLCGroup class];
}

+ (instancetype)listGroups:(MLCServiceCollectionCompletionHandler)handler {
    return [self findResourcesWithSearchParameters:@{@"registrable": @YES} handler:handler];
}

+ (instancetype)listGroupsForUser:(MLCUser *)user handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self listGroupsForResource:(id<MLCEntityProtocol>)user handler:handler];
}

+ (instancetype)listGroupsForResource:(id<MLCEntityProtocol>)resource handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self findScopedResourcesForResource:resource searchParameters:@{@"registrable": @YES} handler:handler];
}

+ (instancetype)addUser:(MLCUser *)user toGroup:(MLCGroup *)group handler:(MLCServiceSuccessCompletionHandler)handler {
    NSString * path = [NSString pathWithComponents:@[[[user class] collectionName], user.uniqueIdentifier, [[group class] collectionName], group.uniqueIdentifier]];
    return [self update:path parameters:nil handler:handler];
}

+ (instancetype)addCurrentUserToGroup:(MLCGroup *)group handler:(MLCServiceSuccessCompletionHandler)handler {
    MLCUser *user = MLCServiceManager.sharedServiceManager.currentUser;
    return [self addUser:user toGroup:group handler:handler];
}

+ (instancetype)addUser:(MLCUser *)user toGroupNamed:(NSString *)groupName handler:(MLCServiceSuccessCompletionHandler)handler {
    if (!user || groupName.length == 0) {
        NSMutableArray *failureReasons = [NSMutableArray arrayWithCapacity:2];
        if (!user) {
            [failureReasons addObject:@"User is nil."];
        }
        if (groupName.length == 0) {
            [failureReasons addObject:@"Invalid group name."];
        }

        NSString * description = [NSString stringWithFormat:NSLocalizedString(@"Invalid parameter.", nil), [[self classForResource] collectionName]];
        NSError *error = [NSError errorWithDomain:@"MLCServiceErrorDomain" code:1000 userInfo:@{NSLocalizedDescriptionKey: description, NSLocalizedFailureReasonErrorKey: [failureReasons componentsJoinedByString:@"\n"]}];
        return (MLCGroupsService *)[MLCInvalidService invalidServiceFailedWithError:error handler:handler];
    }

    NSString * path = [NSString pathWithComponents:@[[[user class] collectionName], user.uniqueIdentifier, [MLCGroup collectionName]]];
    return [self update:path parameters:@{@"name": groupName} handler:handler];
}

+ (instancetype)addCurrentUserToGroupNamed:(NSString *)groupName handler:(MLCServiceSuccessCompletionHandler)handler {
    MLCUser *user = MLCServiceManager.sharedServiceManager.currentUser;
    return [self addUser:user toGroupNamed:groupName handler:handler];
}

+ (instancetype)removeUser:(MLCUser *)user fromGroupNamed:(NSString *)groupName handler:(MLCServiceSuccessCompletionHandler)handler {
    NSString * path = [NSString pathWithComponents:@[[[user class] collectionName], user.uniqueIdentifier, [MLCGroup collectionName]]];
    return [self destroy:path parameters:@{@"name": groupName} handler:handler];
}

+ (instancetype)removeCurrentUserFromGroupNamed:(NSString *)groupName handler:(MLCServiceSuccessCompletionHandler)handler {
    MLCUser *user = MLCServiceManager.sharedServiceManager.currentUser;
    return [self removeUser:user fromGroupNamed:groupName handler:handler];
}

@end
