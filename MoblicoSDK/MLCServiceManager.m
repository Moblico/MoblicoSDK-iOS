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

#import "MLCServiceManager.h"
#import "MLCAuthenticationService.h"
#import "MLCAuthenticationToken.h"
#import "MLCUser.h"
#import "MLCStatus.h"
#import "MLCKeychainPasswordItem.h"
#import "MLCLogger.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

NSString *const MLCInvalidAPIKeyException = @"MLCInvalidAPIKeyException";
static NSString *const MLCServiceManagerTestingEnabledKey = @"MLCServiceManagerTestingEnabled";
static NSString *const MLCServiceManagerLocalhostEnabledKey = @"MLCServiceManagerLocalhostEnabled";
static NSString *const MLCServiceManagerLoggingEnabledKey = @"MLCServiceManagerLoggingEnabled";
static NSString *const MLCServiceManagerPersistentTokenKey = @"MLCServiceManagerPersistentToken";
static NSString *const MLCServiceManagerPlatformNameKey = @"MLCServiceManagerPlatformName";

@interface MLCServiceManager ()

@property (atomic, strong) MLCAuthenticationToken *authenticationToken;
@property (atomic, readwrite, strong) MLCUser *currentUser;
@property (atomic, readwrite, strong) NSString *childKeyword;
@property (atomic, readonly, strong) NSString *serviceName;
@property (atomic, readonly, strong) NSOperationQueue *authenticationQueue;
@end

@implementation MLCServiceManager {
    MLCAuthenticationToken *_authenticationToken;
    NSString *_serviceName;
    NSOperationQueue *_authenticationQueue;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    MLCServiceManager *copy = [[MLCServiceManager allocWithZone:zone] init];
    [copy setCurrentUser:[self.currentUser copy] childKeyword:[self.childKeyword copy]];
    copy.authenticationToken = [self.authenticationToken copy];
    return copy;
}

- (NSString *)serviceName {
    @synchronized (self) {
        if (!_serviceName) {
            _serviceName = NSBundle.mainBundle.bundleIdentifier;
        }
        return _serviceName;
    }
}

- (NSOperationQueue *)authenticationQueue {
    @synchronized (self) {
        if (!_authenticationQueue) {
            _authenticationQueue = [[NSOperationQueue alloc] init];
            _authenticationQueue.maxConcurrentOperationCount = 1;
        }
        return _authenticationQueue;
    }
}

+ (MLCServiceManager *)sharedServiceManager {
    if (MLCServiceManager.currentAPIKey == nil) {
        [[NSException exceptionWithName:MLCInvalidAPIKeyException reason:@"You must set your API key before getting an instance of the ServiceManager." userInfo:nil] raise];
    }
    static MLCServiceManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];

        NSError *error;
        NSArray *items = [MLCKeychainPasswordItem itemsWithService:sharedInstance.serviceName error:&error];
        if (error) {
            MLCLog(@"Error: %@", error);
            error = nil;
        }
        MLCKeychainPasswordItem *item = items.firstObject;
        NSDictionary *credentials = (NSDictionary *)[item readDataOfClass:[NSDictionary class] error:&error];
        if (error) {
            MLCLog(@"Error: %@", error);
            error = nil;
        }

        if (credentials) {
            NSString *password = credentials[@"password"];
            NSString *childKeyword = credentials[@"childKeyword"];

            MLCUser *user = [MLCUser userWithUsername:item.account password:password];
            [sharedInstance setCurrentUser:user childKeyword:childKeyword];
        }
    });

    return sharedInstance;
}

static NSString *_apiKey = nil;
static NSString *_testingAPIKey = nil;

+ (void)setAPIKey:(NSString *)apiKey {
    @synchronized (self) {
        if (_apiKey != nil) {
            [[NSException exceptionWithName:MLCInvalidAPIKeyException reason:@"You can only set the API Key once." userInfo:nil] raise];
        }
        _apiKey = [apiKey copy];
    }
}

+ (NSString *)APIKey {
    @synchronized (self) {
        return [_apiKey copy];
    }
}

+ (void)setTestingAPIKey:(NSString *)apiKey {
    @synchronized (self) {
        if (_testingAPIKey != nil) {
            [[NSException exceptionWithName:MLCInvalidAPIKeyException reason:@"You can only set the testing API Key once." userInfo:nil] raise];
        }
        _testingAPIKey = [apiKey copy];
    }
}

static MLCServiceManagerConfiguration *_configuration = nil;

+ (void)setConfiguration:(MLCServiceManagerConfiguration *)configuration {
    @synchronized (self) {
        _configuration = configuration;
    }
}

+ (MLCServiceManagerConfiguration *)configuration {
    @synchronized (self) {
        return _configuration;
    }
}

+ (NSString *)testingAPIKey {
    @synchronized (self) {
        return [_testingAPIKey copy];
    }
}

+ (NSString *)currentAPIKey {
    @synchronized (self) {
        if (self.configuration) {
            return [self.configuration.apiKey copy];
        }
        if ([self isTestingEnabled]) {
            return [_testingAPIKey copy] ?: @"";
        }
        return [_apiKey copy] ?: @"";
    }
}

+ (BOOL)automaticallyNotifiesObserversOfCurrentToken {
    return NO;
}

- (NSString *)currentToken {
    return [self.authenticationToken.token copy];
}

- (void)setAuthenticationToken:(MLCAuthenticationToken *)authenticationToken {
    NSString *currentTokenKey = NSStringFromSelector(@selector(currentToken));
    @synchronized (self) {
        if (MLCServiceManager.isPersistentTokenEnabled) {
            NSDictionary *token = [MLCAuthenticationToken serialize:authenticationToken];
            [self willChangeValueForKey:currentTokenKey];
            [NSUserDefaults.standardUserDefaults setObject:token forKey:MLCServiceManagerPersistentTokenKey];
            [NSUserDefaults.standardUserDefaults synchronize];
            [self didChangeValueForKey:currentTokenKey];
        } else if (_authenticationToken != authenticationToken) {
            [self willChangeValueForKey:currentTokenKey];
            _authenticationToken = authenticationToken;
            [self didChangeValueForKey:currentTokenKey];
        }
    }
}

- (MLCAuthenticationToken *)authenticationToken {
    @synchronized (self) {
        if (MLCServiceManager.isPersistentTokenEnabled) {
            NSDictionary *token = [NSUserDefaults.standardUserDefaults dictionaryForKey:MLCServiceManagerPersistentTokenKey];
            return [[MLCAuthenticationToken alloc] initWithJSONObject:token];
        }
        return _authenticationToken;
    }
}

- (void)setCurrentUser:(MLCUser *)user remember:(BOOL)rememberCredentials {
    [self setCurrentUser:user childKeyword:self.childKeyword remember:rememberCredentials];
}

- (void)resetAuthenticationToken {
    __weak __typeof__(self) weakSelf = self;
    [self.authenticationQueue addOperationWithBlock:^{
        weakSelf.authenticationToken = nil;
    }];
}

- (void)setCurrentUser:(MLCUser *)user childKeyword:(NSString *)childKeyword {
    @synchronized (self) {
        self.currentUser = user;
        self.childKeyword = childKeyword ?: @"";
        [self resetAuthenticationToken];
    }
}

- (void)setCurrentUser:(MLCUser *)user childKeyword:(NSString *)childKeyword remember:(BOOL)rememberCredentials {
    @synchronized (self) {
        self.currentUser = user;
        self.childKeyword = childKeyword ?: @"";
        [self resetAuthenticationToken];
        NSString *username = user.username ?: @"";
        NSDictionary *credentials = @{@"password": user.password ?: @"", @"childKeyword": self.childKeyword};

        if (user.social || !rememberCredentials) {
            username = @"";
            credentials = @{};
        }

        NSError *error;
        NSArray *items = [MLCKeychainPasswordItem itemsWithService:self.serviceName error:&error];
        if (error) {
            MLCLog(@"Error: %@", error);
            error = nil;
        }
        for (MLCKeychainPasswordItem *item in items) {
            [MLCKeychainPasswordItem destroyItem:item error:&error];
            if (error) {
                MLCLog(@"Error: %@", error);
                error = nil;
            }
        }

        if (username.length && rememberCredentials) {
            MLCKeychainPasswordItem *item = [MLCKeychainPasswordItem itemWithService:self.serviceName account:username];
            [item saveData:credentials ofClass:[NSDictionary class] error:&error];
            if (error) {
                MLCLog(@"Error: %@", error);
                error = nil;
            }
        }
    }
}

+ (void)setTestingEnabled:(BOOL)testing {
    @synchronized (self) {
        [NSUserDefaults.standardUserDefaults setBool:testing forKey:MLCServiceManagerTestingEnabledKey];
        [NSUserDefaults.standardUserDefaults synchronize];

        if (self.currentAPIKey.length) {
            self.sharedServiceManager.authenticationToken = nil;
        }
    }
}

+ (BOOL)isTestingEnabled {
    @synchronized (self) {
        return [NSUserDefaults.standardUserDefaults boolForKey:MLCServiceManagerTestingEnabledKey];
    }
}

+ (void)setLogging:(MLCServiceManagerLogging)logging {
    @synchronized (self) {
        [NSUserDefaults.standardUserDefaults setInteger:logging forKey:MLCServiceManagerLoggingEnabledKey];
        [NSUserDefaults.standardUserDefaults synchronize];
    }
}

+ (MLCServiceManagerLogging)logging {
    @synchronized (self) {
        NSInteger logging = [NSUserDefaults.standardUserDefaults integerForKey:MLCServiceManagerLoggingEnabledKey];
        return (MLCServiceManagerLogging)logging;
    }
}

+ (void)setPlatformName:(NSString *)platformName {
    @synchronized (self) {
        [NSUserDefaults.standardUserDefaults setObject:platformName forKey:MLCServiceManagerPlatformNameKey];
        [NSUserDefaults.standardUserDefaults synchronize];
    }
}

+ (NSString *)platformName {
    @synchronized (self) {
        NSString *platformName = [NSUserDefaults.standardUserDefaults stringForKey:MLCServiceManagerPlatformNameKey];
#if TARGET_OS_IPHONE
        if (!platformName && UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone && ![UIDevice.currentDevice.model isEqualToString:@"iPhone"]) {
            platformName = @"iPhone";
        }
#endif
        return platformName;
    }
}

- (void)_authenticateRequest:(NSURLRequest *)request handler:(MLCServiceManagerAuthenticationCompletionHandler)handler {
    NSMutableURLRequest *authenticatedRequest = [request mutableCopy];
    MLCAuthenticationToken *currentToken = self.authenticationToken;

    if (currentToken.valid) {
        NSString *authToken = [NSString stringWithFormat:@"Token token=\"%@\"", currentToken.token];
        [authenticatedRequest setValue:authToken forHTTPHeaderField:@"Authorization"];
        handler(authenticatedRequest, nil);
    } else {
        MLCUser *user = self.currentUser;
        NSString *childKeyword = self.childKeyword;
        NSString *platformName = MLCServiceManager.platformName;
        NSString *apiKey = MLCServiceManager.currentAPIKey;
        MLCAuthenticationService *service = [MLCAuthenticationService authenticateAPIKey:apiKey user:user childKeyword:childKeyword platformName:platformName handler:^(MLCAuthenticationToken *newToken, NSError *error) {
            if (error) {
                MLCStatus *status = error.userInfo[@"status"];
                BOOL correctClass = [status isKindOfClass:[MLCStatus class]];
                BOOL correctStatusType = status.type == MLCStatusTypeInvalidUser;
                BOOL currentUserIsSet = user != nil;
                if (correctClass && correctStatusType && currentUserIsSet) {
                    [self setCurrentUser:nil childKeyword:self.childKeyword remember:YES];
                    MLCAuthenticationService *retryService = [MLCAuthenticationService authenticateAPIKey:apiKey user:nil childKeyword:childKeyword platformName:platformName handler:^(MLCAuthenticationToken *retryNewToken, NSError *retryError) {
                        if (retryError) {
                            handler(nil, retryError);
                        } else {
                            self.authenticationToken = retryNewToken;
                            NSString *authToken = [NSString stringWithFormat:@"Token token=\"%@\"", retryNewToken.token];
                            [authenticatedRequest setValue:authToken forHTTPHeaderField:@"Authorization"];
                            handler(authenticatedRequest, retryError);
                        }
                    }];
                    [retryService start];
                } else {
                    handler(nil, error);
                }
            } else {
                self.authenticationToken = newToken;
                NSString *authToken = [NSString stringWithFormat:@"Token token=\"%@\"", self.authenticationToken.token];
                [authenticatedRequest setValue:authToken forHTTPHeaderField:@"Authorization"];
                handler(authenticatedRequest, error);
            }
        }];
        [service start];
    }
}

- (void)authenticateRequest:(NSURLRequest *)request handler:(MLCServiceManagerAuthenticationCompletionHandler)handler {
    __weak __typeof__(self) weakSelf = self;
    [self.authenticationQueue addOperationWithBlock:^{
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf _authenticateRequest:request handler:^(NSURLRequest *_Nullable authenticatedRequest, NSError *_Nullable error) {
                handler(authenticatedRequest, error);
                dispatch_semaphore_signal(sema);
            }];
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }];
}

static BOOL _persistentTokenEnabled = NO;

+ (void)setPersistentTokenEnabled:(BOOL)persistToken {
    _persistentTokenEnabled = persistToken;
}

+ (BOOL)isPersistentTokenEnabled {
    return _persistentTokenEnabled;
}

+ (NSString *)host {
    if (self.configuration) {
        return [self.configuration.host copy];
    }
    if ([self isTestingEnabled]) {
        return @"moblicosandbox.com";
    }

    return @"moblico.net";
}

+ (NSString *)apiVersion {
    return @"v4";
}

#if SWIFT_PACKAGE
double MoblicoSDKVersionNumber = 2.0;
#else
FOUNDATION_EXPORT double MoblicoSDKVersionNumber;
#endif

+ (NSString *)sdkVersion {
    NSBundle *bundle = [NSBundle bundleForClass:[MLCServiceManager class]];
    return [bundle objectForInfoDictionaryKey:@"CFBundleVersion"] ?: @(MoblicoSDKVersionNumber).stringValue;
}

@end

@implementation MLCServiceManagerConfiguration

+ (instancetype)configurationWithAPIKey:(NSString *)apiKey {
    return [[self alloc] initWithHost:@"moblico.net" port:nil apiKey:apiKey sslDisabled:NO];
}

- (instancetype)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Use `- initWithHost:port:apiKey:secure:` instead" userInfo:nil];
}

- (instancetype)initWithHost:(NSString *)host port:(NSNumber *)port apiKey:(NSString *)apiKey sslDisabled:(BOOL)sslDisabled {
    self = [super init];
    if (self) {
        _host = host;
        _port = port;
        _apiKey = apiKey;
        _sslDisabled = sslDisabled;
    }
    return self;
}

@end
