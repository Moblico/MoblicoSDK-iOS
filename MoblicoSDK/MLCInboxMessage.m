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

#import "MLCInboxMessage.h"

@implementation MLCInboxMessage

+ (NSString *)collectionName {
    return @"inbox";
}

- (instancetype)initWithJSONObject:(NSDictionary<NSString *,id> *)jsonObject {
    NSMutableDictionary *object = [jsonObject mutableCopy];
    NSData *payloadData = [jsonObject[@"payload"] dataUsingEncoding:NSUTF8StringEncoding];
    object[@"payload"] = payloadData ? [NSJSONSerialization JSONObjectWithData:payloadData options:0 error:nil] : nil;
    self = [super initWithJSONObject:object];
    return self;
}

@end