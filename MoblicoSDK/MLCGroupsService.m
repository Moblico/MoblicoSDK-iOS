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

@implementation MLCGroupsService

+ (NSString *)pathForUser:(MLCUser *)user group:(MLCGroup *)group {
	if (group) {
		return [NSString pathWithComponents:@[[[user class] collectionName], user.uniqueIdentifier, [[group class] collectionName], group.uniqueIdentifier]];
	}

	return [NSString pathWithComponents:@[[[user class] collectionName], user.uniqueIdentifier, [MLCGroup collectionName]]];
}

+ (NSArray<Class> *)scopeableResources {
    return @[[MLCUser class]];
}

+ (Class)classForResource {
    return [MLCGroup class];
}

+ (instancetype)listGroups:(MLCGroupsServiceCollectionCompletionHandler)handler {
    return [self findResourcesWithSearchParameters:@{@"registrable": @YES} handler:handler];
}

+ (instancetype)listGroupsForUser:(MLCUser *)user handler:(MLCGroupsServiceCollectionCompletionHandler)handler {
    return [self listGroupsForResource:user handler:handler];
}

+ (instancetype)listGroupsForResource:(MLCEntity *)resource handler:(MLCGroupsServiceCollectionCompletionHandler)handler {
    return [self findScopedResourcesForResource:resource searchParameters:@{@"registrable": @YES} handler:handler];
}

+ (instancetype)addUser:(MLCUser *)user toGroup:(MLCGroup *)group handler:(MLCServiceSuccessCompletionHandler)handler {
    NSString * path = [self pathForUser:user group:group];
    return [self update:path parameters:nil handler:handler];
}

+ (instancetype)addCurrentUserToGroup:(MLCGroup *)group handler:(MLCServiceSuccessCompletionHandler)handler {
    MLCUser *user = MLCServiceManager.sharedServiceManager.currentUser;
    return [self addUser:user toGroup:group handler:handler];
}

+ (instancetype)addUser:(MLCUser *)user toGroupNamed:(NSString *)groupName handler:(MLCServiceSuccessCompletionHandler)handler {
    NSMutableArray *errors = [NSMutableArray array];
    if (!user) {
        [errors addObject:[self errorWithCode:MLCServiceErrorCodeMissingParameter description:@"User is nil." recoverySuggestion:nil]];
    }
    if (groupName.length == 0) {
        [errors addObject:[self errorWithCode:MLCServiceErrorCodeInvalidParameter description:@"Invalid group name." recoverySuggestion:nil]];
    }

    NSError *error = errors.firstObject;
    if (errors.count > 1) {
        error = [self errorWithErrors:errors];
    }

    if (error) {
        return [self invalidServiceFailedWithError:error handler:handler];
    }

    NSString *path = [self pathForUser:user group:nil];
    return [self update:path parameters:@{@"name": groupName} handler:handler];
}

+ (instancetype)addCurrentUserToGroupNamed:(NSString *)groupName handler:(MLCServiceSuccessCompletionHandler)handler {
    MLCUser *user = MLCServiceManager.sharedServiceManager.currentUser;
    return [self addUser:user toGroupNamed:groupName handler:handler];
}

+ (instancetype)removeUser:(MLCUser *)user fromGroup:(MLCGroup *)group handler:(MLCServiceSuccessCompletionHandler)handler {
	NSString * path = [self pathForUser:user group:group];
	return [self destroy:path parameters:nil handler:handler];
}

+ (instancetype)removeCurrentUserFromGroup:(MLCGroup *)group handler:(MLCServiceSuccessCompletionHandler)handler {
	MLCUser *user = MLCServiceManager.sharedServiceManager.currentUser;
	return [self removeUser:user fromGroup:group handler:handler];
}

+ (instancetype)removeUser:(MLCUser *)user fromGroupNamed:(NSString *)groupName handler:(MLCServiceSuccessCompletionHandler)handler {
	NSString * path = [self pathForUser:user group:nil];
	return [self destroy:path parameters:@{@"name": groupName} handler:handler];
}

+ (instancetype)removeCurrentUserFromGroupNamed:(NSString *)groupName handler:(MLCServiceSuccessCompletionHandler)handler {
    MLCUser *user = MLCServiceManager.sharedServiceManager.currentUser;
    return [self removeUser:user fromGroupNamed:groupName handler:handler];
}

+ (instancetype)readGroupWithGroupId:(__unused NSUInteger)groupId handler:(__unused MLCGroupsServiceResourceCompletionHandler)handler {
    // TODO: Add support to backend
    NSString *reason = [NSString stringWithFormat:@"'%@' is not available in this version of the MoblicoSDK.", NSStringFromSelector(_cmd)];
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
}
@end
