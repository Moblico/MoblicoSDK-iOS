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

#import "MLCAuthenticationToken.h"
#import "MLCEntity_Private.h"

@implementation MLCAuthenticationToken

- (instancetype)initWithJSONObject:(NSDictionary<NSString *, id> *)jsonObject {
    NSString *token = [MLCEntity nilIfEmptyStringFromValue:jsonObject[@"token"]];
    NSDate *tokenExpiry = [MLCEntity dateFromTimestampValue:jsonObject[@"tokenExpiry"]];

    if (!token || !tokenExpiry) {
        return nil;
    }

    self = [super initWithJSONObject:jsonObject];
    return self;
}

+ (NSString *)collectionName {
    return @"authenticate";
}

- (BOOL)isValid {
    NSDate *now = [NSDate date];

    return ([self.tokenExpiry earlierDate:now] == now);
}

@end
