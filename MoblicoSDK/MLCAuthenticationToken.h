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

#import <MoblicoSDK/MLCEntity.h>

/**
 An MLCAuthenticationToken will be generated by the MLCServiceManager during
 the - [MLCServiceManager authenticateRequest:] method.

 Tokens expire 24 hours after being issued.
 */
@interface MLCAuthenticationToken : MLCEntity

/**
 The token used to authenticate a service call.
 */
@property (copy, nonatomic) NSString *token;

/**
 The expiration date of the token.
 */
@property (strong, nonatomic) NSDate *tokenExpiry;

/**
 Checks whether a token is still valid, or if a new token will need to be
 requested.
 
 @return YES if the token is not nil and hasn't expired, otherwise NO.
 */
@property (NS_NONATOMIC_IOSONLY, getter=isValid, readonly) BOOL valid;

@end