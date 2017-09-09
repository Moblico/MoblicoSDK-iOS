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

#import <MoblicoSDK/MLCService.h>
@class MLCEntity;

NS_ASSUME_NONNULL_BEGIN

/**
 The callback handler for collection MLCService requests

 @param collection The array of resources returned by the service request.
 @param error An error identifier.
 */
typedef void(^MLCGenericServiceCollectionCompletionHandler)(NSArray<__kindof MLCEntity *> *_Nullable collection, NSError *_Nullable error) NS_SWIFT_NAME(MLCGenericService.CollectionCompletionHandler);

/**
 The callback handler for resource MLCService requests

 @param resource The object returned by the service request.
 @param error An error identifier.
 */
typedef void(^MLCGenericServiceResourceCompletionHandler)(id _Nullable resource, NSError *_Nullable error) NS_SWIFT_NAME(MLCGenericService.ResourceCompletionHandler);

NS_SWIFT_NAME(GenericService)
@interface MLCGenericService : MLCService

+ (instancetype)create:(NSString *)path parameters:(NSDictionary<NSString *,id> *)parameters handler:(MLCGenericServiceResourceCompletionHandler)handler;

+ (instancetype)update:(NSString *)path parameters:(NSDictionary<NSString *,id> *)parameters handler:(MLCServiceSuccessCompletionHandler)handler;

+ (instancetype)destroy:(NSString *)path parameters:(NSDictionary<NSString *,id> *)parameters handler:(MLCServiceSuccessCompletionHandler)handler;

+ (instancetype)read:(NSString *)path parameters:(NSDictionary<NSString *,id> *)parameters handler:(MLCGenericServiceResourceCompletionHandler)handler;

+ (instancetype)find:(NSString *)path searchParameters:(NSDictionary<NSString *,id> *)searchParameters handler:(MLCGenericServiceCollectionCompletionHandler)handler;

+ (instancetype)service:(MLCServiceRequestMethod)method path:(NSString *)path parameters:(NSDictionary<NSString *, id> *)parameters handler:(MLCServiceJSONCompletionHandler)handler;

+ (Class)classForResource;

@end

NS_ASSUME_NONNULL_END
