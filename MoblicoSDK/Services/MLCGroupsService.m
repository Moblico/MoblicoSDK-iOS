//
//  MLCGroupsService.m
//  MoblicoSDK
//
//  Created by Cameron Knight on 12/22/13.
//  Copyright (c) 2013 Moblico Solutions LLC. All rights reserved.
//

#import "MLCService_Private.h"
#import "MLCGroupsService.h"

@implementation MLCGroupsService

+ (NSArray *)scopeableResources {
    return @[@"MLCUser"];
}

+ (Class<MLCEntity>)classForResource {
    return [MLCGroup class];
}

+ (instancetype)readGroupWithGroupId:(NSUInteger)groupId handler:(MLCServiceResourceCompletionHandler)handler {
    return [self readResourceWithUniqueIdentifier:@(groupId) handler:handler];
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
@end
