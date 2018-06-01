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

#import <MoblicoSDK/MLCService.h>

NS_ASSUME_NONNULL_BEGIN

@class MLCUser;
@class MLCGroup;

MLCServiceCreateResourceCompletionHandler(MLCGroupsService, MLCGroup);
MLCServiceCreateCollectionCompletionHandler(MLCGroupsService, MLCGroup);

NS_SWIFT_NAME(GroupsService)
@interface MLCGroupsService : MLCService

+ (instancetype)listGroups:(MLCGroupsServiceCollectionCompletionHandler)handler;

+ (instancetype)listGroupsForUser:(MLCUser *)user handler:(MLCGroupsServiceCollectionCompletionHandler)handler;

+ (instancetype)addUser:(MLCUser *)user toGroup:(MLCGroup *)group handler:(MLCServiceSuccessCompletionHandler)handler;
+ (instancetype)addCurrentUserToGroup:(MLCGroup *)group handler:(MLCServiceSuccessCompletionHandler)handler;

+ (instancetype)addUser:(MLCUser *)user toGroupNamed:(NSString *)groupName handler:(MLCServiceSuccessCompletionHandler)handler;
+ (instancetype)addCurrentUserToGroupNamed:(NSString *)groupName handler:(MLCServiceSuccessCompletionHandler)handler;

+ (instancetype)removeUser:(MLCUser *)user fromGroup:(MLCGroup *)group handler:(MLCServiceSuccessCompletionHandler)handler;
+ (instancetype)removeCurrentUserFromGroup:(MLCGroup *)group handler:(MLCServiceSuccessCompletionHandler)handler;

+ (instancetype)removeUser:(MLCUser *)user fromGroupNamed:(NSString *)groupName handler:(MLCServiceSuccessCompletionHandler)handler;
+ (instancetype)removeCurrentUserFromGroupNamed:(NSString *)groupName handler:(MLCServiceSuccessCompletionHandler)handler;

@end

NS_ASSUME_NONNULL_END
