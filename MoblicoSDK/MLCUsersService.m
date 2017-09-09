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
#import "MLCServiceManager.h"
#import "MLCUsersService.h"
#import "MLCUser.h"
#import "MLCStatus.h"
#import "MLCCredential.h"
#import "MLCEntity_Private.h"

#if TARGET_OS_IOS
@import UIKit;
#endif


NSString *MLCDeviceIdFromDeviceToken(NSData *deviceToken) {
    if ([deviceToken isKindOfClass:[NSString class]]) {
        return (NSString *)deviceToken;
    }

    const unsigned char *bytes = deviceToken.bytes;
    const NSUInteger length = deviceToken.length;

    NSMutableString *deviceId = [NSMutableString string];
    for (NSUInteger idx = 0; idx < length; ++idx) {
        [deviceId appendFormat:@"%02x", bytes[idx]];
    }

    return [deviceId copy];
}

@implementation MLCUsersService

+ (Class)classForResource {
    return [MLCUser class];
}

+ (instancetype)verifyExistingUserWithUsername:(NSString *)username handler:(MLCUsersServiceVerifyExistingUserCompletionHandler)handler {
    return [self verifyExistingUserWithValue:username forKey:@"username" handler:handler];
}

+ (instancetype)verifyExistingUserWithPhone:(NSString *)phone handler:(MLCUsersServiceVerifyExistingUserCompletionHandler)handler {
    return [self verifyExistingUserWithValue:phone forKey:@"phone" handler:handler];
}

+ (instancetype)verifyExistingUserWithEmail:(NSString *)email handler:(MLCUsersServiceVerifyExistingUserCompletionHandler)handler {
    return [self verifyExistingUserWithValue:email forKey:@"email" handler:handler];
}

+ (instancetype)verifyExistingUserWithValue:(NSString *)value forKey:(NSString *)key handler:(MLCUsersServiceVerifyExistingUserCompletionHandler)handler {
    if (value.length == 0) {
        NSError *error =[self errorWithCode:MLCServiceErrorCodeMissingParameter];
        return [self invalidServiceWithError:error handler:handler];
    }

    NSString *path = [NSString pathWithComponents:@[[MLCUser collectionName], @"exists"]];

    return [self readSuccess:path parameters:@{key: value} handler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            handler(@YES, nil);
        } else if ([MLCStatus typeFromError:error] == MLCStatusTypeUserNotFound) {
            handler(@NO, nil);
        } else {
            handler(nil, error);
        }
    }];
}

+ (instancetype)createUser:(MLCUser *)user handler:(MLCServiceSuccessCompletionHandler)handler {
    return [self createSuccessResource:user handler:handler];
}

+ (instancetype)readUser:(MLCUser *)user handler:(MLCUsersServiceResourceCompletionHandler)handler {
    return [self readUserWithUsername:user.username handler:handler];
}

+ (instancetype)readUserWithUsername:(NSString *)username handler:(MLCUsersServiceResourceCompletionHandler)handler {
    return [self readResourceWithUniqueIdentifier:username ?: @"" handler:handler];
}

+ (instancetype)updateUser:(MLCUser *)user handler:(MLCServiceSuccessCompletionHandler)handler {
    return [self updateResource:user handler:handler];
}

+ (instancetype)destroyUser:(__unused MLCUser *)user handler:(__unused MLCServiceSuccessCompletionHandler)handler {
    // TODO: Add support to backend
    NSString *reason = [NSString stringWithFormat:@"'%@' is not available in this version of the MoblicoSDK.", NSStringFromSelector(_cmd)];
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
}

+ (instancetype)createAnonymousUserWithDeviceToken:(NSData *)deviceToken handler:(MLCUsersServiceResourceCompletionHandler)handler {
    NSString *device = MLCDeviceIdFromDeviceToken(deviceToken);
    NSString *username = nil;

#if TARGET_OS_IOS
    username = UIDevice.currentDevice.identifierForVendor.UUIDString;
#endif

    if (!username) {
        username = device;
    }
    NSDictionary *parameters = parameters = @{@"username": username};
    NSString *path = [@"device" stringByAppendingPathComponent:device];

    return [self createSuccess:path parameters:parameters handler:^(BOOL success, NSError *error) {
        MLCUser *user = nil;
        if (success) {
            user = [MLCUser userWithUsername:username];
            [MLCServiceManager.sharedServiceManager setCurrentUser:user remember:NO];
        }
        handler(user, error);
    }];
}

+ (instancetype)addDeviceWithDeviceToken:(NSData *)deviceToken toUser:(MLCUser *)user handler:(MLCServiceSuccessCompletionHandler)handler {
    NSString *deviceId = MLCDeviceIdFromDeviceToken(deviceToken);
    [NSUserDefaults.standardUserDefaults setObject:deviceId forKey:@"MLCDeviceId"];

    NSString *path = [NSString pathWithComponents:@[[[user class] collectionName], user.uniqueIdentifier, @"device"]];

    return [self update:path parameters:@{@"deviceId": deviceId} handler:handler];
}

+ (instancetype)destroyDeviceForUser:(MLCUser *)user handler:(MLCServiceSuccessCompletionHandler)handler {
    NSString *deviceId = [NSUserDefaults.standardUserDefaults stringForKey:@"MLCDeviceId"];

    if (!deviceId.length) {
        NSString *description = [NSString stringWithFormat:NSLocalizedString(@"Missing device for user: %@", nil), user];
        NSError *error = [self errorWithCode:MLCServiceErrorCodeMissingParameter description:description];
        return [self invalidServiceFailedWithError:error handler:handler];
    }

    NSString *path = [NSString pathWithComponents:@[[[user class] collectionName], user.uniqueIdentifier, @"device"]];

    return [self destroy:path parameters:@{@"deviceId": deviceId} handler:^(BOOL success, NSError *error) {
        if (success) {
            [NSUserDefaults.standardUserDefaults setObject:nil forKey:@"MLCDeviceId"];
        }
        handler(success, error);
    }];
}

+ (instancetype)resetPasswordForUser:(MLCUser *)user handler:(MLCUsersServiceResetPasswordCompletionHandler)handler {
    NSString *uniqueIdentifier = user.uniqueIdentifier;

    if (!uniqueIdentifier.length) {
        NSString *description = [NSString stringWithFormat:NSLocalizedString(@"Missing %@", nil), [[self classForResource] uniqueIdentifierKey]];
        NSError *error = [self errorWithCode:MLCServiceErrorCodeMissingParameter description:description];
        return [self invalidServiceWithError:error handler:handler];
    }

    NSString *path = [[[self classForResource] collectionName] stringByAppendingPathComponent:uniqueIdentifier];
    path = [path stringByAppendingPathComponent:@"resetPassword"];

    return [self service:MLCServiceRequestMethodPUT path:path parameters:nil handler:^(id jsonObject, NSError *error) {
        NSURL *url = nil;
        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dictionary = (NSDictionary *)jsonObject;
            url = [MLCEntity URLFromValue:dictionary[@"url"]];
        }
        handler(url, error);
    }];
}

+ (instancetype)addUser:(MLCUser *)user toAccount:(MLCAccount *)account handler:(MLCServiceSuccessCompletionHandler)handler {
    NSString *path = [NSString pathWithComponents:@[[[user class] collectionName], user.uniqueIdentifier, @"account"]];
    NSDictionary *parameters = @{@"accountId": @(account.accountId).stringValue};

    return [self update:path parameters:parameters handler:handler];
}

@end
