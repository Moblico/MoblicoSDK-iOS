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
#import "MLCSessionManager.h"

#import "MLCEntity_Private.h"
#import "MLCStatus.h"

#import "MLCLogger.h"

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

    MLCServiceManagerAuthenticationCompletionHandler handler = ^(NSURLRequest *authenticatedRequest, NSError *error) {
        if (error) {
            self.jsonCompletionHandler(self, nil, error, nil);
        } else {
            self.request.authenticatedURLRequest = authenticatedRequest;
            self.connection = [MLCSessionManager.session dataTaskWithRequest:authenticatedRequest completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable taskError) {
                [self handleData:data response:response error:taskError];
            }];
            [self.connection resume];
        }
    };

    if (self.skipAuthentication) {
        handler(self.request.URLRequest, nil);
    } else {
        MLCServiceManager *manager = self.serviceManager ?: MLCServiceManager.sharedServiceManager;
        [manager authenticateRequest:self.request.URLRequest handler:handler];
    }
}

- (void)cancel {
    [self.connection cancel];
    self.connection = nil;
}

+ (instancetype)serviceForMethod:(MLCServiceRequestMethod)method path:(NSString *)path parameters:(NSDictionary *)parameters contentType:(MLCServiceRequestMediaType)contentType handler:(MLCServiceInternalJSONCompletionHandler)handler {
    MLCService *service = [[self alloc] init];
    service.jsonCompletionHandler = handler;
    service.request = [MLCServiceRequest requestWithMethod:method path:path parameters:parameters contentType:contentType];
    return service;
}

+ (instancetype)_service:(MLCServiceRequestMethod)method path:(NSString *)path parameters:(NSDictionary *)parameters contentType:(MLCServiceRequestMediaType)contentType handler:(MLCServiceJSONCompletionHandler)handler {
    return [self serviceForMethod:method
                             path:path
                       parameters:parameters
                      contentType:contentType
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
                      contentType:nil
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
                      contentType:nil
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
                      contentType:nil
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
                      contentType:nil
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
        NSString *description = [NSString localizedStringWithFormat:NSLocalizedString(@"Missing %@", nil), [[self classForResource] uniqueIdentifierKey]];
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
                      contentType:nil
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
                      contentType:nil
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
        NSString *description = [NSString localizedStringWithFormat:NSLocalizedString(@"Invalid scope for %@", nil), [[self classForResource] collectionName]];
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
                      contentType:nil
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

- (void)logDictionaryWithData:(NSData *)data jsonObject:(id)jsonObject jsonError:(NSError *)jsonError httpResponse:(NSHTTPURLResponse *)httpResponse error:(NSError *)error {
    NSString *className = NSStringFromClass([self class]);
    NSString *method = self.request.method;
    NSURLComponents *components = self.request.components;

    if (MLCServiceManager.logging < MLCServiceManagerLoggingEnabledVerbose) {
        MLCLog(@"%@ (%@): %@ %@", @(httpResponse.statusCode).stringValue, className, method, components.path ?: @"/");
    }

    NSMutableDictionary *headerFields = [(self.request.authenticatedURLRequest.allHTTPHeaderFields ?: self.request.headers ?: @{}) mutableCopy];
    if (!headerFields[@"User-Agent"]) {
        headerFields[@"User-Agent"] = [MLCServiceRequest userAgent];
    }

    NSMutableString *curlArguments = [NSMutableString string];
    [headerFields enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, __unused BOOL *stop) {
        [curlArguments appendFormat:@" -H '%@: %@'", key, obj];
    }];

    NSString *bodyString;
    if (self.request.body) {
        bodyString = [[NSString alloc] initWithData:self.request.body encoding:NSUTF8StringEncoding];
        if (!bodyString) {
            bodyString = [self.request.body base64EncodedStringWithOptions:0];
        }
        if (bodyString) {
            [curlArguments appendFormat:@" -d '%@'", bodyString];
        }
    }

    MLCDebugLog(@"curl -X %@ \"%@\"%@", method, components.URL.absoluteString, curlArguments);

    if (error) {
        MLCLog(@"Error: (%@ - %@) %@", error.domain, @(error.code), error.localizedDescription);
    }

    if (jsonError) {
        MLCLog(@"Parse Error: (%@ - %@) %@", jsonError.domain, @(jsonError.code), jsonError.localizedDescription);
    }

    NSMutableString *responseMessage = [NSMutableString stringWithFormat:@"HTTP/1.1 %@ %@\n", @(httpResponse.statusCode).stringValue, [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]];
    [httpResponse.allHeaderFields enumerateKeysAndObjectsUsingBlock:^(id key, id obj, __unused BOOL *stop) {
        [responseMessage appendFormat:@"%@: %@\n", key, obj];
    }];
//    [responseMessage appendFormat:@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    MLCDebugLog(@"Response String: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    MLCDebugLog(@"Response Object: %@", jsonObject);
}

- (void)handleData:(NSData *_Nullable)data response:(NSURLResponse *_Nullable)response error:(NSError *_Nullable)error {
    NSHTTPURLResponse *httpResponse;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        httpResponse = (NSHTTPURLResponse *)response;
    }

    NSError *jsonError;
    id jsonObject = nil;

    if (data.length) {
        jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
    }

    [self logDictionaryWithData:data jsonObject:jsonObject jsonError:jsonError httpResponse:httpResponse error:jsonError];

    if (error || jsonError) {
        self.jsonCompletionHandler(self, nil, error ?: jsonError, httpResponse);
        return;
    }

    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *statusJSON = jsonObject[@"status"];
        if ([statusJSON isKindOfClass:[NSDictionary class]]) {
            MLCStatus *status = [[MLCStatus alloc] initWithJSONObject:statusJSON];
            if (status.type != MLCStatusTypeSuccess) {
                MLCStatusError *statusError = [[MLCStatusError alloc] initWithStatus:status];
                self.jsonCompletionHandler(self, nil, statusError, httpResponse);
                return;
            }
        }
    } else if (jsonObject == [NSNull null]) {
        jsonObject = nil;
    }

    self.jsonCompletionHandler(self, jsonObject, nil, httpResponse);
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
