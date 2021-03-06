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

#import "MLCCredential.h"

@implementation MLCCredential

- (instancetype)initWithJSONObject:(NSDictionary<NSString *, id> *)jsonObject {
    self = [super initWithJSONObject:jsonObject];
    if (self) {
        NSMutableDictionary *accountDictionary = [NSMutableDictionary dictionary];
        accountDictionary[@"id"] = jsonObject[@"accountId"];
        accountDictionary[@"name"] = jsonObject[@"accountName"];
        accountDictionary[@"parentId"] = jsonObject[@"parentAccountId"];
        accountDictionary[@"companyName"] = jsonObject[@"companyName"];
        _account = [[MLCAccount alloc] initWithJSONObject:accountDictionary];
    }
    return self;
}

@end

@implementation MLCAccount

@end
