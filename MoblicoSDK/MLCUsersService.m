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
#import "MLCResetPassword.h"

#if TARGET_OS_WATCH
#import <WatchKit/WatchKit.h>
#elif TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

MLCUsersServiceVerifyResults const MLCUsersServiceVerifyResultsFound = @"MLCUsersServiceVerifyResultsFound";
MLCUsersServiceVerifyResults const MLCUsersServiceVerifyResultsNotFound = @"MLCUsersServiceVerifyResultsNotFound";


NSString *MLCDeviceIdFromDeviceToken(id token) {
    if ([token isKindOfClass:[NSString class]]) {
        return (NSString *)token;
    }

    if (![token isKindOfClass:[NSData class]]) {
        return nil;
    }

    NSData *deviceToken = (NSData *)token;
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
        NSString *description = [NSString localizedStringWithFormat:NSLocalizedString(@"Missing value for %@.", nil), key];
        MLCServiceError *error = [MLCServiceError missingParameterErrorWithDescription:description];
        return [self _invalidServiceWithError:error handler:handler];
    }

    NSString *path = [NSString pathWithComponents:@[[MLCUser collectionName], @"exists"]];

    return [self readSuccess:path parameters:@{key: value} handler:^(BOOL success, NSError *_Nullable error) {
        if (success) {
            handler(MLCUsersServiceVerifyResultsFound, nil);
        } else if ([MLCStatus typeFromError:error] == MLCStatusTypeUserNotFound) {
            handler(MLCUsersServiceVerifyResultsNotFound, nil);
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

+ (instancetype)destroyUser:(MLCUser *)user handler:(MLCServiceSuccessCompletionHandler)handler {
    return [self destroyResource:user handler:handler];
}

+ (instancetype)createAnonymousUserWithDeviceToken:(NSData *)deviceToken handler:(MLCUsersServiceResourceCompletionHandler)handler {
    NSString *device = MLCDeviceIdFromDeviceToken(deviceToken);
    NSString *username = nil;

#if TARGET_OS_WATCH
    if (@available(watchOS 6.2, *)) {
        username = WKInterfaceDevice.currentDevice.identifierForVendor.UUIDString;
    }
#elif TARGET_OS_IPHONE
    username = UIDevice.currentDevice.identifierForVendor.UUIDString;
#endif

    if (!username) {
        username = device;
    }
    NSDictionary *parameters = @{@"username": username};
    NSString *path = [@"device" stringByAppendingPathComponent:device];

    NSString *childKeyword = MLCServiceManager.sharedServiceManager.childKeyword;
    return [self createSuccess:path parameters:parameters handler:^(BOOL success, NSError *error) {
        MLCUser *user = nil;
        if (success) {
            user = [MLCUser userWithUsername:username];
            [MLCServiceManager.sharedServiceManager setCurrentUser:user childKeyword:childKeyword remember:NO];
        }
        handler(user, error);
    }];
}

+ (instancetype)addDeviceWithDeviceToken:(NSData *)deviceToken toUser:(MLCUser *)user handler:(MLCServiceSuccessCompletionHandler)handler {
    NSString *deviceId = MLCDeviceIdFromDeviceToken(deviceToken);
    [NSUserDefaults.standardUserDefaults setObject:deviceId forKey:@"MLCDeviceId"];

    NSString *path = [NSString pathWithComponents:@[[[user class] collectionName], user.uniqueIdentifier, @"device"]];

    return [self _update:path parameters:@{@"deviceId": deviceId} handler:handler];
}

+ (instancetype)destroyDeviceForUser:(MLCUser *)user handler:(MLCServiceSuccessCompletionHandler)handler {
    NSString *deviceId = [NSUserDefaults.standardUserDefaults stringForKey:@"MLCDeviceId"];

    if (!deviceId.length) {
        NSString *description = [NSString localizedStringWithFormat:NSLocalizedString(@"Missing device for user: %@", nil), user];
        MLCServiceError *error = [MLCServiceError missingParameterErrorWithDescription:description];
        return [self _invalidServiceFailedWithError:error handler:handler];
    }

    NSString *path = [NSString pathWithComponents:@[[[user class] collectionName], user.uniqueIdentifier, @"device"]];

    return [self _destroy:path parameters:@{@"deviceId": deviceId} handler:^(BOOL success, NSError *error) {
        if (success) {
            [NSUserDefaults.standardUserDefaults setObject:nil forKey:@"MLCDeviceId"];
        }
        handler(success, error);
    }];
}

+ (instancetype)resetPasswordForUser:(MLCUser *)user handler:(MLCUsersServiceResetPasswordCompletionHandler)handler {
    NSString *uniqueIdentifier = user.uniqueIdentifier;

    if (!uniqueIdentifier.length) {
        NSString *description = [NSString localizedStringWithFormat:NSLocalizedString(@"Missing %@", nil), [[self classForResource] uniqueIdentifierKey]];
        MLCServiceError *error = [MLCServiceError missingParameterErrorWithDescription:description];
        return [self _invalidServiceWithError:error handler:handler];
    }

    NSString *path = [[[self classForResource] collectionName] stringByAppendingPathComponent:uniqueIdentifier];
    path = [path stringByAppendingPathComponent:@"resetPassword"];

    return [self _service:MLCServiceRequestMethodPOST path:path parameters:nil contentType:nil handler:^(id jsonObject, NSError *error) {
        MLCResetPassword *resetPassword = [[MLCResetPassword alloc] initWithJSONObject:jsonObject];
        handler(resetPassword, error);
    }];
}

+ (instancetype)addUser:(MLCUser *)user toAccount:(MLCAccount *)account handler:(MLCServiceSuccessCompletionHandler)handler {
    NSString *path = [NSString pathWithComponents:@[[[user class] collectionName], user.uniqueIdentifier, @"account"]];
    NSDictionary *parameters = @{@"accountId": @(account.accountId).stringValue};

    return [self _update:path parameters:parameters handler:handler];
}

+ (instancetype)lookupUsernameWithUsername:(NSString *)username handler:(MLCUsersServiceLookupUsernameCompletionHandler)handler {
    NSDictionary *parameters = username ? @{@"username": username} : nil;
    return [self lookupUsernameWithSearchParameters:parameters handler:handler];
}

+ (instancetype)lookupUsernameWithPhone:(NSString *)phone handler:(MLCUsersServiceLookupUsernameCompletionHandler)handler {
    NSDictionary *parameters = phone ? @{@"phone": phone} : nil;
    return [self lookupUsernameWithSearchParameters:parameters handler:handler];
}

+ (instancetype)lookupUsernameWithEmail:(NSString *)email handler:(MLCUsersServiceLookupUsernameCompletionHandler)handler {
    NSDictionary *parameters = email ? @{@"email": email} : nil;
    return [self lookupUsernameWithSearchParameters:parameters handler:handler];
}

+ (instancetype)lookupUsernameWithSearchParameters:(NSDictionary<NSString *, NSString *> *)searchParameters handler:(MLCUsersServiceLookupUsernameCompletionHandler)handler {
    if (searchParameters.count == 0) {
        MLCServiceError *error = [MLCServiceError missingParameterErrorWithDescription:NSLocalizedString(@"Missing search parameters.", nil)];
        return [self _invalidServiceWithError:error handler:handler];
    }
    NSString *path = [NSString pathWithComponents:@[[MLCUser collectionName], @"exists"]];

    NSMutableDictionary *parameters = [searchParameters mutableCopy];
    parameters[@"lookup"] = @"true";
    return [self serviceForMethod:MLCServiceRequestMethodGET
                             path:path
                       parameters:parameters
                      contentType:nil
                          handler:^(MLCService *service, id jsonObject, NSError *serviceError, __unused NSHTTPURLResponse *response) {
                              dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                  NSString *username = jsonObject[@"username"];
                                  MLCStatus *status = [[MLCStatus alloc] initWithJSONObject:jsonObject[@"status"]];
                                  NSError *error = status ? [[MLCStatusError alloc] initWithStatus:status] : serviceError;
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      handler(username, error);
                                      service.dispatchGroup = nil;
                                  });
                              });
                          }];
}

@end
