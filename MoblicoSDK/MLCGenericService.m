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

#import "MLCGenericService.h"
#import "MLCService_Private.h"

@implementation MLCGenericService

+ (instancetype)create:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceResourceCompletionHandler)handler {
    return [self _create:path parameters:parameters handler:handler];
}

+ (instancetype)update:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceSuccessCompletionHandler)handler {
    return [self _update:path parameters:parameters handler:handler];
}

+ (instancetype)destroy:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceSuccessCompletionHandler)handler {
    return [self _destroy:path parameters:parameters handler:handler];
}

+ (instancetype)read:(NSString *)path parameters:(NSDictionary *)parameters handler:(MLCServiceResourceCompletionHandler)handler {
    return [self _read:path parameters:parameters handler:handler];
}

+ (instancetype)find:(NSString *)path searchParameters:(NSDictionary *)searchParameters handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self _find:path searchParameters:searchParameters handler:handler];
}

+ (instancetype)service:(NSString *)method path:(NSString *)path parameters:(NSDictionary<NSString *, id> *)parameters handler:(MLCServiceJSONCompletionHandler)handler {
    return [self _service:method path:path parameters:parameters handler:handler];
}

+ (instancetype)invalidServiceWithError:(MLCServiceError *)error handler:(MLCServiceJSONCompletionHandler)handler {
    return [self _invalidServiceWithError:error handler:handler];
}

+ (instancetype)invalidServiceFailedWithError:(MLCServiceError *)error handler:(MLCServiceSuccessCompletionHandler)handler {
    return [self _invalidServiceFailedWithError:error handler:handler];
}

+ (Class)classForResource {
    return [super classForResource];
}

@end
