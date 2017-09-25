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

#import "MLCLogger.h"

#if TARGET_OS_IPHONE
@import UIKit;
#endif

NSErrorDomain const MLCServiceErrorDomain = @"MLCServiceErrorDomain";
NSErrorUserInfoKey const MLCServiceDetailedErrorsKey = @"MLCInvalidServiceDetailedErrorsKey";

@implementation MLCService

- (void)setDispatchGroup:(dispatch_group_t)dispatchGroup {
    if (_dispatchGroup) {
        dispatch_group_leave(_dispatchGroup);
    }

    if (dispatchGroup) {
        dispatch_group_enter(dispatchGroup);
    }

    _dispatchGroup = dispatchGroup;
}

+ (NSArray<Class> *)scopeableResources {
    return [[NSArray<Class> alloc] init];
}

+ (BOOL)canScopeResource:(MLCEntity *)resource {
    return [[self scopeableResources] containsObject:[resource class]];
}

+ (Class)classForResource {
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
    if (self.invalidServiceError) {
        if (self.invalidServiceSuccessCompletionHandler) {
            self.invalidServiceSuccessCompletionHandler(NO, self.invalidServiceError);
        }
        if (self.invalidServiceJsonCompletionHandler) {
            self.invalidServiceJsonCompletionHandler(nil, self.invalidServiceError);
        }
        self.dispatchGroup = nil;
        return;
    }

    if (self.connection) {
        [self cancel];
    }
    [MLCServiceManager.sharedServiceManager authenticateRequest:self.request handler:^(NSURLRequest *authenticatedRequest, NSError *error) {
        if (error) {
            self.jsonCompletionHandler(self, nil, error, nil);
        } else {
            self.request = authenticatedRequest;
            self.connection = [NSURLConnection connectionWithRequest:authenticatedRequest delegate:self];
#if TARGET_OS_IPHONE
            UIApplication.sharedApplication.networkActivityIndicatorVisible = YES;
#endif
            [self.connection start];
        }
    }];
}

- (void)cancel {
    [self.connection cancel];
    self.connection = nil;
}

+ (instancetype)serviceForMethod:(MLCServiceRequestMethod)method path:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceInternalJSONCompletionHandler)handler {
    MLCService *service = [[[self class] alloc] init];
    service.jsonCompletionHandler = handler;
    service.request = [self requestWithMethod:method path:path parameters:parameters];

    return service;
}

+ (instancetype)service:(MLCServiceRequestMethod)method path:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceJSONCompletionHandler)handler {
    return [self serviceForMethod:method
                             path:path
                       parameters:parameters
                          handler:^(MLCService *service, id jsonObject, NSError *error, __unused NSHTTPURLResponse *response) {
                              handler(jsonObject, error);
                              service.dispatchGroup = nil;
                          }];
}

+ (instancetype)createResource:(MLCEntity *)resource handler:(MLCServiceInternalResourceCompletionHandler)handler {
    return [self create:[[resource class] collectionName] parameters:[[resource class] serialize:resource] handler:handler];
}

+ (instancetype)create:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceInternalResourceCompletionHandler)handler {
    return [self serviceForMethod:MLCServiceRequestMethodPOST
                             path:path
                       parameters:parameters
                          handler:^(MLCService *service, id jsonObject, NSError *error, __unused NSHTTPURLResponse *response) {

                              if (handler) {
                                  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                      MLCEntity *resource = [[service class] deserializeResource:jsonObject];
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          handler(resource, error);
                                          service.dispatchGroup = nil;
                                      });
                                  });
                              } else {
                                  service.dispatchGroup = nil;
                              }
                          }];
}

+ (instancetype)createSuccessResource:(MLCEntity *)resource handler:(MLCServiceSuccessCompletionHandler)handler {
    return [self createSuccess:[[resource class] collectionName] parameters:[[resource class] serialize:resource] handler:handler];
}

+ (instancetype)createSuccess:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceSuccessCompletionHandler)handler {
    return [self serviceForMethod:MLCServiceRequestMethodPOST
                             path:path
                       parameters:parameters
                          handler:^(MLCService *service, id jsonObject, NSError *error, NSHTTPURLResponse *response) {
                              if (handler) {
                                  BOOL success;
                                  MLCStatus *status = [[MLCStatus alloc] initWithJSONObject:jsonObject];
                                  if (status) {
                                      success = status.type == MLCStatusTypeSuccess;
                                  } else {
                                      success = (response.statusCode >= 200 && response.statusCode < 300 && error == nil);
                                  }
                                  handler(success, error);
                                  service.dispatchGroup = nil;
                              } else {
                                  service.dispatchGroup = nil;
                              }
                          }];
}

+ (instancetype)updateResource:(MLCEntity *)resource handler:(MLCServiceSuccessCompletionHandler)handler {
    NSString *path = [[[resource class] collectionName] stringByAppendingPathComponent:resource.uniqueIdentifier];
    NSMutableDictionary *serializedObject = [[[resource class] serialize:resource] mutableCopy];
    [serializedObject removeObjectForKey:[[resource class] uniqueIdentifierKey]];

    return [self update:path parameters:serializedObject handler:handler];
}

+ (instancetype)update:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceSuccessCompletionHandler)handler {
    return [self serviceForMethod:MLCServiceRequestMethodPUT
                             path:path
                       parameters:parameters
                          handler:^(MLCService *service, id jsonObject, NSError *error, NSHTTPURLResponse *response) {

                              if (handler) {
                                  BOOL success;
                                  MLCStatus *status = [[MLCStatus alloc] initWithJSONObject:jsonObject];
                                  if (status) {
                                      success = status.type == MLCStatusTypeSuccess;
                                  } else {
                                      success = (response.statusCode >= 200 && response.statusCode < 300 && error == nil);
                                  }
                                  handler(success, error);
                                  service.dispatchGroup = nil;
                              } else {
                                  service.dispatchGroup = nil;
                              }
                          }];
}

+ (instancetype)destroyResource:(MLCEntity *)resource handler:(MLCServiceSuccessCompletionHandler)handler {
    NSString *path = [[[resource class] collectionName] stringByAppendingPathComponent:resource.uniqueIdentifier];

    return [self destroy:path parameters:nil handler:handler];
}

+ (instancetype)destroy:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceSuccessCompletionHandler)handler {
    return [self serviceForMethod:MLCServiceRequestMethodDELETE
                             path:path
                       parameters:parameters
                          handler:^(MLCService *service, id jsonObject, NSError *error, NSHTTPURLResponse *response) {
                              if (handler) {
                                  BOOL success;
                                  MLCStatus *status = [[MLCStatus alloc] initWithJSONObject:jsonObject];
                                  if (status) {
                                      success = status.type == MLCStatusTypeSuccess;
                                  } else {
                                      success = (response.statusCode >= 200 && response.statusCode < 300 && error == nil);
                                  }
                                  handler(success, error);
                                  service.dispatchGroup = nil;
                              } else {
                                  service.dispatchGroup = nil;
                              }
                          }];
}

+ (instancetype)readResourceWithUniqueIdentifier:(id)uniqueIdentifierObject handler:(MLCServiceInternalResourceCompletionHandler)handler {
    NSString *uniqueIdentifier = [MLCEntity stringFromValue:uniqueIdentifierObject];

    if (!uniqueIdentifier.length) {
        NSString *description = [NSString stringWithFormat:NSLocalizedString(@"Missing %@", nil), [[self classForResource] uniqueIdentifierKey]];
        MLCServiceError *error = [MLCServiceError missingParameterErrorWithDescription:description];
        return [self invalidServiceWithError:error handler:handler];
    }
    NSString *path = [[[self classForResource] collectionName] stringByAppendingPathComponent:uniqueIdentifier];

    return [self read:path parameters:nil handler:handler];
}

+ (instancetype)read:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceInternalResourceCompletionHandler)handler {
    return [self serviceForMethod:MLCServiceRequestMethodGET
                             path:path
                       parameters:parameters
                          handler:^(MLCService *service, id jsonObject, NSError *error, __unused NSHTTPURLResponse *response) {
                              dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                  MLCEntity *resource = [[service class] deserializeResource:jsonObject];
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      handler(resource, error);
                                      service.dispatchGroup = nil;
                                  });
                              });
                          }];
}

+ (instancetype)readSuccess:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceSuccessCompletionHandler)handler {
    return [self serviceForMethod:MLCServiceRequestMethodGET
                             path:path
                       parameters:parameters
                          handler:^(MLCService *service, id jsonObject, NSError *error, __unused NSHTTPURLResponse *response) {
                              BOOL success;
                              MLCStatus *status = [[MLCStatus alloc] initWithJSONObject:jsonObject];
                              if (status) {
                                  success = status.type == MLCStatusTypeSuccess;
                              } else {
                                  success = (response.statusCode >= 200 && response.statusCode < 300 && error == nil);
                              }
                              handler(success, error);
                              service.dispatchGroup = nil;
                          }];
}

+ (instancetype)listScopedResourcesForResource:(MLCEntity *)resource handler:(MLCServiceInternalCollectionCompletionHandler)handler {
    return [self findScopedResourcesForResource:resource searchParameters:nil handler:handler];
}

+ (instancetype)listResources:(MLCServiceInternalCollectionCompletionHandler)handler {
    return [self findResourcesWithSearchParameters:nil handler:handler];
}

+ (instancetype)list:(NSString *)path handler:(MLCServiceInternalCollectionCompletionHandler)handler {
    return [self find:path searchParameters:nil handler:handler];
}

+ (instancetype)findScopedResourcesForResource:(MLCEntity *)resource searchParameters:(NSDictionary *)searchParameters handler:(MLCServiceInternalCollectionCompletionHandler)handler {
    if ([self canScopeResource:resource] == NO) {
        NSString *description = [NSString stringWithFormat:NSLocalizedString(@"Invalid scope for %@", nil), [[self classForResource] collectionName]];
        MLCServiceError *error = [MLCServiceError invalidParameterErrorWithDescription:description];
        return [self invalidServiceWithError:error handler:handler];
    }

    NSString *path = [NSString pathWithComponents:@[[[resource class] collectionName], resource.uniqueIdentifier, [[self classForResource] collectionName]]];

    return [self find:path searchParameters:searchParameters handler:handler];
}

+ (instancetype)findResourcesWithSearchParameters:(NSDictionary *)searchParameters handler:(MLCServiceInternalCollectionCompletionHandler)handler {
    return [self find:[[self classForResource] collectionName] searchParameters:searchParameters handler:handler];
}

+ (instancetype)find:(NSString *)path searchParameters:(NSDictionary *)searchParameters handler:(MLCServiceInternalCollectionCompletionHandler)handler {
    return [self serviceForMethod:MLCServiceRequestMethodGET
                             path:path
                       parameters:searchParameters
                          handler:^(MLCService *service, id jsonObject, NSError *error, __unused NSHTTPURLResponse *response) {
                              NSInteger httpStatus = [error.userInfo[@"status"] httpStatus];

                              if (httpStatus == 404) {
                                  handler([[NSArray<MLCEntity *> alloc] init], nil);
                                  service.dispatchGroup = nil;
                              } else {
                                  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                      NSArray<MLCEntity *> *array = [[service class] deserializeArray:jsonObject];
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          handler(array, error);
                                          service.dispatchGroup = nil;
                                      });
                                  });
                              }
                          }];
}

+ (MLCEntity *)deserializeResource:(NSDictionary *)resource {
    if (![resource isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    Class EntityClass = [self classForResource];

    if (EntityClass) {
        return [[EntityClass alloc] initWithJSONObject:resource];
    }

    if (resource[@"status"]) {
        return [[MLCStatus alloc] initWithJSONObject:resource[@"status"]];
    }

    return nil;
}

+ (NSArray<MLCEntity *> *)deserializeArray:(NSArray *)array {
    if (![array isKindOfClass:[NSArray class]]) return nil;

    NSMutableArray *deserializedArray = [NSMutableArray arrayWithCapacity:array.count];

    [array enumerateObjectsUsingBlock:^(id obj, __unused NSUInteger idx, __unused BOOL *stop) {
        id resource = [self deserializeResource:obj];
        if (resource) [deserializedArray addObject:resource];
    }];

    return [deserializedArray copy];
}

+ (NSString *)stringWithPercentEscapesAddedToString:(NSString *)string {
    NSMutableCharacterSet *set = [NSCharacterSet.illegalCharacterSet.invertedSet mutableCopy];
    [set removeCharactersInString:@":/?#[]@!$ &'()*+,;=\"<>{}|\\^~`"];
    return [string stringByAddingPercentEncodingWithAllowedCharacters:set];
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

+ (NSURLRequest *)requestWithMethod:(MLCServiceRequestMethod)method path:(NSString *)servicePath parameters:(NSDictionary *)parameters {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];

    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:[self userAgent] forHTTPHeaderField:@"User-Agent"];

    request.HTTPMethod = [self stringFromMLCServiceRequestMethod:method];

    NSString *path = [NSString pathWithComponents:@[@"/", @"services", MLCServiceManager.apiVersion, servicePath]];

    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = MLCServiceManager.isSSLDisabled ? @"http" : @"https";
    components.host = MLCServiceManager.host;
    components.path = path;
    components.queryItems = [self queryItemsFromParameters:parameters];
    NSString *query1 = components.query;
    components.percentEncodedQuery = [self oldSerializeParameters:parameters];
    NSString *query2 = components.query;
    if (query1 != query2 && ![query1 isEqualToString:query2]) {
        NSLog(@"Percent Escaping Differs\nqueryItemsFromParameters: %@\n  oldSerializeParameters: %@", query1, query2);
    }
    BOOL alwaysUseQueryParams = MLCServiceManager.isForceQueryParametersEnabled;

    if (components.query.length && !(alwaysUseQueryParams || method == MLCServiceRequestMethodGET || method == MLCServiceRequestMethodDELETE)) {
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        request.HTTPBody = [components.query dataUsingEncoding:NSUTF8StringEncoding];
        components.query = nil;
    }

    request.URL = components.URL;

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
        userAgent = [NSString stringWithFormat:@"%@ %@ - %@ (%@; %@ %@; %@) SDK %@", name, version, build, model, systemName, systemVersion, locale, sdkVersion];
    });

    return userAgent;
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(__unused NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.httpResponse = (NSHTTPURLResponse *)response;
    self.receivedData.length = 0;
}

- (void)connection:(__unused NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
}

- (void)logDictionaryWithResponse:(id)response error:(NSError *)error {
    NSString *className = NSStringFromClass([self class]);

    NSURLComponents *components = [NSURLComponents componentsWithURL:self.request.URL resolvingAgainstBaseURL:NO];
    MLCLog(@"%@ (%@): %@ %@", @(self.httpResponse.statusCode).stringValue, className, self.request.HTTPMethod ?: [NSNull null], components.path ?: [NSNull null]);

    NSString *responseObject;
    if (response) {
        responseObject = response;
    } else if (self.receivedData.length > 0) {
        responseObject = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
    }

    NSMutableDictionary *headerFields = [self.request.allHTTPHeaderFields mutableCopy];
    if (!headerFields[@"User-Agent"]) {
        headerFields[@"User-Agent"] = [[self class] userAgent];
    }
    NSMutableString *curlArguments = [NSMutableString string];

    [headerFields enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, __unused BOOL *stop) {
        [curlArguments appendFormat:@" -H '%@: %@'", key, obj];
    }];


    if (self.request.HTTPBody) {
        NSString *bodyString = [[NSString alloc] initWithData:self.request.HTTPBody encoding:NSUTF8StringEncoding];
        if (!bodyString) {
            bodyString = [self.request.HTTPBody base64EncodedStringWithOptions:0];
        }
        if (bodyString) {
            [curlArguments appendFormat:@" -d '%@'", bodyString];
        }
    }

    NSMutableString *responseMessage = [NSMutableString stringWithFormat:@"HTTP/1.1 %@ %@\n", @(self.httpResponse.statusCode).stringValue, [NSHTTPURLResponse localizedStringForStatusCode:self.httpResponse.statusCode]];
    [self.httpResponse.allHeaderFields enumerateKeysAndObjectsUsingBlock:^(id key, id obj, __unused BOOL *stop) {
        [responseMessage appendFormat:@"%@: %@\n", key, obj];
    }];
    [responseMessage appendFormat:@"%@", [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding]];
    MLCDebugLog(@"curl -X %@ \"%@\"%@\n%@%%\n\n", self.request.HTTPMethod, [self.request.URL absoluteString], curlArguments, responseMessage);

    NSDictionary *data = @{@"class": className ?: [NSNull null],
                           @"response": responseObject ?: [NSNull null],
                           @"url": self.request.URL ?: [NSNull null],
                           @"method": self.request.HTTPMethod ?: [NSNull null],
                           @"body": self.request.HTTPBody ?: [NSNull null],
                           @"requestHeader": self.request.allHTTPHeaderFields ?: [NSNull null],
                           @"responseHeaders": self.httpResponse.allHeaderFields ?: [NSNull null],
                           @"statusCode": @(self.httpResponse.statusCode).stringValue,
                           @"statusCodeString": [NSHTTPURLResponse localizedStringForStatusCode:self.httpResponse.statusCode],
                           @"error": error.localizedDescription ?: [NSNull null]};

    MLCDebugLog(@"\n=====\n%@\n=====", data);
}

- (void)connection:(__unused NSURLConnection *)connection didFailWithError:(NSError *)error {
#if TARGET_OS_IPHONE
    UIApplication.sharedApplication.networkActivityIndicatorVisible = NO;
#endif

    MLCDebugLog(@"connection:didFailWithError:%@", error);
    [self logDictionaryWithResponse:nil error:error];

    self.jsonCompletionHandler(self, nil, error, self.httpResponse);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
#if TARGET_OS_IPHONE
    UIApplication.sharedApplication.networkActivityIndicatorVisible = NO;
#endif

    NSError *error;
    id jsonObject = nil;

    if (self.receivedData.length) {
        jsonObject = [NSJSONSerialization JSONObjectWithData:self.receivedData options:NSJSONReadingAllowFragments error:&error];
    }

    MLCDebugLog(@"connectionDidFinishLoading: %@", connection);
    [self logDictionaryWithResponse:jsonObject error:error];

    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *statusJSON = jsonObject[@"status"];
        if ([statusJSON isKindOfClass:[NSDictionary class]]) {
            MLCStatus *status = [[MLCStatus alloc] initWithJSONObject:statusJSON];
            if (status.type != MLCStatusTypeSuccess) {
                MLCStatusError *statusError = [[MLCStatusError alloc] initWithStatus:status];
                self.jsonCompletionHandler(self, nil, statusError, self.httpResponse);
                self.receivedData = nil;
                return;
            }
        }
    } else if (jsonObject == [NSNull null]) {
        jsonObject = nil;
    }

    self.jsonCompletionHandler(self, jsonObject, nil, self.httpResponse);
    self.receivedData = nil;
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    MLCDebugLog(@"connection: %@ willSendRequestForAuthenticationChallenge: %@", connection, challenge);
    MLCDebugLog(@"challenge.protectionSpace: %@ challenge.proposedCredential: %@ challenge.previousFailureCount: %@ challenge.failureResponse: %@ challenge.error: %@ challenge.sender: %@", challenge.protectionSpace, challenge.proposedCredential, @(challenge.previousFailureCount), challenge.failureResponse, challenge.error, challenge.sender);
    [challenge.sender performDefaultHandlingForAuthenticationChallenge:challenge];
}

+ (instancetype)invalidServiceFailedWithError:(MLCServiceError *)error handler:(MLCServiceSuccessCompletionHandler)handler {
    MLCService *service = [[self alloc] init];
    service.invalidServiceError = error;
    service.invalidServiceSuccessCompletionHandler = handler;
    return service;
}

+ (instancetype)invalidServiceWithError:(MLCServiceError *)error handler:(MLCServiceJSONCompletionHandler)handler {
    MLCService *service = [[self alloc] init];
    service.invalidServiceError = error;
    service.invalidServiceJsonCompletionHandler = handler;
    return service;
}


@end

@implementation MLCServiceError

+ (instancetype)missingParameterErrorWithDescription:(NSString *)description {
    return [[self alloc] initWithCode:MLCServiceErrorCodeMissingParameter description:description errors:nil];
}

+ (instancetype)invalidParameterErrorWithDescription:(NSString *)description {
    return [[self alloc] initWithCode:MLCServiceErrorCodeInvalidParameter description:description errors:nil];
}

+ (instancetype)multipleErrorsErrorWithErrors:(NSArray<MLCServiceError *> *)errors {
    return [[self alloc] initWithCode:MLCServiceErrorCodeMultipleErrors description:nil errors:errors];
}

- (NSArray<MLCServiceError *> *)errors {
    return self.userInfo[MLCServiceDetailedErrorsKey];
}

- (instancetype)initWithCode:(MLCServiceErrorCode)code description:(NSString *)description errors:(nullable NSArray<MLCServiceError *> *)errors {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (description.length > 0) {
        userInfo[NSLocalizedDescriptionKey] = description;
    }

    if (errors.count > 0) {
        userInfo[MLCServiceDetailedErrorsKey] = errors;
    }

    self = [super initWithDomain:MLCServiceErrorDomain code:code userInfo:userInfo];
    return self;
}

+ (instancetype)errorWithErrors:(NSArray<MLCServiceError *> *)errors {
    if (errors.count == 0) {
        return nil;
    }

    if (errors.count == 1) {
        return errors.firstObject;
    }

    return [self multipleErrorsErrorWithErrors:errors];
}

@end
