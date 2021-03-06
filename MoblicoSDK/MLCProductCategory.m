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

#import "MLCProductCategory.h"
#import "MLCProductType.h"

@implementation MLCProductCategory

+ (NSString *)collectionName {
    return @"product_categories";
}

- (instancetype)initWithJSONObject:(NSDictionary *)jsonObject {
    self = [super initWithJSONObject:jsonObject];

    if (self) {
        NSArray *jsonProductTypes = jsonObject[@"productTypes"];
        if ([jsonProductTypes isKindOfClass:[NSArray class]] && jsonProductTypes.count > 0) {
            NSMutableArray *productTypes = [NSMutableArray arrayWithCapacity:jsonProductTypes.count];

            for (id jsonProductType in jsonProductTypes) {
                MLCProductType *productType = [[MLCProductType alloc] initWithJSONObject:jsonProductType];
                if (productType) {
                    [productTypes addObject:productType];
                }
            }

            _productTypes = [productTypes copy];
        } else {
            _productTypes = @[];
        }
    }

    return self;
}

@end
