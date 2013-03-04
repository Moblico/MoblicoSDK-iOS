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
#import "MLCServiceProtocol.h"
#import "MLCAuthenticationService.h"
#import "MLCAuthenticationToken.h"

@implementation MLCAuthenticationService

+ (Class<MLCEntityProtocol>)classForResource {
    return [MLCAuthenticationToken class];
}

+ (id)authenticateWithAPIKey:(NSString *)apiKey username:(NSString *)username password:(NSString *)password handler:(MLCServiceResourceCompletionHandler)handler {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:3];
    if (apiKey) parameters[@"apikey"] = apiKey;
    if (username) parameters[@"username"] = username;
    if (password) parameters[@"password"] = password;

    return [self read:[MLCAuthenticationToken collectionName] parameters:parameters handler:handler];
}

- (void)start {
    [self cancel];
    self.connection = [NSURLConnection connectionWithRequest:self.request delegate:self];;
    [self.connection start];
}

@end
