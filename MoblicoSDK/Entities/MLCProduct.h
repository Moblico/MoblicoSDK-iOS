//
//  MLCProduct.h
//  MoblicoSDK
//
//  Created by Cameron Knight on 7/1/14.
//  Copyright (c) 2014 Moblico Solutions LLC. All rights reserved.
//

#import <MoblicoSDK/MLCEntity.h>

@class MLCMedia;

@interface MLCProduct : MLCEntity

@property (nonatomic) NSUInteger productId;
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

@end
