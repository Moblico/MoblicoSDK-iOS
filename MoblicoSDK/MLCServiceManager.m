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

NSString *const MLCInvalidAPIKeyException = @"MLCInvalidAPIKeyException";
static NSString *const MLCServiceManagerTestingEnabledKey = @"MLCServiceManagerTestingEnabled";
static NSString *const MLCServiceManagerLocalhostEnabledKey = @"MLCServiceManagerLocalhostEnabled";
static NSString *const MLCServiceManagerLoggingEnabledKey = @"MLCServiceManagerLoggingEnabled";
static NSString *const MLCServiceManagerSSLDisabledKey = @"MLCServiceManagerSSLDisabled";
static NSString *const MLCServiceManagerPersistentTokenKey = @"MLCServiceManagerPersistentToken";

@interface MLCServiceManager ()

@property (atomic, strong) MLCAuthenticationToken *authenticationToken;
@property (atomic, readonly) NSMutableDictionary *keychainItemData;
@property (atomic, readonly) NSDictionary *genericPasswordQuery;
@property (atomic, readwrite, strong) MLCUser *currentUser;
@property (atomic, readwrite, strong) NSString *childKeyword;
@property (atomic, readonly, strong) NSString *serviceName;
@property (atomic, readonly, strong) NSOperationQueue *authenticationQueue;
@end

@implementation MLCServiceManager {
    MLCAuthenticationToken *_authenticationToken;
    NSString *_serviceName;
    NSDictionary *_genericPasswordQuery;
    NSMutableDictionary *_keychainItemData;
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
            NSString *appName = NSBundle.mainBundle.infoDictionary[@"CFBundleName"];
            _serviceName = [@"com.moblico.SDK.credentials." stringByAppendingString:appName];
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
        NSString *username = sharedInstance.keychainItemData[(__bridge id)kSecAttrAccount];
        NSDictionary *credentials = sharedInstance.keychainItemData[(__bridge id)kSecValueData];

        if (username.length) {
            NSString *password = credentials[@"password"];
            NSString *childKeyword = credentials[@"childKeyword"];

            [sharedInstance setCurrentUser:[MLCUser userWithUsername:username password:password] childKeyword:childKeyword];
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

        SecItemDelete((__bridge CFDictionaryRef)self.genericPasswordQuery);
        self.keychainItemData[(__bridge id)kSecAttrAccount] = username;
        self.keychainItemData[(__bridge id)kSecValueData] = credentials;

        [self writeToKeychain];
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
        NSString *apiKey = [[self class] currentAPIKey];
        MLCAuthenticationService *service = [MLCAuthenticationService authenticateAPIKey:apiKey user:user childKeyword:childKeyword handler:^(MLCAuthenticationToken *newToken, NSError *error) {
            if (error) {
                MLCStatus *status = error.userInfo[@"status"];
                BOOL correctClass = [status isKindOfClass:[MLCStatus class]];
                BOOL correctStatusType = status.type == MLCStatusTypeInvalidUser;
                BOOL currentUserIsSet = user != nil;
                if (correctClass && correctStatusType && currentUserIsSet) {
                    [self setCurrentUser:nil childKeyword:self.childKeyword remember:YES];
                    MLCAuthenticationService *retryService = [MLCAuthenticationService authenticateAPIKey:apiKey user:nil childKeyword:childKeyword handler:^(MLCAuthenticationToken *retryNewToken, NSError *retryError) {
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

+ (void)setSSLDisabled:(BOOL)disabled {
    @synchronized (self) {
        [NSUserDefaults.standardUserDefaults setBool:disabled forKey:MLCServiceManagerSSLDisabledKey];
        [NSUserDefaults.standardUserDefaults synchronize];
    }
}

+ (BOOL)isSSLDisabled {
    @synchronized (self) {
        if (self.configuration) {
            return !self.configuration.secure;
        }

        return [NSUserDefaults.standardUserDefaults boolForKey:MLCServiceManagerSSLDisabledKey];
    }
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

FOUNDATION_EXPORT double MoblicoSDKVersionNumber;

+ (NSString *)sdkVersion {
    NSBundle *bundle = [NSBundle bundleForClass:[MLCServiceManager class]];
    return [bundle objectForInfoDictionaryKey:@"CFBundleVersion"] ?: @(MoblicoSDKVersionNumber).stringValue;
}

- (NSDictionary *)genericPasswordQuery {
    @synchronized (self) {
        if (!_genericPasswordQuery) {
            _genericPasswordQuery = [@{(__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                                       (__bridge id)kSecAttrService: self.serviceName,
                                       (__bridge id)kSecAttrGeneric: @"com.moblico.SDK.credentials",
                                       (__bridge id)kSecAttrAccessible: (__bridge id)kSecAttrAccessibleAfterFirstUnlock,
                                       (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitOne,
                                       (__bridge id)kSecReturnAttributes: (__bridge id)kCFBooleanTrue} mutableCopy];
        }

        return _genericPasswordQuery;
    }
}

- (NSMutableDictionary *)keychainItemData {
    @synchronized (self) {
        if (_keychainItemData) return _keychainItemData;

        NSDictionary *tempQuery = [NSDictionary dictionaryWithDictionary:self.genericPasswordQuery];

        CFMutableDictionaryRef outDictionary = NULL;

        OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)tempQuery, (CFTypeRef *)&outDictionary);

        if (status == noErr) {
            // load the saved data from Keychain.
            _keychainItemData = [self secItemFormatToDictionary:(__bridge NSDictionary *)outDictionary];
        } else {
            _keychainItemData = [@{(__bridge id)kSecAttrAccount: @"",
                                   (__bridge id)kSecAttrLabel: @"",
                                   (__bridge id)kSecAttrDescription: @"",
                                   (__bridge id)kSecValueData: @{},
                                   (__bridge id)kSecAttrAccessible: (__bridge id)kSecAttrAccessibleAfterFirstUnlock,
                                   (__bridge id)kSecAttrService: self.serviceName} mutableCopy];
            id attrGeneric = self.genericPasswordQuery[(__bridge id)kSecAttrGeneric];
            if (attrGeneric) {
                _keychainItemData[(__bridge id)kSecAttrGeneric] = attrGeneric;
            }
        }

        if (outDictionary) CFRelease(outDictionary);

        return _keychainItemData;
    }
}

- (NSMutableDictionary *)dictionaryToSecItemFormat:(NSDictionary *)dictionaryToConvert {
    // The assumption is that this method will be called with a properly populated dictionary
    // containing all the right key/value pairs for a SecItem.

    // Create a dictionary to return populated with the attributes and data.
    NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionaryToConvert];

    // Add the Generic Password keychain item class attribute.
    returnDictionary[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;

    // Convert the NSString to NSData to meet the requirements for the value type kSecValueData.
    // This is where to store sensitive data that should be encrypted.
    NSDictionary *credentials = dictionaryToConvert[(__bridge id)kSecValueData];
    returnDictionary[(__bridge id)kSecValueData] = [NSKeyedArchiver archivedDataWithRootObject:credentials requiringSecureCoding:NO error:nil];

    return returnDictionary;
}

- (NSMutableDictionary *)secItemFormatToDictionary:(NSDictionary *)dictionaryToConvert {
    // The assumption is that this method will be called with a properly populated dictionary
    // containing all the right key/value pairs for the UI element.

    // Create a dictionary to return populated with the attributes and data.
    NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionaryToConvert];

    // Add the proper search key and class attribute.
    returnDictionary[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
    returnDictionary[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;

    // Acquire the password data from the attributes.
    CFDataRef passwordData = NULL;

    if (SecItemCopyMatching((__bridge CFDictionaryRef)returnDictionary, (CFTypeRef *)&passwordData) == noErr) {
        // Remove the search, class, and identifier key/value, we don't need them anymore.
        [returnDictionary removeObjectForKey:(__bridge id)kSecReturnData];

        // Add the password to the dictionary, converting from NSData to NSString.
        NSData *data = (__bridge NSData *)passwordData;
        if (data != nil) {
            @try {
                returnDictionary[(__bridge id)kSecValueData] = (NSDictionary *)[NSKeyedUnarchiver unarchivedObjectOfClass:[NSDictionary class] fromData:data error:nil];
            }
            @catch (NSException *exception) {
                @throw exception;
            }
        }
    } else {
        // Don't do anything if nothing is found.
        NSAssert(NO, @"Serious error, no matching item found in the keychain.\n");
    }

    if (passwordData) CFRelease(passwordData);

    return returnDictionary;
}

- (BOOL)writeToKeychain {
    CFDictionaryRef attributes = NULL;
    NSMutableDictionary *updateItem = nil;
    OSStatus result;

    if (SecItemCopyMatching((__bridge CFDictionaryRef)self.genericPasswordQuery, (CFTypeRef *)&attributes) == noErr) {
        // First we need the attributes from the Keychain.
        updateItem = [NSMutableDictionary dictionaryWithDictionary:(__bridge NSDictionary *)attributes];
        // Second we need to add the appropriate search key/values.
        updateItem[(__bridge id)kSecClass] = self.genericPasswordQuery[(__bridge id)kSecClass];

        // Lastly, we need to set up the updated attribute list being careful to remove the class.
        NSMutableDictionary *tempCheck = [self dictionaryToSecItemFormat:self.keychainItemData];
        [tempCheck removeObjectForKey:(__bridge id)kSecClass];

        // An implicit assumption is that you can only update a single item at a time.

        result = SecItemUpdate((__bridge CFDictionaryRef)updateItem, (__bridge CFDictionaryRef)tempCheck);
        NSAssert(result == noErr, @"Couldn't update the Keychain Item. %@", @(result));
    } else {
        // No previous item found; add the new one.
        result = SecItemAdd((__bridge CFDictionaryRef)[self dictionaryToSecItemFormat:self.keychainItemData], NULL);
        NSAssert(result == noErr, @"Couldn't add the Keychain Item. %@", @(result));
    }

    if (attributes) CFRelease(attributes);

    return result == noErr;
}

@end

@implementation MLCServiceManagerConfiguration

+ (instancetype)configurationWithAPIKey:(NSString *)apiKey {
    return [[self alloc] initWithHost:@"moblico.net" port:nil apiKey:apiKey secure:YES];
}

- (instancetype)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Use `- initWithHost:port:apiKey:secure:` instead" userInfo:nil];
}

- (instancetype)initWithHost:(NSString *)host port:(NSNumber *)port apiKey:(NSString *)apiKey secure:(BOOL)secure {
    self = [super init];
    if (self) {
        _host = host;
        _port = port;
        _apiKey = apiKey;
        _secure = secure;
    }
    return self;
}

@end
