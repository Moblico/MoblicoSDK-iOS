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

#import "MLCAd.h"
#import "MLCEntity_Private.h"
#import "MLCImage.h"

@implementation MLCAd

- (instancetype)initWithJSONObject:(NSDictionary *)jsonObject {
    NSMutableDictionary *adJson = [jsonObject mutableCopy];
    NSString *clickToCall = [MLCEntity stringFromValue:adJson[@"clickToCall"]];
    if (clickToCall.length > 0 && ![clickToCall hasPrefix:@"tel:"]) {
        adJson[@"clickToCall"] = [@"tel:" stringByAppendingString:clickToCall];
    }

    self = [super initWithJSONObject:adJson];

    if (self) {
        _image = [[MLCImage alloc] initWithJSONObject:adJson[@"image"]];
    }

    return self;
}

@end
