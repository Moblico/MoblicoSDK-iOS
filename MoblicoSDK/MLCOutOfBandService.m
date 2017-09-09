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

#import "MLCOutOfBandService.h"
#import "MLCService_Private.h"

@implementation MLCOutOfBandService

+ (instancetype)read:(NSString *)endPoint parameters:(NSDictionary<NSString *,id> *)parameters handler:(MLCServiceJSONCompletionHandler)handler {
    return [self outOfBandMethod:MLCServiceRequestMethodGET endPoint:endPoint parameters:parameters handler:handler];
}

+ (instancetype)create:(NSString *)endPoint parameters:(NSDictionary<NSString *,id> *)parameters handler:(MLCServiceJSONCompletionHandler)handler {
    return [self outOfBandMethod:MLCServiceRequestMethodPOST endPoint:endPoint parameters:parameters handler:handler];
}

+ (instancetype)outOfBandMethod:(MLCServiceRequestMethod)method endPoint:(NSString *)endPoint parameters:(NSDictionary *)parameters handler:(MLCServiceJSONCompletionHandler)handler {
    NSString *path = [@"outofband" stringByAppendingPathComponent:endPoint];
    return [self service:method path:path parameters:parameters handler:handler];

}

@end
