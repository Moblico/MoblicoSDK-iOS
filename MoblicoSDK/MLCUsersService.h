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
@class MLCResetPassword;
@class MLCAccount;

MLCServiceCreateResourceCompletionHandler(MLCUsersService, MLCUser);

typedef NSString *MLCUsersServiceVerifyResults NS_TYPED_ENUM NS_SWIFT_NAME(MLCUsersService.VerifyResults);
FOUNDATION_EXPORT MLCUsersServiceVerifyResults const MLCUsersServiceVerifyResultsFound;
FOUNDATION_EXPORT MLCUsersServiceVerifyResults const MLCUsersServiceVerifyResultsNotFound;

typedef void(^MLCUsersServiceVerifyExistingUserCompletionHandler)(MLCUsersServiceVerifyResults _Nullable results, NSError *_Nullable error) NS_SWIFT_NAME(MLCUsersService.VerifyExistingUserCompletionHandler);
typedef void(^MLCUsersServiceResetPasswordCompletionHandler)(MLCResetPassword *_Nullable results, NSError *_Nullable error) NS_SWIFT_NAME(MLCUsersService.ResetPasswordCompletionHandler);

NS_SWIFT_NAME(UsersService)
@interface MLCUsersService : MLCService

+ (instancetype)verifyExistingUserWithUsername:(NSString *)username handler:(MLCUsersServiceVerifyExistingUserCompletionHandler)handler;
+ (instancetype)verifyExistingUserWithPhone:(NSString *)phone handler:(MLCUsersServiceVerifyExistingUserCompletionHandler)handler;
+ (instancetype)verifyExistingUserWithEmail:(NSString *)email handler:(MLCUsersServiceVerifyExistingUserCompletionHandler)handler;
+ (instancetype)createUser:(MLCUser *)user handler:(MLCServiceSuccessCompletionHandler)handler NS_SWIFT_NAME(create(_:handler:));
+ (instancetype)readUser:(MLCUser *)user handler:(MLCUsersServiceResourceCompletionHandler)handler;
+ (instancetype)readUserWithUsername:(NSString *)username handler:(MLCUsersServiceResourceCompletionHandler)handler;
+ (instancetype)updateUser:(MLCUser *)user handler:(MLCServiceSuccessCompletionHandler)handler;

+ (instancetype)addUser:(MLCUser *)user toAccount:(MLCAccount *)account handler:(MLCServiceSuccessCompletionHandler)handler;

+ (instancetype)createAnonymousUserWithDeviceToken:(NSData *)deviceToken handler:(MLCUsersServiceResourceCompletionHandler)handler;
+ (instancetype)addDeviceWithDeviceToken:(NSData *)deviceToken toUser:(MLCUser *)user handler:(MLCServiceSuccessCompletionHandler)handler;
+ (instancetype)destroyDeviceForUser:(MLCUser *)user handler:(MLCServiceSuccessCompletionHandler)handler;
+ (instancetype)resetPasswordForUser:(MLCUser *)user handler:(MLCUsersServiceResetPasswordCompletionHandler)handler;

@end

@interface MLCUsersService (Unavailable)

/**
 @since Unavailable in this version of the MoblicoSDK.
 */
+ (instancetype)destroyUser:(MLCUser *)user handler:(MLCServiceSuccessCompletionHandler)handler __attribute__((unavailable("'destroyUser:handler:' is not available with this version of the Moblico SDK.")));

@end

NS_ASSUME_NONNULL_END
