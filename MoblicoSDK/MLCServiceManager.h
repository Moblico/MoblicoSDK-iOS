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

NS_ASSUME_NONNULL_BEGIN

/**
 The callback handler for `authenticateRequest:handler:`

 @param authenticatedRequest The authenticated request.
 @param error The error that occurred during authentication (will be nil if no error).
 */
typedef void(^MLCServiceManagerAuthenticationCompletionHandler)(NSURLRequest *_Nullable authenticatedRequest, NSError *_Nullable error) NS_SWIFT_NAME(MLCServiceManager.AuthenticationCompletionHandler);

/**
 The name of the exception raised when getting an instance of the `MLCServiceManager` before the API key is set.
 
 Also raised if the API key is set more than once.
 */
FOUNDATION_EXPORT NSString *const MLCInvalidAPIKeyException NS_SWIFT_NAME(MLCServiceManager.InvalidAPIKeyException);

typedef NS_ENUM(NSInteger, MLCServiceManagerLogging) {
    MLCServiceManagerLoggingDisabled = 0,
    MLCServiceManagerLoggingEnabled = 1,
    MLCServiceManagerLoggingEnabledVerbose NS_SWIFT_NAME(verbose)
} NS_SWIFT_NAME(MLCServiceManager.Logging);


NS_SWIFT_NAME(MLCServiceManager.Configuration)
@interface MLCServiceManagerConfiguration : NSObject

@property (nonatomic, copy, readonly) NSString *host;
@property (nonatomic, copy, readonly, nullable) NSNumber *port;
@property (nonatomic, copy, readonly) NSString *apiKey;
@property (nonatomic, assign, readonly, getter=isSSLDisabled) BOOL sslDisabled;

+ (instancetype)configurationWithAPIKey:(NSString *)apiKey NS_SWIFT_NAME(apiKey(_:));

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithHost:(NSString *)host port:(nullable NSNumber *)port apiKey:(NSString *)apiKey sslDisabled:(BOOL)sslDisabled NS_DESIGNATED_INITIALIZER;

@end

/**
 `MLCServiceManager` keeps track of your Moblico API Key, and authenticates
 all service calls.

 Get a shared instance of `MLCServiceManager` by using the
 `MLCServiceManager.sharedServiceManager` class property.
 
 For user level authentication call `-[MLCServiceManager setCurrentUser:remember:]`
 on the shared instance.
 */
NS_SWIFT_NAME(ServiceManager)
@interface MLCServiceManager : NSObject<NSCopying>

@property (atomic, class, strong, nullable) MLCServiceManagerConfiguration *configuration;

#pragma mark Shared Instance
///----------------------
/// @name Shared Instance
///----------------------

/**
 Shared instance of `MLCServiceManager`.

 @warning You must set the API Key before getting an instance
 of `MLCServiceManager`.
 */
@property (nonatomic, class, strong, readonly) MLCServiceManager *sharedServiceManager;

#pragma mark API Key Management
///-------------------------
/// @name API Key Management
///-------------------------

/// The current API Key used for all service calls.
@property (atomic, class, copy, readonly, nullable) NSString *currentAPIKey;

/**
 The API Key used for all production service calls.

 @warning The API Key should only be set once.
 Setting the API key more than once will raise an exception.
 */
@property (atomic, class, copy, nullable) NSString *APIKey;

/**
 The API Key used for all testing service calls.

 @warning The testing API Key should only be set once.
 Setting the testing API key more than once will raise an exception.
 */
@property (atomic, class, copy, nullable) NSString *testingAPIKey;

#pragma mark Authentication
///---------------------
/// @name Authentication
///---------------------

/// The currently authenticated user used for user level authentication. (read-only)
@property (readonly, nullable) MLCUser *currentUser;

/// The account keyword for the currently authenticated user.
@property (readonly, nullable) NSString *childKeyword;

// The current token passed with all service calls.
@property (readonly, nullable, copy) NSString *currentToken;

/**
 Set the current user for authentication and optionally store the credentials in the keychain. The current childKeyword (if any) will not be cleared.

 @param user                The MLCUser to use as the current user.
 @param rememberCredentials Store the credentials in the keystore?
 */
- (void)setCurrentUser:(nullable MLCUser *)user remember:(BOOL)rememberCredentials;

/**
 Set the current user for authentication and optionally store the credentials in the keychain.

 @param user                The MLCUser to use as the current user.
 @param childKeyword        Account keyword used during authentication.
 @param rememberCredentials Store the credentials in the keystore?
 */
- (void)setCurrentUser:(nullable MLCUser *)user childKeyword:(NSString *_Nullable)childKeyword remember:(BOOL)rememberCredentials;

/**
 Create an authenticated request.

 @param request The unauthenticated request which needs to be authenticated.
 @param handler Completion handler with the authenticated request.
 */
- (void)authenticateRequest:(NSURLRequest *)request handler:(MLCServiceManagerAuthenticationCompletionHandler)handler NS_SWIFT_NAME(authenticate(_:handler:));

#pragma mark Configuration
///--------------------
/// @name Configuration
///--------------------

/// Indicates whether the Moblico testing environment should be used.
@property (atomic, class, assign, getter=isTestingEnabled) BOOL testingEnabled;

/// Indicates whether service calls are logged to the console.
@property (atomic, class, assign) MLCServiceManagerLogging logging;

/// Indicates whether the current authentication is persisted between launches.
@property (atomic, class, assign, getter=isPersistentTokenEnabled) BOOL persistentTokenEnabled;

/// Override the automatically detected platform.
@property (atomic, class, copy, nullable) NSString *platformName;

#pragma mark Information
///------------------
/// @name Information
///------------------

/// The host name for the Moblico platform, used for service calls.
@property (nonatomic, class, copy, readonly) NSString *host;

/// The Moblico API version number.
@property (nonatomic, class, copy, readonly) NSString *apiVersion;

/// The Moblico SDK for iOS version number.
@property (nonatomic, class, copy, readonly) NSString *sdkVersion;

@end

NS_ASSUME_NONNULL_END
