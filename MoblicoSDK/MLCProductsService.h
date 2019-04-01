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

NS_ASSUME_NONNULL_BEGIN

@class MLCProduct;

MLCServiceCreateCollectionCompletionHandler(MLCProductsService, MLCProduct);

NS_SWIFT_NAME(ProductsService)
@interface MLCProductsService : MLCService

+ (instancetype)listProducts:(MLCProductsServiceCollectionCompletionHandler)handler;

+ (instancetype)findProductsWithFilters:(NSString *)filters handler:(MLCProductsServiceCollectionCompletionHandler)handler;

+ (instancetype)findProductsWithProductTypes:(NSArray<NSString *> *)productTypes handler:(MLCProductsServiceCollectionCompletionHandler)handler;

+ (instancetype)findProductsWithFilters:(NSString *)filters productTypes:(NSArray<NSString *> *)productTypes handler:(MLCProductsServiceCollectionCompletionHandler)handler;

@end

NS_ASSUME_NONNULL_END
