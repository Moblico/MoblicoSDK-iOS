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

NS_ASSUME_NONNULL_BEGIN

typedef void(^MLCServiceInternalJSONCompletionHandler)(MLCService *service, id _Nullable jsonObject, NSError *_Nullable error, NSHTTPURLResponse *_Nullable response) NS_SWIFT_NAME(MLCService.InternalJSONCompletionHandler);

@interface MLCService ()

@property (copy, nonatomic) MLCServiceInternalJSONCompletionHandler jsonCompletionHandler;
@property (strong, nonatomic, nullable) NSURLSessionDataTask *connection;
@property (strong, nonatomic) MLCServiceRequest *request;
#if OS_OBJECT_USE_OBJC
@property (strong, nonatomic, nullable) dispatch_group_t dispatchGroup;
#else
@property (assign, nonatomic, nullable) dispatch_group_t dispatchGroup;
#endif
@property (strong, nonatomic, nullable) NSError *invalidServiceError;
@property (copy, nonatomic) MLCServiceJSONCompletionHandler invalidServiceJsonCompletionHandler;
@property (copy, nonatomic) MLCServiceSuccessCompletionHandler invalidServiceSuccessCompletionHandler;
@property (assign, nonatomic) BOOL skipAuthentication;

- (void)handleData:(NSData *_Nullable)data response:(NSURLResponse *_Nullable)response error:(NSError *_Nullable)error;

+ (instancetype)_invalidServiceWithError:(MLCServiceError *)error handler:(MLCServiceJSONCompletionHandler)handler;
+ (instancetype)_invalidServiceFailedWithError:(MLCServiceError *)error handler:(MLCServiceSuccessCompletionHandler)handler;

+ (instancetype)_service:(MLCServiceRequestMethod)method path:(NSString *)path parameters:(nullable NSDictionary<NSString *, id> *)parameters handler:(MLCServiceJSONCompletionHandler)handler;

+ (instancetype)_create:(NSString *)path parameters:(nullable NSDictionary<NSString *, id> *)parameters handler:(nullable MLCServiceResourceCompletionHandler)handler;
+ (instancetype)createResource:(MLCEntity *)resource handler:(nullable MLCServiceResourceCompletionHandler)handler;

+ (instancetype)createSuccess:(NSString *)path parameters:(nullable NSDictionary *)parameters handler:(nullable MLCServiceSuccessCompletionHandler)handler;
+ (instancetype)createSuccessResource:(MLCEntity *)resource handler:(nullable MLCServiceSuccessCompletionHandler)handler;

+ (instancetype)_update:(NSString *)path parameters:(nullable NSDictionary<NSString *, id> *)parameters handler:(nullable MLCServiceSuccessCompletionHandler)handler;
+ (instancetype)updateResource:(MLCEntity *)resource handler:(nullable MLCServiceSuccessCompletionHandler)handler;

+ (instancetype)_destroy:(NSString *)path parameters:(nullable NSDictionary<NSString *, id> *)parameters handler:(nullable MLCServiceSuccessCompletionHandler)handler;
+ (instancetype)destroyResource:(MLCEntity *)resource handler:(nullable MLCServiceSuccessCompletionHandler)handler;

+ (instancetype)_read:(NSString *)path parameters:(nullable NSDictionary<NSString *, id> *)parameters handler:(nullable MLCServiceResourceCompletionHandler)handler;
+ (instancetype)readResourceWithUniqueIdentifier:(id)uniqueIdentifier handler:(nullable MLCServiceResourceCompletionHandler)handler;
+ (instancetype)readSuccess:(NSString *)path parameters:(nullable NSDictionary *)parameters handler:(nullable MLCServiceSuccessCompletionHandler)handler;

+ (instancetype)_find:(NSString *)path searchParameters:(nullable NSDictionary<NSString *, id> *)searchParameters handler:(nullable MLCServiceCollectionCompletionHandler)handler;
+ (instancetype)findResourcesWithSearchParameters:(nullable NSDictionary<NSString *, id> *)searchParameters handler:(nullable MLCServiceCollectionCompletionHandler)handler;
+ (instancetype)findScopedResourcesForResource:(MLCEntity *)resource searchParameters:(nullable NSDictionary<NSString *, id> *)searchParameters handler:(nullable MLCServiceCollectionCompletionHandler)handler;

+ (nullable NSArray<Class> *)scopeableResources;
+ (BOOL)canScopeResource:(MLCEntity *)resource;

+ (instancetype)serviceForMethod:(MLCServiceRequestMethod)method path:(NSString *)path parameters:(nullable NSDictionary<NSString *, id> *)parameters handler:(MLCServiceInternalJSONCompletionHandler)handler;

+ (nullable MLCEntity *)deserializeResource:(nullable NSDictionary<NSString *, id> *)resource;
+ (nullable NSArray<MLCEntity *> *)deserializeArray:(nullable NSArray<NSDictionary<NSString *, id> *> *)array;
+ (nullable Class)classForResource;

@end

NS_ASSUME_NONNULL_END
