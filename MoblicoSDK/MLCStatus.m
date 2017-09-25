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

#import "MLCStatus.h"

NSErrorDomain const MLCStatusErrorDomain = @"MLCStatusErrorDomain";
NSErrorUserInfoKey const MLCStatusStatusErrorKey = @"status";

@implementation MLCStatus

- (instancetype)initWithJSONObject:(NSDictionary *)jsonObject {
    NSMutableDictionary *statusParameters = [jsonObject mutableCopy];

    NSNumber *statusType = statusParameters[@"statusType"];
    [statusParameters removeObjectForKey:@"statusType"];

    self = [super initWithJSONObject:statusParameters];

    if (self) {
        if (statusType && (id)statusType != [NSNull null]) {
            _type = (MLCStatusType)statusType.integerValue;
        } else {
            _type = MLCStatusTypeMissing;
        }
    }

    return self;
}

+ (instancetype)statusFromError:(NSError *)error {
    if (error && [error.domain isEqualToString:MLCStatusErrorDomain]) {
        return error.userInfo[MLCStatusStatusErrorKey];
    }

    return nil;
}

+ (MLCStatusType)typeFromError:(NSError *)error {
    MLCStatus *status = [self statusFromError:error];
    if (status) {
        NSAssert(status.type == error.code, @"status.type does not match error.code: (%@ %@) (%@ %@)", status, @(status.type), error, @(error.code));
        return status.type;
    }

    return MLCStatusTypeMissing;
}

@end

@implementation MLCStatusError

- (MLCStatus *)status {
    return self.userInfo[MLCStatusStatusErrorKey];
}

- (instancetype)initWithStatus:(MLCStatus *)status {
    NSString *message = status.message;
    if (!message) {
        message = @"Unknown Error";
    }
    NSDictionary<NSErrorUserInfoKey, id> *userInfo = @{NSLocalizedDescriptionKey: message,
                               MLCStatusStatusErrorKey: status};
    self = [super initWithDomain:MLCStatusErrorDomain code:status.type userInfo:userInfo];
    return self;
}

@end
