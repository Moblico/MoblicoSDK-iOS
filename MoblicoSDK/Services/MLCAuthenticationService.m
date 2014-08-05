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
#import "MLCAuthenticationService.h"
#import "MLCAuthenticationToken.h"
#import "MLCUser.h"

#if TARGET_OS_IPHONE
@import UIKit;
#endif

@interface MLCAuthenticationService ()

+ (instancetype)authenticateWithAPIKey:(NSString *)apiKey username:(NSString *)username password:(NSString *)password social:(NSString *)social socialToken:(NSString *)socialToken handler:(MLCServiceResourceCompletionHandler)handler;

@end

@implementation MLCAuthenticationService

+ (Class<MLCEntity>)classForResource {
    return [MLCAuthenticationToken class];
}

+ (instancetype)authenticateWithAPIKey:(NSString *)apiKey username:(NSString *)username password:(NSString *)password handler:(MLCServiceResourceCompletionHandler)handler {
    MLCUser *user = [MLCUser userWithUsername:username password:password];

    return [self authenticateWithAPIKey:apiKey user:user handler:handler];
}

+ (instancetype)authenticateWithAPIKey:(NSString *)apiKey user:(MLCUser *)user handler:(MLCServiceResourceCompletionHandler)handler {
    if (user.socialType != MLCUserSocialTypeNone) {
        NSArray *components = [user.username componentsSeparatedByString:@"."];
        NSString *social = [[components firstObject] uppercaseString];

        return [self authenticateWithAPIKey:apiKey username:user.username password:nil social:social socialToken:user.password handler:handler];
    }

    return [self authenticateWithAPIKey:apiKey username:user.username password:user.password social:nil socialToken:nil handler:handler];
}

+ (instancetype)authenticateWithAPIKey:(NSString *)apiKey username:(NSString *)username password:(NSString *)password social:(NSString *)social socialToken:(NSString *)socialToken handler:(MLCServiceResourceCompletionHandler)handler {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:3];
    if (apiKey) parameters[@"apikey"] = apiKey;
    if (username) parameters[@"username"] = username;
    if (password) parameters[@"password"] = password;
    if (social) parameters[@"social"] = social;
    if (socialToken) parameters[@"socialToken"] = socialToken;

    return [self read:[MLCAuthenticationToken collectionName] parameters:parameters handler:handler];
}

- (void)start {
    [self cancel];
    self.connection = [NSURLConnection connectionWithRequest:self.request delegate:self];;
#if TARGET_OS_IPHONE
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
#endif
    [self.connection start];
}

@end
