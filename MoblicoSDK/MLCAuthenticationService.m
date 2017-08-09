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

+ (instancetype)authenticateWithAPIKey:(NSString *)apiKey username:(NSString *)username password:(NSString *)password social:(NSString *)social socialToken:(NSString *)socialToken childKeyword:(NSString *)childKeyword handler:(MLCServiceResourceCompletionHandler)handler;

@end

@implementation MLCAuthenticationService

+ (Class<MLCEntityProtocol>)classForResource {
    return [MLCAuthenticationToken class];
}

+ (instancetype)authenticateWithAPIKey:(NSString *)apiKey user:(MLCUser *)user childKeyword:(NSString *)childKeyword handler:(MLCServiceResourceCompletionHandler)handler {
    if (user.socialType != MLCUserSocialTypeNone) {
        NSArray *components = [user.username componentsSeparatedByString:@"."];
        NSString *social = [components.firstObject uppercaseString];

        return [self authenticateWithAPIKey:apiKey username:user.username password:nil social:social socialToken:user.socialToken childKeyword:childKeyword handler:handler];
    }

    return [self authenticateWithAPIKey:apiKey username:user.username password:user.password social:nil socialToken:nil childKeyword:childKeyword handler:handler];
}

+ (instancetype)authenticateWithAPIKey:(NSString *)apiKey username:(NSString *)username password:(NSString *)password social:(NSString *)social socialToken:(NSString *)socialToken childKeyword:(NSString *)childKeyword handler:(MLCServiceResourceCompletionHandler)handler {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:3];
    if (apiKey) parameters[@"apikey"] = apiKey;
    if (username) parameters[@"username"] = username;
    if (password) parameters[@"password"] = password;
    if (social) parameters[@"social"] = social;
    if (socialToken) parameters[@"socialToken"] = socialToken;
    if (childKeyword.length) parameters[@"childKeyword"] = childKeyword;

#if TARGET_OS_IPHONE
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone && ![UIDevice.currentDevice.model isEqualToString:@"iPhone"]) {
        parameters[@"platformName"] = @"iPhone";
    }
#endif

    return [self read:[MLCAuthenticationToken collectionName] parameters:parameters handler:handler];
}

- (void)start {
    [self cancel];
    self.connection = [NSURLConnection connectionWithRequest:self.request delegate:self];
#if TARGET_OS_IPHONE
    UIApplication.sharedApplication.networkActivityIndicatorVisible = YES;
#endif
    [self.connection start];
}

@end