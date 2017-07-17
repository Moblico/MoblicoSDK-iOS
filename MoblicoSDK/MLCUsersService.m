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
#import "MLCInvalidService.h"

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

+ (Class<MLCEntityProtocol>)classForResource {
    return [MLCUser class];
}

+ (instancetype)verifyExistingUserWithUsername:(NSString *)username handler:(MLCUserServiceVerifyExistingUserCompletionHandler)handler {
    return [self verifyExistingUserWithValue:username forKey:@"username" handler:handler];
}

+ (instancetype)verifyExistingUserWithPhone:(NSString *)phone handler:(MLCUserServiceVerifyExistingUserCompletionHandler)handler {
    return [self verifyExistingUserWithValue:phone forKey:@"phone" handler:handler];
}

+ (instancetype)verifyExistingUserWithEmail:(NSString *)email handler:(MLCUserServiceVerifyExistingUserCompletionHandler)handler {
    return [self verifyExistingUserWithValue:email forKey:@"email" handler:handler];
}

+ (instancetype)verifyExistingUserWithValue:(NSString *)value forKey:(NSString *)key handler:(MLCUserServiceVerifyExistingUserCompletionHandler)handler {
    NSString *path = [NSString pathWithComponents:@[[MLCUser collectionName], @"exists"]];

    return [self read:path parameters:value.length ? @{key: value} : nil handler:^(__unused id<MLCEntityProtocol> resource, NSError *error, NSHTTPURLResponse *response) {
        if (handler) {
            if (response.statusCode == 200) {
                handler(YES, error, response);
            }
            else {
                handler(NO, error, response);
            }
        }
    }];
}

+ (instancetype)createUser:(MLCUser *)user handler:(MLCServiceResourceCompletionHandler)handler {
    return [self createResource:user handler:handler];
}

+ (instancetype)readUser:(MLCUser *)user handler:(MLCServiceResourceCompletionHandler)handler {
    return [self readUserWithUsername:user.username handler:handler];
}

+ (instancetype)readUserWithUsername:(NSString *)username handler:(MLCServiceResourceCompletionHandler)handler {
    return [self readResourceWithUniqueIdentifier:username ? username : @"" handler:handler];
}

+ (instancetype)updateUser:(MLCUser *)user handler:(MLCServiceSuccessCompletionHandler)handler {
    return [self updateResource:user handler:handler];
}

+ (instancetype)destroyUser:(__unused MLCUser *)user handler:(__unused MLCServiceSuccessCompletionHandler)handler {
    [self doesNotRecognizeSelector:_cmd];

    return nil;
}

+ (instancetype)createAnonymousDeviceWithDeviceToken:(NSData *)deviceToken handler:(MLCServiceResourceCompletionHandler)handler {
    NSString *device = MLCDeviceIdFromDeviceToken(deviceToken);
    NSString *username = nil;
    Class Device = NSClassFromString(@"UIDevice");

    if (Device) {
        SEL selector = NSSelectorFromString(@"currentDevice");

        if ([Device respondsToSelector:selector]) {
            id currentDevice = [Device valueForKey:NSStringFromSelector(selector)];
            selector = NSSelectorFromString(@"identifierForVendor");

            if ([currentDevice respondsToSelector:selector]) {
                NSUUID *identifierForVendor = [currentDevice valueForKey:NSStringFromSelector(selector)];
                username = identifierForVendor.UUIDString;
            }

        }
    }


    if (!username) {
        username = device;
    }
    NSDictionary *parameters = parameters = @{@"username": username};
    NSString *path = [@"device" stringByAppendingPathComponent:device];

    return [self create:path parameters:parameters handler:^(MLCStatus *status, NSError *error, NSHTTPURLResponse *response) {
        if (!error) {
            MLCUser *user = [MLCUser userWithUsername:username];
            [[MLCServiceManager sharedServiceManager] setCurrentUser:user remember:NO];
        }
        handler(status, error, response);
    }];
}

+ (instancetype)createDeviceWithDeviceId:(NSString *)deviceId forUser:(MLCUser *)user handler:(MLCServiceSuccessCompletionHandler)handler {
    return [self addDeviceWithDeviceToken:(id)deviceId toUser:user handler:handler];
}

+ (instancetype)updateDeviceWithDeviceToken:(NSData *)deviceToken forUser:(MLCUser *)user handler:(MLCServiceSuccessCompletionHandler)handler {
    return [self addDeviceWithDeviceToken:deviceToken toUser:user handler:handler];
}

+ (instancetype)addDeviceWithDeviceToken:(NSData *)deviceToken toUser:(MLCUser *)user handler:(MLCServiceSuccessCompletionHandler)handler {
    NSString *deviceId = MLCDeviceIdFromDeviceToken(deviceToken);
    [[NSUserDefaults standardUserDefaults] setObject:deviceId forKey:@"MLCDeviceId"];
    
    NSString *path = [NSString pathWithComponents:@[[[user class] collectionName], user.uniqueIdentifier, @"device"]];
    
    // return [self create:path parameters:@{@"deviceId": deviceId} handler:handler];
    return [self update:path parameters:@{@"deviceId": deviceId} handler:handler];
}

+ (instancetype)destroyDeviceForUser:(MLCUser *)user handler:(MLCServiceSuccessCompletionHandler)handler {
    NSString *deviceId = [[NSUserDefaults standardUserDefaults] stringForKey:@"MLCDeviceId"];

    if (!deviceId.length) {
        NSString *description = [NSString stringWithFormat:NSLocalizedString(@"Missing device for user: %@", nil), user];
        NSError *error = [NSError errorWithDomain:@"MLCServiceErrorDomain" code:1002 userInfo:@{NSLocalizedDescriptionKey: description}];

        return (MLCUsersService *)[MLCInvalidService invalidServiceFailedWithError:error handler:handler];
    }

    NSString *path = [NSString pathWithComponents:@[[[user class] collectionName], user.uniqueIdentifier, @"device"]];

    return [self destroy:path parameters:@{@"deviceId": deviceId} handler:^(BOOL success, NSError *error, NSHTTPURLResponse *response) {
        if (success) {
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"MLCDeviceId"];
        }
        handler(success, error, response);
    }];
}

+ (instancetype)destroyDeviceWithDeviceId:(NSString *)deviceId forUser:(MLCUser *)user handler:(MLCServiceSuccessCompletionHandler)handler {
    NSString *path = [NSString pathWithComponents:@[[[user class] collectionName], user.uniqueIdentifier, @"device"]];

    return [self destroy:path parameters:@{@"deviceId": deviceId} handler:^(BOOL success, NSError *error, NSHTTPURLResponse *response) {
        handler(success, error, response);
    }];
}

+ (instancetype)createResetPasswordForUser:(MLCUser *)user handler:(MLCServiceResourceCompletionHandler)handler {
    NSString *uniqueIdentifier = user.uniqueIdentifier;

    if (!uniqueIdentifier.length) {
        NSString *description = [NSString stringWithFormat:NSLocalizedString(@"Missing %@", nil), [[self classForResource] uniqueIdentifierKey]];
        NSError *error = [NSError errorWithDomain:@"MLCServiceErrorDomain" code:1001 userInfo:@{NSLocalizedDescriptionKey: description}];

        return (MLCUsersService *)[MLCInvalidService invalidServiceWithError:error handler:handler];
    }

    NSString *path = [[[self classForResource] collectionName] stringByAppendingPathComponent:uniqueIdentifier];
    path = [path stringByAppendingPathComponent:@"resetPassword"];

    return [self create:path parameters:nil handler:handler];
}

+ (instancetype)addAccountId:(NSUInteger)accountId toUser:(MLCUser *)user handler:(MLCServiceSuccessCompletionHandler)handler {
    NSString *path = [NSString pathWithComponents:@[[[user class] collectionName], user.uniqueIdentifier, @"account"]];

    return [self update:path parameters:@{@"accountId": @(accountId).stringValue} handler:handler];
}

@end
