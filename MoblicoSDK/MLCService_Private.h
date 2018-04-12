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
#import "MLCEntity.h"
#import "MLCServiceRequest.h"

typedef void(^MLCServiceInternalJSONCompletionHandler)(MLCService *service, id jsonObject, NSError *error, NSHTTPURLResponse *response) NS_SWIFT_NAME(MLCService.InternalJSONCompletionHandler);

@interface MLCService () <NSURLConnectionDataDelegate>

@property (copy, nonatomic) MLCServiceInternalJSONCompletionHandler jsonCompletionHandler;
@property (strong, nonatomic) NSURLConnection *connection;
@property (copy, nonatomic) NSURLRequest *request;
@property (strong, nonatomic) NSMutableData *receivedData;
@property (strong, nonatomic) NSHTTPURLResponse *httpResponse;
#if OS_OBJECT_USE_OBJC
@property (strong, nonatomic) dispatch_group_t dispatchGroup;
#else
@property (assign, nonatomic) dispatch_group_t dispatchGroup;
#endif
@property (strong, nonatomic) NSError *invalidServiceError;
@property (copy, nonatomic) MLCServiceJSONCompletionHandler invalidServiceJsonCompletionHandler;
@property (copy, nonatomic) MLCServiceSuccessCompletionHandler invalidServiceSuccessCompletionHandler;

+ (instancetype)_invalidServiceWithError:(MLCServiceError *)error handler:(MLCServiceJSONCompletionHandler)handler;
+ (instancetype)_invalidServiceFailedWithError:(MLCServiceError *)error handler:(MLCServiceSuccessCompletionHandler)handler;

+ (instancetype)_service:(MLCServiceRequestMethod)method path:(NSString *)path parameters:(NSDictionary<NSString *, id> *)parameters handler:(MLCServiceJSONCompletionHandler)handler;

+ (instancetype)_create:(NSString *)path parameters:(NSDictionary<NSString *, id> *)parameters handler:(MLCServiceResourceCompletionHandler)handler;
+ (instancetype)createResource:(MLCEntity *)resource handler:(MLCServiceResourceCompletionHandler)handler;

+ (instancetype)createSuccess:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceSuccessCompletionHandler)handler;
+ (instancetype)createSuccessResource:(MLCEntity *)resource handler:(MLCServiceSuccessCompletionHandler)handler;

+ (instancetype)_update:(NSString *)path parameters:(NSDictionary<NSString *, id> *)parameters handler:(MLCServiceSuccessCompletionHandler)handler;
+ (instancetype)updateResource:(MLCEntity *)resource handler:(MLCServiceSuccessCompletionHandler)handler;

+ (instancetype)_destroy:(NSString *)path parameters:(NSDictionary<NSString *, id> *)parameters handler:(MLCServiceSuccessCompletionHandler)handler;
+ (instancetype)destroyResource:(MLCEntity *)resource handler:(MLCServiceSuccessCompletionHandler)handler;

+ (instancetype)_read:(NSString *)path parameters:(NSDictionary<NSString *, id> *)parameters handler:(MLCServiceResourceCompletionHandler)handler;
+ (instancetype)readResourceWithUniqueIdentifier:(id)uniqueIdentifier handler:(MLCServiceResourceCompletionHandler)handler;
+ (instancetype)readSuccess:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceSuccessCompletionHandler)handler;

+ (instancetype)_find:(NSString *)path searchParameters:(NSDictionary<NSString *, id> *)searchParameters handler:(MLCServiceCollectionCompletionHandler)handler;
+ (instancetype)findResourcesWithSearchParameters:(NSDictionary<NSString *, id> *)searchParameters handler:(MLCServiceCollectionCompletionHandler)handler;
+ (instancetype)findScopedResourcesForResource:(MLCEntity *)resource searchParameters:(NSDictionary<NSString *, id> *)searchParameters handler:(MLCServiceCollectionCompletionHandler)handler;

+ (NSArray<Class> *)scopeableResources;
+ (BOOL)canScopeResource:(MLCEntity *)resource;

+ (instancetype)serviceForMethod:(MLCServiceRequestMethod)method path:(NSString *)path parameters:(NSDictionary<NSString *, id> *)parameters handler:(MLCServiceInternalJSONCompletionHandler)handler;

+ (MLCEntity *)deserializeResource:(NSDictionary<NSString *, id> *)resource;
+ (NSArray<MLCEntity *> *)deserializeArray:(NSArray<NSDictionary<NSString *, id> *> *)array;
+ (Class)classForResource;

@end
