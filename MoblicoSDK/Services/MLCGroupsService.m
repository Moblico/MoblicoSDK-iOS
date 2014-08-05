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

@implementation MLCGroupsService

+ (NSArray *)scopeableResources {
    return @[@"MLCUser"];
}

+ (Class<MLCEntity>)classForResource {
    return [MLCGroup class];
}

+ (instancetype)listGroups:(MLCServiceCollectionCompletionHandler)handler {
    return [self listResources:handler];
}

+ (instancetype)listGroupsForUser:(MLCUser *)user handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self listGroupsForResource:(id<MLCEntity>)user handler:handler];
}

+ (instancetype)listGroupsForResource:(id <MLCEntity>)resource handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self listScopedResourcesForResource:resource handler:handler];
}

+ (instancetype)addUser:(MLCUser *)user toGroup:(MLCGroup *)group handler:(MLCServiceStatusCompletionHandler)handler {
    NSString *path = [NSString pathWithComponents:@[[user collectionName], [user uniqueIdentifier], [group collectionName], [group uniqueIdentifier]]];
    return [self update:path parameters:nil handler:handler];
}

+ (instancetype)addCurrentUserToGroup:(MLCGroup *)group handler:(MLCServiceStatusCompletionHandler)handler {
    MLCUser *user = [MLCServiceManager sharedServiceManager].currentUser;
    return [self addUser:user toGroup:group handler:handler];
}

+ (instancetype)addUser:(MLCUser *)user toGroupNamed:(NSString *)groupName handler:(MLCServiceStatusCompletionHandler)handler {
    NSString *path = [NSString pathWithComponents:@[[user collectionName], [user uniqueIdentifier], [MLCGroup collectionName]]];
    return [self update:path parameters:@{@"name": groupName} handler:handler];
}

+ (instancetype)addCurrentUserToGroupNamed:(NSString *)groupName handler:(MLCServiceStatusCompletionHandler)handler {
    MLCUser *user = [MLCServiceManager sharedServiceManager].currentUser;
    return [self addUser:user toGroupNamed:groupName handler:handler];
}

@end
