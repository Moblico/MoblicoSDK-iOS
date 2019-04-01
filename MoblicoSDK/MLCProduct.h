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

@class MLCMedia;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MLCProductCompareOrder) {
    MLCProductCompareOrderTitle,
    MLCProductCompareOrderRevDate
} NS_SWIFT_NAME(MLCProduct.CompareOrder);

NS_SWIFT_NAME(Product)
@interface MLCProduct : MLCEntity

@property (nonatomic) NSUInteger productId NS_SWIFT_NAME(id);
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy, nullable) NSString *price;
@property (nonatomic, copy, nullable) NSString *legalese;
@property (nonatomic, copy, nullable) NSString *details;
@property (nonatomic, copy, nullable) NSString *sku;
@property (nonatomic, copy, nullable) NSURL *url;
@property (nonatomic, copy, nullable) NSString *productType;
@property (nonatomic, copy, nullable) NSString *specifications;
@property (nonatomic, copy, nullable) NSString *salesRepEmail;
@property (nonatomic, copy, nullable) NSString *salesRepName;
@property (nonatomic, copy, nullable) NSString *distribution;
@property (nonatomic, copy, nullable) NSString *externalId;
@property (nonatomic, getter=isActive) BOOL active;
@property (nonatomic, getter=isDiscontinued) BOOL discontinued;
@property (nonatomic, getter=isInstock) BOOL instock;
@property (nonatomic, getter=isRevised) BOOL revised;
@property (nonatomic, getter=isEmailable) BOOL emailable;
@property (nonatomic) BOOL mustContactSalesRep;
@property (nonatomic, strong, nullable) NSDate *introDate;
@property (nonatomic, strong) NSDate *lastUpdateDate;
@property (nonatomic, strong, nullable) NSDate *revDate;
@property (nonatomic, strong, nullable) NSDate *expirationDate;
@property (nonatomic, strong, nullable) MLCMedia *media;

- (NSComparisonResult)compare:(MLCProduct *)product order:(MLCProductCompareOrder)order;
- (NSComparisonResult)compare:(MLCProduct *)product;

@end

NS_ASSUME_NONNULL_END
