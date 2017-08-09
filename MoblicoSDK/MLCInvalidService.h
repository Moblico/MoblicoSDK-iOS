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

FOUNDATION_EXPORT NSString *const MLCServiceErrorDomain;
FOUNDATION_EXPORT NSString *const MLCServiceDetailedErrorsKey;

typedef NS_ENUM(NSUInteger, MLCServiceErrorCode) {
    MLCServiceErrorCodeMissingParameter = 1000,
    MLCServiceErrorCodeInvalidParameter,
    MLCServiceErrorCodeInternalError,
    MLCServiceErrorCodeMultipleErrors
};

typedef void(^MLCInvalidServiceCompletionHandler)(id jsonObject, NSError *error, NSHTTPURLResponse *response);
typedef void(^MLCInvalidServiceFailedCompletionHandler)(BOOL success, NSError *error, NSHTTPURLResponse *response);

@interface MLCInvalidService : NSObject <MLCServiceProtocol>

@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) NSHTTPURLResponse *response;
@property (nonatomic, strong) MLCInvalidServiceCompletionHandler jsonHandler;
@property (nonatomic, strong) MLCInvalidServiceFailedCompletionHandler successHandler;

+ (instancetype)invalidServiceWithError:(NSError *)error response:(NSHTTPURLResponse *)response handler:(MLCInvalidServiceCompletionHandler)handler;
+ (instancetype)invalidServiceFailedWithError:(NSError *)error response:(NSHTTPURLResponse *)response handler:(MLCInvalidServiceFailedCompletionHandler)handler;
+ (instancetype)invalidServiceWithError:(NSError *)error handler:(MLCInvalidServiceCompletionHandler)handler;
+ (instancetype)invalidServiceFailedWithError:(NSError *)error handler:(MLCInvalidServiceFailedCompletionHandler)handler;

+ (NSError *)serviceErrorWithCode:(MLCServiceErrorCode)code description:(NSString *)description recoverySuggestion:(NSString *)recoverySuggestion;
+ (NSError *)serviceErrorWithErrors:(NSArray<NSError *> *)errors;

@end