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

#import <MoblicoSDK/MLCEntity.h>

NS_ASSUME_NONNULL_BEGIN

@class MLCProductType;

NS_SWIFT_NAME(ProductCategory)
@interface MLCProductCategory : MLCEntity

@property (nonatomic) NSUInteger productCategoryId NS_SWIFT_NAME(id);
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray<MLCProductType *> *productTypes;

@end

NS_ASSUME_NONNULL_END
