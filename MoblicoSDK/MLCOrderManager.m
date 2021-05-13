//
//  MLCOrderManager.m
//  MoblicoSDK
//
//  Created by Cameron Knight on 12/4/19.
//  Copyright © 2019 Moblico. All rights reserved.
//

#import "MLCOrderManager.h"
#import <CommonCrypto/CommonDigest.h>

static NSString *const OrderHistoryKey = @"orderHistory";

@interface MLCOrderManager ()
@property(nonatomic, strong) NSUserDefaults *sharedDefaults;
@end

@implementation MLCOrderManager

+ (MLCOrderManager *)sharedOrderManager {
    static dispatch_once_t onceToken;
    static MLCOrderManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[MLCOrderManager alloc] init];
    });
    return manager;
}

static NSString *_groupId = nil;

+ (NSString *)groupId {
    return _groupId;
}

+ (void)setGroupId:(NSString *)groupId {
    _groupId = groupId;
}

- (NSUserDefaults *)sharedDefaults {
    if (!_sharedDefaults) {
        _sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:_groupId];
    }
    return _sharedDefaults;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self reload];
    }
    return self;
}

- (void)clear {
    self.orderHistory.currentOrder = [self.orderHistory.currentOrder copy];
    self.orderHistory.currentOrder.products = @[];
    self.orderHistory.currentOrder.createDate = [NSDate date];
    self.orderHistory.currentOrder.comments = @"";
    self.orderHistory.currentOrder.baseId = nil;
    [self save];
}

- (void)add:(NSString *)partNumber quantity:(NSInteger)quantity {
    NSMutableArray *orderItems = [self.products mutableCopy] ?: [NSMutableArray array];
    BOOL found = NO;
    for (MLCOrderItem *other in orderItems) {
        if ([other.productId isEqualToString:partNumber]) {
            other.quantity += quantity;
            found = YES;
            break;
        }
    }
    if (!found) {
        MLCOrderItem *item = [[MLCOrderItem alloc] init];
        item.productId = partNumber;
        item.quantity = quantity;
        [orderItems addObject:item];
    }

    self.products = orderItems;
    [self save];
}

- (NSString *)sha1Hash:(NSData *)data {
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];

    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);

    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];

    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }

    return output;
}

- (void)addImage:(NSData *)imageData quantity:(NSInteger)quantity {
    NSString *partNumber = [self sha1Hash:imageData];
    NSMutableArray *orderItems = [self.products mutableCopy] ?: [NSMutableArray array];
    BOOL found = NO;
    for (MLCOrderItem *other in orderItems) {
        if ([other.productId isEqualToString:partNumber]) {
            other.quantity += quantity;
            found = YES;
            break;
        }
    }
    if (!found) {
        MLCOrderItem *item = [[MLCOrderItem alloc] init];
        item.productId = partNumber;
        item.imageData = imageData;
        item.quantity = quantity;
        [orderItems addObject:item];
    }

    self.products = orderItems;
    [self save];
}

- (void)addPendingOrder:(MLCOrder *)order {
    NSMutableArray *pendingOrders = [self.orderHistory.pendingOrders mutableCopy] ?: [NSMutableArray array];
    [pendingOrders insertObject:order atIndex:0];
    //    [pendingOrders addObject:order];
    self.orderHistory.pendingOrders = pendingOrders;
    [self save];
}

- (void)removePendingOrderAtIndex:(NSUInteger)idx {
    NSMutableArray *pendingOrders = [self.orderHistory.pendingOrders mutableCopy] ?: [NSMutableArray array];
    if (idx >= pendingOrders.count) {
        return;
    }
    [pendingOrders removeObjectAtIndex:idx];
    self.orderHistory.pendingOrders = pendingOrders;
    [self save];
}

- (void)addCompletedOrder:(MLCOrder *)order {
    NSMutableArray *completedOrders = [self.orderHistory.completedOrders mutableCopy] ?: [NSMutableArray array];
    [completedOrders insertObject:order atIndex:0];
    //    [completedOrders addObject:order];
    self.orderHistory.completedOrders = completedOrders;
    [self save];
}

- (void)removeItemAtIndex:(NSUInteger)idx {
    NSMutableArray *orderItems = [self.products mutableCopy] ?: [NSMutableArray array];
    if (idx >= orderItems.count) {
        return;
    }
    [orderItems removeObjectAtIndex:idx];
    self.products = orderItems;
    [self save];
}

- (void)save {
    NSDictionary *orderHistory = self.orderHistory.dictionaryValue;
    [self.sharedDefaults setObject:orderHistory forKey:OrderHistoryKey];
    [self.sharedDefaults synchronize];
}

- (void)reload {
    NSDictionary *orderHistory = [self.sharedDefaults dictionaryForKey:OrderHistoryKey];
    self.orderHistory = [[MLCOrderHistory alloc] initWithDictionay:orderHistory];
}

- (NSArray *)products {
    [self reload];
    return self.orderHistory.currentOrder.products;
}

- (void)setProducts:(NSArray *)products {
    self.orderHistory.currentOrder.products = products;
}

@end

@implementation MLCOrderHistory

+ (NSDictionary *)serialize:(MLCOrderHistory *)orderHistory {
    return orderHistory.dictionaryValue;
}

- (MLCOrder *)currentOrder {
    if (!_currentOrder) {
        _currentOrder = [[MLCOrder alloc] initWithDictionay:@{}];
    }

    return _currentOrder;
}

- (nonnull NSDictionary *)dictionaryValue {
    NSDictionary *currentOrder = self.currentOrder.dictionaryValue;
    NSMutableArray *pendingOrders = [NSMutableArray array];
    for (MLCOrder *order in self.pendingOrders) {
        [pendingOrders addObject:order.dictionaryValue];
    }
    NSMutableArray *completedOrders = [NSMutableArray array];
    for (MLCOrder *order in self.completedOrders) {
        [completedOrders addObject:order.dictionaryValue];
    }
    return @{
        @"currentOrder": currentOrder,
        @"pendingOrders": pendingOrders,
        @"completedOrders": completedOrders,
    };
}

- (nonnull instancetype)initWithDictionay:(nonnull NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.currentOrder = [[MLCOrder alloc] initWithDictionay:dictionary[@"currentOrder"]];
        NSMutableArray *pendingOrders = [NSMutableArray array];
        for (NSDictionary *order in dictionary[@"pendingOrders"]) {
            [pendingOrders addObject:[[MLCOrder alloc] initWithDictionay:order]];
        }
        self.pendingOrders = pendingOrders;
        NSMutableArray *completedOrders = [NSMutableArray array];
        for (NSDictionary *order in dictionary[@"completedOrders"]) {
            [completedOrders addObject:[[MLCOrder alloc] initWithDictionay:order]];
        }
        NSDate *thirtyDaysAgo = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:-30 toDate:[NSDate date] options:0];
        [completedOrders filterUsingPredicate:[NSPredicate predicateWithFormat:@"lastUpdateDate >= %@", thirtyDaysAgo]];
        self.completedOrders = completedOrders;
    }
    return self;
}

@end

@implementation MLCOrder

- (id)copyWithZone:(nullable NSZone *)zone {
    return [[[self class] allocWithZone:zone] initWithDictionay:self.dictionaryValue];
}

- (nonnull NSDictionary *)dictionaryValue {
    NSMutableArray *products = [NSMutableArray array];
    for (MLCOrderItem *product in self.products) {
        [products addObject:product.dictionaryValue];
    }
    NSMutableArray *customFields = [NSMutableArray array];
    for (MLCCustomField *customField in self.customFields) {
        [customFields addObject:customField.dictionaryValue];
    }

    NSMutableDictionary *dictionaryValue = [@{
        @"firstName": self.firstName,
        @"lastName": self.lastName,
        @"emailAddress": self.emailAddress,
        @"phoneNumber": self.phoneNumber,
        @"products": products,
        @"customFields": customFields,
        @"comments": self.comments,
        @"emailToAddress": self.emailToAddress,
        @"createDate": self.createDate,
        @"lastUpdateDate": self.lastUpdateDate
    } mutableCopy];

    if (self.baseId.length > 0) {
        dictionaryValue[@"baseId"] = self.baseId;
    }

    return dictionaryValue;
}

- (nonnull instancetype)initWithDictionay:(nonnull NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.firstName = dictionary[@"firstName"] ?: @"";
        self.lastName = dictionary[@"lastName"] ?: @"";
        self.emailAddress = dictionary[@"emailAddress"] ?: @"";
        self.phoneNumber = dictionary[@"phoneNumber"] ?: @"";
        self.comments = dictionary[@"comments"] ?: @"";
        self.emailToAddress = dictionary[@"emailToAddress"] ?: @"";
        self.createDate = dictionary[@"createDate"] ?: [NSDate date];
        self.lastUpdateDate = dictionary[@"lastUpdateDate"] ?: [NSDate date];

        NSMutableArray *products = [NSMutableArray array];
        for (NSDictionary *orderItem in dictionary[@"products"]) {
            [products addObject:[[MLCOrderItem alloc] initWithDictionay:orderItem]];
        }
        self.products = products;

        NSMutableArray *customFields = [NSMutableArray array];
        for (NSDictionary *customField in dictionary[@"customFields"]) {
            [customFields addObject:[[MLCCustomField alloc] initWithDictionay:customField]];
        }
        self.customFields = customFields;

        self.baseId = dictionary[@"baseId"];
    }
    return self;
}

@end

@implementation MLCOrderItem

- (id)copyWithZone:(nullable NSZone *)zone {
    return [[[self class] allocWithZone:zone] initWithDictionay:self.dictionaryValue];
}

- (nonnull NSDictionary *)dictionaryValue {
    NSMutableDictionary *dictionaryValue = [@{
        @"productId": self.productId,
        @"imageData": [self.imageData base64EncodedStringWithOptions:0] ?: @"",
        @"note": self.note ?: @"",
        @"quantity": @(self.quantity)
    } mutableCopy];

    if (self.baseQuantity > 0) {
        dictionaryValue[@"baseQuantity"] = @(self.baseQuantity);
    }

    return dictionaryValue;
}

- (nonnull instancetype)initWithDictionay:(nonnull NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.productId = dictionary[@"productId"];
        NSString *base64String = dictionary[@"imageData"];
        if (base64String.length) {
            self.imageData = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
        }
        self.note = dictionary[@"note"] ?: dictionary[@"label"];
        self.quantity = [(dictionary[@"quantity"] ?: @0) integerValue];
        self.baseQuantity = [(dictionary[@"baseQuantity"] ?: @0) integerValue];
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[MLCOrderItem class]]) {
        return NO;
    }
    MLCOrderItem *other = (MLCOrderItem *)object;

    return [self.dictionaryValue isEqualToDictionary:other.dictionaryValue];
}

- (NSString *)description {
    NSMutableString *description = [super.description mutableCopy];
    [description appendFormat:@" productId: %@ note: %@ quantity: %@ imageData: %@", self.productId, self.note, @(self.quantity), self.imageData];
    if (self.baseQuantity > 0) {
        [description appendFormat:@" baseQuantity: %@", @(self.baseQuantity)];
    }
    return description;
}

@end

@implementation MLCCustomField

- (nonnull NSDictionary *)dictionaryValue {
    return @{
        @"name": self.name,
        @"value": self.value
    };
}

- (nonnull instancetype)initWithDictionay:(nonnull NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.name = dictionary[@"name"];
        self.value = dictionary[@"value"];
    }
    return self;
}

@end

@implementation MLCBaseOrder

- (id)copyWithZone:(nullable NSZone *)zone {
    return [[[self class] allocWithZone:zone] initWithDictionay:self.dictionaryValue];
}

- (nonnull NSDictionary *)dictionaryValue {
    NSMutableArray *products = [NSMutableArray array];
    for (MLCBaseOrderItem *product in self.products) {
        [products addObject:product.dictionaryValue];
    }

    return @{
        @"baseId": self.baseId,
        @"products": products
    };
}

- (nonnull instancetype)initWithDictionay:(nonnull NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.baseId = dictionary[@"baseId"] ?: @"";

        NSMutableArray *products = [NSMutableArray array];
        for (NSDictionary *orderItem in dictionary[@"products"]) {
            [products addObject:[[MLCBaseOrderItem alloc] initWithDictionay:orderItem]];
        }
        self.products = products;
    }
    return self;
}

- (NSString *)description {
    NSMutableString *description = [super.description mutableCopy];
    [description appendFormat:@" baseId: %@ products: %@", self.baseId, self.products];
    return description;
}

@end

@implementation MLCBaseOrderItem

- (id)copyWithZone:(nullable NSZone *)zone {
    return [[[self class] allocWithZone:zone] initWithDictionay:self.dictionaryValue];
}

- (nonnull NSDictionary *)dictionaryValue {
    return @{
        @"productId": self.productId,
        @"quantity": @(self.quantity),
    };
}

- (nonnull instancetype)initWithDictionay:(nonnull NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.productId = dictionary[@"productId"];
        self.quantity = [(dictionary[@"quantity"] ?: @0) integerValue];
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[MLCBaseOrderItem class]]) {
        return NO;
    }
    MLCBaseOrderItem *other = (MLCBaseOrderItem *)object;

    return [self.dictionaryValue isEqualToDictionary:other.dictionaryValue];
}

- (NSString *)description {
    NSMutableString *description = [super.description mutableCopy];
    [description appendFormat:@" productId: %@ quantity: %@", self.productId, @(self.quantity)];
    return description;
}

@end
