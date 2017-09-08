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

typedef NS_ENUM(NSUInteger, MLCProductCompareOrder) {
    MLCProductCompareOrderTitle,
    MLCProductCompareOrderRevDate
} NS_SWIFT_NAME(MLCProduct.CompareOrder);

NS_SWIFT_NAME(Product)
@interface MLCProduct : MLCEntity

@property (nonatomic) NSUInteger productId NS_SWIFT_NAME(id);
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, copy) NSString *legalese;
@property (nonatomic, copy) NSString *details;
@property (nonatomic, copy) NSString *sku;
@property (nonatomic, copy) NSURL *url;
@property (nonatomic, copy) NSString *productType;
@property (nonatomic, copy) NSString *specifications;
@property (nonatomic, copy) NSString *salesRepEmail;
@property (nonatomic, copy) NSString *salesRepName;
@property (nonatomic, copy) NSString *distribution;
@property (nonatomic, copy) NSString *externalId;
@property (nonatomic, getter=isActive) BOOL active;
@property (nonatomic, getter=isDiscontinued) BOOL discontinued;
@property (nonatomic, getter=isInstock) BOOL instock;
@property (nonatomic, getter=isRevised) BOOL revised;
@property (nonatomic, getter=isEmailable) BOOL emailable;
@property (nonatomic) BOOL mustContactSalesRep;
@property (nonatomic, strong) NSDate *introDate;
@property (nonatomic, strong) NSDate *lastUpdateDate;
@property (nonatomic, strong) NSDate *revDate;
@property (nonatomic, strong) NSDate *expirationDate;
@property (nonatomic, strong) MLCMedia *media;

- (NSComparisonResult)compare:(MLCProduct *)product order:(MLCProductCompareOrder)order;
- (NSComparisonResult)compare:(MLCProduct *)product;

@end
