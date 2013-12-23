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
    
	const unsigned char *bytes = [deviceToken bytes];
	const NSUInteger length = [deviceToken length];
	
	NSMutableString *deviceId = [NSMutableString string];
	for (NSUInteger idx = 0; idx < length; ++idx) {
		[deviceId appendFormat:@"%02x", bytes[idx]];
	}
	
	return [deviceId copy];
}

@implementation MLCUsersService

+ (Class<MLCEntity>)classForResource {
    return [MLCUser class];
}

+ (instancetype)verifyExistingUserWithUsername:(NSString *)username handler:(MLCServiceResourceCompletionHandler)handler {
    return [self verifyExistingUserWithValue:username forKey:@"username" handler:handler];
}

+ (instancetype)verifyExistingUserWithPhone:(NSString *)phone handler:(MLCServiceResourceCompletionHandler)handler {
    return [self verifyExistingUserWithValue:phone forKey:@"phone" handler:handler];
}

+ (instancetype)verifyExistingUserWithEmail:(NSString *)email handler:(MLCServiceResourceCompletionHandler)handler {
    return [self verifyExistingUserWithValue:email forKey:@"email" handler:handler];
}

+ (instancetype)verifyExistingUserWithValue:(NSString *)value forKey:(NSString *)key handler:(MLCServiceResourceCompletionHandler)handler {
    NSString *path = [NSString pathWithComponents:@[[MLCUser collectionName], @"exists"]];
    NSDictionary * parameters;
    if (value.length) parameters = @{key: value};
    return [self read:path parameters:parameters handler:handler];
}

+ (instancetype)createUser:(MLCUser *)user handler:(MLCServiceStatusCompletionHandler)handler {
    return [self createResource:user handler:handler];
}

+ (instancetype)readUser:(MLCUser *)user handler:(MLCServiceResourceCompletionHandler)handler {
    return [self readUserWithUsername:user.username handler:handler];
}

+ (instancetype)readUserWithUsername:(NSString *)username handler:(MLCServiceResourceCompletionHandler)handler {
    if (username == nil) {
        username = @"";
//        NSString *description = [NSString stringWithFormat:NSLocalizedString(@"Missing %@", nil), [[self classForResource] uniqueIdentifierKey]];
//        NSError * error = [NSError errorWithDomain:@"MLCServiceErrorDomain" code:1001 userInfo:@{NSLocalizedDescriptionKey: description}];
//        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:nil statusCode:401 HTTPVersion:nil headerFields:nil];
//        return (MLCUsersService *)[MLCInvalidService invalidServiceWithError:error response:response handler:handler];
    }
    return [self readResourceWithUniqueIdentifier:username handler:handler];
}

+ (instancetype)updateUser:(MLCUser *)user handler:(MLCServiceStatusCompletionHandler)handler {
    return [self updateResource:user handler:handler];
}

+ (instancetype)destroyUser:(MLCUser *)user handler:(MLCServiceStatusCompletionHandler)handler {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
    return [self destroyResource:user handler:handler];
}

+ (instancetype)createAnonymousDeviceWithDeviceToken:(NSData *)deviceToken handler:(MLCServiceStatusCompletionHandler)handler {
    NSString *device = MLCDeviceIdFromDeviceToken(deviceToken);
    NSString *username = nil;
    Class Device = NSClassFromString(@"UIDevice");
    if (Device) {
        SEL selector = NSSelectorFromString(@"currentDevice");
        if ([Device respondsToSelector:selector]) {
            id currentDevice = [Device valueForKey:NSStringFromSelector(selector)];
            selector = NSSelectorFromString(@"identifierForVendor");
            if ([currentDevice respondsToSelector:selector]) {
                NSUUID * identifierForVendor = [currentDevice valueForKey:NSStringFromSelector(selector)];
                username = [identifierForVendor UUIDString];
            }

        }
    }


    if (!username) {
        username = device;
    }
    NSDictionary *parameters = parameters = @{@"username": username};
    NSString *path = [@"device" stringByAppendingPathComponent:device];
    return [self create:path parameters:parameters handler:^(MLCStatus *status, NSError *error, NSHTTPURLResponse *response) {
        if (!error && status.type == MLCStatusTypeSuccess) {
            MLCUser *user = [MLCUser userWithUsername:username];
            [[MLCServiceManager sharedServiceManager] setCurrentUser:user remember:NO];
        }
        handler(status, error, response);
    }];
/*
 NSString *username = MLCDeviceIdFromDeviceToken(deviceToken);
    MLCUser * user = [MLCUser userWithUsername:username];

    MLCUsersService *updateDeviceService = [MLCUsersService updateDeviceWithDeviceToken:deviceToken forUser:user handler:handler];

	// This block of code will create a user, it will not execute until you call [createUserService start]
	MLCUsersService *createUserService = [MLCUsersService createUser:user handler:^(MLCStatus *status, NSError *error, NSHTTPURLResponse *response) {
		if (response.statusCode == 200) {
			// User was succesfully created
//			NSLog(@"Created User: %@", user);
            [[MLCServiceManager sharedServiceManager] setUsername:user.username password:nil remember:NO];
            [updateDeviceService start];
		}
		else {
			// User was not created
//			NSLog(@"Unable to create user.\nstatus: %@ error: %@ response: %@", status, error, response);
            handler(status, error, response);
		}
	}];
    
	// This block of code determines if the user already exists, it will not execute until you call [verifyUserService start]
	MLCUsersService *verifyUserService = [MLCUsersService verifyExistingUserWithUsername:user.username handler:^(id<MLCEntity> resource, NSError *error, NSHTTPURLResponse *response) {
		if (response.statusCode == 200) {
//			NSLog(@"User exists, registering device.");
            [[MLCServiceManager sharedServiceManager] setUsername:user.username password:nil remember:NO];
            [updateDeviceService start];
		}
		
		else if (response.statusCode == 404) {
//			NSLog(@"User not found. Creating User");
			[createUserService start];
		}
		else {
            MLCStatus *status = nil;
            if ([resource isKindOfClass:[MLCStatus class]]) {
                status = (MLCStatus *)resource;
            }
            handler(status, error, response);
//			NSLog(@"Unable to verify user.\nresource: %@ error: %@ response: %@", resource, error, response);
		}
	}];
	
	// Execute
	return verifyUserService;
 */
}

+ (instancetype)createDeviceWithDeviceId:(NSString *)deviceId forUser:(MLCUser *)user handler:(MLCServiceStatusCompletionHandler)handler {
    return [self addDeviceWithDeviceToken:(id)deviceId toUser:user handler:handler];
}

+ (instancetype)updateDeviceWithDeviceToken:(NSData *)deviceToken forUser:(MLCUser *)user handler:(MLCServiceStatusCompletionHandler)handler {
    return [self addDeviceWithDeviceToken:deviceToken toUser:user handler:handler];
}

+ (instancetype)addDeviceWithDeviceToken:(NSData *)deviceToken toUser:(MLCUser *)user handler:(MLCServiceStatusCompletionHandler)handler {
    NSString *deviceId = MLCDeviceIdFromDeviceToken(deviceToken);
    [[NSUserDefaults standardUserDefaults] setObject:deviceId forKey:@"MLCDeviceId"];
    
    NSString *path = [NSString pathWithComponents:@[[user collectionName], [user uniqueIdentifier], @"device"]];
    
    // return [self create:path parameters:@{@"deviceId": deviceId} handler:handler];
    return [self update:path parameters:@{@"deviceId": deviceId} handler:handler];
}

+ (instancetype)destroyDeviceForUser:(MLCUser *)user handler:(MLCServiceStatusCompletionHandler)handler {
    NSString *deviceId = [[NSUserDefaults standardUserDefaults] stringForKey:@"MLCDeviceId"];
    NSString *path = [NSString pathWithComponents:@[[user collectionName], [user uniqueIdentifier], @"device"]];
    return [self destroy:path parameters:@{@"deviceId": deviceId} handler:^(MLCStatus *status, NSError *error, NSHTTPURLResponse *response) {
        if ([status httpStatus] == 200) {
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"MLCDeviceId"];
        }
        handler(status, error, response);
    }];
}

+ (instancetype)destroyDeviceWithDeviceId:(NSString *)deviceId forUser:(MLCUser *)user handler:(MLCServiceStatusCompletionHandler)handler {
    NSString *path = [NSString pathWithComponents:@[[user collectionName], [user uniqueIdentifier], @"device"]];
    return [self destroy:path parameters:@{@"deviceId": deviceId} handler:^(MLCStatus *status, NSError *error, NSHTTPURLResponse *response) {
        handler(status, error, response);
    }];
}


@end
