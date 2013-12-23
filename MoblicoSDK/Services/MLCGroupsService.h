//
//  MLCGroupsService.h
//  MoblicoSDK
//
//  Created by Cameron Knight on 12/22/13.
//  Copyright (c) 2013 Moblico Solutions LLC. All rights reserved.
//

#import <MoblicoSDK/MoblicoSDK.h>
@class MLCUser;
@class MLCGroup;

@interface MLCGroupsService : MLCService

+ (instancetype)readGroupWithGroupId:(NSUInteger)groupId handler:(MLCServiceResourceCompletionHandler)handler;
+ (instancetype)listGroups:(MLCServiceCollectionCompletionHandler)handler;
+ (instancetype)listGroupsForUser:(MLCUser *)user handler:(MLCServiceCollectionCompletionHandler)handler;
+ (instancetype)listGroupsForResource:(id <MLCEntity>)resource handler:(MLCServiceCollectionCompletionHandler)handler;

+ (instancetype)addUser:(MLCUser *)user toGroup:(MLCGroup *)group handler:(MLCServiceStatusCompletionHandler)handler;

@end
