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

#import "MLCService.h"
#import "MLCService_Private.h"
#import "MLCServiceManager.h"

#import "MLCEntity.h"
#import "MLCEntity_Private.h"
#import "MLCStatus.h"
#import "version.h"

#import "MLCInvalidService.h"
#if TARGET_OS_IPHONE
@import UIKit;
#endif

static BOOL ALWAYS_USE_QUERY_PARAMS = YES;

@implementation MLCService

+ (NSArray *)scopeableResources {
    return nil;
}

+ (BOOL)canScopeResource:(id<MLCEntity>)resource {
    NSString *className = NSStringFromClass([resource class]);

    return [[self scopeableResources] containsObject:className];
}

+ (Class<MLCEntity>)classForResource {
    NSString *className = NSStringFromClass([self class]);
    className = [className stringByReplacingOccurrencesOfString:@"sService" withString:@""];
    Class classForResource = NSClassFromString(className);

    if (classForResource) {
        return classForResource;
    }

    [self doesNotRecognizeSelector:_cmd];

    return Nil;
}

- (void)start {
    if (self.connection) {
        [self cancel];
    }
    [MLCServiceManager.sharedServiceManager authenticateRequest:self.request handler:^(NSURLRequest *authenticatedRequest, NSError *error, NSHTTPURLResponse *response) {
        if (error) {
            self.jsonCompletionhandler(nil, error, response);
        } else {
            self.connection = [NSURLConnection connectionWithRequest:authenticatedRequest delegate:self];
#if TARGET_OS_IPHONE
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
#endif
            [self.connection start];
        }
    }];
}

- (void)cancel {
    NSLog(@"Service Canceled: %@", self);
    [self.connection cancel];
    self.connection = nil;
}

+ (instancetype)serviceForMethod:(MLCServiceRequestMethod)method path:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceJSONCompletionHandler)handler {
    MLCService *service = [[[self class] alloc] init];
    service.jsonCompletionhandler = handler;
    service.request = [self requestWithMethod:method path:path parameters:parameters];

    return service;
}

+ (instancetype)createResource:(id<MLCEntity>)resource handler:(MLCServiceStatusCompletionHandler)handler {
    return [self create:[resource collectionName] parameters:[resource serialize] handler:handler];
}

+ (instancetype)create:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceStatusCompletionHandler)handler {
    return [self serviceForMethod:MLCServiceRequestMethodPOST
                             path:path
                       parameters:parameters
                          handler:^(id jsonObject, NSError *error, NSHTTPURLResponse *response) {
							  if (handler) {
								  handler([MLCStatus deserialize:jsonObject], error, response);
							  }
                          }];
}

+ (instancetype)updateResource:(id<MLCEntity>)resource handler:(MLCServiceStatusCompletionHandler)handler {
    NSString *path = [[resource collectionName] stringByAppendingPathComponent:[resource uniqueIdentifier]];
    NSMutableDictionary *serializedObject = [[resource serialize] mutableCopy];
    [serializedObject removeObjectForKey:[[resource class] uniqueIdentifierKey]];

    return [self update:path parameters:serializedObject handler:handler];
}

+ (instancetype)update:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceStatusCompletionHandler)handler {
    return [self serviceForMethod:MLCServiceRequestMethodPUT
                             path:path
                       parameters:parameters
                          handler:^(id jsonObject, NSError *error, NSHTTPURLResponse *response) {
                              NSLog(@"received jsonObject: %@", jsonObject);
                              handler([MLCStatus deserialize:jsonObject], error, response);
                          }];
}

+ (instancetype)destroyResource:(id<MLCEntity>)resource handler:(MLCServiceStatusCompletionHandler)handler {
    NSString *path = [[resource collectionName] stringByAppendingPathComponent:[resource uniqueIdentifier]];

    return [self destroy:path parameters:nil handler:handler];
}

+ (instancetype)destroy:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceStatusCompletionHandler)handler {
    return [self serviceForMethod:MLCServiceRequestMethodDELETE
                             path:path
                       parameters:parameters
                          handler:^(id jsonObject, NSError *error, NSHTTPURLResponse *response) {
                              handler([MLCStatus deserialize:jsonObject], error, response);
                          }];
}

+ (instancetype)readResourceWithUniqueIdentifier:(id)uniqueIdentifierObject handler:(MLCServiceResourceCompletionHandler)handler {
    NSString *uniqueIdentifier = [MLCEntity stringFromValue:uniqueIdentifierObject];

    if (![uniqueIdentifier length]) {
        NSString *description = [NSString stringWithFormat:NSLocalizedString(@"Missing %@", nil), [[self classForResource] uniqueIdentifierKey]];
        NSError *error = [NSError errorWithDomain:@"MLCServiceErrorDomain" code:1001 userInfo:@{NSLocalizedDescriptionKey: description}];

        return (MLCService *)[MLCInvalidService invalidServiceWithError:error handler:handler];
    }
    NSString *path = [[[self classForResource] collectionName] stringByAppendingPathComponent:uniqueIdentifier];

    return [self read:path parameters:nil handler:handler];
}

+ (instancetype)read:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceResourceCompletionHandler)handler {
    return [self serviceForMethod:MLCServiceRequestMethodGET
                             path:path
                       parameters:parameters
                          handler:^(id jsonObject, NSError *error, NSHTTPURLResponse *response) {
                              dispatch_queue_t currentQueue = dispatch_get_main_queue();
                              dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                  id <MLCEntity> resource = [self deserializeResource:jsonObject];
                                  dispatch_async(currentQueue, ^{
                                      handler(resource, error, response);
                                  });
                              });
                          }];
}

+ (instancetype)listScopedResourcesForResource:(id<MLCEntity>)resource handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self findScopedResourcesForResource:resource searchParameters:nil handler:handler];
}

+ (instancetype)listResources:(MLCServiceCollectionCompletionHandler)handler {
    return [self findResourcesWithSearchParameters:nil handler:handler];
}

+ (instancetype)list:(NSString *)path handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self find:path searchParameters:nil handler:handler];
}

+ (instancetype)findScopedResourcesForResource:(id<MLCEntity>)resource searchParameters:(NSDictionary *)searchParameters handler:(MLCServiceCollectionCompletionHandler)handler {
    if ([self canScopeResource:resource] == NO) {
        NSString *failureReason = [NSString stringWithFormat:NSLocalizedString(@"%@ do not have %@", nil), [[self classForResource] collectionName], [resource collectionName]];
        NSString *description = [NSString stringWithFormat:NSLocalizedString(@"Invalid scope for %@", nil), [[self classForResource] collectionName]];
        NSError *error = [NSError errorWithDomain:@"MLCServiceErrorDomain" code:1000 userInfo:@{NSLocalizedDescriptionKey: description, NSLocalizedFailureReasonErrorKey: failureReason}];
        return (MLCService *)[MLCInvalidService invalidServiceWithError:error handler:handler];
    }

    NSString *path = [NSString pathWithComponents:@[[resource collectionName], [resource uniqueIdentifier], [[self classForResource] collectionName]]];

    return [self find:path searchParameters:searchParameters handler:handler];
}

+ (instancetype)findResourcesWithSearchParameters:(NSDictionary *)searchParameters handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self find:[[self classForResource] collectionName] searchParameters:searchParameters handler:handler];
}

+ (instancetype)find:(NSString *)path searchParameters:(NSDictionary *)searchParameters handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self serviceForMethod:MLCServiceRequestMethodGET
                             path:path
                       parameters:searchParameters
                          handler:^(id jsonObject, NSError *error, NSHTTPURLResponse *response) {
                              NSInteger httpStatus = [error.userInfo[@"status"] httpStatus];

                              if (httpStatus == 404) {
                                  handler(@[], nil, response);
                              } else {
                                  dispatch_queue_t currentQueue = dispatch_get_main_queue();
                                  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                      NSArray *array = [self deserializeArray:jsonObject];
                                      dispatch_async(currentQueue, ^{
                                          handler(array, error, response);
                                      });
                                  });
                              }
                          }];
}

+ (id <MLCEntity>)deserializeResource:(NSDictionary *)resource {
    if ([self classForResource]) {
        return [[self classForResource] deserialize:resource];
    }

    if (resource[@"status"]) {
        return [MLCStatus deserialize:resource[@"status"]];
    }

    return nil;
}

+ (NSArray *)deserializeArray:(NSArray *)array {
    if (![array isKindOfClass:[NSArray class]]) return nil;

    NSMutableArray *deserializedArray = [NSMutableArray arrayWithCapacity:[array count]];

    [array enumerateObjectsUsingBlock:^(id obj, __unused NSUInteger idx, __unused BOOL *stop) {
        id resource = [self deserializeResource:obj];
        if (resource) [deserializedArray addObject:resource];
    }];

    return [deserializedArray copy];
}

+ (NSString *)stringWithPercentEscapesAddedToString:(NSString *)string {
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(nil, (__bridge CFStringRef)(string), NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>{}|\\^~`"), kCFStringEncodingUTF8);
}

+ (NSString *)serializeArray:(NSArray *)array {
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:[array count]];

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
    NSMutableArray *keyValuePairs = [NSMutableArray arrayWithCapacity:[dictionary count]];

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

+ (NSString *)serializeParameters:(NSDictionary *)parameters {
    if ([parameters count] == 0) return nil;

    NSMutableArray *queryParams = [NSMutableArray arrayWithCapacity:[parameters count]];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, __unused BOOL *stop) {
        id value = obj;

        if ([obj isKindOfClass:[NSArray class]]) {
            value = [self serializeArray:obj];
        } else if ([obj isKindOfClass:[NSDictionary class]]) {
            value = [self serializeDictionary:obj];
        } else if ([obj isKindOfClass:[NSString class]]) {
            value = [self stringWithPercentEscapesAddedToString:value];
        }

        [queryParams addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
    }];

    return [queryParams componentsJoinedByString:@"&"];
}

//+ (NSString *)apiVersion {
//    return [MLCServiceManager apiVersion];
//}

+ (NSURLRequest *)requestWithMethod:(MLCServiceRequestMethod)method path:(NSString *)servicePath parameters:(NSDictionary *)parameters {
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];

    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[request setHTTPMethod:[self stringFromMLCServiceRequestMethod:method]];

    NSString *path = [NSString pathWithComponents:@[@"/", @"services", [MLCServiceManager apiVersion], servicePath]];

    NSURL *requestURL = [[NSURL alloc] initWithScheme:([MLCServiceManager isSSLDisabled] ? @"http" : @"https") host:[MLCServiceManager host] path:path];

    NSString *parameterString = [self serializeParameters:parameters];

    if (parameterString) {
        if (ALWAYS_USE_QUERY_PARAMS || method == MLCServiceRequestMethodGET || method == MLCServiceRequestMethodDELETE) {
            NSMutableString *urlString = [[requestURL absoluteString] mutableCopy];
            [urlString appendFormat:@"?%@", parameterString];
            requestURL = [NSURL URLWithString:urlString];
        } else {
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
            NSData *formData = [NSData dataWithBytes:[parameterString UTF8String] length:[parameterString length]];
            [request setHTTPBody:formData];
        }
    }

	[request setURL:requestURL];
    [request setValue:[self userAgent] forHTTPHeaderField:@"User-Agent"];

	return request;
}

+ (NSString *)stringFromMLCServiceRequestMethod:(MLCServiceRequestMethod)method {
	switch (method) {
		case MLCServiceRequestMethodGET:
        return @"GET";
		case MLCServiceRequestMethodPOST:
        return @"POST";
		case MLCServiceRequestMethodPUT:
        return @"PUT";
		case MLCServiceRequestMethodDELETE:
        return @"DELETE";
	}

	return nil;
}

- (NSMutableData *)receivedData {
    if (!_receivedData) {
        self.receivedData = [[NSMutableData alloc] init];
    }

    return _receivedData;
}

+ (NSString *)userAgent {
	@synchronized (self) {
        static NSString *userAgent = nil;

        if (userAgent) return userAgent;

        NSString *model;
        NSString *systemName;
        NSString *systemVersion;
        NSString *locale = [[NSLocale currentLocale] localeIdentifier];

#if TARGET_OS_IPHONE
        model = [[UIDevice currentDevice] model];
        systemName = [[UIDevice currentDevice] systemName];
        systemVersion = [[UIDevice currentDevice] systemVersion];
#else
        model = @"Macintosh";
        systemName = @"Mac OS X";
        systemVersion = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"][@"ProductVersion"];
#endif

        NSString *appName = @"MoblicoSDK";
        NSString *appVersion = @(MOBLICO_SDK_VERSION_STRING);
        userAgent = [NSString stringWithFormat:@"%@ %@ (%@; %@ %@; %@)", appName, appVersion, model, systemName, systemVersion, locale];

		return userAgent;
	}
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(__unused NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.httpResponse = (NSHTTPURLResponse *)response;
	[self.receivedData setLength:0];
}

- (void)connection:(__unused NSURLConnection *)connection didReceiveData:(NSData *)data {
	[self.receivedData appendData:data];
}

- (void)connection:(__unused NSURLConnection *)connection didFailWithError:(NSError *)error {
#if TARGET_OS_IPHONE
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
#endif
    if ([MLCServiceManager isLoggingEnabled]) NSLog(@"connection:didFailWithError:%@", error);
    NSMutableDictionary *logDictionary = [NSMutableDictionary dictionary];
    if (self.request.URL) logDictionary[@"url"] = self.request.URL;
    if (self.request.HTTPMethod) logDictionary[@"method"] = self.request.HTTPMethod;
    if (self.request.allHTTPHeaderFields) logDictionary[@"requestHeader"] = self.request.allHTTPHeaderFields;
    if (self.httpResponse.allHeaderFields) logDictionary[@"responseHeaders"] = self.httpResponse.allHeaderFields;
    if (self.httpResponse.statusCode) {
        logDictionary[@"statusCode"] = @(self.httpResponse.statusCode);
        logDictionary[@"statusCodeString"] = [NSHTTPURLResponse localizedStringForStatusCode:self.httpResponse.statusCode];
    }
    if ([MLCServiceManager isLoggingEnabled]) NSLog(@"\n=====\n%@\n=====", logDictionary);

    self.jsonCompletionhandler(nil, error, self.httpResponse);
}

- (void)connectionDidFinishLoading:(__unused NSURLConnection *)connection {
#if TARGET_OS_IPHONE
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
#endif

    NSError *error;
    id jsonObject = nil;

    if ([self.receivedData length]) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wassign-enum"
        jsonObject = [NSJSONSerialization JSONObjectWithData:self.receivedData options:0 error:&error];
        #pragma clang diagnostic pop
    }

    if (error) {
        //        self.jsonCompletionhandler(nil, error, self.httpResponse);
        error = nil;
        jsonObject = nil;
    }

    NSMutableDictionary *logDictionary = [NSMutableDictionary dictionary];
    if (jsonObject) logDictionary[@"response"] = jsonObject;
    if (self.request.URL) logDictionary[@"url"] = self.request.URL;
    if (self.request.HTTPMethod) logDictionary[@"method"] = self.request.HTTPMethod;
    if (self.request.allHTTPHeaderFields) logDictionary[@"requestHeader"] = self.request.allHTTPHeaderFields;
    if (self.httpResponse.allHeaderFields) logDictionary[@"responseHeaders"] = self.httpResponse.allHeaderFields;
    if (self.httpResponse.statusCode) {
        logDictionary[@"statusCode"] = @(self.httpResponse.statusCode);
        logDictionary[@"statusCodeString"] = [NSHTTPURLResponse localizedStringForStatusCode:self.httpResponse.statusCode];
    }
    if ([MLCServiceManager isLoggingEnabled]) NSLog(@"\n=====\n%@\n=====", logDictionary);
    if ([jsonObject isKindOfClass:[NSDictionary class]] && jsonObject[@"status"]) {
        NSDictionary *statusDictionary = jsonObject[@"status"];
        MLCStatus *status = [MLCStatus deserialize:statusDictionary];
        NSError *statusError = [NSError errorWithDomain:MLCStatusErrorDomain code:status.type userInfo:@{NSLocalizedDescriptionKey: status.message, @"status": status}];
        self.jsonCompletionhandler(nil, statusError, self.httpResponse);
    } else {
        self.jsonCompletionhandler(jsonObject, error, self.httpResponse);
    }
 	self.receivedData = nil;
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    if ([MLCServiceManager isLoggingEnabled]) NSLog(@"connection: %@ canAuthenticateAgainstProtectionSpace: %@", connection, protectionSpace);
    
	return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([MLCServiceManager isLoggingEnabled]) NSLog(@"connection: %@ didReceiveAuthenticationChallenge: %@", connection, challenge);
	if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust] &&
        [challenge.protectionSpace.host isEqualToString:[MLCServiceManager host]] &&
        [MLCServiceManager isTestingEnabled]) {
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        [challenge.sender useCredential:credential
             forAuthenticationChallenge:challenge];
    }
    
	[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}
    
    @end
