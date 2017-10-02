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

#import "MLCServiceRequest.h"
#import "MLCServiceManager.h"
#import "MLCEntity_Private.h"

#if TARGET_OS_IPHONE
@import UIKit;
#endif

MLCServiceRequestHeaderKey const MLCServiceRequestHeaderKeyAccept = @"Accept";
MLCServiceRequestHeaderKey const MLCServiceRequestHeaderKeyContentType = @"Content-Type";
MLCServiceRequestHeaderKey const MLCServiceRequestHeaderKeyAuthorization = @"Authorization";
MLCServiceRequestHeaderKey const MLCServiceRequestHeaderKeyUserAgent = @"User-Agent";

MLCServiceRequestMethod const MLCServiceRequestMethodGET = @"GET";
MLCServiceRequestMethod const MLCServiceRequestMethodPOST = @"POST";
MLCServiceRequestMethod const MLCServiceRequestMethodPUT = @"PUT";
MLCServiceRequestMethod const MLCServiceRequestMethodDELETE = @"DELETE";

@interface MLCServiceRequest ()

@property (nonatomic, strong, readwrite) NSURL *URL;
@property (nonatomic, copy, readwrite) MLCServiceRequestMethod method;
@property (nonatomic, copy, readwrite) NSDictionary<NSString *, NSString *> *headers;
@property (nonatomic, copy, readwrite) NSData *body;
@property (nonatomic, copy, readwrite) NSURLRequest *URLRequest;
@property (nonatomic, copy, readonly, class) NSString *userAgent;
@end

@implementation MLCServiceRequest

+ (NSString *)userAgent {
    static NSString *userAgent = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *model;
        NSString *systemName;
        NSString *systemVersion;
        NSString *locale = NSLocale.currentLocale.localeIdentifier;

#if TARGET_OS_IPHONE
        model = UIDevice.currentDevice.model;
        systemName = UIDevice.currentDevice.systemName;
        systemVersion = UIDevice.currentDevice.systemVersion;
#else
        model = @"Macintosh";
        systemName = @"Mac OS X";
        systemVersion = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"][@"ProductVersion"];
#endif

        NSString *displayName = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        NSString *bundleName = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleName"];
        NSString *processName = NSProcessInfo.processInfo.processName;
        NSString *name = displayName ?: bundleName ?: processName;

        NSString *build = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleVersion"];
        NSString *version = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];

        NSString *sdkVersion = MLCServiceManager.sdkVersion;
        userAgent = [NSString stringWithFormat:@"%@/%@-%@ (%@; %@/%@; %@) SDK/%@", name, version, build, model, systemName, systemVersion, locale, sdkVersion];
    });

    return userAgent;
}

+ (NSArray *)queryItemsFromParameters:(NSDictionary *)parameters {
    if (parameters.count == 0) return nil;

    NSMutableArray *queryItems = [NSMutableArray arrayWithCapacity:parameters.count];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, __unused BOOL *stop) {
        NSString *value = obj;

        if ([obj isKindOfClass:[NSArray class]]) {
            value = [self serializeArray:obj];
        } else if ([obj isKindOfClass:[NSDictionary class]]) {
            value = [self serializeDictionary:obj];
        }

        value = [MLCEntity stringFromValue:value];
        NSString *name = [MLCEntity stringFromValue:key];
        NSURLQueryItem *item = [[NSURLQueryItem alloc] initWithName:name value:value];

        [queryItems addObject:item];
    }];

    return queryItems;
}

+ (NSString *)serializeArray:(NSArray *)array {
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:array.count];

    [array enumerateObjectsUsingBlock:^(id unescapedItem, __unused NSUInteger idx, __unused BOOL *stop) {
        id item = unescapedItem;

        if ([item isKindOfClass:[NSString class]]) {
            item = [self stringWithPercentEscapesAddedToString:item];
        }

        [items addObject:item];
    }];

    return [items componentsJoinedByString:@","];
}

+ (NSString *)serializeDictionary:(NSDictionary *)dictionary {
    NSMutableArray *keyValuePairs = [NSMutableArray arrayWithCapacity:dictionary.count];

    [dictionary enumerateKeysAndObjectsUsingBlock:^(id unescapedKey, id obj, __unused BOOL *stop) {
        id key = unescapedKey;
        id value = obj;

        if ([key isKindOfClass:[NSString class]]) {
            key = [self stringWithPercentEscapesAddedToString:key];
        }

        if ([value isKindOfClass:[NSString class]]) {
            value = [self stringWithPercentEscapesAddedToString:value];
        } else if ([value isKindOfClass:[NSArray class]]) {
            value = [self serializeArray:value];
        }

        NSString *keyValuePair = [@[key, value] componentsJoinedByString:@","];
        [keyValuePairs addObject:keyValuePair];
    }];

    return [keyValuePairs componentsJoinedByString:@";"];
}

+ (NSString *)stringWithPercentEscapesAddedToString:(NSString *)string {
    NSMutableCharacterSet *set = [NSCharacterSet.illegalCharacterSet.invertedSet mutableCopy];
    [set removeCharactersInString:@":/?#[]@!$ &'()*+,;=\"<>{}|\\^~`"];
    return [string stringByAddingPercentEncodingWithAllowedCharacters:set];
}

+ (BOOL)methodUsesBody:(MLCServiceRequestMethod)method {
    if ([method isEqualToString:MLCServiceRequestMethodGET] || [method isEqualToString:MLCServiceRequestMethodDELETE]) {
        return NO;
    }

    return YES;
}

+ (instancetype)requestWithMethod:(MLCServiceRequestMethod)method path:(NSString *)servicePath parameters:(NSDictionary *)parameters {
    MLCServiceRequest *request = [[MLCServiceRequest alloc] init];

    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    headers[MLCServiceRequestHeaderKeyAccept] = @"application/json";
    headers[MLCServiceRequestHeaderKeyUserAgent] = self.userAgent;

    request.method = method;

    NSString *path = [NSString pathWithComponents:@[@"/", @"services", MLCServiceManager.apiVersion, servicePath]];

    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = MLCServiceManager.isSSLDisabled ? @"http" : @"https";
    components.host = MLCServiceManager.host;
    components.path = path;
    components.queryItems = [self queryItemsFromParameters:parameters];

    if (components.query.length && [self methodUsesBody:method]) {
        headers[MLCServiceRequestHeaderKeyContentType] = @"application/x-www-form-urlencoded";
        request.body = [components.query dataUsingEncoding:NSUTF8StringEncoding];
        components.query = nil;
    }

    request.URL = components.URL;
    request.headers = headers;
    
    return request;
}

- (NSURLRequest *)URLRequest {
    if (!self.URL) {
        return nil;
    }
    
    if (!_URLRequest) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.URL];
        request.HTTPMethod = self.method;
        request.HTTPBody = self.body;
        [self.headers enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, __unused BOOL * _Nonnull stop) {
            [request setValue:obj forHTTPHeaderField:key];
        }];
        _URLRequest = [request copy];
    }
    return _URLRequest;
}

@end
