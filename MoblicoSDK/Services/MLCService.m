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
#import "MLCLogger.h"

#if TARGET_OS_IPHONE
@import UIKit;
#endif

//static BOOL ALWAYS_USE_QUERY_PARAMS = NO;

@implementation MLCService

+ (NSArray<MLCEntityProtocol> *)scopeableResources {
    return [[NSArray<MLCEntityProtocol> alloc] init];
}

+ (BOOL)canScopeResource:(id<MLCEntityProtocol>)resource {
    NSString *className = NSStringFromClass([resource class]);

    return [[self scopeableResources] containsObject:className];
}

+ (Class<MLCEntityProtocol>)classForResource {
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
            self.request = authenticatedRequest;
            self.connection = [NSURLConnection connectionWithRequest:authenticatedRequest delegate:self];
#if TARGET_OS_IPHONE
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
#endif
            [self.connection start];
        }
    }];
}

- (void)cancel {
    [self.connection cancel];
    self.connection = nil;
}

+ (instancetype)serviceForMethod:(MLCServiceRequestMethod)method path:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceJSONCompletionHandler)handler {
    MLCService *service = [[[self class] alloc] init];
    service.jsonCompletionhandler = handler;
    service.request = [self requestWithMethod:method path:path parameters:parameters];

    return service;
}

+ (instancetype)createResource:(id<MLCEntityProtocol>)resource handler:(MLCServiceResourceCompletionHandler)handler {
    return [self create:[[resource class] collectionName] parameters:[[resource class] serialize:resource] handler:handler];
}

+ (instancetype)create:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceResourceCompletionHandler)handler {
    return [self serviceForMethod:MLCServiceRequestMethodPOST
                             path:path
                       parameters:parameters
                          handler:^(id jsonObject, NSError *error, NSHTTPURLResponse *response) {

							  if (handler) {
//								  handler([[MLCStatus alloc] initWithJSONObject:jsonObject], error, response);
                                  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                      id<MLCEntityProtocol> resource = [self deserializeResource:jsonObject];
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          handler(resource, error, response);
                                      });
                                  });
							  }
                          }];
}

+ (instancetype)updateResource:(id<MLCEntityProtocol>)resource handler:(MLCServiceSuccessCompletionHandler)handler {
    NSString *path = [[[resource class] collectionName] stringByAppendingPathComponent:resource.uniqueIdentifier];
    NSMutableDictionary *serializedObject = [[[resource class] serialize:resource] mutableCopy];
    [serializedObject removeObjectForKey:[[resource class] uniqueIdentifierKey]];

    return [self update:path parameters:serializedObject handler:handler];
}

+ (instancetype)update:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceSuccessCompletionHandler)handler {
    return [self serviceForMethod:MLCServiceRequestMethodPUT
                             path:path
                       parameters:parameters
                          handler:^(id jsonObject, NSError *error, NSHTTPURLResponse *response) {

                              if (handler) {
                                  BOOL success;
                                  MLCStatus *status = [[MLCStatus alloc] initWithJSONObject:jsonObject];
                                  if (status) {
                                      success = status.type == MLCStatusTypeSuccess;
                                  }
                                  else {
                                      success = (response.statusCode >= 200 && response.statusCode < 300 && error == nil);
                                  }
                                  handler(success, error, response);
                              }

                          }];
}

+ (instancetype)destroyResource:(id<MLCEntityProtocol>)resource handler:(MLCServiceSuccessCompletionHandler)handler {
    NSString *path = [[[resource class] collectionName] stringByAppendingPathComponent:resource.uniqueIdentifier];

    return [self destroy:path parameters:nil handler:handler];
}

+ (instancetype)destroy:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceSuccessCompletionHandler)handler {
    return [self serviceForMethod:MLCServiceRequestMethodDELETE
                             path:path
                       parameters:parameters
                          handler:^(id jsonObject, NSError *error, NSHTTPURLResponse *response) {
                              if (handler) {
                                  BOOL success;
                                  MLCStatus *status = [[MLCStatus alloc] initWithJSONObject:jsonObject];
                                  if (status) {
                                      success = status.type == MLCStatusTypeSuccess;
                                  }
                                  else {
                                      success = (response.statusCode >= 200 && response.statusCode < 300 && error == nil);
                                  }
                                  handler(success, error, response);
                              }
                          }];
}

+ (instancetype)readResourceWithUniqueIdentifier:(id)uniqueIdentifierObject handler:(MLCServiceResourceCompletionHandler)handler {
    NSString *uniqueIdentifier = [MLCEntity stringFromValue:uniqueIdentifierObject];

    if (!uniqueIdentifier.length) {
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
                              dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                  id<MLCEntityProtocol> resource = [self deserializeResource:jsonObject];
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      handler(resource, error, response);
                                  });
                              });
                          }];
}

+ (instancetype)listScopedResourcesForResource:(id<MLCEntityProtocol>)resource handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self findScopedResourcesForResource:resource searchParameters:nil handler:handler];
}

+ (instancetype)listResources:(MLCServiceCollectionCompletionHandler)handler {
    return [self findResourcesWithSearchParameters:nil handler:handler];
}

+ (instancetype)list:(NSString *)path handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self find:path searchParameters:nil handler:handler];
}

+ (instancetype)findScopedResourcesForResource:(id<MLCEntityProtocol>)resource searchParameters:(NSDictionary *)searchParameters handler:(MLCServiceCollectionCompletionHandler)handler {
    if ([self canScopeResource:resource] == NO) {
        NSString *failureReason = [NSString stringWithFormat:NSLocalizedString(@"%@ do not have %@", nil), [[self classForResource] collectionName], [[resource class] collectionName]];
        NSString *description = [NSString stringWithFormat:NSLocalizedString(@"Invalid scope for %@", nil), [[self classForResource] collectionName]];
        NSError *error = [NSError errorWithDomain:@"MLCServiceErrorDomain" code:1000 userInfo:@{NSLocalizedDescriptionKey: description, NSLocalizedFailureReasonErrorKey: failureReason}];
        return (MLCService *)[MLCInvalidService invalidServiceWithError:error handler:handler];
    }

    NSString *path = [NSString pathWithComponents:@[[[resource class] collectionName], resource.uniqueIdentifier, [[self classForResource] collectionName]]];

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
                                  handler([[NSArray<MLCEntityProtocol> alloc] init], nil, response);
                              } else {
                                  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                      NSArray<MLCEntityProtocol> *array = [self deserializeArray:jsonObject];
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          handler(array, error, response);
                                      });
                                  });
                              }
                          }];
}

+ (id<MLCEntityProtocol>)deserializeResource:(NSDictionary *)resource {
    Class EntityClass = [self classForResource];

    if (EntityClass) {
        return [[EntityClass alloc] initWithJSONObject:resource];
    }

    if (resource[@"status"]) {
        return [[MLCStatus alloc] initWithJSONObject:resource[@"status"]];
    }

    return nil;
}

+ (NSArray<MLCEntityProtocol> *)deserializeArray:(NSArray *)array {
    if (![array isKindOfClass:[NSArray class]]) return nil;

    NSMutableArray *deserializedArray = [NSMutableArray arrayWithCapacity:array.count];

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

+ (NSArray *)queryItemsFromParameters:(NSDictionary *)parameters {
    if (parameters.count == 0) return nil;

    NSMutableArray *queryItems = [NSMutableArray arrayWithCapacity:parameters.count];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
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

+ (NSString *)oldSerializeParameters:(NSDictionary *)parameters {
    if (parameters.count == 0) return nil;

    NSMutableArray *queryParams = [NSMutableArray arrayWithCapacity:parameters.count];
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
	request.HTTPMethod = [self stringFromMLCServiceRequestMethod:method];

    NSString *path = [NSString pathWithComponents:@[@"/", @"services", [MLCServiceManager apiVersion], servicePath]];

    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = [MLCServiceManager isSSLDisabled] ? @"http" : @"https";
    components.host = [MLCServiceManager host];
    components.path = path;
    components.queryItems = [self queryItemsFromParameters:parameters];
    BOOL alwaysUseQueryParams = [MLCServiceManager isForceQueryParametersEnabled];
    
    if (components.query.length && !(alwaysUseQueryParams || method == MLCServiceRequestMethodGET || method == MLCServiceRequestMethodDELETE)) {
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        request.HTTPBody = [components.query dataUsingEncoding:NSUTF8StringEncoding];
        components.query = nil;
    }

	request.URL = components.URL;
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
        NSString *locale = [NSLocale currentLocale].localeIdentifier;

#if TARGET_OS_IPHONE
        model = [UIDevice currentDevice].model;
        systemName = [UIDevice currentDevice].systemName;
        systemVersion = [UIDevice currentDevice].systemVersion;
#else
        model = @"Macintosh";
        systemName = @"Mac OS X";
        systemVersion = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"][@"ProductVersion"];
#endif

        NSString *appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
        NSString *appVersion = @(MOBLICO_SDK_VERSION_STRING);
        userAgent = [NSString stringWithFormat:@"%@ %@ (%@; %@ %@; %@)", appName, appVersion, model, systemName, systemVersion, locale];

		return userAgent;
	}
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(__unused NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.httpResponse = (NSHTTPURLResponse *)response;
	(self.receivedData).length = 0;
}

- (void)connection:(__unused NSURLConnection *)connection didReceiveData:(NSData *)data {
	[self.receivedData appendData:data];
}

- (void)connection:(__unused NSURLConnection *)connection didFailWithError:(NSError *)error {
#if TARGET_OS_IPHONE
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
#endif
    
    MLCLDebugLog(@"connection:didFailWithError:%@", error);
    NSMutableDictionary *logDictionary = [NSMutableDictionary dictionary];
    if (self.request.URL) logDictionary[@"url"] = self.request.URL;
    if (self.request.HTTPMethod) logDictionary[@"method"] = self.request.HTTPMethod;
    if (self.request.HTTPBody) logDictionary[@"body"] = [[NSString alloc] initWithData:self.request.HTTPBody encoding:NSUTF8StringEncoding];
    if (self.request.allHTTPHeaderFields) logDictionary[@"requestHeader"] = self.request.allHTTPHeaderFields;
    if (self.httpResponse.allHeaderFields) logDictionary[@"responseHeaders"] = self.httpResponse.allHeaderFields;
    if (self.httpResponse.statusCode) {
        logDictionary[@"statusCode"] = @(self.httpResponse.statusCode);
        logDictionary[@"statusCodeString"] = [NSHTTPURLResponse localizedStringForStatusCode:self.httpResponse.statusCode];
    }
    MLCLDebugLog(@"\n=====\n%@\n=====", logDictionary);

    self.jsonCompletionhandler(nil, error, self.httpResponse);
}

- (void)connectionDidFinishLoading:(__unused NSURLConnection *)connection {
#if TARGET_OS_IPHONE
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
#endif

    NSError *error;
    id jsonObject = nil;

    if ((self.receivedData).length) {
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
    if (self.request.HTTPBody) logDictionary[@"body"] = [[NSString alloc] initWithData:self.request.HTTPBody encoding:NSUTF8StringEncoding];
    if (self.request.allHTTPHeaderFields) logDictionary[@"requestHeader"] = self.request.allHTTPHeaderFields;
    if (self.httpResponse.allHeaderFields) logDictionary[@"responseHeaders"] = self.httpResponse.allHeaderFields;
    if (self.httpResponse.statusCode) {
        logDictionary[@"statusCode"] = @(self.httpResponse.statusCode);
        logDictionary[@"statusCodeString"] = [NSHTTPURLResponse localizedStringForStatusCode:self.httpResponse.statusCode];
    }

    MLCLDebugLog(@"connectionDidFinishLoading: %@", connection);
    MLCLDebugLog(@"\n=====\n%@\n=====", logDictionary);

    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *statusJSON = jsonObject[@"status"];
        if (statusJSON && [statusJSON isKindOfClass:[NSDictionary class]]) {
            MLCStatus *status = [[MLCStatus alloc] initWithJSONObject:statusJSON];
            if (status.type != MLCStatusTypeSuccess) {
                NSString *message = status.message;
                if (!message) {
                    message = @"Unknown Error";
                }
                NSError *statusError = [NSError errorWithDomain:MLCStatusErrorDomain code:status.type userInfo:@{NSLocalizedDescriptionKey:message, @"status": status}];
                self.jsonCompletionhandler(nil, statusError, self.httpResponse);
				self.receivedData = nil;
                return;
            }
        }
    }
//	Class EntityClass = [[self class] classForResource];
//	NSLog(@"connectionFinishedEntityClass: %@", EntityClass);

//	BOOL entityHasStatus = [EntityClass instancesRespondToSelector:NSSelectorFromString(@"status")];
//	NSLog(@"entityHasStatus: %@", entityHasStatus ? @"YES" : @"NO");
//    if (!entityHasStatus && [jsonObject isKindOfClass:[NSDictionary class]] && jsonObject[@"status"]) {
//        NSDictionary *statusDictionary = jsonObject[@"status"];
//        MLCStatus *status = [[MLCStatus alloc] initWithJSONObject:statusDictionary];
//        NSError *statusError = [NSError errorWithDomain:MLCStatusErrorDomain code:status.type userInfo:@{NSLocalizedDescriptionKey: status.message, @"status": status}];
//        self.jsonCompletionhandler(nil, statusError, self.httpResponse);
//    } else {
        self.jsonCompletionhandler(jsonObject, error, self.httpResponse);
		self.receivedData = nil;

//    }
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    MLCLDebugLog(@"connection: %@ canAuthenticateAgainstProtectionSpace: %@", connection, protectionSpace);
    
	return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    MLCLDebugLog(@"connection: %@ didReceiveAuthenticationChallenge: %@", connection, challenge);
	if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust] &&
        [challenge.protectionSpace.host isEqualToString:[MLCServiceManager host]] &&
        [MLCServiceManager isTestingEnabled]) {
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
    }
    
	[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (void)connection:(nonnull NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(nonnull NSURLAuthenticationChallenge *)challenge {
    MLCLDebugLog(@"connection: %@ willSendRequestForAuthenticationChallenge: %@", connection, challenge);
    MLCLDebugLog(@"challenge.protectionSpace: %@ challenge.proposedCredential: %@ challenge.previousFailureCount: %@ challenge.failureResponse: %@ challenge.error: %@ challenge.sender: %@", challenge.protectionSpace, challenge.proposedCredential, @(challenge.previousFailureCount), challenge.failureResponse, challenge.error, challenge.sender);

//    if ([MLCServiceManager isLoggingEnabled]) NSLog(@"challenge.sender: %@", challenge.sender);
    [challenge.sender performDefaultHandlingForAuthenticationChallenge:challenge];
//    return;
//    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust] &&
//        [challenge.protectionSpace.host isEqualToString:[MLCServiceManager host]] &&
//        [MLCServiceManager isTestingEnabled]) {
//
//        if ([challenge previousFailureCount] == 0) {
//            if ([MLCServiceManager isLoggingEnabled]) NSLog(@"Using credentials");
//            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
//            [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
//        }
//        else {
//            if ([MLCServiceManager isLoggingEnabled]) NSLog(@"Not using credentials");
//            [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
//        }
//    }
//    else {
//
//        if ([MLCServiceManager isLoggingEnabled]) NSLog(@"Default response");
//        [challenge.sender performDefaultHandlingForAuthenticationChallenge:challenge];
////        [[challenge sender] rejectProtectionSpaceAndContinueWithChallenge:challenge];
//    }
}

@end
