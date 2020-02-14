//
//  MLCOrderManager.h
//  MoblicoSDK
//
//  Created by Cameron Knight on 12/4/19.
//  Copyright © 2019 Moblico. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MLCDictionayConvertable <NSObject>

- (instancetype)initWithDictionay:(NSDictionary *)dictionary;
@property (nonatomic, copy, readonly) NSDictionary *dictionaryValue;

@end

NS_SWIFT_NAME(CustomField)
@interface MLCCustomField : NSObject <MLCDictionayConvertable>
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *value;
@end

NS_SWIFT_NAME(OrderItem)
@interface MLCOrderItem : NSObject <MLCDictionayConvertable>
@property (nonatomic, copy) NSString *productId;
@property (nonatomic, assign) NSInteger quantity;
@end

NS_SWIFT_NAME(Order)
@interface MLCOrder : NSObject <MLCDictionayConvertable, NSCopying>
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *emailAddress;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSArray<MLCOrderItem *> *products;
@property (nonatomic, copy) NSArray<MLCCustomField *> *customFields;
@property (nonatomic, copy) NSString *comments;
@property (nonatomic, copy) NSString *emailToAddress;
@property (nonatomic, strong) NSDate *createDate;
@property (nonatomic, strong) NSDate *lastUpdateDate;
@end

NS_SWIFT_NAME(OrderHistory)
@interface MLCOrderHistory : NSObject <MLCDictionayConvertable>
@property (nonatomic, strong, null_resettable) MLCOrder *currentOrder;
@property (nonatomic, copy) NSArray<MLCOrder *> *pendingOrders;
@property (nonatomic, copy) NSArray<MLCOrder *> *completedOrders;
@end

NS_SWIFT_NAME(OrderManager)
@interface MLCOrderManager : NSObject
@property (nonatomic, class, strong, readonly) MLCOrderManager *sharedOrderManager NS_SWIFT_NAME(shared);
@property (nonatomic, class, copy, nullable) NSString *groupId;
@property (nonatomic, strong) MLCOrderHistory *orderHistory;
- (void)reload;
- (void)clear;
- (void)save;
- (void)add:(NSString *)productId quantity:(NSInteger)quantity;
- (void)removeItemAtIndex:(NSUInteger)idx;
- (void)addCompletedOrder:(MLCOrder *)order;
- (void)addPendingOrder:(MLCOrder *)order;
- (void)removePendingOrderAtIndex:(NSUInteger)idx;
@end

NS_ASSUME_NONNULL_END
