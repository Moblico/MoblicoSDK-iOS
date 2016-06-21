//
//  MLCGroupsService.m
//  MoblicoSDK
//
//  Created by Cameron Knight on 12/22/13.
//  Copyright (c) 2013 Moblico Solutions LLC. All rights reserved.
//

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
    NSString *path = [NSString pathWithComponents:@[[[user class] collectionName], user.uniqueIdentifier, [[group class] collectionName], group.uniqueIdentifier]];
    return [self update:path parameters:nil handler:handler];
}

+ (instancetype)addCurrentUserToGroup:(MLCGroup *)group handler:(MLCServiceSuccessCompletionHandler)handler {
    MLCUser *user = [MLCServiceManager sharedServiceManager].currentUser;
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

        NSString *description = [NSString stringWithFormat:NSLocalizedString(@"Invalid parameter.", nil), [[self classForResource] collectionName]];
        NSError *error = [NSError errorWithDomain:@"MLCServiceErrorDomain" code:1000 userInfo:@{NSLocalizedDescriptionKey: description, NSLocalizedFailureReasonErrorKey: [failureReasons componentsJoinedByString:@"\n"]}];
        return (MLCGroupsService *)[MLCInvalidService invalidServiceFailedWithError:error handler:handler];
    }

    NSString *path = [NSString pathWithComponents:@[[[user class] collectionName], user.uniqueIdentifier, [MLCGroup collectionName]]];
    return [self update:path parameters:@{@"name": groupName} handler:handler];
}

+ (instancetype)addCurrentUserToGroupNamed:(NSString *)groupName handler:(MLCServiceSuccessCompletionHandler)handler {
    MLCUser *user = [MLCServiceManager sharedServiceManager].currentUser;
    return [self addUser:user toGroupNamed:groupName handler:handler];
}

+ (instancetype)removeUser:(MLCUser *)user fromGroupNamed:(NSString *)groupName handler:(MLCServiceSuccessCompletionHandler)handler {
    NSString *path = [NSString pathWithComponents:@[[[user class] collectionName], user.uniqueIdentifier, [MLCGroup collectionName]]];
    return [self destroy:path parameters:@{@"name": groupName} handler:handler];
}

+ (instancetype)removeCurrentUserFromGroupNamed:(NSString *)groupName handler:(MLCServiceSuccessCompletionHandler)handler {
    MLCUser *user = [MLCServiceManager sharedServiceManager].currentUser;
    return [self removeUser:user fromGroupNamed:groupName handler:handler];
}

@end
