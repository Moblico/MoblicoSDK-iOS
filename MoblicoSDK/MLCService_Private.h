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

typedef void(^MLCServiceInternalJSONCompletionHandler)(MLCService *service, id jsonObject,  NSError *error, NSHTTPURLResponse *response);

@interface MLCService () <NSURLConnectionDataDelegate>
@property (copy, nonatomic) MLCServiceInternalJSONCompletionHandler jsonCompletionHandler;
@property (strong, nonatomic) NSURLConnection *connection;
@property (copy, nonatomic) NSURLRequest *request;
@property (strong, nonatomic) NSMutableData *receivedData;
@property (strong, nonatomic) NSHTTPURLResponse *httpResponse;
@property (strong, nonatomic) dispatch_group_t dispatchGroup;

+ (instancetype)create:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceResourceCompletionHandler)handler;
+ (instancetype)createResource:(id<MLCEntityProtocol>)resource handler:(MLCServiceResourceCompletionHandler)handler;

+ (instancetype)update:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceSuccessCompletionHandler)handler;
+ (instancetype)updateResource:(id<MLCEntityProtocol>)resource handler:(MLCServiceSuccessCompletionHandler)handler;

+ (instancetype)destroy:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceSuccessCompletionHandler)handler;
+ (instancetype)destroyResource:(id<MLCEntityProtocol>)resource handler:(MLCServiceSuccessCompletionHandler)handler;

+ (instancetype)read:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceResourceCompletionHandler)handler;
+ (instancetype)readResourceWithUniqueIdentifier:(id)uniqueIdentifier handler:(MLCServiceResourceCompletionHandler)handler;

+ (instancetype)list:(NSString *)path handler:(MLCServiceCollectionCompletionHandler)handler;
+ (instancetype)listResources:(MLCServiceCollectionCompletionHandler)handler;
+ (instancetype)listScopedResourcesForResource:(id<MLCEntityProtocol>)resource handler:(MLCServiceCollectionCompletionHandler)handler;

+ (instancetype)find:(NSString *)path searchParameters:(NSDictionary *)searchParameters handler:(MLCServiceCollectionCompletionHandler)handler;
+ (instancetype)findResourcesWithSearchParameters:(NSDictionary *)searchParameters handler:(MLCServiceCollectionCompletionHandler)handler;
+ (instancetype)findScopedResourcesForResource:(id<MLCEntityProtocol>)resource searchParameters:(NSDictionary *)searchParameters handler:(MLCServiceCollectionCompletionHandler)handler;

+ (NSArray<NSString *> *)scopeableResources;
+ (BOOL)canScopeResource:(id<MLCEntityProtocol>)resource;

+ (NSURLRequest *)requestWithMethod:(MLCServiceRequestMethod)method path:(NSString *)path parameters:(NSDictionary *)parameters;
+ (NSString *)stringFromMLCServiceRequestMethod:(MLCServiceRequestMethod)method;
+ (NSString *)stringWithPercentEscapesAddedToString:(NSString *)string;

+ (instancetype)serviceForMethod:(MLCServiceRequestMethod)method path:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceInternalJSONCompletionHandler)handler;

+ (id<MLCEntityProtocol>)deserializeResource:(NSDictionary *)resource;
+ (NSArray<MLCEntityProtocol> *)deserializeArray:(NSArray *)array;
+ (Class<MLCEntityProtocol>)classForResource;

@end
