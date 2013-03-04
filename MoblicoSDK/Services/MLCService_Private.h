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

@interface MLCService () <NSURLConnectionDataDelegate>
@property (strong, nonatomic) MLCServiceJSONCompletionHandler jsonCompletionhandler;
@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) NSURLRequest *request;
@property (strong, nonatomic) NSMutableData *receivedData;
@property (strong, nonatomic) NSHTTPURLResponse *httpResponse;

+ (id)create:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceStatusCompletionHandler)handler;
+ (id)createResource:(id<MLCEntityProtocol>)resource handler:(MLCServiceStatusCompletionHandler)handler;

+ (id)update:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceStatusCompletionHandler)handler;
+ (id)updateResource:(id<MLCEntityProtocol>)resource handler:(MLCServiceStatusCompletionHandler)handler;

+ (id)destroy:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceStatusCompletionHandler)handler;
+ (id)destroyResource:(id<MLCEntityProtocol>)resource handler:(MLCServiceStatusCompletionHandler)handler;

+ (id)read:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceResourceCompletionHandler)handler;
+ (id)readResourceWithUniqueIdentifier:(id)uniqueIdentifier handler:(MLCServiceResourceCompletionHandler)handler;

+ (id)list:(NSString *)path handler:(MLCServiceCollectionCompletionHandler)handler;
+ (id)listResources:(MLCServiceCollectionCompletionHandler)handler;
+ (id)listScopedResourcesForResource:(id<MLCEntityProtocol>)resource handler:(MLCServiceCollectionCompletionHandler)handler;

+ (id)find:(NSString *)path searchParameters:(NSDictionary *)searchParameters handler:(MLCServiceCollectionCompletionHandler)handler;
+ (id)findResourcesWithSearchParameters:(NSDictionary *)searchParameters handler:(MLCServiceCollectionCompletionHandler)handler;
+ (id)findScopedResourcesForResource:(id<MLCEntityProtocol>)resource searchParameters:(NSDictionary *)searchParameters handler:(MLCServiceCollectionCompletionHandler)handler;

+ (NSArray *)scopeableResources;
+ (BOOL)canScopeResource:(id<MLCEntityProtocol>)resource;

+ (id)requestWithMethod:(MLCServiceRequestMethod)method path:(NSString *)path parameters:(NSDictionary *)parameters;
+ (NSString *)stringFromMLCServiceRequestMethod:(MLCServiceRequestMethod)method;
+ (NSString *)stringWithPercentEscapesAddedToString:(NSString *)string;

+ (id)serviceForMethod:(MLCServiceRequestMethod)method path:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceJSONCompletionHandler)handler;

+ (id)deserializeResource:(NSDictionary *)resource;
+ (NSArray *)deserializeArray:(NSArray *)array;
+ (Class<MLCEntityProtocol>)classForResource;

@end
