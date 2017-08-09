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

#import "MLCProductsService.h"
#import "MLCProduct.h"
#import "MLCService_Private.h"

@implementation MLCProductsService

+ (Class<MLCEntityProtocol>)classForResource {
    return [MLCProduct class];
}

+ (instancetype)findProductsWithFilters:(NSString *)filters handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self findProductsWithFilters:filters productTypes:nil handler:handler];
}

+ (instancetype)findProductsWithProductTypes:(NSArray *)productTypes handler:(MLCServiceCollectionCompletionHandler)handler {
    return [self findProductsWithFilters:nil productTypes:productTypes handler:handler];
}

+ (instancetype)findProductsWithFilters:(NSString *)filters productTypes:(NSArray *)productTypes handler:(MLCServiceCollectionCompletionHandler)handler {
    NSMutableDictionary *parameters = [@{} mutableCopy];

    if (productTypes.count) {
        parameters[@"productTypes"] = [productTypes componentsJoinedByString:@","];
    }

    if (filters.length) {
        parameters[@"filters"] = filters;
    }

    if (parameters.count) {
        return [self findResourcesWithSearchParameters:parameters handler:handler];
    }

    return [self listResources:handler];
}


@end
