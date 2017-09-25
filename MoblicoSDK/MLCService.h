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


@import Foundation;

NS_ASSUME_NONNULL_BEGIN
@class MLCServiceError;

FOUNDATION_EXPORT NSErrorDomain const MLCServiceErrorDomain NS_SWIFT_NAME(MLCService.ErrorDomain);
FOUNDATION_EXPORT NSErrorUserInfoKey const MLCServiceDetailedErrorsKey NS_SWIFT_NAME(MLCService.DetailedErrorsKey);

typedef NS_ERROR_ENUM(MLCServiceErrorDomain, MLCServiceErrorCode) {
    MLCServiceErrorCodeMissingParameter = 1000,
    MLCServiceErrorCodeInvalidParameter,
    MLCServiceErrorCodeInternalError,
    MLCServiceErrorCodeMultipleErrors
} NS_SWIFT_NAME(MLCService.Error);

/**
 Indicates the method used in the request
 */
typedef NS_ENUM(NSUInteger, MLCServiceRequestMethod) {
    /// Requests a representation of the specified resource.
    MLCServiceRequestMethodGET NS_SWIFT_NAME(get),

    /// Creates a resource.
    MLCServiceRequestMethodPOST NS_SWIFT_NAME(post),

    /// Updates the specified resource.
    MLCServiceRequestMethodPUT NS_SWIFT_NAME(put),

    /// Deletes the specified resource.
    MLCServiceRequestMethodDELETE NS_SWIFT_NAME(delete)
} NS_SWIFT_NAME(MLCService.RequestMethod);

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

#define MLCServiceCreateResourceCompletionHandler(Name, Type) typedef void(^Name ## ResourceCompletionHandler)(Type *_Nullable resource, NSError *_Nullable error) NS_SWIFT_NAME(Name.ResourceCompletionHandler)

#define MLCServiceCreateCollectionCompletionHandler(Name, Type) typedef void(^Name ## CollectionCompletionHandler)(NSArray<Type *> *_Nullable collection, NSError *_Nullable error) NS_SWIFT_NAME(Name.CollectionCompletionHandler)

/**
 Base class for all Moblico service objects.
 */
NS_SWIFT_NAME(Service)
@interface MLCService : NSObject
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

- (instancetype)initWithDomain:(NSErrorDomain)domain code:(NSInteger)code userInfo:(nullable NSDictionary<NSErrorUserInfoKey,id> *)dict NS_UNAVAILABLE;
+ (instancetype)errorWithDomain:(NSErrorDomain)domain code:(NSInteger)code userInfo:(nullable NSDictionary<NSErrorUserInfoKey,id> *)dict NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
