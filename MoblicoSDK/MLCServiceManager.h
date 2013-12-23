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

#import <Foundation/Foundation.h>
@class MLCUser;

/**
 The callback handler for `authenticateRequest:handler:`

 @param authenticatedRequest The authenticated request.
 @param error The error that occured during authentication
        (will be nil if no error).
 @param response The data returned during authentication.

 @discussion Discussion that applies to the entire callback.
 */
typedef void(^MLCServiceManagerAuthenticationCompletionHandler)(NSURLRequest *authenticatedRequest,
                                                                NSError *error,
                                                                NSHTTPURLResponse *response);

/**
 MLCInvalidAPIKeyException
 */
extern NSString *const MLCInvalidAPIKeyException;


/**
 `MLCServiceManager` keeps track of your Moblico API Key, and authenticates
 all service calls.

 Get a shared instance of `MLCServiceManager` by calling the
 `sharedServiceManager` class method.
 
 For user level authentication call `setUsername:password:remember:`
 on the shared instance.
 */
@interface MLCServiceManager : NSObject

#pragma mark Shared Instance
///----------------------
/// @name Shared Instance
///----------------------

/**
 Shared instance of `MLCServiceManager`.

 @warning You must set the API Key before getting an instance
 of `MLCServiceManager`.

 @exception MLCInvalidAPIKeyException You must set your API key before getting
 an instance of the `MLCServiceManager`.

 @return A shared instance of `MLCServiceManager`.
 
 @see setAPIKey:
 */
+ (MLCServiceManager *)sharedServiceManager;

#pragma mark API Key Management
///-------------------------
/// @name API Key Management
///-------------------------

/**
 Set the API Key used for all service calls.

 @param apiKey The API Key provided by Moblico.

 @warning The API Key should only be set once.
 Calling setAPIKey more than once will raise an exception.

 @exception MLCInvalidAPIKeyException You can only set the API Key once.

 @see apiKey
 */
+ (void)setAPIKey:(NSString *)apiKey;

/**
 Get the current API Key.

 @return The API Key will be nil until setAPIKey is called.

 @see setAPIKey:
 */
+ (NSString *)apiKey;

#pragma mark Authentication
///---------------------
/// @name Authentication
///---------------------

/**
 The currently authenticated user used for user level authentication. (read-only)

 @see setCurrentUser:remember:
 */
@property (readonly, strong) MLCUser *currentUser;

- (void)setCurrentUser:(MLCUser *)user
       remember:(BOOL)rememberCredentials;

/**
 Create an authenticated request.

 @param request The unauthenticated request which needs to be authenticated.
 @param handler Completion handler with the authenticated request.
 */
- (void)authenticateRequest:(NSURLRequest *)request
                    handler:(MLCServiceManagerAuthenticationCompletionHandler)handler;

#pragma mark Configuration
///--------------------
/// @name Configuration
///--------------------

/**
 Sets whether SSL should be used with service calls.

 @param disabled Specify YES to disable SSL or NO to remain enabled.

 @see isSSLDisabled
 */
+ (void)setSSLDisabled:(BOOL)disabled;

/**
 Returns a Boolean value indicating whether SSL is disabled.

 @return YES if SSL is disabled; otherwise, NO.

 @see setSSLDisabled:
 */
+ (BOOL)isSSLDisabled;

/**
 Sets wheter the Moblico testing environment should be used.

 @param testing Specify YES to use the Moblico testing environment
 or NO to use the production environment.

 @see isTestingEnabled
 */
+ (void)setTestingEnabled:(BOOL)testing;

/**
 Returns a Boolean value indicating whether the Moblico testing environment is enabled.

 @return YES if the Moblico testing environment is enabled; otherwise, NO.

 @see setTestingEnabled:
 */
+ (BOOL)isTestingEnabled;

/**
 Sets whether service calls are logged to the console.

 @param logging Specify YES to enable logging or NO to disable it.

 @see isLoggingEnabled
 
 @since Available in MoblicoSDK 1.1.1 and later.
 */
+ (void)setLoggingEnabled:(BOOL)logging;

/**
 Returns a Boolean value indicating whether service calls are logged to the console.

 @return YES if logging is enabled; otherwise, NO.

 @see setLoggingEnabled:
 
 @since Available in MoblicoSDK 1.1.1 and later.
 */
+ (BOOL)isLoggingEnabled;

#pragma mark Information
///------------------
/// @name Information
///------------------

/**
 Returns the host name for the Moblico platform.

 @return The host name used for service calls.
 */
+ (NSString *)host;

/**
 Returns the Moblico API version number.

 @return The API version number.
 */
+ (NSString *)apiVersion;

/**
 Returns the Moblico SDK for iOS version number.

 @return The SDK version number
 */
+ (NSString *)sdkVersion;

@end

@interface MLCServiceManager (Deprecated)

@property (readonly) NSString *username __attribute__((deprecated ("Use 'currentUser' instead.")));
@property (readonly) NSString *password __attribute__((deprecated ("Use 'currentUser' instead.")));
- (void)setUsername:(NSString *)username password:(NSString *)password remember:(BOOL)rememberCredentials __attribute__((deprecated ("Use 'setCurrentUser:remember:' instead.")));

@end
