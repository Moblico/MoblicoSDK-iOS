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

#import "MLCDeal.h"
#import "MLCImage.h"

@implementation MLCDeal

+ (instancetype)deserialize:(NSDictionary *)jsonObject {
    
    MLCDeal *deal = [super deserialize:jsonObject];
    
    if (![deal.image isKindOfClass:[NSDictionary class]]) return deal;
    
    NSDictionary * image = (NSDictionary *)deal.image;
    if ([image count]) {
        deal.image = [MLCImage deserialize:image];
    } else {
        deal.image = nil;
    }
    
    return deal;
}

- (NSDictionary *)serialize {
    NSMutableDictionary *serializedObject = [[super serialize] mutableCopy];
    
    if (self.image) {
        serializedObject[@"image"] = [self.image serialize];
    }
    
    return [serializedObject mutableCopy];
}

@end
