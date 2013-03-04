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

#import "MLCUsersService.h"
#import "MLCUser.h"

@implementation MLCUsersService

+ (Class<MLCEntityProtocol>)classForResource {
    return [MLCUser class];
}

+ (id)verifyExistingUserWithUsername:(NSString *)username handler:(MLCServiceResourceCompletionHandler)handler {
    return [self verifyExistingUserWithValue:username forKey:@"username" handler:handler];
}

+ (id)verifyExistingUserWithPhone:(NSString *)phone handler:(MLCServiceResourceCompletionHandler)handler {
    return [self verifyExistingUserWithValue:phone forKey:@"phone" handler:handler];
}

+ (id)verifyExistingUserWithEmail:(NSString *)email handler:(MLCServiceResourceCompletionHandler)handler {
    return [self verifyExistingUserWithValue:email forKey:@"email" handler:handler];
}

+ (id)verifyExistingUserWithValue:(NSString *)value forKey:(NSString *)key handler:(MLCServiceResourceCompletionHandler)handler {
    NSString *path = [NSString pathWithComponents:@[[MLCUser collectionName], @"exists"]];
    NSDictionary * parameters;
    if (value.length) parameters = @{key: value};
    return [self read:path parameters:parameters handler:handler];
}

+ (id)createUser:(MLCUser *)user handler:(MLCServiceStatusCompletionHandler)handler {
    return [self createResource:user handler:handler];
}

+ (id)readUserWithUsername:(NSString *)username handler:(MLCServiceResourceCompletionHandler)handler {
    return [self readResourceWithUniqueIdentifier:username handler:handler];
}

+ (id)updateUser:(MLCUser *)user handler:(MLCServiceStatusCompletionHandler)handler {
    return [self updateResource:user handler:handler];
}

//+ (id)destroyUser:(MLCUser *)user handler:(MLCServiceStatusCompletionHandler)handler {
//    return [self destroyResource:user handler:handler];
//}

+ (id)createDeviceWithDeviceId:(NSString *)deviceId forUser:(MLCUser *)user handler:(MLCServiceStatusCompletionHandler)handler {
    NSString *path = [NSString pathWithComponents:@[[user collectionName], [user uniqueIdentifier], @"device"]];

    // return [self create:path parameters:@{@"deviceId": deviceId} handler:handler];
    return [self update:path parameters:@{@"deviceId": deviceId} handler:handler];
}

+ (id)destroyDeviceWithDeviceId:(NSString *)deviceId forUser:(MLCUser *)user handler:(MLCServiceStatusCompletionHandler)handler {
    NSString *path = [NSString pathWithComponents:@[[user collectionName], [user uniqueIdentifier], @"device"]];
    return [self destroy:path parameters:@{@"deviceId": deviceId} handler:handler];
}


@end
