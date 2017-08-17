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

#import <MoblicoSDK/MLCAvailability.h>
#import <MoblicoSDK/MLCService.h>
@class MLCUser;

typedef void(^MLCUserServiceVerifyExistingUserCompletionHandler)(BOOL found, NSError *error, NSHTTPURLResponse *response);

@interface MLCUsersService : MLCService
+ (instancetype)verifyExistingUserWithUsername:(NSString *)username handler:(MLCUserServiceVerifyExistingUserCompletionHandler)handler;
+ (instancetype)verifyExistingUserWithPhone:(NSString *)phone handler:(MLCUserServiceVerifyExistingUserCompletionHandler)handler;
+ (instancetype)verifyExistingUserWithEmail:(NSString *)email handler:(MLCUserServiceVerifyExistingUserCompletionHandler)handler;
+ (instancetype)createUser:(MLCUser *)user handler:(MLCServiceResourceCompletionHandler)handler;
+ (instancetype)readUser:(MLCUser *)user handler:(MLCServiceResourceCompletionHandler)handler;
+ (instancetype)readUserWithUsername:(NSString *)username handler:(MLCServiceResourceCompletionHandler)handler;
+ (instancetype)updateUser:(MLCUser *)user handler:(MLCServiceSuccessCompletionHandler)handler;
+ (instancetype)addAccountId:(NSUInteger)accountId toUser:(MLCUser *)user handler:(MLCServiceSuccessCompletionHandler)handler;

+ (instancetype)createAnonymousDeviceWithDeviceToken:(NSData *)deviceToken handler:(MLCServiceResourceCompletionHandler)handler;

/**
 @since Available in MoblicoSDK 1.2 and later.
 */
+ (instancetype)addDeviceWithDeviceToken:(NSData *)deviceToken toUser:(MLCUser *)user handler:(MLCServiceSuccessCompletionHandler)handler;

/**
 @since Available in MoblicoSDK 1.2 and later.
 */
+ (instancetype)destroyDeviceForUser:(MLCUser *)user handler:(MLCServiceSuccessCompletionHandler)handler;

/**
 @since Available in MoblicoSDK 1.6 and later.
 */
+ (instancetype)createResetPasswordForUser:(MLCUser *)user handler:(MLCServiceResourceCompletionHandler)handler;

@end

@interface MLCUsersService (Unavailable)

/**
 @since Unavailable in this version of the MoblicoSDK.
 */
+ (instancetype)destroyUser:(MLCUser *)user handler:(MLCServiceSuccessCompletionHandler)handler MLC_UNAVAILABLE("'destroyUser:handler:' is not available with this version of the Moblico SDK.");

@end
