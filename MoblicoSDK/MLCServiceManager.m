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
#import "MLCUsersService.h"
#import "version.h"

NSString *const MLCInvalidAPIKeyException = @"MLCInvalidAPIKeyException";
static NSString *const MLCServiceManagerTestingEnabledKey = @"MLCServiceManagerTestingEnabled";
static NSString *const MLCServiceManagerLocalhostEnabledKey = @"MLCServiceManagerLocalhostEnabled";
static NSString *const MLCServiceManagerLoggingEnabledKey = @"MLCServiceManagerLoggingEnabled";
static NSString *const MLCServiceManagerSSLDisabledKey = @"MLCServiceManagerSSLDisabled";

@interface MLCServiceManager ()

@property (atomic, strong) MLCAuthenticationToken *authenticationToken;
@property (atomic, readonly) NSMutableDictionary *keychainItemData;
@property (atomic, readonly) NSDictionary *genericPasswordQuery;
@property (atomic, readwrite, strong) MLCUser *currentUser;

@end

@implementation MLCServiceManager
@synthesize genericPasswordQuery = _genericPasswordQuery;
@synthesize keychainItemData = _keychainItemData;
@synthesize currentUser = _currentUser;

+ (MLCServiceManager *)sharedServiceManager {
    if ([MLCServiceManager apiKey] == nil) {
        [[NSException exceptionWithName:MLCInvalidAPIKeyException reason:@"You must set your API key before getting an instance of the ServiceManager." userInfo:nil] raise];
    }
	static MLCServiceManager *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[MLCServiceManager alloc] init];
        NSString *username = sharedInstance.keychainItemData[(__bridge id)kSecAttrAccount];
        NSString *password = sharedInstance.keychainItemData[(__bridge id)kSecValueData];

        if ([username length]) {
            [sharedInstance setCurrentUser:[MLCUser userWithUsername:username password:password] remember:YES];
        }
	});

	return sharedInstance;
}

static NSString *_apiKey = nil;
static NSString *_testingAPIKey = nil;

+ (void)setAPIKey:(NSString *)apiKey {
	@synchronized(self) {
        if (_apiKey != nil) {
            [[NSException exceptionWithName:MLCInvalidAPIKeyException reason:@"You can only set the API Key once." userInfo:nil] raise];
        }
		_apiKey = [apiKey copy];
	}
}

+ (void)setTestingAPIKey:(NSString *)apiKey {
    @synchronized(self) {
        if (_testingAPIKey != nil) {
            [[NSException exceptionWithName:MLCInvalidAPIKeyException reason:@"You can only set the testing API Key once." userInfo:nil] raise];
        }
        _testingAPIKey = [apiKey copy];
    }
}

+ (NSString *)apiKey {
    @synchronized(self) {
        if ([self isTestingEnabled]) {
            return _testingAPIKey;
        }
        return _apiKey;
    }
}

//- (void)processUser:(MLCUser *)user {
//    NSLog(@"processUser: %@", user);
//    if (user) {
//        [[MLCUsersService readUser:user handler:^(id<MLCEntity> resource, __unused NSError *error, __unused NSHTTPURLResponse *response) {
//            if (resource) {
//                NSLog(@"resource: %@", resource);
////                self.currentUser = resource;
//            } else {
////                [self setCurrentUser:nil remember:YES];
//            }
//        }] start];
//    }
//}

- (void)setCurrentUser:(MLCUser *)user remember:(BOOL)rememberCredentials {
    @synchronized(self) {
        self.currentUser = user;
        self.authenticationToken = nil;
        NSString *username = user.username;
        NSString *password = user.password;

        if (user.socialType != MLCUserSocialTypeNone || !rememberCredentials) {
            username = nil;
            password = nil;
        }
        self.keychainItemData[(__bridge id)kSecAttrAccount] = username ? username : @"";
        self.keychainItemData[(__bridge id)kSecValueData] = password ? password : @"";

        [self writeToKeychain];
    }
}

//static BOOL _testing = nil;

+ (void)setTestingEnabled:(BOOL)testing {
    @synchronized(self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:testing forKey:MLCServiceManagerTestingEnabledKey];
        [defaults synchronize];

        if ([[self apiKey] length]) {
            [[self sharedServiceManager] setAuthenticationToken:nil];
        }
    }
}

+ (BOOL)isTestingEnabled {
    @synchronized(self) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:MLCServiceManagerTestingEnabledKey];
    }
}

//static BOOL _logging = nil;

+ (void)setLoggineEnabled:(BOOL)logging {
    [self setLoggingEnabled:logging];
}

+ (void)setLoggingEnabled:(BOOL)logging {
    @synchronized(self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:logging forKey:MLCServiceManagerLoggingEnabledKey];
        [defaults synchronize];
    }
}

+ (BOOL)isLoggingEnabled {
    @synchronized(self) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:MLCServiceManagerLoggingEnabledKey];
    }
}

- (void)authenticateRequest:(NSURLRequest *)request handler:(MLCServiceManagerAuthenticationCompletionHandler)handler {
    NSMutableURLRequest *authenticatedRequest = [request mutableCopy];
    MLCAuthenticationToken *currentToken = self.authenticationToken;

    if ([currentToken isValid]) {
        NSString *authToken = [NSString stringWithFormat:@"Token token=\"%@\"", currentToken.token];
        [authenticatedRequest setValue:authToken forHTTPHeaderField:@"Authorization"];
        handler(authenticatedRequest, nil, nil);
    } else {
        MLCAuthenticationService *service = [MLCAuthenticationService authenticateWithAPIKey:[[self class] apiKey] user:self.currentUser handler:^(MLCAuthenticationToken *newToken, NSError *error, NSHTTPURLResponse *response) {
            if (error) {
                handler(nil, error, response);
            } else {
                self.authenticationToken = newToken;
                NSString *authToken = [NSString stringWithFormat:@"Token token=\"%@\"", self.authenticationToken.token];
                [authenticatedRequest setValue:authToken forHTTPHeaderField:@"Authorization"];
                handler(authenticatedRequest, error, response);
//                if (self.currentUser) {
//                    [self performSelectorInBackground:@selector(processUser:) withObject:self.currentUser];
//                }
            }
        }];
        [service start];
    }
}

//static BOOL _sslDisabled = nil;

+ (void)setSSLDisabled:(BOOL)disabled {
    @synchronized(self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:disabled forKey:MLCServiceManagerSSLDisabledKey];
        [defaults synchronize];
    }
}

+ (BOOL)isSSLDisabled {
    @synchronized(self) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:MLCServiceManagerSSLDisabledKey];
    }
}

+ (NSString *)host {
    if ([self isTestingEnabled]) {
        return @"moblicosandbox.com";
    }

    return @"moblico.net";
}

+ (NSString *)apiVersion {
    return @"v4";
}

+ (NSString *)sdkVersion {
    return @(MOBLICO_SDK_VERSION_STRING);
}

- (NSDictionary *)genericPasswordQuery {
    @synchronized(self) {
        if (!_genericPasswordQuery) {
            _genericPasswordQuery = [@{(__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                                       (__bridge id)kSecAttrService: @"com.moblico.SDK.credentials",
                                       (__bridge id)kSecAttrGeneric: @"com.moblico.SDK.credentials",
                                       (__bridge id)kSecAttrAccessible: (__bridge id)kSecAttrAccessibleAlways,
                                       (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitOne,
                                       (__bridge id)kSecReturnAttributes: (__bridge id)kCFBooleanTrue} mutableCopy];
        }

        return _genericPasswordQuery;
    }
}

- (NSMutableDictionary *)keychainItemData {
    @synchronized(self) {
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
                                   (__bridge id)kSecValueData: @"",
                                   (__bridge id)kSecAttrAccessible: (__bridge id)kSecAttrAccessibleAlways,
                                   (__bridge id)kSecAttrService: @"com.moblico.SDK.credentials",
                                   (__bridge id)kSecAttrGeneric: self.genericPasswordQuery[(__bridge id)kSecAttrGeneric]} mutableCopy];

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
    NSString *passwordString = dictionaryToConvert[(__bridge id)kSecValueData];
    returnDictionary[(__bridge id)kSecValueData] = [passwordString dataUsingEncoding:NSUTF8StringEncoding];

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
        NSString *password = [[NSString alloc] initWithBytes:[(__bridge NSData *)passwordData bytes] length:[(__bridge NSData *)passwordData length]
                                                    encoding:NSUTF8StringEncoding];
        returnDictionary[(__bridge id)kSecValueData] = password;
    } else {
        // Don't do anything if nothing is found.
        NSAssert(NO, @"Serious error, no matching item found in the keychain.\n");
    }

	if (passwordData) CFRelease(passwordData);
    
	return returnDictionary;
}

- (void)writeToKeychain {    
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
		NSAssert( result == noErr, @"Couldn't update the Keychain Item. %@", @(result));
    } else {
        // No previous item found; add the new one.
        result = SecItemAdd((__bridge CFDictionaryRef)[self dictionaryToSecItemFormat:self.keychainItemData], NULL);
        NSAssert( result == noErr, @"Couldn't add the Keychain Item. %@", @(result));
    }
	
	if (attributes) CFRelease(attributes);
}

#pragma mark -
#pragma mark Deprecated

- (NSString *)username {
    return self.currentUser.username;
}

- (NSString *)password {
    return self.currentUser.password;
}

- (void)setUsername:(NSString *)username password:(NSString *)password remember:(BOOL)rememberCredentials {
    MLCUser *user = [MLCUser userWithUsername:username password:password];
    [self setCurrentUser:user remember:rememberCredentials];
}

@end
