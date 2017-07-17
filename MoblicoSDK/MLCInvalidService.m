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

#import "MLCInvalidService.h"

NSString *const MLCServiceErrorDomain = @"MLCServiceErrorDomain";
NSString *const MLCServiceDetailedErrorsKey = @"MLCServiceDetailedErrorsKey";

@implementation MLCInvalidService

+ (instancetype)invalidServiceFailedWithError:(NSError *)error handler:(MLCInvalidServiceFailedCompletionHandler)handler {
    return [self invalidServiceFailedWithError:error response:nil handler:handler];
}

+ (instancetype)invalidServiceFailedWithError:(NSError *)error response:(NSHTTPURLResponse *)response handler:(MLCInvalidServiceFailedCompletionHandler)handler {
    MLCInvalidService *service = [[self alloc] init];
    service.error = error;
    service.successHandler = handler;
    service.response = response;

    return service;
}

+ (instancetype)invalidServiceWithError:(NSError *)error handler:(MLCInvalidServiceCompletionHandler)handler {
    return [self invalidServiceWithError:error response:nil handler:handler];
}

+ (instancetype)invalidServiceWithError:(NSError *)error response:(NSHTTPURLResponse *)response handler:(MLCInvalidServiceCompletionHandler)handler {
    MLCInvalidService *service = [[self alloc] init];
    service.error = error;
    service.jsonHandler = handler;
    service.response = response;
    
    return service;
}

- (void)start {
    if (self.jsonHandler) {
        self.jsonHandler(nil, self.error, self.response);
    }
    if (self.successHandler) {
        self.successHandler(NO, self.error, self.response);
    }
}

- (void)cancel {
    
}

+ (NSError *)serviceErrorWithCode:(MLCServiceErrorCode)code description:(NSString *)description recoverySuggestion:(NSString *)recoverySuggestion {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];

    if (description.length) {
        userInfo[NSLocalizedDescriptionKey] = description;
    }

    if (recoverySuggestion.length) {
        userInfo[NSLocalizedRecoverySuggestionErrorKey] = recoverySuggestion;
    }

    if (userInfo.count) {
        return [NSError errorWithDomain:MLCServiceErrorDomain code:code userInfo:userInfo];
    }

    return [NSError errorWithDomain:MLCServiceErrorDomain code:code userInfo:userInfo];
}

+ (NSError *)serviceErrorWithErrors:(NSArray<NSError *> *)errors {
    return [NSError errorWithDomain:MLCServiceErrorDomain code:MLCServiceErrorCodeMultipleErrors userInfo:@{MLCServiceDetailedErrorsKey: errors}];
}


@end
