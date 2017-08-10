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

@protocol MLCEntityProtocol;

/**
 All MLCService objects conform to the MLCService protocol.
 */
@protocol MLCServiceProtocol <NSObject>

@required
- (void)start;
- (void)cancel;

@end


@class MLCStatus;

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
};

/**
 The callback handler for JSON MLCService requests
 
 @param jsonObject The JSON data returned by the service request.
 @param error An error identifier.
 @param response The URL response returned by the service request that includes the HTTP response codes.
 */
typedef void(^MLCServiceJSONCompletionHandler)(id _Nullable jsonObject, NSError *_Nullable error, NSHTTPURLResponse *_Nullable response);


/**
 The callback handler for resource MLCService requests
 
 @param resource The object returned by the service request.
 @param error An error identifier.
 @param response The URL response returned by the service request that includes the HTTP response codes.
 */
typedef void(^MLCServiceResourceCompletionHandler)(id<MLCEntityProtocol> _Nullable resource, NSError *_Nullable error, NSHTTPURLResponse *_Nullable response);

/**
 The callback handler for collection MLCService requests

 @param collection The array of resources returned by the service request.
 @param error An error identifier.
 @param response The URL response returned by the service request that includes the HTTP response codes.
 */
typedef void(^MLCServiceCollectionCompletionHandler)(NSArray<MLCEntityProtocol> *_Nullable collection, NSError *_Nullable error, NSHTTPURLResponse *_Nullable response);

/**
 The callback handler for status MLCService requests
 
 @param success Boolean indicating if the action was successful.
 @param error An error identifier.
 @param response The URL response returned by the service request that includes the HTTP response codes.
 */
typedef void(^MLCServiceSuccessCompletionHandler)(BOOL success, NSError *_Nullable error, NSHTTPURLResponse *_Nullable response);

/**
 Base class for all Moblico service objects.
 */
@interface MLCService : NSObject <MLCServiceProtocol>

@end

NS_ASSUME_NONNULL_END
