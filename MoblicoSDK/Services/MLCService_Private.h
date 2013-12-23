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

+ (instancetype)create:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceStatusCompletionHandler)handler;
+ (instancetype)createResource:(id<MLCEntity>)resource handler:(MLCServiceStatusCompletionHandler)handler;

+ (instancetype)update:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceStatusCompletionHandler)handler;
+ (instancetype)updateResource:(id<MLCEntity>)resource handler:(MLCServiceStatusCompletionHandler)handler;

+ (instancetype)destroy:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceStatusCompletionHandler)handler;
+ (instancetype)destroyResource:(id<MLCEntity>)resource handler:(MLCServiceStatusCompletionHandler)handler;

+ (instancetype)read:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceResourceCompletionHandler)handler;
+ (instancetype)readResourceWithUniqueIdentifier:(id)uniqueIdentifier handler:(MLCServiceResourceCompletionHandler)handler;

+ (instancetype)list:(NSString *)path handler:(MLCServiceCollectionCompletionHandler)handler;
+ (instancetype)listResources:(MLCServiceCollectionCompletionHandler)handler;
+ (instancetype)listScopedResourcesForResource:(id<MLCEntity>)resource handler:(MLCServiceCollectionCompletionHandler)handler;

+ (instancetype)find:(NSString *)path searchParameters:(NSDictionary *)searchParameters handler:(MLCServiceCollectionCompletionHandler)handler;
+ (instancetype)findResourcesWithSearchParameters:(NSDictionary *)searchParameters handler:(MLCServiceCollectionCompletionHandler)handler;
+ (instancetype)findScopedResourcesForResource:(id<MLCEntity>)resource searchParameters:(NSDictionary *)searchParameters handler:(MLCServiceCollectionCompletionHandler)handler;

+ (NSArray *)scopeableResources;
+ (BOOL)canScopeResource:(id<MLCEntity>)resource;

+ (NSURLRequest *)requestWithMethod:(MLCServiceRequestMethod)method path:(NSString *)path parameters:(NSDictionary *)parameters;
+ (NSString *)stringFromMLCServiceRequestMethod:(MLCServiceRequestMethod)method;
+ (NSString *)stringWithPercentEscapesAddedToString:(NSString *)string;

+ (instancetype)serviceForMethod:(MLCServiceRequestMethod)method path:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceJSONCompletionHandler)handler;

+ (id<MLCEntity>)deserializeResource:(NSDictionary *)resource;
+ (NSArray *)deserializeArray:(NSArray *)array;
+ (Class<MLCEntity>)classForResource;

@end
