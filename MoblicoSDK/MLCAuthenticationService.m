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

+ (instancetype)authenticateAPIKey:(NSString *)apiKey username:(NSString *)username password:(NSString *)password social:(NSString *)social socialToken:(NSString *)socialToken childKeyword:(NSString *)childKeyword handler:(MLCAuthenticationServiceResourceCompletionHandler)handler;

@end

@implementation MLCAuthenticationService

+ (Class)classForResource {
    return [MLCAuthenticationToken class];
}

+ (instancetype)authenticateAPIKey:(NSString *)apiKey user:(MLCUser *)user childKeyword:(NSString *)childKeyword handler:(MLCAuthenticationServiceResourceCompletionHandler)handler {
    return [self authenticateAPIKey:apiKey username:user.username password:user.password social:user.social socialToken:user.socialToken childKeyword:childKeyword handler:handler];
}

+ (instancetype)authenticateAPIKey:(NSString *)apiKey username:(NSString *)username password:(NSString *)password social:(NSString *)social socialToken:(NSString *)socialToken childKeyword:(NSString *)childKeyword handler:(MLCAuthenticationServiceResourceCompletionHandler)handler {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"apikey"] = apiKey;
    parameters[@"username"] = username;
    parameters[@"childKeyword"] = childKeyword;

    if (social && socialToken) {
        parameters[@"social"] = social;
        parameters[@"socialToken"] = socialToken;
    } else if (password) {
        parameters[@"password"] = password;
    }

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
