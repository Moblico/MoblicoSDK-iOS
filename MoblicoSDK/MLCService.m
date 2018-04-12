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

#import "MLCEntity_Private.h"
#import "MLCStatus.h"

#import "MLCLogger.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
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
    MLCService *service = [[self alloc] init];
    service.jsonCompletionHandler = handler;
    service.request = [MLCServiceRequest requestWithMethod:method path:path parameters:parameters].URLRequest;
    return service;
}

+ (instancetype)_service:(MLCServiceRequestMethod)method path:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceJSONCompletionHandler)handler {
    return [self serviceForMethod:method
                             path:path
                       parameters:parameters
                          handler:^(MLCService *service, id jsonObject, NSError *error, __unused NSHTTPURLResponse *response) {
                              handler(jsonObject, error);
                              service.dispatchGroup = nil;
                          }];
}

+ (instancetype)createResource:(MLCEntity *)resource handler:(MLCServiceResourceCompletionHandler)handler {
    return [self _create:[[resource class] collectionName] parameters:[[resource class] serialize:resource] handler:handler];
}

+ (instancetype)_create:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceResourceCompletionHandler)handler {
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

    return [self _update:path parameters:serializedObject handler:handler];
}

+ (instancetype)_update:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceSuccessCompletionHandler)handler {
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

    return [self _destroy:path parameters:nil handler:handler];
}

+ (instancetype)_destroy:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceSuccessCompletionHandler)handler {
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

+ (instancetype)readResourceWithUniqueIdentifier:(id)uniqueIdentifierObject handler:(MLCServiceResourceCompletionHandler)handler {
    NSString *uniqueIdentifier = [MLCEntity stringFromValue:uniqueIdentifierObject];

    if (!uniqueIdentifier.length) {
        NSString *description = [NSString stringWithFormat:NSLocalizedString(@"Missing %@", nil), [[self classForResource] uniqueIdentifierKey]];
        MLCServiceError *error = [MLCServiceError missingParameterErrorWithDescription:description];
        return [self _invalidServiceWithError:error handler:handler];
    }
    NSString *path = [[[self classForResource] collectionName] stringByAppendingPathComponent:uniqueIdentifier];

    return [self _read:path parameters:nil handler:handler];
}

+ (instancetype)_read:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceResourceCompletionHandler)handler {
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

+ (instancetype)findScopedResourcesForResource:(MLCEntity *)resource searchParameters:(NSDictionary *)searchParameters handler:(MLCServiceCollectionCompletionHandler)handler {
    if (![self canScopeResource:resource]) {
        NSString *description = [NSString stringWithFormat:NSLocalizedString(@"Invalid scope for %@", nil), [[self classForResource] collectionName]];
        MLCServiceError *error = [MLCServiceError invalidParameterErrorWithDescription:description];
        return [self _invalidServiceWithError:error handler:handler];
    }

    NSString *path = [NSString pathWithComponents:@[[[resource class] collectionName], resource.uniqueIdentifier, [[self classForResource] collectionName]]];

    return [self _find:path searchParameters:searchParameters handler:handler];
}

+ (instancetype)findResourcesWithSearchParameters:(NSDictionary *)searchParameters handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self _find:[[self classForResource] collectionName] searchParameters:searchParameters handler:handler];
}

+ (instancetype)_find:(NSString *)path searchParameters:(NSDictionary *)searchParameters handler:(MLCServiceCollectionCompletionHandler)handler {
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
        return [(__kindof MLCEntity *)[EntityClass alloc] initWithJSONObject:resource];
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

- (NSMutableData *)receivedData {
    if (!_receivedData) {
        self.receivedData = [[NSMutableData alloc] init];
    }

    return _receivedData;
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
    MLCLog(@"%@ (%@): %@ %@", @(self.httpResponse.statusCode).stringValue, className, self.request.HTTPMethod ?: @"(nil)", components.path ?: @"(nil)");

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

    NSString *bodyString;
    if (self.request.HTTPBody) {
        bodyString = [[NSString alloc] initWithData:self.request.HTTPBody encoding:NSUTF8StringEncoding];
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

    NSDictionary *data = @{@"class": className ?: @"(nil)",
                           @"response": responseObject ?: @"(nil)",
                           @"url": self.request.URL.absoluteString ?: @"(nil)",
                           @"method": self.request.HTTPMethod ?: @"(nil)",
                           @"body": bodyString ?: @"(nil)",
                           @"requestHeader": self.request.allHTTPHeaderFields ?: @{},
                           @"responseHeaders": self.httpResponse.allHeaderFields ?: @{},
                           @"statusCode": @(self.httpResponse.statusCode).stringValue,
                           @"statusCodeString": [NSHTTPURLResponse localizedStringForStatusCode:self.httpResponse.statusCode],
                           @"error": error.localizedDescription ?: @"(nil)"};

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

+ (instancetype)_invalidServiceFailedWithError:(MLCServiceError *)error handler:(MLCServiceSuccessCompletionHandler)handler {
    MLCService *service = [[self alloc] init];
    service.invalidServiceError = error;
    service.invalidServiceSuccessCompletionHandler = handler;
    return service;
}

+ (instancetype)_invalidServiceWithError:(MLCServiceError *)error handler:(MLCServiceJSONCompletionHandler)handler {
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
