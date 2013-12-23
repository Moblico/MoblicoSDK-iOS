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
@protocol MLCEntity;

/**
 All MLCService objects conform to the MLCService protocol.
 */
@protocol MLCService <NSObject>
@required
- (void)start;
- (void)cancel;
@end


@class MLCStatus;

/**
 Indicates the method used in the request
 */
typedef NS_ENUM(NSUInteger, MLCServiceRequestMethod) {
    /**
     Requests a representation of the specified resource.
     */
	MLCServiceRequestMethodGET,
    
    /**
     Creates a resource.
     */
	MLCServiceRequestMethodPOST,
    
    /**
     Updates the specified resource.
     */
	MLCServiceRequestMethodPUT,
    
    /* Deletes the specified resource.*/
	MLCServiceRequestMethodDELETE
};

/**
 The callback handler for JSON MLCService requests
 
 The parameters for this handler are:

 @param jsonObject The JSON data returned by the service request.
 @param error An error identifier.
 @param response The URL response returned by the service request that includes the HTTP response codes.
 */
typedef void(^MLCServiceJSONCompletionHandler)(id jsonObject, NSError *error, NSHTTPURLResponse *response);


/**
 The callback handler for resource MLCService requests
 
 The parameters for this handler are:

 @param resource The object returned by the service request.
 @param error An error identifier.
 @param response The URL response returned by the service request that includes the HTTP response codes.
 */
typedef void(^MLCServiceResourceCompletionHandler)(id<MLCEntity> resource, NSError *error, NSHTTPURLResponse *response);

/**
 The callback handler for collection MLCService requests
 
 The parameters for this handler are:

 @param collection The array of resources returned by the service request.
 @param error An error identifier.
 @param response The URL response returned by the service request that includes the HTTP response codes.
 */
typedef void(^MLCServiceCollectionCompletionHandler)(NSArray *collection, NSError *error, NSHTTPURLResponse *response);

/**
 The callback handler for status MLCService requests
 
 The parameters for this handler are:
 @param status The status returned by the service request.
 @param error An error identifier.
 @param response The URL response returned by the service request that includes the HTTP response codes.
 */
typedef void(^MLCServiceStatusCompletionHandler)(MLCStatus *status, NSError *error, NSHTTPURLResponse *response);

/**
 Base class for all Moblico service objects.
 */
@interface MLCService : NSObject <MLCService>
@end
