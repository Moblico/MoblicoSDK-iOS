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
#import "MLCServiceProtocol.h"
#import "MLCServiceManager.h"
#import "MLCEntityProtocol.h"
#import "MLCEntity.h"
#import "MLCEntity_Private.h"
#import "MLCStatus.h"

#import "MLCInvalidService.h"
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

#define ALWAYS_USE_QUERY_PARAMS YES

@implementation MLCService

+ (NSArray *)scopeableResources {
    return nil;
}


+ (BOOL)canScopeResource:(id<MLCEntityProtocol>)resource {
    NSString * className = NSStringFromClass([resource class]);
    return [[self scopeableResources] containsObject:className];
}

+ (Class<MLCEntityProtocol>)classForResource {
    [self doesNotRecognizeSelector:_cmd];
    return Nil;
}

- (void)start {
    [self cancel];
    [[MLCServiceManager sharedServiceManager] authenticateRequest:self.request handler:^(NSURLRequest *authenticatedRequest, NSError *error, NSHTTPURLResponse *response) {
        if (error) {
            self.jsonCompletionhandler(nil, error, response);
        } else {
            self.connection = [NSURLConnection connectionWithRequest:authenticatedRequest delegate:self];;
            [self.connection start];
        }
    }];
}

- (void)cancel {
    [self.connection cancel];
    self.connection = nil;
}

+ (id)serviceForMethod:(MLCServiceRequestMethod)method path:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceJSONCompletionHandler)handler {
    MLCService *service = [[[self class] alloc] init];
    service.jsonCompletionhandler = handler;
    service.request = [self requestWithMethod:method path:path parameters:parameters];
    return service;
}

+ (id)createResource:(id<MLCEntityProtocol>)resource handler:(MLCServiceStatusCompletionHandler)handler {
    return [self create:[resource collectionName] parameters:[resource serialize] handler:handler];
}

+ (id)create:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceStatusCompletionHandler)handler {
    return [self serviceForMethod:MLCServiceRequestMethodPOST
                             path:path
                       parameters:parameters
                          handler:^(id jsonObject, NSError *error, NSHTTPURLResponse *response) {
							  if (handler) {
								  handler([MLCStatus deserialize:jsonObject], error, response);
							  }
                          }];
}

+ (id)updateResource:(id<MLCEntityProtocol>)resource handler:(MLCServiceStatusCompletionHandler)handler {
    NSString *path = [[resource collectionName] stringByAppendingPathComponent:[resource uniqueIdentifier]];
    NSMutableDictionary *serializedObject = [[resource serialize] mutableCopy];
    [serializedObject removeObjectForKey:[[resource class] uniqueIdentifierKey]];
    return [self update:path parameters:serializedObject handler:handler];
}

+ (id)update:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceStatusCompletionHandler)handler {
    return [self serviceForMethod:MLCServiceRequestMethodPUT
                             path:path
                       parameters:parameters
                          handler:^(id jsonObject, NSError *error, NSHTTPURLResponse *response) {
                              handler([MLCStatus deserialize:jsonObject], error, response);
                          }];
}

+ (id)destroyResource:(id<MLCEntityProtocol>)resource handler:(MLCServiceStatusCompletionHandler)handler {
    NSString *path = [[resource collectionName] stringByAppendingPathComponent:[resource uniqueIdentifier]];
    return [self destroy:path parameters:nil handler:handler];
}

+ (id)destroy:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceStatusCompletionHandler)handler {
    return [self serviceForMethod:MLCServiceRequestMethodDELETE
                             path:path
                       parameters:parameters
                          handler:^(id jsonObject, NSError *error, NSHTTPURLResponse *response) {
                              handler([MLCStatus deserialize:jsonObject], error, response);
                          }];
}

+ (id)readResourceWithUniqueIdentifier:(id)uniqueIdentifier handler:(MLCServiceResourceCompletionHandler)handler {
    uniqueIdentifier = [MLCEntity stringFromValue:uniqueIdentifier];
    if (![uniqueIdentifier length]) {
        NSString *description = [NSString stringWithFormat:NSLocalizedString(@"Missing %@", nil), [[self classForResource] uniqueIdentifierKey]];
        NSError * error = [NSError errorWithDomain:@"com.moblico.service" code:1001 userInfo:@{NSLocalizedDescriptionKey: description}];
        return [MLCInvalidService invalidServiceWithError:error handler:handler];
    }
    NSString *path = [[[self classForResource] collectionName] stringByAppendingPathComponent:uniqueIdentifier];
    return [self read:path parameters:nil handler:handler];
}

+ (id)read:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceResourceCompletionHandler)handler {
    return [self serviceForMethod:MLCServiceRequestMethodGET
                             path:path
                       parameters:parameters
                          handler:^(id jsonObject, NSError *error, NSHTTPURLResponse *response) {
                              handler([self deserializeResource:jsonObject], error, response);
                          }];
}

+ (id)listScopedResourcesForResource:(id<MLCEntityProtocol>)resource handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self findScopedResourcesForResource:resource searchParameters:nil handler:handler];
}

+ (id)listResources:(MLCServiceCollectionCompletionHandler)handler {
    return [self findResourcesWithSearchParameters:nil handler:handler];
}

+ (id)list:(NSString *)path handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self find:path searchParameters:nil handler:handler];
}



+ (id)findScopedResourcesForResource:(id<MLCEntityProtocol>)resource searchParameters:(NSDictionary *)searchParameters handler:(MLCServiceCollectionCompletionHandler)handler {
    if ([self canScopeResource:resource] == NO) {
        NSString *failureReason = [NSString stringWithFormat:NSLocalizedString(@"%@ do not have %@", nil), [[self classForResource] collectionName], [resource collectionName]];
        NSString *description = [NSString stringWithFormat:NSLocalizedString(@"Invalid scope for %@", nil), [[self classForResource] collectionName]];
        NSError * error = [NSError errorWithDomain:@"com.moblico.model" code:1000 userInfo:@{NSLocalizedDescriptionKey: description, NSLocalizedFailureReasonErrorKey: failureReason}];
        return [MLCInvalidService invalidServiceWithError:error handler:handler];
    }

    NSString *path = [NSString pathWithComponents:@[[resource collectionName], [resource uniqueIdentifier], [[self classForResource] collectionName]]];
    return [self find:path searchParameters:searchParameters handler:handler];
}

+ (id)findResourcesWithSearchParameters:(NSDictionary *)searchParameters handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self find:[[self classForResource] collectionName] searchParameters:searchParameters handler:handler];
}

+ (id)find:(NSString *)path searchParameters:(NSDictionary *)searchParameters handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self serviceForMethod:MLCServiceRequestMethodGET
                             path:path
                       parameters:searchParameters
                          handler:^(id jsonObject, NSError *error, NSHTTPURLResponse *response) {
                              int httpStatus = [error.userInfo[@"status"] httpStatus];
                              if (httpStatus == 404) {
                                  handler(@[], nil, response);
                              } else {
                                  handler([self deserializeArray:jsonObject], error, response);
                              }
                          }];
}


+ (id)deserializeResource:(NSDictionary *)resource {
    return [[self classForResource] deserialize:resource];
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

+ (id)requestWithMethod:(MLCServiceRequestMethod)method path:(NSString *)path parameters:(NSDictionary *)parameters {
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[request setHTTPMethod:[self stringFromMLCServiceRequestMethod:method]];
	
    path = [NSString pathWithComponents:@[@"/", @"services", [MLCServiceManager apiVersion], path]];
    
    NSURL *requestURL = [[NSURL alloc] initWithScheme:([MLCServiceManager isSSLDisabled] ? @"http" : @"https") host:[MLCServiceManager host] path:path];

	if ([parameters count]) {
		NSMutableArray *queryParams = [NSMutableArray arrayWithCapacity:[parameters count]];
		[parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, __unused BOOL *stop) {
            id value = obj;

            if ([obj isKindOfClass:[NSArray class]]) {
                NSMutableArray *array = [NSMutableArray arrayWithCapacity:[obj count]];
                for (id param in obj) {
                    id item = param;
                    if ([item isKindOfClass:[NSString class]]) {
                        item = [self stringWithPercentEscapesAddedToString:item];
                    }
                    [array addObject:item];
                }
                value = [array componentsJoinedByString:@","];
            }
            
            else if ([obj isKindOfClass:[NSDictionary class]]) {
                NSMutableArray *array = [NSMutableArray arrayWithCapacity:[obj count]];
                for (id k in obj) {
                    id item = k;
                    id v = [obj objectForKey:k];
                    if ([item isKindOfClass:[NSString class]]) {
                        item = [self stringWithPercentEscapesAddedToString:item];
                    }
                    if ([v isKindOfClass:[NSString class]]) {
                        v = [self stringWithPercentEscapesAddedToString:v];
                    }
                    NSString *kv = [@[item,v] componentsJoinedByString:@","];
                    [array addObject:kv];
                }
                value = [array componentsJoinedByString:@";"];
            }
         
            else if ([obj isKindOfClass:[NSString class]]) {
                value = [self stringWithPercentEscapesAddedToString:value];
            }
			
			[queryParams addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
		}];
		
		NSString *parameterString = [queryParams componentsJoinedByString:@"&"];
        
		if (ALWAYS_USE_QUERY_PARAMS || method == MLCServiceRequestMethodGET || method == MLCServiceRequestMethodDELETE) {
            NSMutableString * urlString = [[requestURL absoluteString] mutableCopy];
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

		if (!userAgent) {
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
            NSString *appVersion = @"1.1";
            userAgent = [NSString stringWithFormat:@"%@ %@ (%@; %@ %@; %@)", appName, appVersion, model, systemName, systemVersion, locale];
        }
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
    NSError *error;
    id jsonObject = nil;
    if ([self.receivedData length]) {
        NSLog(@"receivedData length: %d", [self.receivedData length]);
        jsonObject = [NSJSONSerialization JSONObjectWithData:self.receivedData options:0 error:&error];
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
        NSDictionary * statusDictionary = jsonObject[@"status"];
        MLCStatus * status = [MLCStatus deserialize:statusDictionary];
        NSError * statusError = [NSError errorWithDomain:@"com.moblico.service.error" code:status.statusType userInfo:@{NSLocalizedDescriptionKey: status.message, @"status": status}];
        self.jsonCompletionhandler(nil, statusError, self.httpResponse);
    }
    else {
        self.jsonCompletionhandler(jsonObject, error, self.httpResponse);
    }
 	self.receivedData = nil;
}

- (BOOL)connection:(__unused NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    if ([MLCServiceManager isLoggingEnabled]) NSLog(@"connection:canAuthenticateAgainstProtectionSpace: %@", protectionSpace);
	return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(__unused NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([MLCServiceManager isLoggingEnabled]) NSLog(@"connection:didReceiveAuthenticationChallenge: %@", challenge);
	if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
		if ([challenge.protectionSpace.host isEqualToString:[MLCServiceManager host]] && [MLCServiceManager isTestingEnabled]) {
			[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
		}
	}
	
	[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

@end
