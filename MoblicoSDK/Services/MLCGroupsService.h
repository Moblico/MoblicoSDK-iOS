//
//  MLCGroupsService.h
//  MoblicoSDK
//
//  Created by Cameron Knight on 12/22/13.
//  Copyright (c) 2013 Moblico Solutions LLC. All rights reserved.
//

#import <MoblicoSDK/MLCService.h>
@class MLCUser;
@class MLCGroup;

@interface MLCGroupsService : MLCService

+ (instancetype)listGroups:(MLCServiceCollectionCompletionHandler)handler;
+ (instancetype)listGroupsForUser:(MLCUser *)user handler:(MLCServiceCollectionCompletionHandler)handler;
+ (instancetype)listGroupsForResource:(id <MLCEntity>)resource handler:(MLCServiceCollectionCompletionHandler)handler;

+ (instancetype)addUser:(MLCUser *)user toGroup:(MLCGroup *)group handler:(MLCServiceStatusCompletionHandler)handler;
+ (instancetype)addCurrentUserToGroup:(MLCGroup *)group handler:(MLCServiceStatusCompletionHandler)handler;

+ (instancetype)addUser:(MLCUser *)user toGroupNamed:(NSString *)groupName handler:(MLCServiceStatusCompletionHandler)handler;
+ (instancetype)addCurrentUserToGroupNamed:(NSString *)groupName handler:(MLCServiceStatusCompletionHandler)handler;

@end

@interface MLCGroupsService (Unavailable)

/**
 @since Unavailable in this version of the MoblicoSDK.
 */
+ (instancetype)readGroupWithGroupId:(NSUInteger)groupId handler:(MLCServiceResourceCompletionHandler)handler __attribute__((unavailable ("'readGroupWithGroupId:handler:' is not available with this version of the Moblico SDK.")));

@end
