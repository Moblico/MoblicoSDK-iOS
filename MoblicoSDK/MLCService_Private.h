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
typedef void(^MLCServiceInternalResourceCompletionHandler)(__kindof MLCEntity *resource, NSError *error) NS_SWIFT_NAME(MLCService.InternalResourceCompletionHandler);
typedef void(^MLCServiceInternalCollectionCompletionHandler)(NSArray<__kindof MLCEntity *> *collection, NSError *error) NS_SWIFT_NAME(MLCService.InternalCollectionCompletionHandler);

@interface MLCService () <NSURLConnectionDataDelegate>

@property (copy, nonatomic) MLCServiceInternalJSONCompletionHandler jsonCompletionHandler;
@property (strong, nonatomic) NSURLConnection *connection;
@property (copy, nonatomic) NSURLRequest *request;
@property (strong, nonatomic) NSMutableData *receivedData;
@property (strong, nonatomic) NSHTTPURLResponse *httpResponse;
@property (strong, nonatomic) dispatch_group_t dispatchGroup;
@property (strong, nonatomic) NSError *invalidServiceError;
@property (copy, nonatomic) MLCServiceJSONCompletionHandler invalidServiceJsonCompletionHandler;
@property (copy, nonatomic) MLCServiceSuccessCompletionHandler invalidServiceSuccessCompletionHandler;

+ (instancetype)invalidServiceWithError:(MLCServiceError *)error handler:(MLCServiceJSONCompletionHandler)handler;
+ (instancetype)invalidServiceFailedWithError:(MLCServiceError *)error handler:(MLCServiceSuccessCompletionHandler)handler;

+ (instancetype)service:(MLCServiceRequestMethod)method path:(NSString *)path parameters:(NSDictionary<NSString *, id> *)parameters handler:(MLCServiceJSONCompletionHandler)handler;

+ (instancetype)create:(NSString *)path parameters:(NSDictionary<NSString *, id> *)parameters handler:(MLCServiceInternalResourceCompletionHandler)handler;
+ (instancetype)createResource:(MLCEntity *)resource handler:(MLCServiceInternalResourceCompletionHandler)handler;

+ (instancetype)createSuccess:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceSuccessCompletionHandler)handler;
+ (instancetype)createSuccessResource:(MLCEntity *)resource handler:(MLCServiceSuccessCompletionHandler)handler;

+ (instancetype)update:(NSString *)path parameters:(NSDictionary<NSString *, id> *)parameters handler:(MLCServiceSuccessCompletionHandler)handler;
+ (instancetype)updateResource:(MLCEntity *)resource handler:(MLCServiceSuccessCompletionHandler)handler;

+ (instancetype)destroy:(NSString *)path parameters:(NSDictionary<NSString *, id> *)parameters handler:(MLCServiceSuccessCompletionHandler)handler;
+ (instancetype)destroyResource:(MLCEntity *)resource handler:(MLCServiceSuccessCompletionHandler)handler;

+ (instancetype)read:(NSString *)path parameters:(NSDictionary<NSString *, id> *)parameters handler:(MLCServiceInternalResourceCompletionHandler)handler;
+ (instancetype)readResourceWithUniqueIdentifier:(id)uniqueIdentifier handler:(MLCServiceInternalResourceCompletionHandler)handler;
+ (instancetype)readSuccess:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceSuccessCompletionHandler)handler;

+ (instancetype)list:(NSString *)path handler:(MLCServiceInternalCollectionCompletionHandler)handler;
+ (instancetype)listResources:(MLCServiceInternalCollectionCompletionHandler)handler;
+ (instancetype)listScopedResourcesForResource:(MLCEntity *)resource handler:(MLCServiceInternalCollectionCompletionHandler)handler;

+ (instancetype)find:(NSString *)path searchParameters:(NSDictionary<NSString *, id> *)searchParameters handler:(MLCServiceInternalCollectionCompletionHandler)handler;
+ (instancetype)findResourcesWithSearchParameters:(NSDictionary<NSString *, id> *)searchParameters handler:(MLCServiceInternalCollectionCompletionHandler)handler;
+ (instancetype)findScopedResourcesForResource:(MLCEntity *)resource searchParameters:(NSDictionary<NSString *, id> *)searchParameters handler:(MLCServiceInternalCollectionCompletionHandler)handler;

+ (NSArray<Class> *)scopeableResources;
+ (BOOL)canScopeResource:(MLCEntity *)resource;

+ (instancetype)serviceForMethod:(MLCServiceRequestMethod)method path:(NSString *)path parameters:(NSDictionary<NSString *, id> *)parameters handler:(MLCServiceInternalJSONCompletionHandler)handler;

+ (MLCEntity *)deserializeResource:(NSDictionary<NSString *, id> *)resource;
+ (NSArray<MLCEntity *> *)deserializeArray:(NSArray<NSDictionary<NSString *, id> *> *)array;
+ (Class)classForResource;

@end
