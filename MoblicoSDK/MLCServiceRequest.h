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

typedef NSString *MLCServiceRequestHeaderKey NS_TYPED_EXTENSIBLE_ENUM NS_SWIFT_NAME(MLCServiceRequest.HeaderKey);

FOUNDATION_EXPORT MLCServiceRequestHeaderKey const MLCServiceRequestHeaderKeyAccept;
FOUNDATION_EXPORT MLCServiceRequestHeaderKey const MLCServiceRequestHeaderKeyContentType;
FOUNDATION_EXPORT MLCServiceRequestHeaderKey const MLCServiceRequestHeaderKeyAuthorization;
FOUNDATION_EXPORT MLCServiceRequestHeaderKey const MLCServiceRequestHeaderKeyUserAgent;

/**
 Indicates the method used in the request
 */
typedef NSString *MLCServiceRequestMethod NS_TYPED_ENUM NS_SWIFT_NAME(MLCServiceRequest.Method);

/// Requests a representation of the specified resource.
FOUNDATION_EXPORT MLCServiceRequestMethod const MLCServiceRequestMethodGET;
/// Creates a resource.
FOUNDATION_EXPORT MLCServiceRequestMethod const MLCServiceRequestMethodPOST;
/// Updates the specified resource.
FOUNDATION_EXPORT MLCServiceRequestMethod const MLCServiceRequestMethodPUT;
/// Deletes the specified resource.
FOUNDATION_EXPORT MLCServiceRequestMethod const MLCServiceRequestMethodDELETE;

@interface MLCServiceRequest : NSObject

@property (nonatomic, strong, readonly, nullable) NSURL *URL;
@property (nonatomic, copy, readonly) MLCServiceRequestMethod method;
@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> *headers;
@property (nonatomic, copy, readonly, nullable) NSData *body;
@property (nonatomic, copy, readonly, nullable) NSURLRequest *URLRequest;

+ (instancetype)requestWithMethod:(MLCServiceRequestMethod)method path:(NSString *)servicePath parameters:(nullable NSDictionary *)parameters;

@end

NS_ASSUME_NONNULL_END
