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


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class MLCServiceManager;
@class MLCServiceError;
@class MLCEntity;

FOUNDATION_EXPORT NSErrorDomain const MLCServiceErrorDomain NS_SWIFT_NAME(MLCService.ErrorDomain);
FOUNDATION_EXPORT NSErrorUserInfoKey const MLCServiceDetailedErrorsKey NS_SWIFT_NAME(MLCService.DetailedErrorsKey);

typedef NS_ERROR_ENUM(MLCServiceErrorDomain, MLCServiceErrorCode) {
    MLCServiceErrorCodeMissingParameter = 1000,
    MLCServiceErrorCodeInvalidParameter,
    MLCServiceErrorCodeInternalError,
    MLCServiceErrorCodeMultipleErrors
} NS_SWIFT_NAME(MLCService.Error);

/**
 The callback handler for JSON MLCService requests
 
 @param jsonObject The JSON data returned by the service request.
 @param error An error identifier.
 */
typedef void(^MLCServiceJSONCompletionHandler)(id _Nullable jsonObject, NSError *_Nullable error) NS_SWIFT_NAME(MLCService.JSONCompletionHandler);

/**
 The callback handler for status MLCService requests
 
 @param success Boolean indicating if the action was successful.
 @param error An error identifier.
 */
typedef void(^MLCServiceSuccessCompletionHandler)(BOOL success, NSError *_Nullable error) NS_SWIFT_NAME(MLCService.SuccessCompletionHandler);

/**
 The callback handler for collection MLCService requests

 @param collection The array of resources returned by the service request.
 @param error An error identifier.
 */
typedef void(^MLCServiceCollectionCompletionHandler)(NSArray<__kindof MLCEntity *> *_Nullable collection, NSError *_Nullable error) NS_SWIFT_NAME(MLCService.CollectionCompletionHandler);

#define MLCServiceCreateCollectionCompletionHandler(Name, Entity) typedef void(^Name ## CollectionCompletionHandler)(NSArray<Entity *> *_Nullable collection, NSError *_Nullable error) NS_SWIFT_NAME(Name.CollectionCompletionHandler)

/**
 The callback handler for resource MLCService requests

 @param resource The object returned by the service request.
 @param error An error identifier.
 */
typedef void(^MLCServiceResourceCompletionHandler)(__kindof MLCEntity *_Nullable resource, NSError *_Nullable error) NS_SWIFT_NAME(MLCService.ResourceCompletionHandler);

#define MLCServiceCreateResourceCompletionHandler(Name, Entity) typedef void(^Name ## ResourceCompletionHandler)(Entity *_Nullable resource, NSError *_Nullable error) NS_SWIFT_NAME(Name.ResourceCompletionHandler)

/**
 Base class for all Moblico service objects.
 */
NS_SWIFT_NAME(Service)
@interface MLCService : NSObject
@property (nonatomic, copy, nullable) MLCServiceManager *serviceManager;

- (void)start;
- (void)cancel;
@end

NS_SWIFT_NAME(MLCService.Error)
@interface MLCServiceError : NSError
@property (nonatomic, copy, readonly, nullable) NSArray<MLCServiceError *> *errors;

- (instancetype)initWithCode:(MLCServiceErrorCode)code description:(nullable NSString *)description errors:(nullable NSArray<MLCServiceError *> *)errors NS_DESIGNATED_INITIALIZER;

+ (instancetype)missingParameterErrorWithDescription:(NSString *)description NS_SWIFT_NAME(missingParameter(_:));
+ (instancetype)invalidParameterErrorWithDescription:(NSString *)description NS_SWIFT_NAME(invalidParameter(_:));
+ (instancetype)multipleErrorsErrorWithErrors:(NSArray<MLCServiceError *> *)description NS_SWIFT_NAME(multipleErrors(_:));

+ (nullable instancetype)errorWithErrors:(NSArray<MLCServiceError *> *)errors;

- (instancetype)initWithDomain:(NSErrorDomain)domain code:(NSInteger)code userInfo:(nullable NSDictionary<NSErrorUserInfoKey, id> *)dict NS_UNAVAILABLE;
+ (instancetype)errorWithDomain:(NSErrorDomain)domain code:(NSInteger)code userInfo:(nullable NSDictionary<NSErrorUserInfoKey, id> *)dict NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
